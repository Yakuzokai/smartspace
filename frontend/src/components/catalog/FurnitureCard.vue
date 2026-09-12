<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useFavoritesStore } from '@/stores/favorites'
import { useAuthStore } from '@/stores/auth'
import FurnitureImage from '@/components/common/FurnitureImage.vue'
import DimensionalBadge from '@/components/common/DimensionalBadge.vue'
import StockBadge from '@/components/common/StockBadge.vue'
import StyleBadge from '@/components/common/StyleBadge.vue'
import type { Furniture } from '@/types/furniture'

const props = defineProps<{
  furniture: Furniture
}>()

const router = useRouter()
const favoritesStore = useFavoritesStore()
const authStore = useAuthStore()

async function onToggleFavorite(e: Event) {
  e.stopPropagation()
  e.preventDefault()
  if (!authStore.isAuthenticated) {
    router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
    return
  }
  try {
    await favoritesStore.toggleFavorite(props.furniture)
  } catch (err) {
    console.error('Failed to toggle favorite', err)
  }
}

function navigateToDetail() {
  router.push({ name: 'product-detail', params: { id: props.furniture.id } })
}
</script>

<template>
  <div
    class="group relative flex flex-col rounded-2xl bg-cream border border-light-border hover:border-forest/50 overflow-hidden shadow-card transition-all duration-300 hover:-translate-y-1 hover:shadow-card-hover cursor-pointer"
    @click="navigateToDetail"
  >
    <!-- Top Image Container with Badges -->
    <div class="relative w-full overflow-hidden bg-off-white">
      <FurnitureImage
        :src="furniture.primary_image"
        :alt="furniture.name"
        :color-hex="furniture.color_hex"
        :category-name="furniture.category?.name"
        :dimensions="furniture.dimensions"
        aspect-ratio="aspect-[4/3]"
      />

      <!-- Floating Favorite Button -->
      <button
        type="button"
        class="absolute top-3 right-3 z-20 w-8 h-8 rounded-full flex items-center justify-center backdrop-blur-md transition-transform duration-200 hover:scale-110 shadow-subtle"
        :class="favoritesStore.isFavorite(furniture.id) ? 'bg-warm-beige text-forest shadow-glow-warm' : 'bg-cream/90 text-muted-gray hover:text-forest border border-light-border'"
        title="Toggle Favorite"
        @click="onToggleFavorite"
      >
        <i class="bi text-sm" :class="favoritesStore.isFavorite(furniture.id) ? 'bi-heart-fill' : 'bi-heart'"></i>
      </button>

      <!-- Style Badge Overlay -->
      <div class="absolute bottom-3 left-3 z-10">
        <StyleBadge :style-name="furniture.style" />
      </div>

      <!-- 3D Ready Indicator -->
      <div class="absolute bottom-3 right-3 z-10 px-2 py-0.5 rounded text-[10px] font-mono font-medium tracking-wider bg-cream/95 backdrop-blur-sm border border-light-border text-forest flex items-center gap-1 shadow-subtle">
        <i class="bi bi-box text-xs text-warm-beige"></i>
        <span>GLB 3D</span>
      </div>
    </div>

    <!-- Product Card Body -->
    <div class="flex-1 p-4 flex flex-col justify-between gap-3">
      
      <!-- Category & SKU -->
      <div>
        <div class="flex items-center justify-between text-[11px] font-mono text-muted-gray mb-1">
          <span>{{ furniture.category?.name || 'Furniture' }}</span>
          <span class="text-muted-gray/70">{{ furniture.sku }}</span>
        </div>

        <h3 class="font-display font-semibold text-charcoal text-sm group-hover:text-forest transition-colors line-clamp-1">
          {{ furniture.name }}
        </h3>

        <p class="text-xs text-muted-gray line-clamp-2 mt-1 leading-relaxed">
          {{ furniture.description }}
        </p>
      </div>

      <!-- Authoritative Physical Dimensions -->
      <div class="pt-2 border-t border-light-border flex flex-wrap items-center justify-between gap-2">
        <DimensionalBadge
          :width="furniture.dimensions.width_cm"
          :depth="furniture.dimensions.depth_cm"
          :height="furniture.dimensions.height_cm"
        />
        <StockBadge
          :status="furniture.availability?.status"
          :quantity="furniture.availability?.quantity"
        />
      </div>

      <!-- Price & Action Link -->
      <div class="pt-2 flex items-center justify-between">
        <div>
          <span class="text-[10px] uppercase font-mono text-muted-gray block">Price</span>
          <span class="font-display font-bold text-base text-warm-beige">
            ₱{{ furniture.price.toLocaleString() }}
          </span>
        </div>

        <span class="text-xs font-medium text-forest group-hover:text-dark-green flex items-center gap-1 group-hover:translate-x-0.5 transition-all">
          <span>View Specs</span>
          <i class="bi bi-arrow-right text-xs"></i>
        </span>
      </div>

    </div>
  </div>
</template>
