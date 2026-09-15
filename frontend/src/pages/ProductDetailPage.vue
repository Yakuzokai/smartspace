<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { catalogService } from '@/services/catalogService'
import { useFavoritesStore } from '@/stores/favorites'
import { useAuthStore } from '@/stores/auth'
import { useCartStore } from '@/stores/cart'
import ImageGallery from '@/components/detail/ImageGallery.vue'
import Product3DViewer from '@/components/detail/Product3DViewer.vue'
import SpatialSpecCard from '@/components/detail/SpatialSpecCard.vue'
import MilestoneActionBanner from '@/components/detail/MilestoneActionBanner.vue'
import StockBadge from '@/components/common/StockBadge.vue'
import StyleBadge from '@/components/common/StyleBadge.vue'
import type { Furniture } from '@/types/furniture'

const route = useRoute()
const router = useRouter()
const favoritesStore = useFavoritesStore()
const authStore = useAuthStore()
const cartStore = useCartStore()

const furniture = ref<Furniture | null>(null)
const loading = ref(true)
const error = ref<string | null>(null)
const visualMode = ref<'gallery' | '3d'>('gallery')
const quantity = ref(1)
const justAdded = ref(false)

function activate3D() {
  visualMode.value = '3d'
  window.scrollTo({ top: 120, behavior: 'smooth' })
}

async function loadProduct(id: string | number) {
  loading.value = true
  error.value = null
  try {
    furniture.value = await catalogService.getById(id)
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Furniture item not found.'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadProduct(route.params.id as string)
})

watch(
  () => route.params.id,
  (newId) => {
    if (newId) loadProduct(newId as string)
  }
)

async function toggleFavorite() {
  if (!furniture.value) return
  if (!authStore.isAuthenticated) {
    router.push({ name: 'login', query: { redirect: route.fullPath } })
    return
  }
  try {
    await favoritesStore.toggleFavorite(furniture.value)
  } catch (err) {
    console.error('Failed to toggle favorite', err)
  }
}

function handleAddToCart() {
  if (!furniture.value || furniture.value.availability?.status === 'out_of_stock') return
  cartStore.addItem(furniture.value, quantity.value, true)
  justAdded.value = true
  setTimeout(() => {
    justAdded.value = false
  }, 2000)
}

function handleBuyNow() {
  if (!furniture.value || furniture.value.availability?.status === 'out_of_stock') return
  cartStore.addItem(furniture.value, quantity.value, false)
  router.push({ name: 'checkout' })
}
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    
    <!-- Loading State -->
    <div v-if="loading" class="py-20 text-center space-y-4">
      <div class="w-12 h-12 rounded-full border-2 border-forest border-t-transparent animate-spin mx-auto"></div>
      <p class="text-xs font-mono text-muted-gray">Loading authoritative physical specs...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error || !furniture" class="p-12 rounded-3xl bg-cream border border-light-border shadow-card text-center space-y-4 my-12">
      <div class="w-16 h-16 rounded-full bg-rose-50 border border-rose-200 text-rose-600 flex items-center justify-center mx-auto text-2xl">
        ✕
      </div>
      <h2 class="font-display font-bold text-xl text-forest">Furniture Not Found</h2>
      <p class="text-xs text-muted-gray max-w-sm mx-auto">{{ error || 'The requested product does not exist in the catalog.' }}</p>
      <router-link to="/catalog" class="inline-block px-4 py-2 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-subtle transition-all">
        Return to Shop
      </router-link>
    </div>

    <!-- Product Detail Content -->
    <div v-else class="space-y-8">
      
      <!-- Breadcrumbs -->
      <nav class="flex items-center gap-2 text-xs font-mono text-muted-gray">
        <router-link to="/" class="hover:text-forest">Home</router-link>
        <span>/</span>
        <router-link to="/catalog" class="hover:text-forest">Shop</router-link>
        <span v-if="furniture.category">/</span>
        <router-link
          v-if="furniture.category"
          :to="{ path: '/catalog', query: { category: furniture.category.slug } }"
          class="hover:text-forest"
        >
          {{ furniture.category.name }}
        </router-link>
        <span>/</span>
        <span class="text-forest font-semibold truncate max-w-xs">{{ furniture.name }}</span>
      </nav>

      <!-- Main Layout: 2 Columns -->
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        
        <!-- Left Column (lg: 7 cols): Visual Mode Switcher, Images/3D & Milestone Action Banners -->
        <div class="lg:col-span-7 space-y-5">
          <!-- Visual Mode Switcher (Gallery vs Interactive 3D Model) -->
          <div class="flex items-center justify-between gap-3">
            <div class="flex items-center p-1 rounded-2xl bg-cream border border-light-border shadow-subtle text-xs font-medium">
              <button
                type="button"
                class="px-4 py-2 rounded-xl flex items-center gap-2 transition-all cursor-pointer"
                :class="visualMode === 'gallery' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
                @click="visualMode = 'gallery'"
              >
                <i class="bi bi-images"></i>
                <span>Photo Gallery</span>
              </button>

              <button
                type="button"
                class="px-4 py-2 rounded-xl flex items-center gap-2 transition-all cursor-pointer"
                :class="visualMode === '3d' ? 'bg-forest text-cream font-semibold shadow-subtle' : 'text-muted-gray hover:text-charcoal'"
                @click="visualMode = '3d'"
              >
                <i class="bi bi-box"></i>
                <span>Interactive 3D Model</span>
                <span class="w-1.5 h-1.5 rounded-full bg-warm-beige"></span>
              </button>
            </div>

            <!-- Certified Physical Scale Badge -->
            <div class="hidden sm:inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-cream border border-light-border text-[11px] font-mono text-forest shadow-subtle">
              <i class="bi bi-shield-check text-forest"></i>
              <span>1.000 Scale Locked</span>
            </div>
          </div>

          <!-- Mode 1: Photo Gallery -->
          <div v-show="visualMode === 'gallery'">
            <ImageGallery
              :images="furniture.images"
              :primary-image="furniture.primary_image"
              :furniture-name="furniture.name"
              :color-hex="furniture.color_hex"
              :category-name="furniture.category?.name"
              :dimensions="furniture.dimensions"
            />
          </div>

          <!-- Mode 2: Interactive Three.js 3D Viewer -->
          <div v-show="visualMode === '3d'">
            <Product3DViewer :furniture="furniture" />
          </div>

          <!-- Milestone Action Banners (Bridge to 3D & Room Planning) -->
          <MilestoneActionBanner :furniture="furniture" @view3d="activate3D" />
        </div>

        <!-- Right Column (lg: 5 cols): Specs, Pricing, Purchase CTAs -->
        <div class="lg:col-span-5 space-y-6">
          
          <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-5">
            
            <!-- Category, SKU & Style -->
            <div class="flex items-center justify-between gap-2">
              <div class="flex items-center gap-2">
                <span class="text-xs font-mono text-muted-gray uppercase tracking-wider">
                  {{ furniture.category?.name || 'Furniture' }}
                </span>
                <span class="text-light-border font-mono text-xs">•</span>
                <span class="text-xs font-mono text-muted-gray">{{ furniture.sku }}</span>
              </div>
              <StyleBadge :style-name="furniture.style" />
            </div>

            <!-- Title -->
            <h1 class="font-display font-bold text-2xl sm:text-3xl text-forest tracking-tight leading-snug">
              {{ furniture.name }}
            </h1>

            <!-- Price & Stock Strip -->
            <div class="flex items-center justify-between py-3.5 border-y border-light-border">
              <div>
                <span class="text-[10px] font-mono uppercase text-muted-gray block">Price (Tax Incl.)</span>
                <span class="font-display font-extrabold text-3xl text-forest">
                  ₱{{ furniture.price.toLocaleString() }}
                </span>
              </div>
              <StockBadge
                :status="furniture.availability?.status"
                :quantity="furniture.availability?.quantity"
              />
            </div>

            <!-- Material & Color Swatch -->
            <div class="grid grid-cols-2 gap-3 text-xs">
              <div class="p-3.5 rounded-xl bg-off-white border border-light-border space-y-1 shadow-subtle">
                <span class="text-muted-gray text-[11px] block">Material</span>
                <span class="text-charcoal font-medium">{{ furniture.material }}</span>
              </div>
              <div class="p-3.5 rounded-xl bg-off-white border border-light-border space-y-1 shadow-subtle">
                <span class="text-muted-gray text-[11px] block">Color Finish</span>
                <div class="flex items-center gap-2">
                  <span
                    class="w-3.5 h-3.5 rounded-full border border-light-border shadow-sm shrink-0"
                    :style="{ backgroundColor: furniture.color_hex }"
                  ></span>
                  <span class="text-charcoal font-medium truncate">{{ furniture.color }}</span>
                </div>
              </div>
            </div>

            <!-- Description -->
            <div class="space-y-1">
              <span class="text-xs font-semibold text-forest">Design Overview</span>
              <p class="text-xs text-muted-gray leading-relaxed">
                {{ furniture.description }}
              </p>
            </div>

            <!-- E-Commerce Purchasing Block -->
            <div class="pt-3 border-t border-light-border space-y-3">
              <!-- Quantity Stepper -->
              <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-charcoal">Quantity</span>
                <div class="flex items-center border border-light-border rounded-xl bg-off-white overflow-hidden text-xs">
                  <button
                    type="button"
                    class="w-9 h-9 flex items-center justify-center text-charcoal hover:bg-cream transition-colors cursor-pointer"
                    :disabled="quantity <= 1"
                    @click="quantity = Math.max(1, quantity - 1)"
                  >
                    −
                  </button>
                  <span class="w-10 text-center font-mono font-semibold text-charcoal">{{ quantity }}</span>
                  <button
                    type="button"
                    class="w-9 h-9 flex items-center justify-center text-charcoal hover:bg-cream transition-colors cursor-pointer"
                    @click="quantity++"
                  >
                    +
                  </button>
                </div>
              </div>

              <!-- Main Purchase CTAs -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5 pt-1">
                <button
                  type="button"
                  :disabled="furniture.availability?.status === 'out_of_stock'"
                  class="w-full py-3.5 px-4 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-glow transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
                  @click="handleAddToCart"
                >
                  <i class="bi" :class="justAdded ? 'bi-check2' : 'bi-bag-plus'"></i>
                  <span>{{ justAdded ? 'Added to Bag!' : 'Add to Bag' }}</span>
                </button>

                <button
                  type="button"
                  :disabled="furniture.availability?.status === 'out_of_stock'"
                  class="w-full py-3.5 px-4 rounded-xl bg-warm-beige hover:bg-warm-beige-hover text-forest font-semibold text-xs shadow-glow-warm transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
                  @click="handleBuyNow"
                >
                  <span>Buy Now</span>
                  <i class="bi bi-arrow-right text-xs"></i>
                </button>
              </div>

              <!-- Secondary Actions (Wishlist) -->
              <div class="pt-1">
                <button
                  type="button"
                  class="w-full py-2.5 px-4 rounded-xl border border-light-border hover:border-forest text-charcoal hover:text-forest bg-off-white text-xs font-medium transition-all flex items-center justify-center gap-2 cursor-pointer"
                  @click="toggleFavorite"
                >
                  <i
                    class="text-sm"
                    :class="favoritesStore.isFavorite(furniture.id) ? 'bi bi-heart-fill text-rose-500' : 'bi bi-heart text-muted-gray'"
                  ></i>
                  <span>{{ favoritesStore.isFavorite(furniture.id) ? 'Saved to Wishlist' : 'Add to Wishlist' }}</span>
                </button>
              </div>

              <!-- Value Props & Guarantee Strip -->
              <div class="pt-3 border-t border-light-border grid grid-cols-2 gap-2 text-[11px] text-muted-gray">
                <div class="flex items-center gap-1.5">
                  <i class="bi bi-truck text-forest"></i>
                  <span>Free delivery ₱5,000+</span>
                </div>
                <div class="flex items-center gap-1.5">
                  <i class="bi bi-arrow-counterclockwise text-forest"></i>
                  <span>30-Day In-Home Trial</span>
                </div>
                <div class="flex items-center gap-1.5">
                  <i class="bi bi-rulers text-forest"></i>
                  <span>1.000 Scale Guaranteed</span>
                </div>
                <div class="flex items-center gap-1.5">
                  <i class="bi bi-shield-check text-forest"></i>
                  <span>5-Year Warranty</span>
                </div>
              </div>

            </div>

          </div>

          <!-- Authoritative Physical Specifications Card -->
          <SpatialSpecCard
            :dimensions="furniture.dimensions"
            :clearance-envelope="furniture.clearance_envelope"
          />

        </div>

      </div>

    </div>

  </div>
</template>
