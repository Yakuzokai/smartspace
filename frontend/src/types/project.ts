import type { Furniture } from './furniture'

export type PlacementStatus =
  | 'valid'
  | 'collision'
  | 'out_of_bounds'
  | 'clearance_warning'

export interface FactorBreakdown {
  score: number
  max_score: number
  passed?: boolean
  violations?: Array<{ message?: string; name?: string; sku?: string; [key: string]: any }>
  warnings?: Array<{ message?: string; name?: string; sku?: string; [key: string]: any }>
  [key: string]: any
}

export interface CompatibilityBreakdown {
  total_score: number
  is_valid: boolean
  verdict: string
  badge: string
  description: string
  room_dimensions: {
    width_m: number
    length_m: number
    height_m: number
    area_sqm: number
  }
  item_count: number
  breakdown: {
    boundary_fit: FactorBreakdown
    collision: FactorBreakdown
    clearance: FactorBreakdown
    utilization: FactorBreakdown
    room_fitness: FactorBreakdown
  }
  evaluation_notes: string[]
}

export interface PlacedFurniture {
  id?: number
  uuid: string
  furniture_id: number
  position_x: number
  position_y: number
  position_z: number
  rotation_y: number
  scale: 1.000 | number
  furniture?: Furniture

  status?: PlacementStatus
  has_collision?: boolean
  is_out_of_bounds?: boolean
  is_selected?: boolean
  status_message?: string

  bounds_2d?: {
    min_x: number
    max_x: number
    min_z: number
    max_z: number
    width?: number
    depth?: number
  }
}

export interface ClientPlacedFurniture extends PlacedFurniture {
  uuid: string
  status: PlacementStatus
}

export interface RoomProject {
  id: number
  name: string
  room_type: string
  width_cm: number
  length_cm: number
  height_cm: number
  room_area_sqm: number
  dimensions?: {
    width_cm: number
    length_cm: number
    height_cm: number
    width_m: number
    length_m: number
    height_m: number
    floor_area_sqm: number
  }
  style: string
  compatibility_score: number
  score_breakdown: CompatibilityBreakdown | null
  placements: PlacedFurniture[]
  furniture_placements?: any[]
  created_at?: string
  updated_at?: string
}

export interface CreateProjectPayload {
  name: string
  room_type: string
  width_cm: number
  length_cm: number
  height_cm: number
  style?: string
}
