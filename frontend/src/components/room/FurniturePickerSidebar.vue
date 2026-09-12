<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { catalogService } from '@/services/catalogService'
import type { Furniture } from '@/types/furniture'
import type { Category } from '@/types/category'

defineProps<{
  roomType: string
}>()

defineEmits<{
  (e: 'add', furniture: Furniture): void
}>()

const isOpen = ref(true)
const searchQuery = ref('')
const selectedCategory = ref<string | null>(null)
const categories = ref<Category[]>([])
const furnitureList = ref<Furniture[]>([])
const loading = ref(false)

onMounted(async () => {
  try {
    categories.value = await catalogService.getCategories()
  } catch (err) {
    console.error('Failed to load categories in picker', err)
  }
  fetchFurniture()
})

async function fetchFurniture() {
  loading.value = true
  try {
    const res = await catalogService.getFurniture({
      search: searchQuery.value || undefined,
      category_slug: selectedCategory.value || undefined,
      per_page: 50,
    })
    furnitureList.value = res.data || []
  } catch (err) {
    console.error('Failed to fetch furniture in picker', err)
  } finally {
    loading.value = false
  }
}

// Debounced search
let searchTimer: any = null
watch(searchQuery, () => {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    fetchFurniture()
  }, 300)
})

watch(selectedCategory, () => {
  fetchFurniture()
})

const filteredCount = computed(() => furnitureList.value.length)
</script>

<template>
  <div class="relative flex h-full z-20">
    <!-- Main Drawer Content -->
    <div
      class="h-full bg-cream/95 backdrop-blur-md border-r border-light-border flex flex-col transition-all duration-300 shadow-card"
      :class="isOpen ? 'w-80 sm:w-88' : 'w-0 overflow-hidden border-none'"
    >
      <!-- Header -->
      <div class="p-4 border-b border-light-border space-y-3 shrink-0">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="text-lg">🛋️</span>
            <h2 class="font-display font-bold text-base text-forest">Furniture Catalog</h2>
          </div>
          <button
            type="button"
            class="p-1 rounded-lg text-muted-gray hover:text-charcoal hover:bg-off-white text-xs cursor-pointer"
            title="Collapse Sidebar"
            @click="isOpen = false"
          >
            ◀
          </button>
        </div>

        <!-- Search Input -->
        <div class="relative">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search sofas, tables, desks..."
            class="w-full px-3 py-2 pl-8 rounded-xl bg-off-white border border-light-border text-xs text-charcoal placeholder-muted-gray focus:outline-none focus:border-forest"
          />
          <span class="absolute left-2.5 top-2.5 text-muted-gray text-xs">🔍</span>
          <button
            v-if="searchQuery"
            type="button"
            class="absolute right-2.5 top-2 text-muted-gray hover:text-charcoal text-xs"
            @click="searchQuery = ''"
          >
            ✕
          </button>
        </div>

        <!-- Category Horizontal Scroll Pills -->
        <div class="flex items-center gap-1.5 overflow-x-auto pb-1 no-scrollbar text-xs">
          <button
            type="button"
            class="px-2.5 py-1 rounded-full text-[11px] font-medium shrink-0 transition-all cursor-pointer"
            :class="
              selectedCategory === null
                ? 'bg-forest text-cream font-semibold'
                : 'bg-off-white text-charcoal border border-light-border hover:border-warm-beige'
            "
            @click="selectedCategory = null"
          >
            All Items
          </button>
          <button
            v-for="cat in categories"
            :key="cat.id"
            type="button"
            class="px-2.5 py-1 rounded-full text-[11px] font-medium shrink-0 transition-all cursor-pointer"
            :class="
              selectedCategory === cat.slug
                ? 'bg-forest text-cream font-semibold'
                : 'bg-off-white text-charcoal border border-light-border hover:border-warm-beige'
            "
            @click="selectedCategory = cat.slug"
          >
            {{ cat.name }}
          </button>
        </div>
      </div>

      <!-- Furniture List -->
      <div class="flex-1 overflow-y-auto p-4 space-y-3">
        <div v-if="loading" class="py-12 text-center space-y-2">
          <div class="w-6 h-6 border-2 border-forest border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p class="text-xs font-mono text-muted-gray">Loading models...</p>
        </div>

        <div v-else-if="furnitureList.length === 0" class="py-12 text-center space-y-2">
          <p class="text-xs text-muted-gray">No furniture found matching criteria.</p>
        </div>

        <div
          v-else
          v-for="item in furnitureList"
          :key="item.id"
          class="p-3 rounded-2xl bg-off-white border border-light-border hover:border-warm-beige transition-all space-y-2.5 group shadow-subtle"
        >
          <div class="flex items-start gap-3">
            <!-- Thumbnail / Color Swatch -->
            <div
              class="w-14 h-14 rounded-xl shrink-0 overflow-hidden border border-light-border bg-cream flex items-center justify-center relative"
            >
              <img
                v-if="item.primary_image"
                :src="item.primary_image"
                :alt="item.name"
                class="w-full h-full object-cover"
                @error="(e: Event) => {
                  const target = e.target as HTMLImageElement;
                  target.style.display = 'none';
                  const fallback = target.nextElementSibling as HTMLElement;
                  if (fallback) fallback.style.display = 'block';
                }"
              />
              <div
                class="w-6 h-6 rounded-full border border-charcoal/20 shadow-sm"
                :style="{
                  backgroundColor: item.color_hex || '#A8A6A1',
                  display: item.primary_image ? 'none' : 'block'
                }"
              ></div>
              <span
                class="absolute bottom-0.5 right-0.5 text-[8px] font-mono px-1 rounded bg-dark-green text-cream"
              >
                1.000
              </span>
            </div>

            <!-- Details -->
            <div class="flex-1 min-w-0 space-y-0.5 text-left">
              <span class="text-[10px] font-mono uppercase text-muted-gray block truncate">
                {{ item.category?.name || 'Furniture' }}
              </span>
              <h4 class="font-display font-semibold text-xs text-forest truncate group-hover:text-dark-green">
                {{ item.name }}
              </h4>
              <p class="font-mono text-[11px] font-bold text-warm-beige">
                ₱{{ Number(item.price).toLocaleString() }}
              </p>
            </div>
          </div>

          <!-- Dimension Pill & Add Button -->
          <div class="flex items-center justify-between pt-1 border-t border-light-border/60">
            <span class="text-[10px] font-mono text-muted-gray">
              {{ item.dimensions?.width_cm }}W × {{ item.dimensions?.depth_cm }}D ×
              {{ item.dimensions?.height_cm }}H cm
            </span>

            <button
              type="button"
              class="px-2.5 py-1 rounded-lg bg-forest hover:bg-dark-green text-cream font-semibold text-[11px] transition-all cursor-pointer flex items-center gap-1 shadow-subtle"
              @click="$emit('add', item)"
            >
              <span>+</span>
              <span>Add</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Footer Info -->
      <div class="p-3 border-t border-light-border bg-cream text-[10px] font-mono text-muted-gray flex items-center justify-between">
        <span>{{ filteredCount }} items available</span>
        <span class="text-forest">Locked Scale 1.000</span>
      </div>
    </div>

    <!-- Toggle Button (when collapsed) -->
    <button
      v-if="!isOpen"
      type="button"
      class="absolute left-3 top-20 z-30 p-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs shadow-glow transition-all flex items-center gap-1.5 cursor-pointer"
      title="Open Furniture Catalog"
      @click="isOpen = true"
    >
      <span>🛋️</span>
      <span class="font-semibold hidden sm:inline">Add Furniture</span>
    </button>
  </div>
</template>
