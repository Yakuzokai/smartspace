<script setup lang="ts">
import { useCatalogStore } from '@/stores/catalog'

const emit = defineEmits<{
  (e: 'openMobileFilters'): void
}>()

const catalogStore = useCatalogStore()

const sortOptions = [
  { value: 'newest', label: 'Newest Arrivals' },
  { value: 'price_asc', label: 'Price: Low to High' },
  { value: 'price_desc', label: 'Price: High to Low' },
  { value: 'width_asc', label: 'Width: Compact First' },
  { value: 'width_desc', label: 'Width: Wide First' },
  { value: 'name_asc', label: 'Name: A to Z' },
]

function onSortChange(e: Event) {
  const select = e.target as HTMLSelectElement
  catalogStore.setFilter('sort_by', select.value as any)
}
</script>

<template>
  <div class="flex flex-wrap items-center justify-between gap-4 p-3.5 rounded-xl bg-cream border border-light-border shadow-subtle">
    
    <!-- Left: Results count & Mobile filter toggle -->
    <div class="flex items-center gap-3">
      <!-- Mobile Filter Button -->
      <button
        type="button"
        class="lg:hidden inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-off-white border border-light-border text-xs font-medium text-charcoal hover:border-forest"
        @click="emit('openMobileFilters')"
      >
        <i class="bi bi-sliders text-forest"></i>
        <span>Filters</span>
      </button>

      <span class="text-xs text-muted-gray font-mono">
        <span class="text-charcoal font-semibold">{{ catalogStore.meta?.total ?? catalogStore.furniture.length }}</span> pieces found
      </span>
    </div>

    <!-- Right: Sort Dropdown -->
    <div class="flex items-center gap-2">
      <label for="catalog-sort" class="text-xs text-muted-gray">Sort by:</label>
      <select
        id="catalog-sort"
        :value="catalogStore.filters.sort_by || 'newest'"
        class="px-3 py-1.5 rounded-lg bg-off-white border border-light-border text-xs text-charcoal font-medium focus:outline-none focus:border-forest cursor-pointer"
        @change="onSortChange"
      >
        <option v-for="opt in sortOptions" :key="opt.value" :value="opt.value">
          {{ opt.label }}
        </option>
      </select>
    </div>

  </div>
</template>
