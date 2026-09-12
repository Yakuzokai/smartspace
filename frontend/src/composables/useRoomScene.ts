import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import type { RoomDimensionsM } from './useFurniturePlacement'

export type LightingPreset = 'showroom' | 'daylight' | 'golden' | 'evening'
export type CameraMode = 'perspective' | 'topdown'

export interface RoomSceneContext {
  scene: THREE.Scene
  camera: THREE.PerspectiveCamera
  orthoCamera: THREE.OrthographicCamera
  activeCamera: THREE.Camera
  renderer: THREE.WebGLRenderer
  controls: OrbitControls
  floorMesh: THREE.Mesh
  roomGroup: THREE.Group
  furnitureGroup: THREE.Group
  setCameraMode: (mode: CameraMode) => void
  setLightingPreset: (preset: LightingPreset) => void
  updateRoomDimensions: (dims: RoomDimensionsM) => void
  focusItem: (x: number, z: number) => void
  resetCamera: () => void
  dispose: () => void
}

export function createRoomScene(
  container: HTMLElement,
  initialDims: RoomDimensionsM
): RoomSceneContext {
  let width = container.clientWidth || 800
  let height = container.clientHeight || 600

  // 1. Scene
  const scene = new THREE.Scene()
  scene.background = new THREE.Color(0xfcfcfa) // SmartSpace Off White

  // Groups
  const roomGroup = new THREE.Group()
  const furnitureGroup = new THREE.Group()
  scene.add(roomGroup)
  scene.add(furnitureGroup)

  // 2. Cameras
  const aspect = width / height
  const camera = new THREE.PerspectiveCamera(42, aspect, 0.1, 100)
  camera.position.set(0, initialDims.height_m * 1.6, initialDims.length_m * 1.5)

  // Orthographic camera for 2D blueprint view
  const frustumSize = Math.max(initialDims.width_m, initialDims.length_m) * 1.4
  const orthoCamera = new THREE.OrthographicCamera(
    (frustumSize * aspect) / -2,
    (frustumSize * aspect) / 2,
    frustumSize / 2,
    frustumSize / -2,
    0.1,
    100
  )
  orthoCamera.position.set(0, 15, 0)
  orthoCamera.lookAt(0, 0, 0)

  let activeCamera: THREE.Camera = camera
  let currentCameraMode: CameraMode = 'perspective'

  // 3. Renderer
  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
  renderer.setSize(width, height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFShadowMap
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1.05
  container.appendChild(renderer.domElement)

  // 4. OrbitControls
  const controls = new OrbitControls(activeCamera, renderer.domElement)
  controls.enableDamping = true
  controls.dampingFactor = 0.05
  controls.maxPolarAngle = Math.PI / 2 - 0.04 // Clamped so camera never goes below floor
  controls.minDistance = 1.0
  controls.maxDistance = 25.0
  controls.target.set(0, 0.4, 0)
  controls.update()

  // 5. Lighting
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.8)
  scene.add(ambientLight)

  const dirLight = new THREE.DirectionalLight(0xfff8ee, 1.4)
  dirLight.position.set(5, 10, 6)
  dirLight.castShadow = true
  dirLight.shadow.mapSize.width = 2048
  dirLight.shadow.mapSize.height = 2048
  dirLight.shadow.camera.near = 0.5
  dirLight.shadow.camera.far = 30
  const d = 8
  dirLight.shadow.camera.left = -d
  dirLight.shadow.camera.right = d
  dirLight.shadow.camera.top = d
  dirLight.shadow.camera.bottom = -d
  dirLight.shadow.bias = -0.0003
  scene.add(dirLight)

  const fillLight = new THREE.DirectionalLight(0xddeeff, 0.45)
  fillLight.position.set(-6, 8, -5)
  scene.add(fillLight)

  // 6. Build Room Geometry
  let floorMesh: THREE.Mesh
  let gridHelper: THREE.GridHelper | null = null

  function buildRoom(dims: RoomDimensionsM) {
    // Clear previous room children
    while (roomGroup.children.length > 0) {
      const obj = roomGroup.children[0]
      roomGroup.remove(obj)
      if (obj instanceof THREE.Mesh) {
        obj.geometry.dispose()
        if (Array.isArray(obj.material)) obj.material.forEach((m) => m.dispose())
        else obj.material.dispose()
      }
    }

    const { width_m: w, length_m: l, height_m: h } = dims
    const halfW = w / 2
    const halfL = l / 2

    // Floor Plane
    const floorGeo = new THREE.PlaneGeometry(w, l)
    const floorMat = new THREE.MeshStandardMaterial({
      color: 0xf5f3ee, // Soft cream parquet tint
      roughness: 0.65,
      metalness: 0.05,
    })
    floorMesh = new THREE.Mesh(floorGeo, floorMat)
    floorMesh.rotation.x = -Math.PI / 2
    floorMesh.position.set(0, 0, 0)
    floorMesh.receiveShadow = true
    floorMesh.name = 'floor_plane'
    roomGroup.add(floorMesh)

    // Floor Perimeter Edge Border
    const borderEdges = new THREE.EdgesGeometry(floorGeo)
    const borderMat = new THREE.LineBasicMaterial({ color: 0x173f35, linewidth: 2 })
    const borderLine = new THREE.LineSegments(borderEdges, borderMat)
    borderLine.rotation.x = -Math.PI / 2
    borderLine.position.y = 0.002
    roomGroup.add(borderLine)

    // Architectural Grid Lines
    const gridDivs = Math.max(Math.round(Math.max(w, l) * 2), 4)
    gridHelper = new THREE.GridHelper(Math.max(w, l), gridDivs, 0xd8b98a, 0xe5e3dd)
    gridHelper.position.y = 0.001
    // Scale grid helper to match room aspect
    gridHelper.scale.set(w / Math.max(w, l), 1, l / Math.max(w, l))
    roomGroup.add(gridHelper)

    // Wall Material
    const wallMat = new THREE.MeshStandardMaterial({
      color: 0xfbf9f5, // Off-white painted drywall
      roughness: 0.85,
      metalness: 0.02,
      side: THREE.DoubleSide,
    })

    const baseboardMat = new THREE.MeshStandardMaterial({
      color: 0x252a27, // Charcoal architectural plinth / baseboard
      roughness: 0.5,
    })

    const wallThickness = 0.08
    const baseboardH = 0.12

    // 1. Back Wall (North: Z = -halfL)
    const backWallGeo = new THREE.BoxGeometry(w, h, wallThickness)
    const backWall = new THREE.Mesh(backWallGeo, wallMat)
    backWall.position.set(0, h / 2, -halfL - wallThickness / 2)
    backWall.receiveShadow = true
    roomGroup.add(backWall)

    const backBaseboard = new THREE.Mesh(
      new THREE.BoxGeometry(w, baseboardH, wallThickness + 0.02),
      baseboardMat
    )
    backBaseboard.position.set(0, baseboardH / 2, -halfL - wallThickness / 2)
    roomGroup.add(backBaseboard)

    // 2. West Wall (Left: X = -halfW)
    const westWallGeo = new THREE.BoxGeometry(wallThickness, h, l)
    const westWall = new THREE.Mesh(westWallGeo, wallMat)
    westWall.position.set(-halfW - wallThickness / 2, h / 2, 0)
    westWall.receiveShadow = true
    roomGroup.add(westWall)

    const westBaseboard = new THREE.Mesh(
      new THREE.BoxGeometry(wallThickness + 0.02, baseboardH, l),
      baseboardMat
    )
    westBaseboard.position.set(-halfW - wallThickness / 2, baseboardH / 2, 0)
    roomGroup.add(westBaseboard)

    // 3. East Wall (Right: X = +halfW)
    const eastWallGeo = new THREE.BoxGeometry(wallThickness, h, l)
    const eastWall = new THREE.Mesh(eastWallGeo, wallMat)
    eastWall.position.set(halfW + wallThickness / 2, h / 2, 0)
    eastWall.receiveShadow = true
    roomGroup.add(eastWall)

    const eastBaseboard = new THREE.Mesh(
      new THREE.BoxGeometry(wallThickness + 0.02, baseboardH, l),
      baseboardMat
    )
    eastBaseboard.position.set(halfW + wallThickness / 2, baseboardH / 2, 0)
    roomGroup.add(eastBaseboard)

    // 4. South Wall Cutaway (Low architectural sill so camera is never blocked)
    const southSillGeo = new THREE.BoxGeometry(w, 0.15, wallThickness)
    const southSill = new THREE.Mesh(southSillGeo, baseboardMat)
    southSill.position.set(0, 0.075, halfL + wallThickness / 2)
    roomGroup.add(southSill)
  }

  // Initial build
  buildRoom(initialDims)

  // 7. Lighting Preset Switcher
  function setLightingPreset(preset: LightingPreset) {
    if (preset === 'daylight') {
      scene.background = new THREE.Color(0xf6f8fc)
      ambientLight.color.setHex(0xe8f0fe)
      ambientLight.intensity = 0.9
      dirLight.color.setHex(0xfffaed)
      dirLight.intensity = 1.6
      dirLight.position.set(7, 12, 5)
      fillLight.color.setHex(0xd0e2f5)
      fillLight.intensity = 0.5
    } else if (preset === 'golden') {
      scene.background = new THREE.Color(0xfcf8f2)
      ambientLight.color.setHex(0xffedd8)
      ambientLight.intensity = 0.75
      dirLight.color.setHex(0xffb86c)
      dirLight.intensity = 1.9
      dirLight.position.set(9, 6, 8)
      fillLight.color.setHex(0x9d7a5b)
      fillLight.intensity = 0.4
    } else if (preset === 'evening') {
      scene.background = new THREE.Color(0x1a201d)
      ambientLight.color.setHex(0xffdfba)
      ambientLight.intensity = 0.4
      dirLight.color.setHex(0xffd29d)
      dirLight.intensity = 1.1
      dirLight.position.set(2, 6, 2)
      fillLight.color.setHex(0x5a6360)
      fillLight.intensity = 0.25
    } else {
      // 'showroom' (default)
      scene.background = new THREE.Color(0xfcfcfa)
      ambientLight.color.setHex(0xffffff)
      ambientLight.intensity = 0.85
      dirLight.color.setHex(0xfff9f0)
      dirLight.intensity = 1.35
      dirLight.position.set(5, 10, 6)
      fillLight.color.setHex(0xe5ecf4)
      fillLight.intensity = 0.4
    }
  }

  // 8. Camera Mode Switcher
  function setCameraMode(mode: CameraMode) {
    currentCameraMode = mode
    if (mode === 'topdown') {
      activeCamera = orthoCamera
      controls.object = orthoCamera
      controls.maxPolarAngle = 0.05 // Lock straight top-down
      controls.minPolarAngle = 0
      controls.target.set(0, 0, 0)
      orthoCamera.position.set(0, 18, 0)
      orthoCamera.lookAt(0, 0, 0)
    } else {
      activeCamera = camera
      controls.object = camera
      controls.maxPolarAngle = Math.PI / 2 - 0.04
      controls.minPolarAngle = 0.1
      controls.target.set(0, 0.4, 0)
      camera.position.set(0, initialDims.height_m * 1.6, initialDims.length_m * 1.5)
    }
    controls.update()
  }

  // 9. Camera actions
  function resetCamera() {
    setCameraMode(currentCameraMode)
  }

  function focusItem(x: number, z: number) {
    controls.target.set(x, 0.4, z)
    if (currentCameraMode === 'perspective') {
      camera.position.set(x + 1.2, 1.4, z + 1.6)
    }
    controls.update()
  }

  function updateRoomDimensions(dims: RoomDimensionsM) {
    buildRoom(dims)
    // Update camera frustum / position limits
    const maxDim = Math.max(dims.width_m, dims.length_m)
    const aspect = width / height
    const frustum = maxDim * 1.4
    orthoCamera.left = (frustum * aspect) / -2
    orthoCamera.right = (frustum * aspect) / 2
    orthoCamera.top = frustum / 2
    orthoCamera.bottom = frustum / -2
    orthoCamera.updateProjectionMatrix()
  }

  // 10. Animation Loop
  let animId: number | null = null
  function animate() {
    animId = requestAnimationFrame(animate)
    controls.update()
    renderer.render(scene, activeCamera)
  }
  animate()

  // 11. Resize Observer
  const resizeObserver = new ResizeObserver((entries) => {
    for (const entry of entries) {
      width = entry.contentRect.width || 800
      height = entry.contentRect.height || 600
      const currentAspect = width / height

      camera.aspect = currentAspect
      camera.updateProjectionMatrix()

      const maxDim = Math.max(initialDims.width_m, initialDims.length_m)
      const frustum = maxDim * 1.4
      orthoCamera.left = (frustum * currentAspect) / -2
      orthoCamera.right = (frustum * currentAspect) / 2
      orthoCamera.top = frustum / 2
      orthoCamera.bottom = frustum / -2
      orthoCamera.updateProjectionMatrix()

      renderer.setSize(width, height)
    }
  })
  resizeObserver.observe(container)

  // 12. Cleanup
  function dispose() {
    if (animId !== null) cancelAnimationFrame(animId)
    resizeObserver.disconnect()
    controls.dispose()
    renderer.dispose()
    if (container.contains(renderer.domElement)) {
      container.removeChild(renderer.domElement)
    }
  }

  return {
    scene,
    camera,
    orthoCamera,
    activeCamera,
    renderer,
    controls,
    floorMesh: floorMesh!,
    roomGroup,
    furnitureGroup,
    setCameraMode,
    setLightingPreset,
    updateRoomDimensions,
    focusItem,
    resetCamera,
    dispose,
  }
}
