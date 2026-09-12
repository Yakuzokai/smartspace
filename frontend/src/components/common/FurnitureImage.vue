<script setup lang="ts">
import { ref, computed } from 'vue'

const props = defineProps<{
  src?: string | null
  alt: string
  colorHex?: string
  categoryName?: string
  dimensions?: {
    width_cm: number
    depth_cm: number
    height_cm: number
  }
  aspectRatio?: string
}>()

const imageError = ref(false)
const imageLoaded = ref(false)

const computedSrc = computed(() => {
  if (!props.src || typeof props.src !== 'string') return null
  if (props.src.startsWith('http://') || props.src.startsWith('https://')) {
    return props.src
  }
  // Use relative path for Vite's /storage proxy
  return props.src.startsWith('/') ? props.src : `/${props.src}`
})

const swatchColor = computed(() => props.colorHex || '#475569')

function handleError() {
  imageError.value = true
}

function handleLoad() {
  imageLoaded.value = true
}
</script>

<template>
  <div
    class="relative w-full overflow-hidden bg-off-white flex items-center justify-center select-none"
    :class="aspectRatio || 'aspect-[4/3]'"
  >
    <!-- Actual Image -->
    <img
      v-if="computedSrc && !imageError"
      :src="computedSrc"
      :alt="alt"
      class="w-full h-full object-contain p-2 sm:p-3 transition-transform duration-500 hover:scale-105"
      @error="handleError"
      @load="handleLoad"
    />

    <!-- Architectural Blueprint / Stylized SVG Fallback -->
    <div
      v-if="!computedSrc || imageError"
      class="absolute inset-0 flex flex-col items-center justify-between p-6 bg-gradient-to-br from-cream via-cream/80 to-off-white border border-light-border"
    >
      <!-- Isometric Architectural Grid Lines Pattern -->
      <svg class="absolute inset-0 w-full h-full opacity-25 pointer-events-none" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <pattern id="grid" width="24" height="24" patternUnits="userSpaceOnUse">
            <path d="M 24 0 L 0 0 0 24" fill="none" stroke="#E5E3DD" stroke-width="0.75" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#grid)" />
      </svg>

      <!-- Top info: Category & Dimensions -->
      <div class="w-full flex items-center justify-between z-10 text-xs font-mono text-muted-gray">
        <span class="uppercase tracking-wider px-2 py-0.5 rounded bg-off-white border border-light-border text-forest font-semibold">
          {{ categoryName || 'Furniture' }}
        </span>
        <span v-if="dimensions" class="text-charcoal font-mono">
          {{ dimensions.width_cm }}×{{ dimensions.depth_cm }}×{{ dimensions.height_cm }} cm
        </span>
      </div>

      <!-- Center: Isometric 3D Wireframe Box with Color Swatch -->
      <div class="relative z-10 flex flex-col items-center my-auto">
        <div
          class="w-16 h-16 rounded-2xl flex items-center justify-center shadow-card border border-light-border transition-transform duration-300 group-hover:scale-110"
          :style="{ backgroundColor: swatchColor }"
        >
          <!-- Bootstrap Icon: 3D Box -->
          <i class="bi bi-box text-3xl text-white drop-shadow-md"></i>
        </div>
        <span class="mt-2 text-xs text-charcoal font-medium tracking-wide">
          Authoritative 3D Model
        </span>
      </div>

      <!-- Bottom badge -->
      <div class="w-full flex items-center justify-center z-10">
        <span class="text-[10px] font-mono tracking-widest uppercase text-forest bg-warm-beige/25 px-2.5 py-1 rounded-full border border-warm-beige/50 font-semibold">
          Scale 1.000 • Physical Truth
        </span>
      </div>
    </div>
  </div>
</template>
