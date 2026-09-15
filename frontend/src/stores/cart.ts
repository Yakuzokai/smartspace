import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { Furniture } from '@/types/furniture'

export interface CartItem {
  id: number
  sku: string
  name: string
  price: number
  quantity: number
  primary_image?: string | null
  category_name?: string
  color: string
  color_hex: string
  material: string
  dimensions: {
    width_cm: number
    height_cm: number
    depth_cm: number
  }
}

const STORAGE_KEY = 'smartspace_cart'

export const useCartStore = defineStore('cart', () => {
  // Load initial items from localStorage
  const items = ref<CartItem[]>(loadPersistedCart())
  const isDrawerOpen = ref(false)
  const lastAddedItem = ref<CartItem | null>(null)
  const showToast = ref(false)
  let toastTimer: ReturnType<typeof setTimeout> | null = null

  function loadPersistedCart(): CartItem[] {
    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      if (raw) {
        const parsed = JSON.parse(raw)
        if (Array.isArray(parsed)) {
          return parsed
        }
      }
    } catch (e) {
      console.error('Failed to load cart from localStorage', e)
    }
    return []
  }

  function persist() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(items.value))
    } catch (e) {
      console.error('Failed to persist cart to localStorage', e)
    }
  }

  // Getters
  const count = computed(() => {
    return items.value.reduce((sum, item) => sum + item.quantity, 0)
  })

  const subtotal = computed(() => {
    return items.value.reduce((sum, item) => sum + item.price * item.quantity, 0)
  })

  const freeDeliveryThreshold = 5000

  const isFreeDelivery = computed(() => {
    return subtotal.value >= freeDeliveryThreshold
  })

  const amountToFreeDelivery = computed(() => {
    return Math.max(0, freeDeliveryThreshold - subtotal.value)
  })

  const freeDeliveryProgress = computed(() => {
    if (subtotal.value <= 0) return 0
    return Math.min(100, Math.round((subtotal.value / freeDeliveryThreshold) * 100))
  })

  const shippingFee = computed(() => {
    if (items.value.length === 0) return 0
    return isFreeDelivery.value ? 0 : 350
  })

  const estimatedTotal = computed(() => {
    return subtotal.value + shippingFee.value
  })

  function isInCart(furnitureId: number): boolean {
    return items.value.some((item) => item.id === furnitureId)
  }

  function getItemQuantity(furnitureId: number): number {
    const found = items.value.find((item) => item.id === furnitureId)
    return found ? found.quantity : 0
  }

  // Actions
  function addItem(furniture: Furniture, quantity = 1, openDrawerImmediately = true) {
    if (quantity <= 0) return

    const existingIndex = items.value.findIndex((item) => item.id === furniture.id)

    if (existingIndex > -1) {
      items.value[existingIndex].quantity += quantity
      lastAddedItem.value = items.value[existingIndex]
    } else {
      const newItem: CartItem = {
        id: furniture.id,
        sku: furniture.sku,
        name: furniture.name,
        price: furniture.price,
        quantity,
        primary_image: furniture.primary_image,
        category_name: furniture.category?.name,
        color: furniture.color,
        color_hex: furniture.color_hex,
        material: furniture.material,
        dimensions: {
          width_cm: furniture.dimensions.width_cm,
          height_cm: furniture.dimensions.height_cm,
          depth_cm: furniture.dimensions.depth_cm,
        },
      }
      items.value.unshift(newItem)
      lastAddedItem.value = newItem
    }

    persist()

    // Trigger toast notification
    showToast.value = true
    if (toastTimer) clearTimeout(toastTimer)
    toastTimer = setTimeout(() => {
      showToast.value = false
    }, 3000)

    if (openDrawerImmediately) {
      isDrawerOpen.value = true
    }
  }

  function updateQuantity(furnitureId: number, quantity: number) {
    if (quantity <= 0) {
      removeItem(furnitureId)
      return
    }

    const item = items.value.find((i) => i.id === furnitureId)
    if (item) {
      item.quantity = quantity
      persist()
    }
  }

  function removeItem(furnitureId: number) {
    items.value = items.value.filter((i) => i.id !== furnitureId)
    persist()
  }

  function clearCart() {
    items.value = []
    try {
      localStorage.removeItem(STORAGE_KEY)
    } catch (e) {
      console.error('Failed to clear cart storage', e)
    }
  }

  function openDrawer() {
    isDrawerOpen.value = true
  }

  function closeDrawer() {
    isDrawerOpen.value = false
  }

  function toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value
  }

  return {
    items,
    isDrawerOpen,
    lastAddedItem,
    showToast,
    count,
    subtotal,
    freeDeliveryThreshold,
    isFreeDelivery,
    amountToFreeDelivery,
    freeDeliveryProgress,
    shippingFee,
    estimatedTotal,
    isInCart,
    getItemQuantity,
    addItem,
    updateQuantity,
    removeItem,
    clearCart,
    openDrawer,
    closeDrawer,
    toggleDrawer,
  }
})
