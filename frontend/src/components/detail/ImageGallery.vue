<script setup lang="ts">
import { ref } from 'vue'
import FurnitureImage from '@/components/common/FurnitureImage.vue'
import type { FurnitureImage as FurnitureImageType } from '@/types/furniture'

const props = defineProps<{
  images: FurnitureImageType[]
  primaryImage?: string | null
  furnitureName: string
  colorHex?: string
  categoryName?: string
  dimensions?: {
    width_cm: number
    depth_cm: number
    height_cm: number
  }
}>()

const activeImagePath = ref<string | null>(props.primaryImage || props.images[0]?.image_path || null)

function selectImage(path: string) {
  activeImagePath.value = path
}
</script>

<template>
  <div class="space-y-4">
    <!-- Main Display Frame -->
    <div class="rounded-3xl overflow-hidden border border-light-border bg-off-white shadow-card">
      <FurnitureImage
        :src="activeImagePath"
        :alt="furnitureName"
        :color-hex="colorHex"
        :category-name="categoryName"
        :dimensions="dimensions"
        aspect-ratio="aspect-[16/10]"
      />
    </div>

    <!-- Thumbnails Strip (if multiple images) -->
    <div v-if="images && images.length > 1" class="flex items-center gap-3 overflow-x-auto pb-2">
      <button
        v-for="img in images"
        :key="img.id"
        type="button"
        class="w-20 h-16 rounded-xl overflow-hidden border transition-all shrink-0 bg-cream cursor-pointer"
        :class="activeImagePath === img.image_path ? 'border-forest ring-2 ring-forest/30 scale-105 shadow-subtle' : 'border-light-border opacity-70 hover:opacity-100'"
        @click="selectImage(img.image_path)"
      >
        <FurnitureImage
          :src="img.image_path"
          :alt="furnitureName"
          :color-hex="colorHex"
          aspect-ratio="aspect-full h-full"
        />
      </button>
    </div>
  </div>
</template>
