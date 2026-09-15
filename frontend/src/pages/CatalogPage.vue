<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useCatalogStore } from '@/stores/catalog'
import CatalogFilterSidebar from '@/components/catalog/CatalogFilterSidebar.vue'
import CatalogSortBar from '@/components/catalog/CatalogSortBar.vue'
import CatalogActiveChips from '@/components/catalog/CatalogActiveChips.vue'
import FurnitureCard from '@/components/catalog/FurnitureCard.vue'
import Pagination from '@/components/common/Pagination.vue'

const route = useRoute()
const catalogStore = useCatalogStore()

const mobileFiltersOpen = ref(false)

onMounted(async () => {
  await Promise.all([
    catalogStore.fetchCategories(),
    catalogStore.fetchStyles(),
  ])

  // Sync route query params
  if (route.query.search) {
    catalogStore.filters.search = String(route.query.search)
  }
  if (route.query.category) {
    catalogStore.filters.category_slug = String(route.query.category)
  }
  if (route.query.style) {
    catalogStore.filters.style = String(route.query.style)
  }

  catalogStore.fetchFurniture()
})

// Watch route changes for search or category
watch(
  () => route.query,
  (query) => {
    if (query.search !== undefined) {
      catalogStore.filters.search = String(query.search || '')
    }
    if (query.category !== undefined) {
      catalogStore.filters.category_slug = String(query.category || '')
    }
    catalogStore.fetchFurniture()
  }
)

function onPageChange(page: number) {
  catalogStore.setPage(page)
  window.scrollTo({ top: 0, behavior: 'smooth' })
}
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
    
    <!-- Page Header -->
    <div class="space-y-1">
      <div class="flex items-center gap-2 text-xs font-mono text-muted-gray">
        <router-link to="/" class="hover:text-forest">Home</router-link>
        <span>/</span>
        <span class="text-forest font-semibold">Shop</span>
      </div>
      <h1 class="font-display font-bold text-3xl text-forest tracking-tight">Curated Furniture Collection</h1>
      <p class="text-xs text-muted-gray">
        Explore minimalist Scandinavian and Japanese designs with locked 1:1 scale specifications.
      </p>
    </div>

    <!-- Main Content: Two Columns -->
    <div class="grid grid-cols-1 lg:grid-cols-4 gap-8 items-start">
      
      <!-- Left Column: Desktop Filter Sidebar (Sticky) -->
      <div class="hidden lg:block lg:col-span-1 sticky top-24">
        <CatalogFilterSidebar />
      </div>

      <!-- Right Column: Catalog Grid & Controls -->
      <div class="lg:col-span-3 space-y-5">
        
        <!-- Sort and Controls Bar -->
        <CatalogSortBar @open-mobile-filters="mobileFiltersOpen = true" />

        <!-- Active Filter Chips Bar -->
        <CatalogActiveChips />

        <!-- Loading Skeletons -->
        <div v-if="catalogStore.loading" class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6">
          <div
            v-for="i in 6"
            :key="i"
            class="rounded-2xl bg-cream border border-light-border p-4 space-y-3 animate-pulse"
          >
            <div class="aspect-[4/3] rounded-xl bg-light-border/60"></div>
            <div class="h-4 bg-light-border/60 rounded w-3/4"></div>
            <div class="h-3 bg-light-border/60 rounded w-1/2"></div>
            <div class="h-8 bg-light-border/60 rounded"></div>
          </div>
        </div>

        <!-- Empty State -->
        <div
          v-else-if="catalogStore.furniture.length === 0"
          class="p-12 rounded-3xl bg-cream border border-light-border text-center space-y-4 my-8 shadow-card"
        >
          <div class="w-16 h-16 rounded-full bg-off-white border border-light-border flex items-center justify-center mx-auto text-forest text-2xl">
            📐
          </div>
          <div class="space-y-1">
            <h3 class="font-display font-bold text-lg text-forest">No Furniture Matches These Spatial Limits</h3>
            <p class="text-xs text-muted-gray max-w-md mx-auto leading-relaxed">
              No items in the catalog satisfy your exact combination of width, depth, height, and style filters. Try increasing your maximum dimensional bounds.
            </p>
          </div>
          <button
            type="button"
            class="px-5 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all cursor-pointer"
            @click="catalogStore.resetFilters()"
          >
            Reset All Filters
          </button>
        </div>

        <!-- Furniture Card Grid -->
        <div v-else class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6">
          <FurnitureCard
            v-for="item in catalogStore.furniture"
            :key="item.id"
            :furniture="item"
          />
        </div>

        <!-- Pagination -->
        <Pagination
          v-if="catalogStore.meta"
          :current-page="catalogStore.meta.current_page"
          :last-page="catalogStore.meta.last_page"
          :total="catalogStore.meta.total"
          :from="catalogStore.meta.from"
          :to="catalogStore.meta.to"
          @change-page="onPageChange"
        />

      </div>
    </div>

    <!-- Mobile Filters Slide-over / Modal -->
    <div
      v-if="mobileFiltersOpen"
      class="lg:hidden fixed inset-0 z-50 flex bg-charcoal/60 backdrop-blur-sm"
      @click="mobileFiltersOpen = false"
    >
      <div
        class="w-full max-w-xs h-full bg-off-white p-6 overflow-y-auto border-r border-light-border shadow-2xl"
        @click.stop
      >
        <CatalogFilterSidebar @close-mobile="mobileFiltersOpen = false" />
      </div>
    </div>

  </div>
</template>
