<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useFavoritesStore } from '@/stores/favorites'
import { useCartStore } from '@/stores/cart'

const router = useRouter()
const authStore = useAuthStore()
const favoritesStore = useFavoritesStore()
const cartStore = useCartStore()

const mobileMenuOpen = ref(false)
const userDropdownOpen = ref(false)
const navSearchQuery = ref('')

onMounted(() => {
  if (authStore.isAuthenticated) {
    favoritesStore.fetchFavorites()
  }
})

function handleSearchSubmit() {
  if (navSearchQuery.value.trim()) {
    router.push({ path: '/catalog', query: { search: navSearchQuery.value.trim() } })
    navSearchQuery.value = ''
    mobileMenuOpen.value = false
  }
}

async function handleLogout() {
  userDropdownOpen.value = false
  mobileMenuOpen.value = false
  await authStore.logout()
  router.push({ name: 'home' })
}
</script>

<template>
  <header class="sticky top-0 z-40 w-full border-b border-light-border bg-off-white/95 backdrop-blur-xl transition-colors">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between gap-4">
      
      <!-- Brand Logo -->
      <router-link to="/" class="flex items-center gap-2.5 group shrink-0">
        <div class="w-9 h-9 rounded-xl bg-cream border border-light-border p-1 flex items-center justify-center shadow-subtle transition-transform duration-300 group-hover:scale-105">
          <img src="/logo.png" alt="SmartSpace" class="w-full h-full object-contain" />
        </div>
        <div class="flex flex-col">
          <span class="font-display font-bold text-lg text-forest tracking-tight leading-none group-hover:text-dark-green transition-colors">
            SmartSpace
          </span>
          <span class="text-[10px] font-mono tracking-widest text-muted-gray uppercase leading-none mt-1">
            Furniture & Design
          </span>
        </div>
      </router-link>

      <!-- Desktop Nav Search -->
      <div class="hidden md:flex flex-1 max-w-md mx-4">
        <form class="relative w-full" @submit.prevent="handleSearchSubmit">
          <input
            v-model="navSearchQuery"
            type="text"
            placeholder="Search minimalist sofas, oak tables, desks..."
            class="w-full pl-9 pr-4 py-1.5 rounded-full bg-cream border border-light-border text-xs text-charcoal placeholder-muted-gray focus:outline-none focus:border-forest focus:ring-1 focus:ring-forest transition-all"
          />
          <i class="bi bi-search text-muted-gray absolute left-3 top-2 pointer-events-none text-xs"></i>
        </form>
      </div>

      <!-- Desktop Navigation Links -->
      <nav class="hidden lg:flex items-center gap-6 text-sm font-medium text-charcoal">
        <router-link
          to="/catalog"
          class="hover:text-forest transition-colors flex items-center gap-1.5"
          active-class="!text-forest font-semibold"
        >
          <i class="bi bi-grid-3x3-gap text-xs"></i>
          <span>Shop</span>
        </router-link>
        <router-link
          to="/projects"
          class="hover:text-forest transition-colors flex items-center gap-1.5"
          active-class="!text-forest font-semibold"
        >
          <i class="bi bi-house-gear text-xs"></i>
          <span>Room Planner</span>
        </router-link>
      </nav>

      <!-- Right Action Area: Favorites, Cart & User Account -->
      <div class="flex items-center gap-2 sm:gap-3">
        <!-- Favorites Link with Badge -->
        <router-link
          to="/favorites"
          class="relative p-2 rounded-lg text-muted-gray hover:text-forest hover:bg-cream transition-colors"
          title="My Wishlist"
        >
          <i class="bi bi-heart text-lg"></i>
          <span
            v-if="favoritesStore.count > 0"
            class="absolute -top-0.5 -right-0.5 min-w-[18px] h-[18px] px-1 rounded-full bg-warm-beige text-[10px] font-bold text-forest flex items-center justify-center shadow-glow-warm"
          >
            {{ favoritesStore.count }}
          </span>
        </router-link>

        <!-- Shopping Bag Trigger with Dynamic Badge -->
        <button
          type="button"
          class="relative p-2 rounded-lg text-muted-gray hover:text-forest hover:bg-cream transition-colors cursor-pointer"
          title="Open Shopping Bag"
          @click="cartStore.openDrawer"
        >
          <i class="bi bi-bag text-lg"></i>
          <span
            v-if="cartStore.count > 0"
            class="absolute -top-0.5 -right-0.5 min-w-[18px] h-[18px] px-1 rounded-full bg-forest text-[10px] font-bold text-cream flex items-center justify-center shadow-subtle animate-in zoom-in-50 duration-200"
          >
            {{ cartStore.count }}
          </span>
        </button>

        <!-- User Profile Dropdown (Authenticated) -->
        <div v-if="authStore.isAuthenticated" class="relative">
          <button
            type="button"
            class="flex items-center gap-2 pl-2 pr-3 py-1.5 rounded-full bg-cream border border-light-border hover:border-warm-beige transition-all text-xs text-charcoal"
            @click="userDropdownOpen = !userDropdownOpen"
          >
            <div class="w-6 h-6 rounded-full bg-gradient-to-br from-forest to-warm-beige flex items-center justify-center text-[10px] font-bold text-cream uppercase">
              {{ authStore.currentUser?.name?.charAt(0) || 'U' }}
            </div>
            <span class="max-w-[100px] truncate hidden sm:inline font-medium text-charcoal">
              {{ authStore.currentUser?.name }}
            </span>
            <i class="bi bi-chevron-down text-muted-gray text-[10px]"></i>
          </button>

          <!-- Dropdown Menu -->
          <div
            v-if="userDropdownOpen"
            class="absolute right-0 mt-2 w-48 rounded-xl bg-cream border border-light-border shadow-card-hover py-1 z-50 animate-in fade-in zoom-in-95 duration-150"
            @click="userDropdownOpen = false"
          >
            <div class="px-4 py-2 border-b border-light-border">
              <p class="text-xs font-semibold text-charcoal truncate">{{ authStore.currentUser?.name }}</p>
              <p class="text-[11px] text-muted-gray truncate">{{ authStore.currentUser?.email }}</p>
            </div>
            <router-link to="/cart" class="block px-4 py-2 text-xs text-charcoal hover:bg-warm-beige/15 hover:text-forest">
              Shopping Bag ({{ cartStore.count }})
            </router-link>
            <router-link to="/projects" class="block px-4 py-2 text-xs text-charcoal hover:bg-warm-beige/15 hover:text-forest">
              My Room Projects
            </router-link>
            <router-link to="/favorites" class="block px-4 py-2 text-xs text-charcoal hover:bg-warm-beige/15 hover:text-forest">
              Saved Favorites ({{ favoritesStore.count }})
            </router-link>
            <button
              type="button"
              class="w-full text-left px-4 py-2 text-xs text-rose-600 hover:bg-rose-50 border-t border-light-border transition-colors"
              @click="handleLogout"
            >
              Sign Out
            </button>
          </div>
        </div>

        <!-- Guest Actions -->
        <div v-else class="flex items-center gap-2">
          <router-link
            to="/login"
            class="px-3.5 py-1.5 rounded-lg text-xs font-medium text-charcoal hover:text-forest hover:bg-cream transition-colors"
          >
            Sign In
          </router-link>
          <router-link
            to="/register"
            class="hidden sm:inline-flex px-3.5 py-1.5 rounded-lg text-xs font-medium bg-forest hover:bg-dark-green text-cream shadow-glow transition-all"
          >
            Register
          </router-link>
        </div>

        <!-- Mobile Menu Toggle Button -->
        <button
          type="button"
          class="lg:hidden p-2 rounded-lg text-charcoal hover:bg-cream"
          @click="mobileMenuOpen = !mobileMenuOpen"
        >
          <i v-if="!mobileMenuOpen" class="bi bi-list text-xl"></i>
          <i v-else class="bi bi-x-lg text-lg"></i>
        </button>

      </div>
    </div>

    <!-- Mobile Navigation Drawer -->
    <div v-if="mobileMenuOpen" class="lg:hidden border-t border-light-border bg-off-white px-4 pt-3 pb-5 space-y-3">
      <form class="relative w-full" @submit.prevent="handleSearchSubmit">
        <input
          v-model="navSearchQuery"
          type="text"
          placeholder="Search catalog..."
          class="w-full pl-9 pr-4 py-2 rounded-lg bg-cream border border-light-border text-sm text-charcoal placeholder-muted-gray"
        />
        <i class="bi bi-search text-muted-gray absolute left-3 top-3 text-xs"></i>
      </form>
      <div class="space-y-1">
        <router-link
          to="/catalog"
          class="block px-3 py-2 rounded-lg text-sm text-charcoal hover:bg-cream hover:text-forest"
          @click="mobileMenuOpen = false"
        >
          Shop Collection
        </router-link>
        <router-link
          to="/projects"
          class="block px-3 py-2 rounded-lg text-sm text-charcoal hover:bg-cream hover:text-forest"
          @click="mobileMenuOpen = false"
        >
          3D Room Planner
        </router-link>
        <button
          type="button"
          class="w-full text-left px-3 py-2 rounded-lg text-sm text-charcoal hover:bg-cream hover:text-forest flex items-center justify-between"
          @click="cartStore.openDrawer(); mobileMenuOpen = false"
        >
          <span>Shopping Bag</span>
          <span class="px-2 py-0.5 rounded-full bg-forest text-cream text-xs font-mono">{{ cartStore.count }}</span>
        </button>
        <router-link
          to="/favorites"
          class="block px-3 py-2 rounded-lg text-sm text-charcoal hover:bg-cream hover:text-forest"
          @click="mobileMenuOpen = false"
        >
          Favorites ({{ favoritesStore.count }})
        </router-link>
      </div>
    </div>
  </header>
</template>
