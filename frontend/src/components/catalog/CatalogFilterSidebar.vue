<script setup lang="ts">
import { ref, watch } from 'vue'
import { useCatalogStore } from '@/stores/catalog'

const emit = defineEmits<{
  (e: 'closeMobile'): void
}>()

const catalogStore = useCatalogStore()

// Local models for dimensional sliders with debounce/apply
const localMaxWidth = ref<number | undefined>(catalogStore.filters.max_width_cm)
const localMaxDepth = ref<number | undefined>(catalogStore.filters.max_depth_cm)
const localMaxHeight = ref<number | undefined>(catalogStore.filters.max_height_cm)

const localPriceMin = ref<number | undefined>(catalogStore.filters.price_min)
const localPriceMax = ref<number | undefined>(catalogStore.filters.price_max)

// Synchronize local states if reset occurs
watch(
  () => catalogStore.filters,
  (f) => {
    localMaxWidth.value = f.max_width_cm
    localMaxDepth.value = f.max_depth_cm
    localMaxHeight.value = f.max_height_cm
    localPriceMin.value = f.price_min
    localPriceMax.value = f.price_max
  },
  { deep: true }
)

function applyDimensions() {
  catalogStore.filters.max_width_cm = localMaxWidth.value ? Number(localMaxWidth.value) : undefined
  catalogStore.filters.max_depth_cm = localMaxDepth.value ? Number(localMaxDepth.value) : undefined
  catalogStore.filters.max_height_cm = localMaxHeight.value ? Number(localMaxHeight.value) : undefined
  catalogStore.filters.page = 1
  catalogStore.fetchFurniture()
}

function applyPrice() {
  catalogStore.filters.price_min = localPriceMin.value ? Number(localPriceMin.value) : undefined
  catalogStore.filters.price_max = localPriceMax.value ? Number(localPriceMax.value) : undefined
  catalogStore.filters.page = 1
  catalogStore.fetchFurniture()
}

function selectCategory(slug: string) {
  if (catalogStore.filters.category_slug === slug) {
    catalogStore.setFilter('category_slug', '')
  } else {
    catalogStore.setFilter('category_slug', slug)
  }
}

function selectStyle(styleName: string) {
  if (catalogStore.filters.style === styleName) {
    catalogStore.setFilter('style', '')
  } else {
    catalogStore.setFilter('style', styleName)
  }
}

function selectMaterial(mat: string) {
  if (catalogStore.filters.material === mat) {
    catalogStore.setFilter('material', '')
  } else {
    catalogStore.setFilter('material', mat)
  }
}

const materials = ['Wood', 'Fabric', 'Leather', 'Metal', 'Glass', 'Marble', 'Steel', 'Oak', 'Walnut']

const expandedCategories = ref<Record<number, boolean>>({
  1: true,
  6: true,
  9: true,
  11: true,
})

function toggleCategoryAccordion(id: number) {
  expandedCategories.value[id] = !expandedCategories.value[id]
}
</script>

<template>
  <aside class="w-full space-y-6 text-charcoal">
    
    <!-- Top Filter Header -->
    <div class="flex items-center justify-between pb-3 border-b border-light-border">
      <div class="flex items-center gap-2">
        <i class="bi bi-sliders text-forest"></i>
        <h2 class="font-display font-semibold text-sm text-forest">Filters</h2>
      </div>

      <div class="flex items-center gap-2">
        <button
          type="button"
          class="text-xs text-forest hover:text-dark-green underline font-semibold transition-colors cursor-pointer"
          @click="catalogStore.resetFilters()"
        >
          Reset
        </button>
        <!-- Mobile close button -->
        <button
          type="button"
          class="lg:hidden p-1 rounded text-muted-gray hover:text-charcoal"
          @click="emit('closeMobile')"
        >
          <i class="bi bi-x-lg text-sm"></i>
        </button>
      </div>
    </div>

    <!-- 1. SPATIAL GEOMETRY FILTERS (Authoritative Dimensional Constraints) -->
    <div class="p-4 rounded-2xl bg-cream border border-light-border space-y-3.5 shadow-subtle">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-1.5 text-xs font-semibold text-forest">
          <i class="bi bi-aspect-ratio text-forest"></i>
          <span>Max Spatial Bounds (cm)</span>
        </div>
        <span class="text-[10px] font-mono text-forest/80 uppercase font-semibold">Fit Engine</span>
      </div>
      <p class="text-[11px] text-muted-gray leading-relaxed">
        Filter furniture pieces guaranteed to fit inside your measured clearance gaps.
      </p>

      <div class="space-y-3 pt-1">
        <!-- Max Width Slider / Input -->
        <div class="space-y-1">
          <div class="flex justify-between text-xs font-mono">
            <span class="text-muted-gray">Max Width (W):</span>
            <span class="text-charcoal font-semibold">{{ localMaxWidth ? `${localMaxWidth} cm` : 'Any' }}</span>
          </div>
          <div class="flex items-center gap-2">
            <input
              v-model.number="localMaxWidth"
              type="range"
              min="40"
              max="280"
              step="5"
              class="w-full accent-forest bg-light-border rounded-lg h-1.5 cursor-pointer"
              @change="applyDimensions"
            />
            <button
              v-if="localMaxWidth"
              type="button"
              class="text-muted-gray hover:text-charcoal text-xs px-1 font-mono"
              @click="localMaxWidth = undefined; applyDimensions()"
            >
              ✕
            </button>
          </div>
        </div>

        <!-- Max Depth Slider / Input -->
        <div class="space-y-1">
          <div class="flex justify-between text-xs font-mono">
            <span class="text-muted-gray">Max Depth (D):</span>
            <span class="text-charcoal font-semibold">{{ localMaxDepth ? `${localMaxDepth} cm` : 'Any' }}</span>
          </div>
          <div class="flex items-center gap-2">
            <input
              v-model.number="localMaxDepth"
              type="range"
              min="30"
              max="220"
              step="5"
              class="w-full accent-forest bg-light-border rounded-lg h-1.5 cursor-pointer"
              @change="applyDimensions"
            />
            <button
              v-if="localMaxDepth"
              type="button"
              class="text-muted-gray hover:text-charcoal text-xs px-1 font-mono"
              @click="localMaxDepth = undefined; applyDimensions()"
            >
              ✕
            </button>
          </div>
        </div>

        <!-- Max Height Slider / Input -->
        <div class="space-y-1">
          <div class="flex justify-between text-xs font-mono">
            <span class="text-muted-gray">Max Height (H):</span>
            <span class="text-charcoal font-semibold">{{ localMaxHeight ? `${localMaxHeight} cm` : 'Any' }}</span>
          </div>
          <div class="flex items-center gap-2">
            <input
              v-model.number="localMaxHeight"
              type="range"
              min="30"
              max="220"
              step="5"
              class="w-full accent-forest bg-light-border rounded-lg h-1.5 cursor-pointer"
              @change="applyDimensions"
            />
            <button
              v-if="localMaxHeight"
              type="button"
              class="text-muted-gray hover:text-charcoal text-xs px-1 font-mono"
              @click="localMaxHeight = undefined; applyDimensions()"
            >
              ✕
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 2. CATEGORIES TREE -->
    <div class="space-y-2.5">
      <h3 class="text-xs font-semibold uppercase tracking-wider text-forest">Categories</h3>
      
      <div class="space-y-1">
        <div
          v-for="cat in catalogStore.categories"
          :key="cat.id"
          class="rounded-xl overflow-hidden border border-light-border bg-cream"
        >
          <!-- Root Category Header -->
          <div
            class="w-full flex items-center justify-between px-3.5 py-2 text-xs font-medium cursor-pointer transition-colors"
            :class="catalogStore.filters.category_slug === cat.slug ? 'text-forest bg-warm-beige/25 font-bold' : 'text-charcoal hover:bg-off-white'"
            @click="selectCategory(cat.slug)"
          >
            <span>{{ cat.name }}</span>
            <button
              v-if="cat.subcategories?.length"
              type="button"
              class="p-1 text-muted-gray hover:text-charcoal"
              @click.stop="toggleCategoryAccordion(cat.id)"
            >
              <i
                class="bi bi-chevron-down text-xs transition-transform duration-200 inline-block"
                :class="expandedCategories[cat.id] ? 'rotate-180' : ''"
              ></i>
            </button>
          </div>

          <!-- Subcategories List -->
          <div
            v-if="expandedCategories[cat.id] && cat.subcategories?.length"
            class="px-2 pb-2 pt-0.5 space-y-0.5 border-t border-light-border bg-off-white/60"
          >
            <button
              v-for="sub in cat.subcategories"
              :key="sub.id"
              type="button"
              class="w-full flex items-center justify-between px-3 py-1.5 rounded-lg text-[11px] transition-colors"
              :class="catalogStore.filters.category_slug === sub.slug ? 'text-forest bg-warm-beige/30 font-bold' : 'text-muted-gray hover:text-charcoal hover:bg-cream'"
              @click="selectCategory(sub.slug)"
            >
              <span>{{ sub.name }}</span>
              <span class="font-mono text-[10px] text-muted-gray bg-cream px-1.5 py-0.5 rounded border border-light-border">
                {{ sub.furniture_count }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 3. INTERIOR STYLE PILLS -->
    <div class="space-y-2.5">
      <h3 class="text-xs font-semibold uppercase tracking-wider text-forest">Interior Style</h3>
      <div class="flex flex-wrap gap-1.5">
        <button
          v-for="style in catalogStore.styles"
          :key="style"
          type="button"
          class="px-2.5 py-1 rounded-lg text-xs capitalize font-medium transition-all"
          :class="catalogStore.filters.style === style ? 'bg-forest text-cream shadow-glow border border-forest font-semibold' : 'bg-cream border border-light-border text-charcoal hover:border-forest/40'"
          @click="selectStyle(style)"
        >
          {{ style }}
        </button>
      </div>
    </div>

    <!-- 4. MATERIAL FILTERS -->
    <div class="space-y-2.5">
      <h3 class="text-xs font-semibold uppercase tracking-wider text-forest">Material</h3>
      <div class="flex flex-wrap gap-1.5">
        <button
          v-for="mat in materials"
          :key="mat"
          type="button"
          class="px-2.5 py-1 rounded-lg text-xs font-medium transition-all"
          :class="catalogStore.filters.material === mat ? 'bg-warm-beige text-forest font-bold shadow-subtle' : 'bg-cream border border-light-border text-charcoal hover:border-forest/40'"
          @click="selectMaterial(mat)"
        >
          {{ mat }}
        </button>
      </div>
    </div>

    <!-- 5. PRICE RANGE -->
    <div class="space-y-2.5">
      <h3 class="text-xs font-semibold uppercase tracking-wider text-forest">Price Range (₱)</h3>
      <div class="grid grid-cols-2 gap-2">
        <div>
          <input
            v-model.number="localPriceMin"
            type="number"
            placeholder="Min ₱"
            class="w-full px-2.5 py-1.5 rounded-lg bg-off-white border border-light-border text-xs text-charcoal font-mono focus:outline-none focus:border-forest"
            @change="applyPrice"
          />
        </div>
        <div>
          <input
            v-model.number="localPriceMax"
            type="number"
            placeholder="Max ₱"
            class="w-full px-2.5 py-1.5 rounded-lg bg-off-white border border-light-border text-xs text-charcoal font-mono focus:outline-none focus:border-forest"
            @change="applyPrice"
          />
        </div>
      </div>
    </div>

  </aside>
</template>
