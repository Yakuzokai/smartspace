<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import * as THREE from 'three'
import {
  createRoomScene,
  type RoomSceneContext,
  type LightingPreset,
  type CameraMode,
} from '@/composables/useRoomScene'
import { useModelLoader } from '@/composables/useModelLoader'
import type { ClientPlacedFurniture, RoomProject } from '@/types/project'

const props = defineProps<{
  project: RoomProject
  placedItems: ClientPlacedFurniture[]
  selectedUuid: string | null
}>()

const emit = defineEmits<{
  (e: 'select', uuid: string | null): void
  (e: 'move', uuid: string, x: number, z: number): void
  (e: 'rotate', uuid: string, deg: number, isAbsolute?: boolean): void
  (e: 'duplicate', uuid: string): void
  (e: 'remove', uuid: string): void
  (e: 'snapInside', uuid: string): void
}>()

const canvasContainer = ref<HTMLDivElement | null>(null)
let sceneCtx: RoomSceneContext | null = null

const activeCameraMode = ref<CameraMode>('perspective')
const activeLighting = ref<LightingPreset>('showroom')

const { loadFurnitureModel } = useModelLoader()

// Map of uuid -> { root: THREE.Group, bboxMesh: THREE.LineSegments, furniture: Furniture }
const itemSceneObjects = new Map<
  string,
  {
    root: THREE.Group
    bboxMesh: THREE.LineSegments
    hitMesh: THREE.Mesh
  }
>()

// Raycasting & Drag State
const raycaster = new THREE.Raycaster()
const mouse = new THREE.Vector2()
const floorPlane = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0)
const planeIntersect = new THREE.Vector3()

let isDragging = false
let draggedUuid: string | null = null
let dragOffset = new THREE.Vector3()
let pointerDownPos = { x: 0, y: 0 }

onMounted(async () => {
  if (!canvasContainer.value) return

  const dims = {
    width_m: props.project.width_cm / 100,
    length_m: props.project.length_cm / 100,
    height_m: props.project.height_cm / 100,
  }

  sceneCtx = createRoomScene(canvasContainer.value, dims)

  // Attach pointer handlers for raycasting & drag
  const dom = sceneCtx.renderer.domElement
  dom.addEventListener('pointerdown', onPointerDown)
  window.addEventListener('pointermove', onPointerMove)
  window.addEventListener('pointerup', onPointerUp)

  // Sync initial furniture items
  syncPlacedItems(props.placedItems)
})

onBeforeUnmount(() => {
  const dom = sceneCtx?.renderer.domElement
  if (dom) {
    dom.removeEventListener('pointerdown', onPointerDown)
  }
  window.removeEventListener('pointermove', onPointerMove)
  window.removeEventListener('pointerup', onPointerUp)

  // Cleanup 3D item objects
  for (const [_, obj] of itemSceneObjects) {
    sceneCtx?.furnitureGroup.remove(obj.root)
  }
  itemSceneObjects.clear()

  sceneCtx?.dispose()
  sceneCtx = null
})

// Watch room dimension changes
watch(
  () => [props.project.width_cm, props.project.length_cm, props.project.height_cm],
  ([w, l, h]) => {
    if (!sceneCtx) return
    sceneCtx.updateRoomDimensions({
      width_m: Number(w) / 100,
      length_m: Number(l) / 100,
      height_m: Number(h) / 100,
    })
  }
)

// Watch placed items array
watch(
  () => props.placedItems,
  (newItems) => {
    syncPlacedItems(newItems)
  },
  { deep: true }
)

// Watch selected item
watch(
  () => props.selectedUuid,
  () => {
    updateBoundingBoxColors()
  }
)

async function syncPlacedItems(items: ClientPlacedFurniture[]) {
  if (!sceneCtx) return

  const currentUuids = new Set(items.map((i) => i.uuid))

  // 1. Remove deleted items from scene
  for (const [uuid, obj] of itemSceneObjects) {
    if (!currentUuids.has(uuid)) {
      sceneCtx.furnitureGroup.remove(obj.root)
      itemSceneObjects.delete(uuid)
    }
  }

  // 2. Add or update items
  for (const item of items) {
    const existing = itemSceneObjects.get(item.uuid)

    if (existing) {
      // Update transform if not currently dragging it
      if (draggedUuid !== item.uuid) {
        existing.root.position.set(item.position_x, item.position_y || 0, item.position_z)
        existing.root.rotation.y = (item.rotation_y * Math.PI) / 180
      }
    } else if (item.furniture) {
      // Load 3D model through shared useModelLoader (M4 cache reuse)
      const { model } = await loadFurnitureModel(item.furniture)
      const itemGroup = new THREE.Group()
      itemGroup.name = `furniture_${item.uuid}`

      // Strict physical scale invariant
      itemGroup.scale.set(1.0, 1.0, 1.0)
      itemGroup.position.set(item.position_x, item.position_y || 0, item.position_z)
      itemGroup.rotation.y = (item.rotation_y * Math.PI) / 180

      const clonedModel = model.clone(true)
      itemGroup.add(clonedModel)

      // Create Bounding Box Wireframe for preview feedback
      const w = Number(item.furniture.dimensions?.width_m ?? (item.furniture.dimensions?.width_cm ? item.furniture.dimensions.width_cm / 100 : 1.0))
      const h = Number(item.furniture.dimensions?.height_m ?? (item.furniture.dimensions?.height_cm ? item.furniture.dimensions.height_cm / 100 : 0.8))
      const d = Number(item.furniture.dimensions?.depth_m ?? (item.furniture.dimensions?.depth_cm ? item.furniture.dimensions.depth_cm / 100 : 0.8))

      const bboxGeo = new THREE.BoxGeometry(w, h, d)
      const bboxEdges = new THREE.EdgesGeometry(bboxGeo)
      const bboxMat = new THREE.LineBasicMaterial({
        color: 0x173f35, // default forest green
        linewidth: 2,
        transparent: true,
        opacity: 0.85,
      })
      const bboxMesh = new THREE.LineSegments(bboxEdges, bboxMat)
      bboxMesh.position.y = h / 2
      itemGroup.add(bboxMesh)

      // Invisible hit mesh for easy clicking & raycasting
      const hitGeo = new THREE.BoxGeometry(w, h, d)
      const hitMat = new THREE.MeshBasicMaterial({ visible: false })
      const hitMesh = new THREE.Mesh(hitGeo, hitMat)
      hitMesh.position.y = h / 2
      hitMesh.userData = { uuid: item.uuid }
      itemGroup.add(hitMesh)

      sceneCtx.furnitureGroup.add(itemGroup)

      itemSceneObjects.set(item.uuid, {
        root: itemGroup,
        bboxMesh,
        hitMesh,
      })
    }
  }

  updateBoundingBoxColors()
}

function updateBoundingBoxColors() {
  for (const item of props.placedItems) {
    const obj = itemSceneObjects.get(item.uuid)
    if (!obj) continue

    const isSelected = item.uuid === props.selectedUuid
    const mat = obj.bboxMesh.material as THREE.LineBasicMaterial

    if (item.status === 'out_of_bounds' || item.status === 'collision') {
      // 🔴 Hard Physical Violation (Preview)
      mat.color.setHex(0xdc2626) // Red
      mat.opacity = isSelected ? 1.0 : 0.75
    } else if (item.status === 'clearance_warning') {
      // 🟠 Clearance Warning (Preview)
      mat.color.setHex(0xd97706) // Amber
      mat.opacity = isSelected ? 1.0 : 0.65
    } else if (isSelected) {
      // 🟢 Selected & Valid
      mat.color.setHex(0x173f35) // Deep Forest Green
      mat.opacity = 1.0
    } else {
      // Subtle Unselected
      mat.color.setHex(0x737a76) // Muted Gray
      mat.opacity = 0.35
    }
  }
}

// Pointer Events for Drag & Select
function getPointerCoords(e: PointerEvent) {
  if (!canvasContainer.value) return { x: 0, y: 0 }
  const rect = canvasContainer.value.getBoundingClientRect()
  return {
    x: ((e.clientX - rect.left) / rect.width) * 2 - 1,
    y: -((e.clientY - rect.top) / rect.height) * 2 + 1,
  }
}

function onPointerDown(e: PointerEvent) {
  if (e.button !== 0 || !sceneCtx) return // Only primary click
  pointerDownPos = { x: e.clientX, y: e.clientY }

  const coords = getPointerCoords(e)
  mouse.x = coords.x
  mouse.y = coords.y

  raycaster.setFromCamera(mouse, sceneCtx.activeCamera)

  // Raycast against all hit meshes
  const hitMeshes = Array.from(itemSceneObjects.values()).map((o) => o.hitMesh)
  const intersects = raycaster.intersectObjects(hitMeshes, false)

  if (intersects.length > 0) {
    const hit = intersects[0]
    const uuid = hit.object.userData.uuid
    if (uuid) {
      emit('select', uuid)
      draggedUuid = uuid
      isDragging = true

      // Disable orbit controls while dragging furniture
      sceneCtx.controls.enabled = false

      // Calculate drag offset on floor plane
      if (raycaster.ray.intersectPlane(floorPlane, planeIntersect)) {
        const itemObj = itemSceneObjects.get(uuid)
        if (itemObj) {
          dragOffset.copy(itemObj.root.position).sub(planeIntersect)
          dragOffset.y = 0 // Keep strictly on floor
        }
      }
    }
  }
}

function onPointerMove(e: PointerEvent) {
  if (!isDragging || !draggedUuid || !sceneCtx) return

  const coords = getPointerCoords(e)
  mouse.x = coords.x
  mouse.y = coords.y

  raycaster.setFromCamera(mouse, sceneCtx.activeCamera)

  if (raycaster.ray.intersectPlane(floorPlane, planeIntersect)) {
    const newPos = planeIntersect.add(dragOffset)
    const itemObj = itemSceneObjects.get(draggedUuid)
    if (itemObj) {
      itemObj.root.position.x = newPos.x
      itemObj.root.position.z = newPos.z
    }

    emit('move', draggedUuid, newPos.x, newPos.z)
  }
}

function onPointerUp(e: PointerEvent) {
  if (sceneCtx) {
    sceneCtx.controls.enabled = true
  }

  // Check if it was a plain click without dragging on empty floor to deselect
  const dist = Math.hypot(e.clientX - pointerDownPos.x, e.clientY - pointerDownPos.y)
  if (dist < 4 && !draggedUuid && sceneCtx) {
    const coords = getPointerCoords(e)
    mouse.x = coords.x
    mouse.y = coords.y
    raycaster.setFromCamera(mouse, sceneCtx.activeCamera)
    const hitMeshes = Array.from(itemSceneObjects.values()).map((o) => o.hitMesh)
    const intersects = raycaster.intersectObjects(hitMeshes, false)
    if (intersects.length === 0) {
      emit('select', null)
    }
  }

  isDragging = false
  draggedUuid = null
}

function setCamera(mode: CameraMode) {
  activeCameraMode.value = mode
  sceneCtx?.setCameraMode(mode)
}

function setLighting(preset: LightingPreset) {
  activeLighting.value = preset
  sceneCtx?.setLightingPreset(preset)
}

function resetView() {
  sceneCtx?.resetCamera()
}
</script>

<template>
  <div class="relative w-full h-full select-none overflow-hidden bg-off-white">
    <!-- WebGL Canvas Container -->
    <div ref="canvasContainer" class="w-full h-full cursor-grab active:cursor-grabbing"></div>

    <!-- Top Studio Controls Overlay -->
    <div class="absolute top-4 inset-x-4 z-10 flex flex-wrap items-center justify-between gap-2 pointer-events-none">
      <!-- Left Controls Toolbar -->
      <div
        class="flex flex-wrap items-center gap-2 bg-cream/90 backdrop-blur-md px-3 py-2 rounded-2xl border border-light-border shadow-subtle text-xs pointer-events-auto"
      >
        <!-- Camera Perspective / Blueprint Switcher -->
        <div class="flex items-center bg-off-white rounded-xl p-0.5 border border-light-border">
          <button
            type="button"
            class="px-3 py-1.5 rounded-lg font-medium transition-all cursor-pointer flex items-center gap-1.5"
            :class="
              activeCameraMode === 'perspective'
                ? 'bg-forest text-cream shadow-sm font-semibold'
                : 'text-charcoal hover:text-forest'
            "
            @click="setCamera('perspective')"
          >
            <span>🧊</span>
            <span>3D Orbit</span>
          </button>
          <button
            type="button"
            class="px-3 py-1.5 rounded-lg font-medium transition-all cursor-pointer flex items-center gap-1.5"
            :class="
              activeCameraMode === 'topdown'
                ? 'bg-forest text-cream shadow-sm font-semibold'
                : 'text-charcoal hover:text-forest'
            "
            @click="setCamera('topdown')"
          >
            <span>📐</span>
            <span>2D Blueprint</span>
          </button>
        </div>

        <div class="h-4 w-px bg-light-border mx-1 hidden sm:block"></div>

        <!-- Lighting Presets -->
        <div class="flex items-center gap-1">
          <button
            type="button"
            class="px-2.5 py-1 rounded-lg transition-all cursor-pointer text-[11px]"
            :class="
              activeLighting === 'showroom'
                ? 'bg-forest text-cream font-semibold'
                : 'text-muted-gray hover:text-charcoal'
            "
            title="Studio Showroom Lighting"
            @click="setLighting('showroom')"
          >
            ◻️ Showroom
          </button>
          <button
            type="button"
            class="px-2.5 py-1 rounded-lg transition-all cursor-pointer text-[11px]"
            :class="
              activeLighting === 'daylight'
                ? 'bg-forest text-cream font-semibold'
                : 'text-muted-gray hover:text-charcoal'
            "
            title="Natural Daylight"
            @click="setLighting('daylight')"
          >
            ☀️ Daylight
          </button>
          <button
            type="button"
            class="px-2.5 py-1 rounded-lg transition-all cursor-pointer text-[11px]"
            :class="
              activeLighting === 'golden'
                ? 'bg-forest text-cream font-semibold'
                : 'text-muted-gray hover:text-charcoal'
            "
            title="Warm Golden Hour"
            @click="setLighting('golden')"
          >
            🌅 Golden
          </button>
          <button
            type="button"
            class="px-2.5 py-1 rounded-lg transition-all cursor-pointer text-[11px]"
            :class="
              activeLighting === 'evening'
                ? 'bg-forest text-cream font-semibold'
                : 'text-muted-gray hover:text-charcoal'
            "
            title="Evening Ambient"
            @click="setLighting('evening')"
          >
            🌙 Evening
          </button>
        </div>

        <div class="h-4 w-px bg-light-border mx-1 hidden sm:block"></div>

        <!-- Reset Camera Button -->
        <button
          type="button"
          class="px-2.5 py-1 rounded-lg text-muted-gray hover:text-forest hover:bg-off-white text-[11px] cursor-pointer"
          title="Reset Camera Target"
          @click="resetView"
        >
          ↺ Reset
        </button>
      </div>

      <!-- Right Scale & Invariant Pill -->
      <div
        class="px-3 py-1.5 rounded-full bg-cream/90 backdrop-blur-md border border-light-border shadow-subtle flex items-center gap-2 text-xs font-mono text-forest font-semibold pointer-events-auto shrink-0"
      >
        <span>🔒</span>
        <span>1.000 Scale Locked</span>
        <span class="text-[10px] text-muted-gray font-normal">| 1 unit = 1 meter</span>
      </div>
    </div>

    <!-- Bottom Center: Selected Item Quick Controls Floating Panel -->
    <div
      v-if="selectedUuid && placedItems.find((i) => i.uuid === selectedUuid)"
      class="absolute bottom-6 left-1/2 -translate-x-1/2 z-20 bg-cream/95 backdrop-blur-md px-5 py-3 rounded-2xl border border-light-border shadow-card flex flex-col sm:flex-row items-center gap-4 text-xs"
    >
      <div
        v-for="item in [placedItems.find((i) => i.uuid === selectedUuid)!]"
        :key="item.uuid"
        class="flex flex-col sm:flex-row items-center gap-4"
      >
        <!-- Item Info & Status Badge -->
        <div class="flex items-center gap-3">
          <div class="space-y-0.5 text-left">
            <span class="font-display font-bold text-sm text-forest block">
              {{ item.furniture?.name }}
            </span>
            <span class="text-[11px] font-mono text-muted-gray">
              {{ item.furniture?.dimensions?.width_cm }}W ×
              {{ item.furniture?.dimensions?.depth_cm }}D ×
              {{ item.furniture?.dimensions?.height_cm }}H cm
            </span>
          </div>

          <!-- Preview Status Badge -->
          <div>
            <span
              v-if="item.status === 'valid'"
              class="px-2.5 py-1 rounded-full text-[11px] font-mono font-semibold bg-emerald-100 text-emerald-800 border border-emerald-300 flex items-center gap-1"
            >
              <span>🟢</span>
              <span>Looks valid (Preview)</span>
            </span>
            <span
              v-else-if="item.status === 'out_of_bounds'"
              class="px-2.5 py-1 rounded-full text-[11px] font-mono font-semibold bg-red-100 text-red-800 border border-red-300 flex items-center gap-1"
            >
              <span>🔴</span>
              <span>Outside Wall Boundary</span>
            </span>
            <span
              v-else-if="item.status === 'collision'"
              class="px-2.5 py-1 rounded-full text-[11px] font-mono font-semibold bg-red-100 text-red-800 border border-red-300 flex items-center gap-1"
            >
              <span>🔴</span>
              <span>Collision Overlap</span>
            </span>
            <span
              v-else
              class="px-2.5 py-1 rounded-full text-[11px] font-mono font-semibold bg-amber-100 text-amber-800 border border-amber-300 flex items-center gap-1"
            >
              <span>🟠</span>
              <span>Clearance Warning</span>
            </span>
          </div>
        </div>

        <div class="h-6 w-px bg-light-border hidden sm:block"></div>

        <!-- Rotation Controls (15° increments, +45°, +90°) -->
        <div class="flex items-center gap-1.5">
          <span class="text-[11px] text-muted-gray font-mono">Rot: {{ item.rotation_y }}°</span>
          <button
            type="button"
            class="px-2 py-1 rounded-lg bg-off-white hover:bg-warm-beige/25 border border-light-border text-charcoal font-mono text-xs cursor-pointer"
            title="Rotate Counter-Clockwise 15°"
            @click="$emit('rotate', item.uuid, -15)"
          >
            -15°
          </button>
          <button
            type="button"
            class="px-2 py-1 rounded-lg bg-off-white hover:bg-warm-beige/25 border border-light-border text-charcoal font-mono text-xs cursor-pointer"
            title="Rotate Clockwise 15°"
            @click="$emit('rotate', item.uuid, 15)"
          >
            +15°
          </button>
          <button
            type="button"
            class="px-2.5 py-1 rounded-lg bg-off-white hover:bg-warm-beige/25 border border-light-border text-charcoal font-semibold text-xs cursor-pointer"
            title="Rotate Clockwise 45°"
            @click="$emit('rotate', item.uuid, 45)"
          >
            +45°
          </button>
          <button
            type="button"
            class="px-2.5 py-1 rounded-lg bg-off-white hover:bg-warm-beige/25 border border-light-border text-charcoal font-semibold text-xs cursor-pointer"
            title="Rotate Clockwise 90°"
            @click="$emit('rotate', item.uuid, 90)"
          >
            +90°
          </button>
        </div>

        <div class="h-6 w-px bg-light-border hidden sm:block"></div>

        <!-- Snap Back & Item Actions -->
        <div class="flex items-center gap-2">
          <!-- Snap Inside Room (visible when out of bounds) -->
          <button
            v-if="item.status === 'out_of_bounds'"
            type="button"
            class="px-3 py-1.5 rounded-xl bg-warm-beige hover:bg-warm-beige/80 text-dark-green font-semibold text-xs transition-all shadow-subtle cursor-pointer flex items-center gap-1"
            title="Fit safely inside room boundaries"
            @click="$emit('snapInside', item.uuid)"
          >
            <span>🧲</span>
            <span>Snap Inside Room</span>
          </button>

          <!-- Duplicate -->
          <button
            type="button"
            class="p-1.5 px-2.5 rounded-xl bg-off-white hover:bg-light-border/40 border border-light-border text-charcoal text-xs cursor-pointer flex items-center gap-1"
            title="Duplicate Item"
            @click="$emit('duplicate', item.uuid)"
          >
            <span>📋</span>
            <span>Duplicate</span>
          </button>

          <!-- Delete -->
          <button
            type="button"
            class="p-1.5 px-2.5 rounded-xl bg-red-50 hover:bg-red-100 text-red-700 border border-red-200 text-xs cursor-pointer flex items-center gap-1"
            title="Remove from room"
            @click="$emit('remove', item.uuid)"
          >
            <span>🗑️</span>
            <span>Delete</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
