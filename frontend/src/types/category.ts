export interface Subcategory {
  id: number
  name: string
  slug: string
  description?: string
  icon?: string
  furniture_count: number
}

export interface Category {
  id: number
  name: string
  slug: string
  description?: string
  icon?: string
  subcategories: Subcategory[]
}
