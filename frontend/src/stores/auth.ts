import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService } from '@/services/authService'
import type { User } from '@/types/auth'

function getStoredUser(): User | null {
  try {
    const raw = localStorage.getItem('smartspace_user')
    if (!raw || raw === 'undefined' || raw === 'null') {
      localStorage.removeItem('smartspace_user')
      return null
    }
    return JSON.parse(raw)
  } catch {
    localStorage.removeItem('smartspace_user')
    return null
  }
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('smartspace_token'))
  const user = ref<User | null>(getStoredUser())
  const loading = ref<boolean>(false)
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => !!token.value)
  const currentUser = computed(() => user.value)
  const userRole = computed(() => user.value?.role || 'customer')

  async function login(email: string, pass: string) {
    loading.value = true
    error.value = null
    try {
      const data = await authService.login(email, pass)
      token.value = data.token
      user.value = data.user
      localStorage.setItem('smartspace_token', data.token)
      if (data.user) {
        localStorage.setItem('smartspace_user', JSON.stringify(data.user))
      }
      return data
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Login failed. Please check your credentials.'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function register(name: string, email: string, pass: string, passConfirm?: string) {
    loading.value = true
    error.value = null
    try {
      const data = await authService.register(name, email, pass, passConfirm)
      token.value = data.token
      user.value = data.user
      localStorage.setItem('smartspace_token', data.token)
      localStorage.setItem('smartspace_user', JSON.stringify(data.user))
      return data
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Registration failed.'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    try {
      if (token.value) {
        await authService.logout()
      }
    } catch (err) {
      console.warn('Logout API failed, clearing local session anyway', err)
    } finally {
      token.value = null
      user.value = null
      localStorage.removeItem('smartspace_token')
      localStorage.removeItem('smartspace_user')
    }
  }

  async function fetchUser() {
    if (!token.value) return null
    try {
      const data = await authService.me()
      const fetchedUser: User = (data as any)?.user || data
      if (fetchedUser && fetchedUser.id) {
        user.value = fetchedUser
        localStorage.setItem('smartspace_user', JSON.stringify(fetchedUser))
        return fetchedUser
      }
      return null
    } catch (err) {
      token.value = null
      user.value = null
      localStorage.removeItem('smartspace_token')
      localStorage.removeItem('smartspace_user')
      return null
    }
  }

  return {
    token,
    user,
    loading,
    error,
    isAuthenticated,
    currentUser,
    userRole,
    login,
    register,
    logout,
    fetchUser,
  }
})
