import { defineStore } from 'pinia'
import { ref, reactive } from 'vue'
import { catalogService } from '@/services/catalogService'
import type { Category } from '@/types/category'
import type { Furniture, FurnitureFilters } from '@/types/furniture'
import type { ApiMeta } from '@/types/api'

export const useCatalogStore = defineStore('catalog', () => {
  const furniture = ref<Furniture[]>([])
  const categories = ref<Category[]>([])
  const styles = ref<string[]>([])
  const featured = ref<Furniture[]>([])
  const meta = ref<ApiMeta | null>(null)
  const loading = ref<boolean>(false)
  const error = ref<string | null>(null)

  const defaultFilters: FurnitureFilters = {
    search: '',
    category_slug: '',
    style: '',
    material: '',
    price_min: undefined,
    price_max: undefined,
    max_width_cm: undefined,
    max_depth_cm: undefined,
    max_height_cm: undefined,
    sort_by: 'newest',
    page: 1,
  }

  const filters = reactive<FurnitureFilters>({ ...defaultFilters })

  async function fetchCategories() {
    if (categories.value.length > 0) return
    try {
      categories.value = await catalogService.getCategories()
    } catch (err: any) {
      console.error('Failed to load categories', err)
    }
  }

  async function fetchStyles() {
    if (styles.value.length > 0) return
    try {
      styles.value = await catalogService.getStyles()
    } catch (err: any) {
      console.error('Failed to load styles', err)
    }
  }

  async function fetchFeatured() {
    if (featured.value.length > 0) return
    try {
      featured.value = await catalogService.getFeatured()
    } catch (err: any) {
      console.error('Failed to load featured furniture', err)
    }
  }

  async function fetchFurniture() {
    loading.value = true
    error.value = null
    try {
      // Clean undefined and empty strings from query
      const cleanParams: Record<string, any> = {}
      for (const [key, val] of Object.entries(filters)) {
        if (val !== undefined && val !== null && val !== '') {
          cleanParams[key] = val
        }
      }

      const response = await catalogService.getFurniture(cleanParams)
      furniture.value = response.data
      meta.value = response.meta || null
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to fetch catalog.'
      console.error('Error fetching furniture catalog', err)
    } finally {
      loading.value = false
    }
  }

  function setFilter<K extends keyof FurnitureFilters>(key: K, value: FurnitureFilters[K]) {
    filters[key] = value
    // Reset to page 1 whenever a filter other than page changes
    if (key !== 'page') {
      filters.page = 1
    }
    fetchFurniture()
  }

  function setPage(page: number) {
    filters.page = page
    fetchFurniture()
  }

  function resetFilters() {
    Object.assign(filters, defaultFilters)
    fetchFurniture()
  }

  return {
    furniture,
    categories,
    styles,
    featured,
    meta,
    filters,
    loading,
    error,
    fetchCategories,
    fetchStyles,
    fetchFeatured,
    fetchFurniture,
    setFilter,
    setPage,
    resetFilters,
  }
})
