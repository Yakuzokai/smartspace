import api from './api'
import type { ApiResponse } from '@/types/api'
import type { Furniture } from '@/types/furniture'

export interface ToggleFavoriteResponse {
  favorited: boolean
  message: string
}

export const favoriteService = {
  async getFavorites(): Promise<Furniture[]> {
    const response = await api.get<ApiResponse<Furniture[]>>('/favorites')
    return response.data.data
  },

  async toggleFavorite(furnitureId: number): Promise<ToggleFavoriteResponse> {
    const response = await api.post<ToggleFavoriteResponse>(`/favorites/toggle/${furnitureId}`)
    return response.data
  },
}
