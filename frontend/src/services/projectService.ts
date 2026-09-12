import api from './api'
import type { ApiResponse } from '@/types/api'
import type { RoomProject, CreateProjectPayload } from '@/types/project'

export interface UpdateLayoutPayload {
  items: Array<{
    furniture_id: number
    position_x: number
    position_y?: number
    position_z: number
    rotation_y?: number
  }>
}

function normalizeProject(raw: any): RoomProject {
  const dims = raw.dimensions || {}
  const width_cm = Number(raw.width_cm ?? dims.width_cm ?? 400)
  const length_cm = Number(raw.length_cm ?? dims.length_cm ?? 500)
  const height_cm = Number(raw.height_cm ?? dims.height_cm ?? 280)
  const room_area_sqm = Number(raw.room_area_sqm ?? dims.floor_area_sqm ?? Math.round((width_cm * length_cm) / 100) / 100)
  const rawPlacements = raw.furniture_placements || raw.placements || []

  // Ensure placements have furniture object populated
  const placements = rawPlacements.map((p: any) => ({
    ...p,
    uuid: p.uuid || `inst_${p.id ?? p.furniture_id}_${Math.random().toString(36).substring(2, 7)}`,
    status: p.status || 'valid',
    furniture: p.furniture || {
      id: p.furniture_id,
      sku: p.sku || `SKU-${p.furniture_id}`,
      name: p.name || 'Furniture Item',
      dimensions: {
        width_m: p.dimensions?.width_m ?? 1.0,
        height_m: p.dimensions?.height_m ?? 0.8,
        depth_m: p.dimensions?.depth_m ?? 0.8,
        width_cm: Math.round((p.dimensions?.width_m ?? 1.0) * 100),
        height_cm: Math.round((p.dimensions?.height_m ?? 0.8) * 100),
        depth_cm: Math.round((p.dimensions?.depth_m ?? 0.8) * 100),
        footprint_area_sqm: (p.dimensions?.width_m ?? 1.0) * (p.dimensions?.depth_m ?? 0.8),
      },
      model_3d: { path: p.model_path, format: 'glb', file_size_mb: 1.0, draco_compressed: true },
      price: p.price ?? 0,
      color_hex: p.color_hex || '#A8A6A1',
      category: p.category_slug ? { id: 1, name: p.category_slug, slug: p.category_slug } : null,
    },
  }))

  return {
    ...raw,
    width_cm,
    length_cm,
    height_cm,
    room_area_sqm,
    placements,
    dimensions: dims,
  }
}

export const projectService = {
  async getProjects(): Promise<RoomProject[]> {
    const response = await api.get<ApiResponse<any[]>>('/room-projects')
    return response.data.data.map(normalizeProject)
  },

  async getProject(id: number | string): Promise<RoomProject> {
    const response = await api.get<ApiResponse<any>>(`/room-projects/${id}`)
    return normalizeProject(response.data.data)
  },

  async createProject(payload: CreateProjectPayload): Promise<RoomProject> {
    const response = await api.post<ApiResponse<any>>('/room-projects', payload)
    return normalizeProject(response.data.data)
  },

  async updateLayout(id: number | string, payload: UpdateLayoutPayload): Promise<RoomProject> {
    const response = await api.put<ApiResponse<any>>(`/room-projects/${id}/layout`, payload)
    return normalizeProject(response.data.data)
  },

  async validateLayout(id: number | string): Promise<{ project_id: number; evaluation: any }> {
    const response = await api.post<{ project_id: number; evaluation: any }>(`/room-projects/${id}/validate`)
    return response.data
  },

  async deleteProject(id: number | string): Promise<void> {
    await api.delete(`/room-projects/${id}`)
  },
}
