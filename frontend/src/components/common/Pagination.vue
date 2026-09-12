<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  currentPage: number
  lastPage: number
  total: number
  from?: number | null
  to?: number | null
}>()

const emit = defineEmits<{
  (e: 'changePage', page: number): void
}>()

const pages = computed(() => {
  const current = props.currentPage
  const last = props.lastPage
  const delta = 2
  const range: number[] = []
  const rangeWithDots: (number | string)[] = []
  let l: number | undefined

  for (let i = 1; i <= last; i++) {
    if (i === 1 || i === last || (i >= current - delta && i <= current + delta)) {
      range.push(i)
    }
  }

  for (const i of range) {
    if (l) {
      if (i - l === 2) {
        rangeWithDots.push(l + 1)
      } else if (i - l !== 1) {
        rangeWithDots.push('...')
      }
    }
    rangeWithDots.push(i)
    l = i
  }

  return rangeWithDots
})

function onPageClick(page: number | string) {
  if (typeof page === 'number' && page !== props.currentPage) {
    emit('changePage', page)
  }
}
</script>

<template>
  <div v-if="lastPage > 1" class="flex flex-col sm:flex-row items-center justify-between gap-4 py-6 border-t border-light-border">
    <div class="text-xs text-muted-gray font-mono">
      Showing <span class="text-charcoal font-semibold">{{ from || 1 }}</span> to
      <span class="text-charcoal font-semibold">{{ to || total }}</span> of
      <span class="text-charcoal font-semibold">{{ total }}</span> curated items
    </div>

    <div class="flex items-center gap-1.5">
      <!-- Previous Button -->
      <button
        type="button"
        :disabled="currentPage <= 1"
        class="px-3 py-1.5 rounded-lg border border-light-border text-xs font-medium transition-colors"
        :class="currentPage <= 1 ? 'opacity-40 cursor-not-allowed text-muted-gray/50' : 'text-charcoal hover:bg-cream hover:border-forest/40'"
        @click="emit('changePage', currentPage - 1)"
      >
        Previous
      </button>

      <!-- Page Numbers -->
      <template v-for="(p, idx) in pages" :key="idx">
        <span
          v-if="p === '...'"
          class="px-2 py-1 text-muted-gray text-xs select-none"
        >
          ...
        </span>
        <button
          v-else
          type="button"
          class="w-8 h-8 rounded-lg border text-xs font-mono font-medium transition-all"
          :class="p === currentPage ? 'bg-forest border-forest text-cream shadow-glow' : 'border-light-border text-muted-gray hover:bg-cream hover:text-forest'"
          @click="onPageClick(p)"
        >
          {{ p }}
        </button>
      </template>

      <!-- Next Button -->
      <button
        type="button"
        :disabled="currentPage >= lastPage"
        class="px-3 py-1.5 rounded-lg border border-light-border text-xs font-medium transition-colors"
        :class="currentPage >= lastPage ? 'opacity-40 cursor-not-allowed text-muted-gray/50' : 'text-charcoal hover:bg-cream hover:border-forest/40'"
        @click="emit('changePage', currentPage + 1)"
      >
        Next
      </button>
    </div>
  </div>
</template>
