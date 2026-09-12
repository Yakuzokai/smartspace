import api from './api'
import type { PaginatedResponse, ApiResponse } from '@/types/api'
import type { Category } from '@/types/category'
import type { Furniture, FurnitureFilters } from '@/types/furniture'

export const catalogService = {
  async getCategories(): Promise<Category[]> {
    const response = await api.get<ApiResponse<Category[]>>('/categories')
    return response.data.data
  },

  async getCategory(idOrSlug: string | number): Promise<Category> {
    const response = await api.get<ApiResponse<Category>>(`/categories/${idOrSlug}`)
    return response.data.data
  },

  async getFurniture(filters: FurnitureFilters = {}): Promise<PaginatedResponse<Furniture>> {
    const response = await api.get<PaginatedResponse<Furniture>>('/furniture', {
      params: filters,
    })
    return response.data
  },

  async getFeatured(): Promise<Furniture[]> {
    const response = await api.get<ApiResponse<Furniture[]>>('/furniture/featured')
    return response.data.data
  },

  async getStyles(): Promise<string[]> {
    const response = await api.get<ApiResponse<string[]>>('/furniture/styles')
    return response.data.data
  },

  async getById(id: number | string): Promise<Furniture> {
    const response = await api.get<ApiResponse<Furniture>>(`/furniture/${id}`)
    return response.data.data
  },
}
