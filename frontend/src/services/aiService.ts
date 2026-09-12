import api from '@/services/api'
import type { Furniture } from '@/types/furniture'

export interface RoomAnalysisData {
  id: number
  image_url: string
  detected_room_type: string
  detected_style: string
  dominant_colors: string[]
  detected_objects: string[]
  confidence: number
  visual_clutter: string
  summary: string | null
  provider: string
  is_mock: boolean
  created_at: string
}

export interface RecommendedFurnitureItem {
  furniture: Furniture
  score: number
  match_reasons: string[]
  aesthetic_notes: string | null
  fits_room_bounds: boolean
}

export interface RecommendationResponseData {
  success: boolean
  target_style: string
  target_palette: string[]
  provider: string
  is_mock: boolean
  recommendations: RecommendedFurnitureItem[]
}

export const aiService = {
  async analyzeRoomPhoto(
    file: File,
    hint?: string,
    roomProjectId?: number
  ): Promise<RoomAnalysisData> {
    const formData = new FormData()
    formData.append('image', file)
    if (hint) formData.append('hint', hint)
    if (roomProjectId) formData.append('room_project_id', String(roomProjectId))

    const response = await api.post<{ success: boolean; analysis: RoomAnalysisData }>(
      '/ai/analyze-room',
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    )
    return response.data.analysis
  },

  async getRecommendations(payload: {
    room_type?: string
    style?: string
    dominant_colors?: string[]
    room_project_id?: number
  }): Promise<RecommendationResponseData> {
    const response = await api.post<RecommendationResponseData>(
      '/ai/recommendations',
      payload
    )
    return response.data
  },
}
