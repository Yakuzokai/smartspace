import { ref, computed } from 'vue'
import type { Furniture } from '@/types/furniture'
import type { ClientPlacedFurniture, PlacementStatus } from '@/types/project'

export interface RoomDimensionsM {
  width_m: number
  length_m: number
  height_m: number
}

/**
 * Computes rotation-aware 2D AABB bounding extents in meters matching Laravel's SpaceCompatibilityService.
 * Uses trigonometric bounding box projection:
 *   rotatedWidth = |w * cos(θ)| + |d * sin(θ)|
 *   rotatedDepth = |w * sin(θ)| + |d * cos(θ)|
 */
export function computeRotated2DBounds(
  width_m: number,
  depth_m: number,
  pos_x: number,
  pos_z: number,
  rot_deg: number
) {
  const rad = (rot_deg * Math.PI) / 180
  const rotatedWidth =
    Math.abs(width_m * Math.cos(rad)) +
    Math.abs(depth_m * Math.sin(rad))
  const rotatedDepth =
    Math.abs(width_m * Math.sin(rad)) +
    Math.abs(depth_m * Math.cos(rad))

  const halfRotW = rotatedWidth / 2
  const halfRotD = rotatedDepth / 2

  const minX = pos_x - halfRotW
  const maxX = pos_x + halfRotW
  const minZ = pos_z - halfRotD
  const maxZ = pos_z + halfRotD

  return {
    min_x: Math.round(minX * 1000) / 1000,
    max_x: Math.round(maxX * 1000) / 1000,
    min_z: Math.round(minZ * 1000) / 1000,
    max_z: Math.round(maxZ * 1000) / 1000,
    width: Math.round(rotatedWidth * 1000) / 1000,
    depth: Math.round(rotatedDepth * 1000) / 1000,
  }
}

/**
 * Checks if two 2D bounding boxes overlap.
 */
export function checkAABBOverlap(
  boxA: { min_x: number; max_x: number; min_z: number; max_z: number },
  boxB: { min_x: number; max_x: number; min_z: number; max_z: number },
  tolerance = 0.01
): boolean {
  return (
    boxA.min_x < boxB.max_x - tolerance &&
    boxA.max_x > boxB.min_x + tolerance &&
    boxA.min_z < boxB.max_z - tolerance &&
    boxA.max_z > boxB.min_z + tolerance
  )
}

export function useFurniturePlacement(roomDimensions: () => RoomDimensionsM) {
  const placedItems = ref<ClientPlacedFurniture[]>([])
  const selectedUuid = ref<string | null>(null)
  const isDirty = ref(false)

  const selectedItem = computed(() => {
    if (!selectedUuid.value) return null
    return placedItems.value.find((i) => i.uuid === selectedUuid.value) || null
  })

  /**
   * Recalculates preview placement statuses for all items.
   * Client-side preview only — non-authoritative.
   */
  function updateAllStatuses() {
    const { width_m, length_m } = roomDimensions()
    const halfW = width_m / 2
    const halfL = length_m / 2
    const tolerance = 0.005

    // 1. Calculate bounds for all items
    for (const item of placedItems.value) {
      const w = Number(item.furniture?.dimensions?.width_m ?? (item.furniture?.dimensions?.width_cm ? item.furniture.dimensions.width_cm / 100 : 1.0))
      const d = Number(item.furniture?.dimensions?.depth_m ?? (item.furniture?.dimensions?.depth_cm ? item.furniture.dimensions.depth_cm / 100 : 1.0))
      item.bounds_2d = computeRotated2DBounds(
        w,
        d,
        item.position_x,
        item.position_z,
        item.rotation_y
      )
    }

    // 2. Check each item against boundaries and collisions
    for (const item of placedItems.value) {
      const bounds = item.bounds_2d!
      let status: PlacementStatus = 'valid'
      let message = 'Placement looks valid (Preview)'

      // Boundary check (west, east, north, south)
      const isWestOut = bounds.min_x < -halfW - tolerance
      const isEastOut = bounds.max_x > halfW + tolerance
      const isNorthOut = bounds.min_z < -halfL - tolerance
      const isSouthOut = bounds.max_z > halfL + tolerance

      if (isWestOut || isEastOut || isNorthOut || isSouthOut) {
        status = 'out_of_bounds'
        message = 'Item extends beyond room boundaries'
      } else {
        // Collision check against other items
        for (const other of placedItems.value) {
          if (other.uuid === item.uuid) continue
          if (checkAABBOverlap(bounds, other.bounds_2d!)) {
            status = 'collision'
            message = `Overlaps with ${other.furniture?.name || 'another item'}`
            break
          }
        }
      }

      item.status = status
      item.status_message = message
      item.is_out_of_bounds = status === 'out_of_bounds'
      item.has_collision = status === 'collision'
      item.is_selected = item.uuid === selectedUuid.value
    }
  }

  /**
   * Add a new furniture item to the room canvas.
   */
  function addFurniture(furniture: Furniture, customPos?: { x: number; z: number }) {
    const { width_m, length_m } = roomDimensions()
    const uuid = `inst_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`

    // Default position: room center or slightly jittered if occupied
    let posX = customPos?.x ?? 0
    let posZ = customPos?.z ?? 0

    if (!customPos) {
      const offset = (placedItems.value.length % 5) * 0.3 - 0.6
      posX = Math.max(-width_m / 2 + 0.5, Math.min(width_m / 2 - 0.5, offset))
      posZ = Math.max(-length_m / 2 + 0.5, Math.min(length_m / 2 - 0.5, offset))
    }

    const newItem: ClientPlacedFurniture = {
      uuid,
      furniture_id: furniture.id,
      position_x: Math.round(posX * 100) / 100,
      position_y: 0,
      position_z: Math.round(posZ * 100) / 100,
      rotation_y: 0,
      scale: 1.0, // Scale strictly locked at 1.000
      furniture,
      status: 'valid',
      status_message: 'Placed (Preview)',
    }

    placedItems.value.push(newItem)
    selectedUuid.value = uuid
    isDirty.value = true
    updateAllStatuses()

    return newItem
  }

  /**
   * Remove item from room.
   */
  function removeItem(uuid: string) {
    const idx = placedItems.value.findIndex((i) => i.uuid === uuid)
    if (idx !== -1) {
      placedItems.value.splice(idx, 1)
      if (selectedUuid.value === uuid) {
        selectedUuid.value = null
      }
      isDirty.value = true
      updateAllStatuses()
    }
  }

  /**
   * Duplicate selected item.
   */
  function duplicateItem(uuid: string) {
    const original = placedItems.value.find((i) => i.uuid === uuid)
    if (!original || !original.furniture) return null

    const { width_m, length_m } = roomDimensions()
    const newUuid = `inst_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`

    // Offset slightly from original
    let newX = original.position_x + 0.35
    let newZ = original.position_z + 0.35

    if (newX > width_m / 2 - 0.4) newX = original.position_x - 0.35
    if (newZ > length_m / 2 - 0.4) newZ = original.position_z - 0.35

    const cloned: ClientPlacedFurniture = {
      uuid: newUuid,
      furniture_id: original.furniture_id,
      position_x: Math.round(newX * 100) / 100,
      position_y: 0,
      position_z: Math.round(newZ * 100) / 100,
      rotation_y: original.rotation_y,
      scale: 1.0,
      furniture: original.furniture,
      status: 'valid',
      status_message: 'Placed (Preview)',
    }

    placedItems.value.push(cloned)
    selectedUuid.value = newUuid
    isDirty.value = true
    updateAllStatuses()

    return cloned
  }

  /**
   * Move item to new (X, Z) coordinates.
   * Free movement — does NOT silently clamp.
   */
  function moveItem(uuid: string, posX: number, posZ: number) {
    const item = placedItems.value.find((i) => i.uuid === uuid)
    if (!item) return

    item.position_x = Math.round(posX * 1000) / 1000
    item.position_z = Math.round(posZ * 1000) / 1000
    isDirty.value = true
    updateAllStatuses()
  }

  /**
   * Rotate item by delta or set absolute rotation.
   * Supports 15° snap increment.
   */
  function rotateItem(uuid: string, degOrDelta: number, isAbsolute = false) {
    const item = placedItems.value.find((i) => i.uuid === uuid)
    if (!item) return

    let newRot = isAbsolute ? degOrDelta : item.rotation_y + degOrDelta
    // Normalize to [0, 360)
    newRot = ((newRot % 360) + 360) % 360

    // Snap to nearest 15°
    const snapped = Math.round(newRot / 15) * 15
    item.rotation_y = snapped % 360
    isDirty.value = true
    updateAllStatuses()
  }

  /**
   * Convenience action: Snap an out-of-bounds item back cleanly inside the room perimeter.
   */
  function snapInsideRoom(uuid: string) {
    const item = placedItems.value.find((i) => i.uuid === uuid)
    if (!item || !item.furniture) return

    const { width_m, length_m } = roomDimensions()
    const halfRoomW = width_m / 2
    const halfRoomL = length_m / 2

    // Get rotated width and depth
    const w = Number(item.furniture.dimensions?.width_m ?? (item.furniture.dimensions?.width_cm ? item.furniture.dimensions.width_cm / 100 : 1.0))
    const d = Number(item.furniture.dimensions?.depth_m ?? (item.furniture.dimensions?.depth_cm ? item.furniture.dimensions.depth_cm / 100 : 1.0))

    const rad = (item.rotation_y * Math.PI) / 180
    const rotatedWidth =
      Math.abs(w * Math.cos(rad)) +
      Math.abs(d * Math.sin(rad))
    const rotatedDepth =
      Math.abs(w * Math.sin(rad)) +
      Math.abs(d * Math.cos(rad))

    const minX = -halfRoomW + rotatedWidth / 2
    const maxX =  halfRoomW - rotatedWidth / 2
    const minZ = -halfRoomL + rotatedDepth / 2
    const maxZ =  halfRoomL - rotatedDepth / 2

    // Clamp center to the nearest valid position inside room
    const clampedX = Math.max(minX, Math.min(maxX, item.position_x))
    const clampedZ = Math.max(minZ, Math.min(maxZ, item.position_z))

    item.position_x = Math.round(clampedX * 1000) / 1000
    item.position_z = Math.round(clampedZ * 1000) / 1000
    isDirty.value = true
    updateAllStatuses()
  }

  /**
   * Load placed items from backend RoomProject.
   */
  function loadFromPlacements(placements: any[]) {
    placedItems.value = placements.map((p, idx) => ({
      id: p.id,
      uuid: `inst_loaded_${idx}_${p.id ?? p.furniture_id}`,
      furniture_id: p.furniture_id,
      position_x: Number(p.position_x) || 0,
      position_y: Number(p.position_y) || 0,
      position_z: Number(p.position_z) || 0,
      rotation_y: Number(p.rotation_y) || 0,
      scale: 1.0,
      furniture: p.furniture,
      status: 'valid' as PlacementStatus,
      status_message: 'Certified placement',
    }))
    isDirty.value = false
    updateAllStatuses()
  }

  /**
   * Prepare serializable items array for PUT /room-projects/{id}/layout.
   */
  function getPayloadForBackend() {
    return placedItems.value.map((item) => ({
      furniture_id: item.furniture_id,
      position_x: item.position_x,
      position_y: item.position_y || 0,
      position_z: item.position_z,
      rotation_y: item.rotation_y || 0,
    }))
  }

  return {
    placedItems,
    selectedUuid,
    selectedItem,
    isDirty,
    addFurniture,
    removeItem,
    duplicateItem,
    moveItem,
    rotateItem,
    snapInsideRoom,
    loadFromPlacements,
    getPayloadForBackend,
    updateAllStatuses,
  }
}
