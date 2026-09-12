<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  styleName: string
}>()

const formattedName = computed(() => {
  return props.styleName ? props.styleName.charAt(0).toUpperCase() + props.styleName.slice(1) : ''
})

const badgeColor = computed(() => {
  switch (props.styleName?.toLowerCase()) {
    case 'scandinavian':
      return 'bg-warm-beige/20 border-warm-beige/60 text-forest'
    case 'minimalist':
      return 'bg-cream border-light-border text-forest'
    case 'industrial':
      return 'bg-warm-beige/30 border-warm-beige text-forest'
    case 'modern':
      return 'bg-forest/10 border-forest/30 text-forest'
    case 'contemporary':
      return 'bg-cream border-warm-beige/50 text-forest'
    case 'japandi':
      return 'bg-warm-beige/25 border-warm-beige/70 text-forest'
    default:
      return 'bg-cream border-light-border text-forest'
  }
})
</script>

<template>
  <span
    class="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-medium tracking-wide uppercase border"
    :class="badgeColor"
  >
    {{ formattedName }}
  </span>
</template>
