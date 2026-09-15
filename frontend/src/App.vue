<script setup lang="ts">
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import AppNavbar from '@/components/common/AppNavbar.vue'
import AppFooter from '@/components/common/AppFooter.vue'
import CartDrawer from '@/components/cart/CartDrawer.vue'

const authStore = useAuthStore()

onMounted(() => {
  authStore.fetchUser()
})
</script>

<template>
  <div class="min-h-screen flex flex-col bg-off-white text-charcoal selection:bg-forest selection:text-cream">
    <AppNavbar />
    <main class="flex-1">
      <router-view v-slot="{ Component, route }">
        <transition name="page" mode="out-in" :duration="{ enter: 320, leave: 200 }">
          <component :is="Component" :key="route.path" />
        </transition>
      </router-view>
    </main>
    <AppFooter />
    <CartDrawer />
  </div>
</template>

<style>
/* Global Page Switch Transitions */
.page-enter-active {
  transition: opacity 0.32s cubic-bezier(0.16, 1, 0.3, 1), transform 0.32s cubic-bezier(0.16, 1, 0.3, 1) !important;
  will-change: opacity, transform;
}

.page-leave-active {
  transition: opacity 0.2s cubic-bezier(0.16, 1, 0.3, 1), transform 0.2s cubic-bezier(0.16, 1, 0.3, 1) !important;
  will-change: opacity, transform;
}

.page-enter-from {
  opacity: 0 !important;
  transform: translateY(18px) !important;
}

.page-leave-to {
  opacity: 0 !important;
  transform: translateY(-12px) !important;
}
</style>
