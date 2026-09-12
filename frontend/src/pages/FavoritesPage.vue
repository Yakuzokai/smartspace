<script setup lang="ts">
import { onMounted } from 'vue'
import { useFavoritesStore } from '@/stores/favorites'
import FurnitureCard from '@/components/catalog/FurnitureCard.vue'

const favoritesStore = useFavoritesStore()

onMounted(() => {
  favoritesStore.fetchFavorites()
})
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
    
    <!-- Page Header -->
    <div class="space-y-1">
      <div class="flex items-center gap-2 text-xs font-mono text-muted-gray">
        <router-link to="/" class="hover:text-forest">Home</router-link>
        <span>/</span>
        <span class="text-forest font-semibold">Favorites</span>
      </div>
      <div class="flex items-center justify-between">
        <h1 class="font-display font-bold text-3xl text-forest">My Saved Favorites</h1>
        <span class="text-xs font-mono text-forest bg-warm-beige/25 border border-warm-beige/60 px-3 py-1 rounded-full font-semibold">
          {{ favoritesStore.count }} Saved Items
        </span>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="favoritesStore.loading" class="py-16 text-center space-y-3">
      <div class="w-10 h-10 rounded-full border-2 border-forest border-t-transparent animate-spin mx-auto"></div>
      <p class="text-xs font-mono text-muted-gray">Loading saved favorites...</p>
    </div>

    <!-- Empty State -->
    <div
      v-else-if="favoritesStore.favorites.length === 0"
      class="p-12 rounded-3xl bg-cream border border-light-border text-center space-y-4 my-8 max-w-lg mx-auto shadow-card"
    >
      <div class="w-16 h-16 rounded-full bg-off-white border border-light-border flex items-center justify-center mx-auto text-forest text-2xl shadow-subtle">
        ♡
      </div>
      <div class="space-y-1">
        <h3 class="font-display font-bold text-lg text-forest">No Saved Favorites Yet</h3>
        <p class="text-xs text-muted-gray leading-relaxed">
          Click the heart icon on any furniture piece in the catalog to save it to your wishlist for spatial planning.
        </p>
      </div>
      <router-link
        to="/catalog"
        class="inline-block px-5 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all"
      >
        Explore Catalog
      </router-link>
    </div>

    <!-- Favorites Grid -->
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      <FurnitureCard
        v-for="item in favoritesStore.favorites"
        :key="item.id"
        :furniture="item"
      />
    </div>

  </div>
</template>
