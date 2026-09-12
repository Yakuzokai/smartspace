<script setup lang="ts">
defineProps<{
  status?: 'in_stock' | 'low_stock' | 'out_of_stock'
  quantity?: number
}>()
</script>

<template>
  <div
    v-if="status === 'in_stock' || !status"
    class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-50 border border-emerald-200 text-emerald-800"
  >
    <span class="w-1.5 h-1.5 rounded-full bg-emerald-600 animate-pulse"></span>
    <span>In Stock</span>
    <span v-if="quantity" class="text-emerald-700 font-mono">({{ quantity }})</span>
  </div>
  <div
    v-else-if="status === 'low_stock'"
    class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-50 border border-amber-200 text-amber-800"
  >
    <span class="w-1.5 h-1.5 rounded-full bg-amber-600"></span>
    <span>Low Stock ({{ quantity }})</span>
  </div>
  <div
    v-else
    class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-rose-50 border border-rose-200 text-rose-800"
  >
    <span class="w-1.5 h-1.5 rounded-full bg-rose-600"></span>
    <span>Backorder</span>
  </div>
</template>
