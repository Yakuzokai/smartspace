import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { favoriteService } from '@/services/favoriteService'
import { useAuthStore } from './auth'
import type { Furniture } from '@/types/furniture'

export const useFavoritesStore = defineStore('favorites', () => {
  const favorites = ref<Furniture[]>([])
  const favoriteIds = ref<Set<number>>(new Set())
  const loading = ref<boolean>(false)

  const count = computed(() => favoriteIds.value.size)

  function isFavorite(id: number): boolean {
    return favoriteIds.value.has(id)
  }

  async function fetchFavorites() {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) return

    loading.value = true
    try {
      const items = await favoriteService.getFavorites()
      favorites.value = items
      favoriteIds.value = new Set(items.map(item => item.id))
    } catch (err) {
      console.error('Failed to load favorites', err)
    } finally {
      loading.value = false
    }
  }

  async function toggleFavorite(item: Furniture) {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) {
      throw new Error('AUTH_REQUIRED')
    }

    const wasFavorited = isFavorite(item.id)

    // Optimistic UI update
    if (wasFavorited) {
      favoriteIds.value.delete(item.id)
      favorites.value = favorites.value.filter(f => f.id !== item.id)
    } else {
      favoriteIds.value.add(item.id)
      favorites.value.unshift(item)
    }

    try {
      const result = await favoriteService.toggleFavorite(item.id)
      if (result.favorited) {
        favoriteIds.value.add(item.id)
      } else {
        favoriteIds.value.delete(item.id)
      }
    } catch (err) {
      // Rollback on error
      if (wasFavorited) {
        favoriteIds.value.add(item.id)
        if (!favorites.value.some(f => f.id === item.id)) {
          favorites.value.unshift(item)
        }
      } else {
        favoriteIds.value.delete(item.id)
        favorites.value = favorites.value.filter(f => f.id !== item.id)
      }
      throw err
    }
  }

  return {
    favorites,
    favoriteIds,
    count,
    loading,
    isFavorite,
    fetchFavorites,
    toggleFavorite,
  }
})
