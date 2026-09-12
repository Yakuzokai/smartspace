<script setup lang="ts">
defineProps<{
  width: number
  depth: number
  height: number
  unit?: 'cm' | 'm'
}>()
</script>

<template>
  <div class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-off-white border border-light-border text-charcoal font-mono text-xs shadow-subtle">
    <!-- Bootstrap Icon: rulers -->
    <i class="bi bi-rulers text-forest"></i>
    <span>
      {{ width }} × {{ depth }} × {{ height }} {{ unit || 'cm' }}
    </span>
  </div>
</template>
