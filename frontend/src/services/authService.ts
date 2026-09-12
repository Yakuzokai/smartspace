import api from './api'
import type { AuthResponse, User } from '@/types/auth'

export const authService = {
  async register(name: string, email: string, password: string, password_confirmation?: string): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/register', {
      name,
      email,
      password,
      password_confirmation: password_confirmation || password,
    })
    return response.data
  },

  async login(email: string, password: string): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/login', {
      email,
      password,
    })
    return response.data
  },

  async me(): Promise<User> {
    const response = await api.get<any>('/auth/me')
    return response.data?.user || response.data
  },

  async logout(): Promise<{ message: string }> {
    const response = await api.post<{ message: string }>('/auth/logout')
    return response.data
  },
}
