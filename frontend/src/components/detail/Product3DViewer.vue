<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { useModelLoader } from '@/composables/useModelLoader'
import type { Furniture } from '@/types/furniture'

const props = defineProps<{
  furniture: Furniture
}>()

const viewerContainer = ref<HTMLDivElement | null>(null)
const canvasContainer = ref<HTMLDivElement | null>(null)
const isLoading = ref(true)
const isProcedural = ref(false)
const isFullscreen = ref(false)
const autoRotate = ref(false)
const showBoundingBox = ref(true)
const activeLighting = ref<'showroom' | 'daylight' | 'golden'>('showroom')
const activeCameraAngle = ref<'perspective' | 'front' | 'side' | 'top'>('perspective')

// Three.js instances
let renderer: THREE.WebGLRenderer | null = null
let scene: THREE.Scene | null = null
let camera: THREE.PerspectiveCamera | null = null
let controls: OrbitControls | null = null
let currentModel: THREE.Group | null = null
let boundingBoxHelper: THREE.BoxHelper | null = null
let animationFrameId: number | null = null
let resizeObserver: ResizeObserver | null = null

// Light references for dynamic switching
let ambientLight: THREE.AmbientLight | null = null
let mainDirLight: THREE.DirectionalLight | null = null
let fillLight: THREE.DirectionalLight | null = null

const { loadFurnitureModel } = useModelLoader()

// Compute dimensions for the HUD
const widthCm = computed(() => Number(props.furniture.dimensions?.width_cm ?? 100))
const depthCm = computed(() => Number(props.furniture.dimensions?.depth_cm ?? 80))
const heightCm = computed(() => Number(props.furniture.dimensions?.height_cm ?? 75))

onMounted(() => {
  initThreeScene()
  loadModel()
  document.addEventListener('fullscreenchange', handleFullscreenChange)
})

onBeforeUnmount(() => {
  disposeThreeScene()
  document.removeEventListener('fullscreenchange', handleFullscreenChange)
})

watch(
  () => props.furniture.id,
  () => {
    loadModel()
  }
)

function initThreeScene() {
  if (!canvasContainer.value) return

  const width = canvasContainer.value.clientWidth
  const height = canvasContainer.value.clientHeight || 450

  // 1. Scene
  scene = new THREE.Scene()

  // 2. Camera
  camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 50)
  camera.position.set(1.8, 1.4, 2.2)

  // 3. Renderer
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
  renderer.setSize(width, height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFShadowMap
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1.05

  canvasContainer.value.appendChild(renderer.domElement)

  // 4. OrbitControls
  controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true
  controls.dampingFactor = 0.05
  controls.minDistance = 0.6
  controls.maxDistance = 5.5
  controls.maxPolarAngle = Math.PI / 2 + 0.05 // Limit below ground
  controls.target.set(0, heightCm.value / 200, 0)
  controls.autoRotate = autoRotate.value
  controls.autoRotateSpeed = 1.5

  // 5. Lights
  setupLighting()

  // 6. Ground Shadow Receiver Plane
  const groundGeom = new THREE.PlaneGeometry(6, 6)
  const groundMat = new THREE.ShadowMaterial({ opacity: 0.15 })
  const ground = new THREE.Mesh(groundGeom, groundMat)
  ground.rotation.x = -Math.PI / 2
  ground.position.y = 0
  ground.receiveShadow = true
  scene.add(ground)

  // Subtle circular ambient ground disk
  const diskGeom = new THREE.CircleGeometry(1.6, 32)
  const diskMat = new THREE.MeshBasicMaterial({
    color: 0x000000,
    transparent: true,
    opacity: 0.03,
  })
  const disk = new THREE.Mesh(diskGeom, diskMat)
  disk.rotation.x = -Math.PI / 2
  disk.position.y = -0.001
  scene.add(disk)

  // 7. Animation loop
  const animate = () => {
    animationFrameId = requestAnimationFrame(animate)
    if (controls) {
      controls.update()
    }
    if (renderer && scene && camera) {
      renderer.render(scene, camera)
    }
  }
  animate()

  // 8. Responsive resize observer
  resizeObserver = new ResizeObserver(() => {
    if (!canvasContainer.value || !renderer || !camera) return
    const newW = canvasContainer.value.clientWidth
    const newH = canvasContainer.value.clientHeight
    camera.aspect = newW / newH
    camera.updateProjectionMatrix()
    renderer.setSize(newW, newH)
  })
  resizeObserver.observe(canvasContainer.value)
}

function setupLighting() {
  if (!scene) return

  ambientLight = new THREE.AmbientLight(0xffffff, 0.85)
  scene.add(ambientLight)

  mainDirLight = new THREE.DirectionalLight(0xffffff, 1.2)
  mainDirLight.position.set(3, 5, 4)
  mainDirLight.castShadow = true
  mainDirLight.shadow.mapSize.width = 1024
  mainDirLight.shadow.mapSize.height = 1024
  mainDirLight.shadow.camera.near = 0.5
  mainDirLight.shadow.camera.far = 15
  mainDirLight.shadow.bias = -0.001
  scene.add(mainDirLight)

  fillLight = new THREE.DirectionalLight(0xffffff, 0.5)
  fillLight.position.set(-3, 3, -2)
  scene.add(fillLight)

  applyLightingPreset(activeLighting.value)
}

function applyLightingPreset(preset: 'showroom' | 'daylight' | 'golden') {
  activeLighting.value = preset
  if (!ambientLight || !mainDirLight || !fillLight) return

  if (preset === 'showroom') {
    // Showroom: Neutral even studio lighting (Default)
    ambientLight.color.setHex(0xffffff)
    ambientLight.intensity = 0.85
    mainDirLight.color.setHex(0xffffff)
    mainDirLight.intensity = 1.2
    mainDirLight.position.set(3, 5, 4)
    fillLight.color.setHex(0xffffff)
    fillLight.intensity = 0.5
  } else if (preset === 'daylight') {
    // Daylight: Crisp daylight with sky fill
    ambientLight.color.setHex(0xf0f8ff)
    ambientLight.intensity = 0.7
    mainDirLight.color.setHex(0xfffaf0)
    mainDirLight.intensity = 1.4
    mainDirLight.position.set(4, 6, 3)
    fillLight.color.setHex(0xd0e0f0)
    fillLight.intensity = 0.4
  } else if (preset === 'golden') {
    // Golden Hour: Warm architectural sunlight
    ambientLight.color.setHex(0xffd7a8)
    ambientLight.intensity = 0.5
    mainDirLight.color.setHex(0xffa742)
    mainDirLight.intensity = 1.7
    mainDirLight.position.set(5, 2.8, 3.5)
    fillLight.color.setHex(0xb0c4de)
    fillLight.intensity = 0.3
  }
}

async function loadModel() {
  if (!scene) return
  isLoading.value = true

  // Remove previous model and helper
  if (currentModel) {
    scene.remove(currentModel)
    currentModel = null
  }
  if (boundingBoxHelper) {
    scene.remove(boundingBoxHelper)
    boundingBoxHelper = null
  }

  try {
    const result = await loadFurnitureModel(props.furniture)
    currentModel = result.model
    isProcedural.value = result.isProcedural
    scene.add(currentModel)

    // Setup Bounding Box Helper
    boundingBoxHelper = new THREE.BoxHelper(currentModel, 0x173f35)
    boundingBoxHelper.visible = showBoundingBox.value
    scene.add(boundingBoxHelper)

    // Adjust camera target to vertical center of furniture
    const box = new THREE.Box3().setFromObject(currentModel)
    const center = new THREE.Vector3()
    box.getCenter(center)
    if (controls) {
      controls.target.copy(center)
    }

    setCameraAngle('perspective')
  } catch (err) {
    console.error('Failed to load 3D model:', err)
  } finally {
    isLoading.value = false
  }
}

function setCameraAngle(angle: 'perspective' | 'front' | 'side' | 'top') {
  if (!camera || !controls || !currentModel) return
  activeCameraAngle.value = angle

  const box = new THREE.Box3().setFromObject(currentModel)
  const size = new THREE.Vector3()
  box.getSize(size)
  const center = new THREE.Vector3()
  box.getCenter(center)

  const maxDim = Math.max(size.x, size.y, size.z)
  const dist = maxDim * 2.1

  controls.target.copy(center)

  switch (angle) {
    case 'front':
      camera.position.set(center.x, center.y, center.z + dist)
      break
    case 'side':
      camera.position.set(center.x + dist, center.y, center.z)
      break
    case 'top':
      camera.position.set(center.x, center.y + dist * 1.3, center.z + 0.001)
      break
    case 'perspective':
    default:
      camera.position.set(center.x + dist * 0.8, center.y + dist * 0.55, center.z + dist * 0.85)
      break
  }

  camera.lookAt(center)
  controls.update()
}

function resetView() {
  setCameraAngle('perspective')
}

function toggleBoundingBox() {
  showBoundingBox.value = !showBoundingBox.value
  if (boundingBoxHelper) {
    boundingBoxHelper.visible = showBoundingBox.value
  }
}

function toggleAutoRotate() {
  autoRotate.value = !autoRotate.value
  if (controls) {
    controls.autoRotate = autoRotate.value
  }
}

function handleFullscreenChange() {
  isFullscreen.value = document.fullscreenElement === viewerContainer.value
}

function toggleFullscreen() {
  const target = viewerContainer.value || canvasContainer.value
  if (!target) return
  if (!document.fullscreenElement) {
    target.requestFullscreen().catch((err) => {
      console.warn('Fullscreen error:', err)
    })
  } else {
    document.exitFullscreen().catch((err) => {
      console.warn('Exit fullscreen error:', err)
    })
  }
}

function disposeThreeScene() {
  if (animationFrameId !== null) {
    cancelAnimationFrame(animationFrameId)
    animationFrameId = null
  }
  if (resizeObserver) {
    resizeObserver.disconnect()
    resizeObserver = null
  }
  if (renderer) {
    renderer.dispose()
    if (renderer.domElement && renderer.domElement.parentNode) {
      renderer.domElement.parentNode.removeChild(renderer.domElement.parentNode)
    }
    renderer = null
  }
  scene = null
  camera = null
  controls = null
  currentModel = null
  boundingBoxHelper = null
}
</script>

<template>
  <div
    ref="viewerContainer"
    class="relative w-full rounded-3xl overflow-hidden bg-gradient-to-b from-[#F5F2EC] to-[#ECE7DE] border border-light-border shadow-card flex flex-col transition-all"
    :class="isFullscreen ? 'fixed inset-0 z-50 rounded-none h-screen' : 'h-[480px] sm:h-[540px]'"
  >
    <!-- Top Header Bar (HUD) -->
    <div class="absolute top-0 left-0 right-0 z-20 px-4 py-3 bg-off-white/80 backdrop-blur-md border-b border-light-border/60 flex items-center justify-between text-xs">
      <div class="flex items-center gap-2">
        <span class="font-mono font-bold text-forest uppercase tracking-wider flex items-center gap-1.5">
          <i class="bi bi-box text-forest"></i>
          3D Model
        </span>
        <span
          v-if="isProcedural"
          class="px-2 py-0.5 rounded text-[10px] font-mono bg-warm-beige/25 border border-warm-beige/70 text-forest font-semibold"
          title="Dimension-certified architectural 3D representation based on exact database W/D/H"
        >
          Dimension-Certified Spec
        </span>
        <span
          v-else
          class="px-2 py-0.5 rounded text-[10px] font-mono bg-forest/10 border border-forest/30 text-forest font-semibold"
        >
          Draco GLB
        </span>
      </div>

      <div class="flex items-center gap-3">
        <!-- Scale Lock Indicator (Critical SmartSpace Invariant) -->
        <div class="hidden sm:inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-cream border border-light-border text-[11px] font-mono text-forest font-semibold shadow-subtle">
          <i class="bi bi-lock-fill text-[10px]"></i>
          <span>Physical Scale: 1.000 (Locked)</span>
        </div>

        <!-- Fullscreen Button -->
        <button
          type="button"
          class="p-1.5 rounded-lg text-muted-gray hover:text-forest hover:bg-cream/80 transition-colors cursor-pointer"
          title="Toggle Fullscreen"
          @click="toggleFullscreen"
        >
          <i class="bi" :class="isFullscreen ? 'bi-fullscreen-exit' : 'bi-arrows-fullscreen'"></i>
        </button>
      </div>
    </div>

    <!-- Center 3D WebGL Canvas -->
    <div ref="canvasContainer" class="relative flex-1 w-full h-full cursor-grab active:cursor-grabbing">
      <!-- Loading Overlay -->
      <div
        v-if="isLoading"
        class="absolute inset-0 z-10 flex flex-col items-center justify-center bg-off-white/80 backdrop-blur-sm space-y-3"
      >
        <div class="w-10 h-10 rounded-full border-2 border-forest border-t-transparent animate-spin"></div>
        <div class="text-center space-y-0.5">
          <p class="text-xs font-mono font-semibold text-forest">Loading 3D Spatial Mesh...</p>
          <p class="text-[10px] font-mono text-muted-gray">Locked 1.000 Scale • WebGL 2.0</p>
        </div>
      </div>

      <!-- Overlaid Centered Dimension HUD Pill -->
      <div
        v-if="!isLoading"
        class="absolute top-14 left-4 z-20 inline-flex items-center gap-2 px-3 py-1.5 rounded-xl bg-off-white/90 backdrop-blur-md border border-light-border shadow-subtle text-xs font-mono text-charcoal pointer-events-none"
      >
        <i class="bi bi-rulers text-forest"></i>
        <span>
          <strong>{{ widthCm }}</strong>W × <strong>{{ depthCm }}</strong>D × <strong>{{ heightCm }}</strong>H cm
        </span>
      </div>
    </div>

    <!-- Bottom Controls & Lighting Bar -->
    <div class="absolute bottom-0 left-0 right-0 z-20 p-3 bg-off-white/85 backdrop-blur-md border-t border-light-border/60 flex flex-wrap items-center justify-between gap-3 text-xs">
      
      <!-- Camera Angle Presets -->
      <div class="flex items-center gap-1 bg-cream/90 p-1 rounded-xl border border-light-border">
        <button
          type="button"
          class="px-2.5 py-1 rounded-lg font-mono text-[11px] transition-all cursor-pointer"
          :class="activeCameraAngle === 'front' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
          @click="setCameraAngle('front')"
        >
          Front
        </button>
        <button
          type="button"
          class="px-2.5 py-1 rounded-lg font-mono text-[11px] transition-all cursor-pointer"
          :class="activeCameraAngle === 'side' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
          @click="setCameraAngle('side')"
        >
          Side
        </button>
        <button
          type="button"
          class="px-2.5 py-1 rounded-lg font-mono text-[11px] transition-all cursor-pointer"
          :class="activeCameraAngle === 'top' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
          @click="setCameraAngle('top')"
        >
          Top
        </button>
        <button
          type="button"
          class="px-2.5 py-1 rounded-lg font-mono text-[11px] transition-all cursor-pointer"
          :class="activeCameraAngle === 'perspective' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
          @click="setCameraAngle('perspective')"
        >
          3/4
        </button>
        <button
          type="button"
          class="px-2 py-1 rounded-lg text-muted-gray hover:text-forest transition-colors cursor-pointer"
          title="Reset Camera"
          @click="resetView"
        >
          <i class="bi bi-arrow-counterclockwise"></i>
        </button>
      </div>

      <!-- Feature Toggles: Bounding Box & Turntable Auto-Rotate -->
      <div class="flex items-center gap-2">
        <button
          type="button"
          class="px-2.5 py-1.5 rounded-xl border text-xs font-mono transition-all flex items-center gap-1.5 cursor-pointer"
          :class="showBoundingBox ? 'bg-forest/10 border-forest text-forest font-semibold' : 'bg-cream border-light-border text-muted-gray hover:text-charcoal'"
          @click="toggleBoundingBox"
        >
          <i class="bi" :class="showBoundingBox ? 'bi-bounding-box' : 'bi-bounding-box-circles'"></i>
          <span>Bounding Box</span>
        </button>

        <button
          type="button"
          class="px-2.5 py-1.5 rounded-xl border text-xs font-mono transition-all flex items-center gap-1.5 cursor-pointer"
          :class="autoRotate ? 'bg-forest/10 border-forest text-forest font-semibold' : 'bg-cream border-light-border text-muted-gray hover:text-charcoal'"
          @click="toggleAutoRotate"
        >
          <i class="bi bi-arrow-repeat" :class="autoRotate ? 'animate-spin' : ''"></i>
          <span>Auto-Rotate</span>
        </button>
      </div>

      <!-- Lighting Presets (Default: Showroom) -->
      <div class="flex items-center gap-1.5">
        <span class="text-[11px] font-mono text-muted-gray hidden md:inline">Lighting:</span>
        <div class="flex items-center gap-1 bg-cream/90 p-1 rounded-xl border border-light-border">
          <button
            type="button"
            class="px-2 py-1 rounded-lg text-[11px] font-medium transition-all flex items-center gap-1 cursor-pointer"
            :class="activeLighting === 'showroom' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
            title="Neutral Showroom Studio"
            @click="applyLightingPreset('showroom')"
          >
            <span>◻️</span>
            <span class="hidden sm:inline">Showroom</span>
          </button>
          <button
            type="button"
            class="px-2 py-1 rounded-lg text-[11px] font-medium transition-all flex items-center gap-1 cursor-pointer"
            :class="activeLighting === 'daylight' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
            title="Natural Daylight"
            @click="applyLightingPreset('daylight')"
          >
            <span>☀️</span>
            <span class="hidden sm:inline">Daylight</span>
          </button>
          <button
            type="button"
            class="px-2 py-1 rounded-lg text-[11px] font-medium transition-all flex items-center gap-1 cursor-pointer"
            :class="activeLighting === 'golden' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
            title="Warm Golden Hour"
            @click="applyLightingPreset('golden')"
          >
            <span>🌅</span>
            <span class="hidden sm:inline">Golden</span>
          </button>
        </div>
      </div>

    </div>
  </div>
</template>

<style scoped>
:fullscreen,
:-webkit-full-screen {
  background-color: #F5F2EC !important;
  background-image: linear-gradient(to bottom, #F5F2EC, #ECE7DE) !important;
  border-radius: 0 !important;
  border: none !important;
  width: 100vw !important;
  height: 100vh !important;
}
</style>
