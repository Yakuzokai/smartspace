<script setup lang="ts">
import { computed } from 'vue'
import { useCatalogStore } from '@/stores/catalog'

const catalogStore = useCatalogStore()

const activeChips = computed(() => {
  const chips: Array<{ id: string; label: string; clear: () => void }> = []
  const f = catalogStore.filters

  if (f.search) {
    chips.push({
      id: 'search',
      label: `Search: "${f.search}"`,
      clear: () => catalogStore.setFilter('search', ''),
    })
  }

  if (f.category_slug) {
    chips.push({
      id: 'category',
      label: `Category: ${f.category_slug}`,
      clear: () => catalogStore.setFilter('category_slug', ''),
    })
  }

  if (f.style) {
    chips.push({
      id: 'style',
      label: `Style: ${f.style}`,
      clear: () => catalogStore.setFilter('style', ''),
    })
  }

  if (f.material) {
    chips.push({
      id: 'material',
      label: `Material: ${f.material}`,
      clear: () => catalogStore.setFilter('material', ''),
    })
  }

  if (f.max_width_cm) {
    chips.push({
      id: 'max_width',
      label: `Width ≤ ${f.max_width_cm} cm`,
      clear: () => catalogStore.setFilter('max_width_cm', undefined),
    })
  }

  if (f.max_depth_cm) {
    chips.push({
      id: 'max_depth',
      label: `Depth ≤ ${f.max_depth_cm} cm`,
      clear: () => catalogStore.setFilter('max_depth_cm', undefined),
    })
  }

  if (f.max_height_cm) {
    chips.push({
      id: 'max_height',
      label: `Height ≤ ${f.max_height_cm} cm`,
      clear: () => catalogStore.setFilter('max_height_cm', undefined),
    })
  }

  if (f.price_min || f.price_max) {
    const min = f.price_min ? `₱${f.price_min}` : '₱0'
    const max = f.price_max ? `₱${f.price_max}` : 'Any'
    chips.push({
      id: 'price',
      label: `Price: ${min} - ${max}`,
      clear: () => {
        catalogStore.filters.price_min = undefined
        catalogStore.filters.price_max = undefined
        catalogStore.fetchFurniture()
      },
    })
  }

  return chips
})
</script>

<template>
  <div v-if="activeChips.length > 0" class="flex flex-wrap items-center gap-2 py-1">
    <span class="text-xs text-muted-gray font-mono">Active Filters:</span>
    
    <div
      v-for="chip in activeChips"
      :key="chip.id"
      class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-cream border border-light-border text-charcoal shadow-subtle"
    >
      <span>{{ chip.label }}</span>
      <button
        type="button"
        class="text-muted-gray hover:text-rose-600 text-xs transition-colors cursor-pointer"
        @click="chip.clear()"
      >
        ✕
      </button>
    </div>

    <button
      type="button"
      class="text-xs text-forest hover:text-dark-green underline font-semibold ml-2 cursor-pointer"
      @click="catalogStore.resetFilters()"
    >
      Clear All
    </button>
  </div>
</template>
