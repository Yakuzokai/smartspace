export interface UserRole {
  id: number
  name: string
  slug: string
}

export interface User {
  id: number
  name: string
  email: string
  role?: string
  created_at?: string
}

export interface AuthResponse {
  message: string
  user: User
  token: string
}
