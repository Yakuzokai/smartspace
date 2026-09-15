import * as THREE from 'three'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js'
import type { Furniture } from '@/types/furniture'

// Shared in-memory cache for loaded GLTF scenes
const modelCache = new Map<string, THREE.Group>()

let dracoLoaderInstance: DRACOLoader | null = null
let gltfLoaderInstance: GLTFLoader | null = null

function getLoaders(): { gltfLoader: GLTFLoader } {
  if (!gltfLoaderInstance) {
    gltfLoaderInstance = new GLTFLoader()
    dracoLoaderInstance = new DRACOLoader()
    // Use official Google Draco decoder CDN
    dracoLoaderInstance.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.7/')
    gltfLoaderInstance.setDRACOLoader(dracoLoaderInstance)
  }
  return { gltfLoader: gltfLoaderInstance }
}

export function useModelLoader() {
  /**
   * Load 3D model for furniture item.
   * Attempts real GLB fetch first; if 404 or fails, seamlessly creates
   * a dimension-certified architectural procedural model matching the exact W/D/H and color_hex.
   */
  async function loadFurnitureModel(
    furniture: Furniture,
    onProgress?: (percent: number) => void
  ): Promise<{ model: THREE.Group; isProcedural: boolean }> {
    const cacheKey = furniture.sku || `id-${furniture.id}`

    // Check cache first
    if (modelCache.has(cacheKey)) {
      const cached = modelCache.get(cacheKey)!.clone(true)
      return { model: cached, isProcedural: cached.userData.isProcedural ?? false }
    }

    // Authoritative real-world dimensions in meters (Three.js 1 unit = 1 meter)
    const targetW = Number(furniture.dimensions?.width_m ?? (furniture.dimensions?.width_cm ? furniture.dimensions.width_cm / 100 : 1.0))
    const targetD = Number(furniture.dimensions?.depth_m ?? (furniture.dimensions?.depth_cm ? furniture.dimensions.depth_cm / 100 : 0.8))
    const targetH = Number(furniture.dimensions?.height_m ?? (furniture.dimensions?.height_cm ? furniture.dimensions.height_cm / 100 : 0.75))
    const colorHex = furniture.color_hex || '#A8A6A1'

    let glbPath = furniture.model_3d?.path || (furniture as any).glb_model_path || undefined
    // Strip localhost:8000 or 127.0.0.1:8000 to use Vite's same-origin proxy and avoid CORS
    if (glbPath && glbPath.includes('/storage/')) {
      glbPath = glbPath.substring(glbPath.indexOf('/storage/'))
    }

    if (glbPath) {
      try {
        const { gltfLoader } = getLoaders()
        const gltf = await new Promise<any>((resolve, reject) => {
          gltfLoader.load(
            glbPath,
            (loaded) => resolve(loaded),
            (xhr) => {
              if (xhr.total > 0 && onProgress) {
                onProgress(Math.min(100, Math.round((xhr.loaded / xhr.total) * 100)))
              }
            },
            (error) => reject(error)
          )
        })

        const rawScene = gltf.scene as THREE.Group

        // Normalize geometry to exact database dimensions so scale remains locked at 1.000
        const normalized = normalizeGLBGeometry(rawScene, targetW, targetH, targetD)
        normalized.userData.isProcedural = false
        normalized.userData.sku = furniture.sku

        modelCache.set(cacheKey, normalized.clone(true))
        return { model: normalized, isProcedural: false }
      } catch (err) {
        console.warn('[useModelLoader] Failed to load GLB at:', glbPath, err)
        // Fall back gracefully to dimension-certified procedural representation
      }
    }

    // Procedural Fallback: Dimension-Certified Architectural Representation
    const procedural = generateProceduralFurniture(furniture, targetW, targetH, targetD, colorHex)
    procedural.userData.isProcedural = true
    procedural.userData.sku = furniture.sku

    modelCache.set(cacheKey, procedural.clone(true))
    return { model: procedural, isProcedural: true }
  }

  /**
   * Normalizes raw GLB geometry to expected physical dimensions,
   * keeping the root object's scale locked at exactly (1.000, 1.000, 1.000).
   */
  function normalizeGLBGeometry(
    rawScene: THREE.Group,
    targetW: number,
    targetH: number,
    targetD: number
  ): THREE.Group {
    const root = new THREE.Group()
    root.name = 'NormalizedFurnitureRoot'

    // Compute original bounding box
    const initialBox = new THREE.Box3().setFromObject(rawScene)
    const initialSize = new THREE.Vector3()
    initialBox.getSize(initialSize)

    // Calculate normalization scales per axis
    const scaleX = initialSize.x > 0.001 ? targetW / initialSize.x : 1
    const scaleY = initialSize.y > 0.001 ? targetH / initialSize.y : 1
    const scaleZ = initialSize.z > 0.001 ? targetD / initialSize.z : 1

    // Scale mesh geometries directly so object scale remains 1.000
    rawScene.traverse((child) => {
      if (child instanceof THREE.Mesh) {
        child.castShadow = true
        child.receiveShadow = true
        if (child.geometry) {
          child.geometry = child.geometry.clone()
          child.geometry.scale(scaleX, scaleY, scaleZ)
        }
      }
    })

    // Center on floor (Y min at 0, centered on X and Z)
    const scaledBox = new THREE.Box3().setFromObject(rawScene)
    const scaledCenter = new THREE.Vector3()
    scaledBox.getCenter(scaledCenter)

    rawScene.position.x = -scaledCenter.x
    rawScene.position.z = -scaledCenter.z
    rawScene.position.y = -scaledBox.min.y // Bottom rests on Y=0 floor

    root.add(rawScene)
    root.scale.set(1.0, 1.0, 1.0) // Scale locked at 1.000

    return root
  }

  /**
   * Generates a high-fidelity architectural procedural model based on category archetype.
   * Root scale is locked at 1.000 and total bounding box matches exactly W × H × D.
   */
  function generateProceduralFurniture(
    furniture: Furniture,
    w: number,
    h: number,
    d: number,
    colorHex: string
  ): THREE.Group {
    const group = new THREE.Group()
    group.name = `Procedural_${furniture.sku}`
    group.scale.set(1.0, 1.0, 1.0)

    const categorySlug = (
      furniture.category?.slug ||
      furniture.name.toLowerCase()
    ).toLowerCase()

    // Primary material with physical PBR properties
    const primaryMat = new THREE.MeshStandardMaterial({
      color: new THREE.Color(colorHex),
      roughness: 0.65,
      metalness: 0.1,
    })

    // Accent wood/metal material for legs and structural details
    const woodMat = new THREE.MeshStandardMaterial({
      color: new THREE.Color('#382C24'),
      roughness: 0.5,
      metalness: 0.2,
    })

    const metalMat = new THREE.MeshStandardMaterial({
      color: new THREE.Color('#1F2321'),
      roughness: 0.3,
      metalness: 0.8,
    })

    const cushionMat = new THREE.MeshStandardMaterial({
      color: new THREE.Color(colorHex).offsetHSL(0, -0.05, 0.08),
      roughness: 0.8,
      metalness: 0.05,
    })

    if (categorySlug.includes('sofa') || categorySlug.includes('loung')) {
      buildSofaArchetype(group, w, h, d, primaryMat, cushionMat, woodMat)
    } else if (
      categorySlug.includes('table') ||
      categorySlug.includes('desk') ||
      categorySlug.includes('dining')
    ) {
      buildTableArchetype(group, w, h, d, primaryMat, woodMat, metalMat)
    } else if (categorySlug.includes('chair') || categorySlug.includes('stool')) {
      buildChairArchetype(group, w, h, d, primaryMat, woodMat)
    } else if (categorySlug.includes('bed') || categorySlug.includes('mattress')) {
      buildBedArchetype(group, w, h, d, primaryMat, cushionMat, woodMat)
    } else if (
      categorySlug.includes('book') ||
      categorySlug.includes('shelf') ||
      furniture.name.toLowerCase().includes('bookcase') ||
      furniture.name.toLowerCase().includes('shelf')
    ) {
      buildBookcaseArchetype(group, w, h, d, metalMat, woodMat)
    } else if (
      categorySlug.includes('storage') ||
      categorySlug.includes('wardrobe') ||
      categorySlug.includes('media') ||
      categorySlug.includes('tv')
    ) {
      buildStorageArchetype(group, w, h, d, primaryMat, woodMat, metalMat)
    } else {
      buildGeneralArchetype(group, w, h, d, primaryMat, woodMat)
    }

    // Ensure all meshes cast & receive shadows
    group.traverse((obj) => {
      if (obj instanceof THREE.Mesh) {
        obj.castShadow = true
        obj.receiveShadow = true
      }
    })

    return group
  }

  // 1. Sofa Archetype: Seat cushions, backrest, armrests, tapered legs
  function buildSofaArchetype(
    group: THREE.Group,
    w: number,
    h: number,
    d: number,
    bodyMat: THREE.Material,
    cushionMat: THREE.Material,
    legMat: THREE.Material
  ) {
    const legH = h * 0.2
    const armW = Math.min(w * 0.12, 0.18)
    const backD = Math.min(d * 0.22, 0.22)
    const seatH = h * 0.25
    const seatW = w - armW * 2
    const seatD = d - backD

    // Seat base
    const baseGeom = new THREE.BoxGeometry(w - 0.04, seatH * 0.4, d - 0.04)
    const baseMesh = new THREE.Mesh(baseGeom, bodyMat)
    baseMesh.position.set(0, legH + (seatH * 0.4) / 2, 0)
    group.add(baseMesh)

    // Seat cushions (split into 2 cushions)
    const halfSeatW = (seatW - 0.02) / 2
    const cushionGeom = new THREE.BoxGeometry(halfSeatW, seatH * 0.6, seatD - 0.02)
    const c1 = new THREE.Mesh(cushionGeom, cushionMat)
    c1.position.set(-halfSeatW / 2 - 0.005, legH + seatH * 0.4 + (seatH * 0.6) / 2, seatD / 2 - d / 2)
    const c2 = new THREE.Mesh(cushionGeom, cushionMat)
    c2.position.set(halfSeatW / 2 + 0.005, legH + seatH * 0.4 + (seatH * 0.6) / 2, seatD / 2 - d / 2)
    group.add(c1, c2)

    // Backrest
    const backH = h - legH - seatH
    const backGeom = new THREE.BoxGeometry(w, backH, backD)
    const backMesh = new THREE.Mesh(backGeom, bodyMat)
    backMesh.position.set(0, legH + seatH + backH / 2, d / 2 - backD / 2)
    group.add(backMesh)

    // Armrests
    const armH = h * 0.65 - legH
    const armGeom = new THREE.BoxGeometry(armW, armH, d)
    const leftArm = new THREE.Mesh(armGeom, bodyMat)
    leftArm.position.set(-w / 2 + armW / 2, legH + armH / 2, 0)
    const rightArm = new THREE.Mesh(armGeom, bodyMat)
    rightArm.position.set(w / 2 - armW / 2, legH + armH / 2, 0)
    group.add(leftArm, rightArm)

    // 4 Tapered Legs
    const legRadius = 0.022
    const legGeom = new THREE.CylinderGeometry(legRadius * 0.7, legRadius, legH, 12)
    const legX = w / 2 - armW / 2
    const legZ = d / 2 - 0.08
    const legs = [
      [-legX, legH / 2, -legZ],
      [legX, legH / 2, -legZ],
      [-legX, legH / 2, legZ],
      [legX, legH / 2, legZ],
    ]
    legs.forEach(([x, y, z]) => {
      const leg = new THREE.Mesh(legGeom, legMat)
      leg.position.set(x, y, z)
      group.add(leg)
    })
  }

  // 2. Table Archetype: Tabletop slab, 4 legs or trestle
  function buildTableArchetype(
    group: THREE.Group,
    w: number,
    h: number,
    d: number,
    topMat: THREE.Material,
    woodMat: THREE.Material,
    _metalMat: THREE.Material
  ) {
    const topThickness = Math.max(0.035, h * 0.05)
    const legH = h - topThickness
    const legRadius = Math.max(0.025, Math.min(w, d) * 0.035)

    // Tabletop
    const topGeom = new THREE.BoxGeometry(w, topThickness, d)
    const topMesh = new THREE.Mesh(topGeom, topMat)
    topMesh.position.set(0, h - topThickness / 2, 0)
    group.add(topMesh)

    // 4 Sturdy Legs
    const legGeom = new THREE.CylinderGeometry(legRadius, legRadius * 0.8, legH, 16)
    const insetX = w * 0.08
    const insetZ = d * 0.08
    const legs = [
      [-w / 2 + insetX, legH / 2, -d / 2 + insetZ],
      [w / 2 - insetX, legH / 2, -d / 2 + insetZ],
      [-w / 2 + insetX, legH / 2, d / 2 - insetZ],
      [w / 2 - insetX, legH / 2, d / 2 - insetZ],
    ]
    legs.forEach(([x, y, z]) => {
      const leg = new THREE.Mesh(legGeom, woodMat)
      leg.position.set(x, y, z)
      group.add(leg)
    })
  }

  // 3. Chair Archetype: Seat, backrest, 4 legs
  function buildChairArchetype(
    group: THREE.Group,
    w: number,
    h: number,
    d: number,
    bodyMat: THREE.Material,
    legMat: THREE.Material
  ) {
    const seatH = h * 0.5
    const seatThickness = 0.04
    const legH = seatH - seatThickness

    // Seat
    const seatGeom = new THREE.BoxGeometry(w, seatThickness, d * 0.85)
    const seatMesh = new THREE.Mesh(seatGeom, bodyMat)
    seatMesh.position.set(0, legH + seatThickness / 2, -d * 0.05)
    group.add(seatMesh)

    // Backrest
    const backH = h - seatH
    const backThickness = 0.035
    const backGeom = new THREE.BoxGeometry(w * 0.92, backH, backThickness)
    const backMesh = new THREE.Mesh(backGeom, bodyMat)
    backMesh.position.set(0, seatH + backH / 2, d * 0.35)
    group.add(backMesh)

    // 4 Legs
    const legRadius = 0.018
    const legGeom = new THREE.CylinderGeometry(legRadius * 0.7, legRadius, legH, 12)
    const insetX = w * 0.12
    const insetZ = d * 0.35
    const legs = [
      [-w / 2 + insetX, legH / 2, -d * 0.4 + insetX],
      [w / 2 - insetX, legH / 2, -d * 0.4 + insetX],
      [-w / 2 + insetX, legH / 2, insetZ],
      [w / 2 - insetX, legH / 2, insetZ],
    ]
    legs.forEach(([x, y, z]) => {
      const leg = new THREE.Mesh(legGeom, legMat)
      leg.position.set(x, y, z)
      group.add(leg)
    })
  }

  // 4. Bed Archetype: Frame, thick mattress, headboard
  function buildBedArchetype(
    group: THREE.Group,
    w: number,
    h: number,
    d: number,
    bodyMat: THREE.Material,
    mattressMat: THREE.Material,
    headboardMat: THREE.Material
  ) {
    const headboardD = 0.12
    const frameH = h * 0.3
    const mattressH = h * 0.28
    const mattressD = d - headboardD

    // Headboard at rear
    const hbGeom = new THREE.BoxGeometry(w, h, headboardD)
    const hbMesh = new THREE.Mesh(hbGeom, headboardMat)
    hbMesh.position.set(0, h / 2, d / 2 - headboardD / 2)
    group.add(hbMesh)

    // Bed frame
    const frameGeom = new THREE.BoxGeometry(w, frameH, mattressD)
    const frameMesh = new THREE.Mesh(frameGeom, bodyMat)
    frameMesh.position.set(0, frameH / 2, -headboardD / 2)
    group.add(frameMesh)

    // Mattress
    const mGeom = new THREE.BoxGeometry(w * 0.94, mattressH, mattressD * 0.96)
    const mMesh = new THREE.Mesh(mGeom, mattressMat)
    mMesh.position.set(0, frameH + mattressH / 2, -headboardD / 2)
    group.add(mMesh)
  }

  // 5. Storage / Credenza / Media Archetype: Cabinet box, doors, plinth
  function buildStorageArchetype(
    group: THREE.Group,
    w: number,
    h: number,
    d: number,
    bodyMat: THREE.Material,
    doorMat: THREE.Material,
    baseMat: THREE.Material
  ) {
    const baseH = Math.max(0.08, h * 0.12)
    const carcassH = h - baseH

    // Base Plinth / Feet
    const baseGeom = new THREE.BoxGeometry(w * 0.92, baseH, d * 0.88)
    const baseMesh = new THREE.Mesh(baseGeom, baseMat)
    baseMesh.position.set(0, baseH / 2, 0)
    group.add(baseMesh)

    // Main Carcass Cabinet
    const carcassGeom = new THREE.BoxGeometry(w, carcassH, d)
    const carcassMesh = new THREE.Mesh(carcassGeom, bodyMat)
    carcassMesh.position.set(0, baseH + carcassH / 2, 0)
    group.add(carcassMesh)

    // Door front accent
    const doorGeom = new THREE.BoxGeometry(w * 0.96, carcassH * 0.92, 0.015)
    const doorMesh = new THREE.Mesh(doorGeom, doorMat)
    doorMesh.position.set(0, baseH + carcassH / 2, -d / 2 - 0.008)
    group.add(doorMesh)
  }

  // 6. Bookcase / Open Shelving Archetype: Steel uprights + open wood tiers
  function buildBookcaseArchetype(
    group: THREE.Group,
    w: number,
    h: number,
    d: number,
    frameMat: THREE.Material,
    shelfMat: THREE.Material
  ) {
    const postThickness = 0.024
    const shelfThickness = 0.022
    const numShelves = 5

    // 4 Corner vertical steel uprights
    const postGeom = new THREE.BoxGeometry(postThickness, h, postThickness)
    const inset = postThickness / 2
    const postPositions = [
      [-w / 2 + inset, h / 2, -d / 2 + inset],
      [w / 2 - inset, h / 2, -d / 2 + inset],
      [-w / 2 + inset, h / 2, d / 2 - inset],
      [w / 2 - inset, h / 2, d / 2 - inset],
    ]
    postPositions.forEach(([x, y, z]) => {
      const post = new THREE.Mesh(postGeom, frameMat)
      post.position.set(x, y, z)
      group.add(post)
    })

    // 5 Horizontal open timber shelves
    const shelfGeom = new THREE.BoxGeometry(w - 0.004, shelfThickness, d - 0.004)
    const availableHeight = h - shelfThickness - 0.08
    const step = availableHeight / (numShelves - 1)
    for (let i = 0; i < numShelves; i++) {
      const shelf = new THREE.Mesh(shelfGeom, shelfMat)
      shelf.position.set(0, 0.08 + i * step + shelfThickness / 2, 0)
      group.add(shelf)
    }

    // Rear architectural diagonal cross-brace
    const braceMat = frameMat
    const braceRadius = 0.004
    const braceLength = Math.sqrt(w * w + h * 0.4 * (h * 0.4))
    const braceGeom = new THREE.CylinderGeometry(braceRadius, braceRadius, braceLength, 8)

    const b1 = new THREE.Mesh(braceGeom, braceMat)
    b1.position.set(0, h * 0.5, -d / 2 + inset)
    b1.rotation.z = Math.atan2(h * 0.4, w)
    const b2 = new THREE.Mesh(braceGeom, braceMat)
    b2.position.set(0, h * 0.5, -d / 2 + inset)
    b2.rotation.z = -Math.atan2(h * 0.4, w)
    group.add(b1, b2)
  }

  // 6. General Architectural Archetype (Fallback)
  function buildGeneralArchetype(
    group: THREE.Group,
    w: number,
    h: number,
    d: number,
    bodyMat: THREE.Material,
    baseMat: THREE.Material
  ) {
    const baseH = h * 0.1
    const bodyH = h - baseH

    const baseGeom = new THREE.BoxGeometry(w * 0.9, baseH, d * 0.9)
    const baseMesh = new THREE.Mesh(baseGeom, baseMat)
    baseMesh.position.set(0, baseH / 2, 0)
    group.add(baseMesh)

    const bodyGeom = new THREE.BoxGeometry(w, bodyH, d)
    const bodyMesh = new THREE.Mesh(bodyGeom, bodyMat)
    bodyMesh.position.set(0, baseH + bodyH / 2, 0)
    group.add(bodyMesh)
  }

  return {
    loadFurnitureModel,
    clearCache: () => modelCache.clear(),
  }
}
