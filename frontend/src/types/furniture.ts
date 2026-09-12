export interface Dimensions {
  width_cm: number
  height_cm: number
  depth_cm: number
  width_m: number
  height_m: number
  depth_m: number
  footprint_area_sqm: number
}

export interface BoundingBox {
  width_m: number
  height_m: number
  depth_m: number
  footprint_area_sqm: number
}

export interface ClearanceEnvelope {
  front_m: number
  side_m: number
  total_width_m: number
  total_depth_m: number
}

export interface FurnitureImage {
  id: number
  image_path: string
  is_primary: boolean
}

export interface Model3D {
  path: string | null
  format: string
  file_size_mb: number
  draco_compressed: boolean
}

export interface Availability {
  status: 'in_stock' | 'low_stock' | 'out_of_stock'
  quantity: number
}

export interface FurnitureCategorySummary {
  id: number
  name: string
  slug: string
  parent?: {
    id: number
    name: string
    slug: string
  } | null
}

export interface Furniture {
  id: number
  sku: string
  name: string
  description: string
  price: number
  dimensions: Dimensions
  bounding_box: BoundingBox
  clearance_envelope: ClearanceEnvelope
  style: string
  material: string
  color: string
  color_hex: string
  primary_image?: string | null
  images: FurnitureImage[]
  model_3d: Model3D
  category?: FurnitureCategorySummary | null
  availability: Availability
  is_favorite: boolean
  created_at?: string
}

export interface FurnitureFilters {
  category_id?: number
  category_slug?: string
  style?: string
  material?: string
  price_min?: number
  price_max?: number
  max_width_cm?: number
  max_depth_cm?: number
  max_height_cm?: number
  search?: string
  sort_by?: 'newest' | 'price_asc' | 'price_desc' | 'width_asc' | 'width_desc' | 'name_asc'
  page?: number
  per_page?: number
}
