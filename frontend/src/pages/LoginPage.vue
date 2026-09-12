<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const submitting = ref(false)
const errorMessage = ref<string | null>(null)

async function handleLogin() {
  if (!email.value || !password.value) {
    errorMessage.value = 'Please provide both email and password.'
    return
  }

  submitting.value = true
  errorMessage.value = null

  try {
    await authStore.login(email.value, password.value)
    const redirect = (route.query.redirect as string) || '/'
    router.push(redirect)
  } catch (err: any) {
    errorMessage.value = err.response?.data?.message || 'Login failed. Please verify credentials.'
  } finally {
    submitting.value = false
  }
}

function fillDemoCustomer() {
  email.value = 'customer@smartspace.local'
  password.value = 'password123'
  handleLogin()
}
</script>

<template>
  <div class="min-h-[75vh] flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md space-y-6">
      
      <!-- Brand Icon & Header -->
      <div class="text-center space-y-2">
        <div class="w-12 h-12 rounded-2xl bg-forest flex items-center justify-center mx-auto shadow-glow">
          <i class="bi bi-box text-2xl text-cream"></i>
        </div>
        <h1 class="font-display font-bold text-2xl text-forest">Sign In to SmartSpace</h1>
        <p class="text-xs text-muted-gray">
          Access your spatial room projects and saved favorites.
        </p>
      </div>

      <!-- Quick Demo Login Button -->
      <div class="p-4 rounded-2xl bg-cream border border-light-border text-center space-y-2 shadow-subtle">
        <span class="text-xs text-forest font-semibold block">Pair Programming / Review Convenience</span>
        <button
          type="button"
          :disabled="submitting"
          class="w-full py-2 px-3 rounded-xl bg-warm-beige/25 hover:bg-warm-beige/40 border border-warm-beige/70 text-forest text-xs font-semibold shadow-subtle transition-all flex items-center justify-center gap-2 cursor-pointer"
          @click="fillDemoCustomer"
        >
          <i class="bi bi-lightning-charge-fill text-forest"></i>
          <span>1-Click Sign In as Demo Customer</span>
        </button>
        <span class="text-[10px] font-mono text-muted-gray block">customer@smartspace.local • password123</span>
      </div>

      <!-- Login Form Card -->
      <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-4">
        
        <div v-if="errorMessage" class="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs">
          {{ errorMessage }}
        </div>

        <form class="space-y-4 text-xs" @submit.prevent="handleLogin">
          <div>
            <label for="email" class="block text-charcoal font-medium mb-1">Email Address</label>
            <input
              id="email"
              v-model="email"
              type="email"
              placeholder="you@example.com"
              required
              class="w-full px-3 py-2.5 rounded-lg bg-off-white border border-light-border text-charcoal placeholder-muted-gray focus:outline-none focus:border-forest font-medium"
            />
          </div>

          <div>
            <label for="password" class="block text-charcoal font-medium mb-1">Password</label>
            <input
              id="password"
              v-model="password"
              type="password"
              placeholder="••••••••"
              required
              class="w-full px-3 py-2.5 rounded-lg bg-off-white border border-light-border text-charcoal placeholder-muted-gray focus:outline-none focus:border-forest font-medium"
            />
          </div>

          <button
            type="submit"
            :disabled="submitting"
            class="w-full py-2.5 px-4 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold shadow-glow transition-all disabled:opacity-50 cursor-pointer"
          >
            {{ submitting ? 'Signing In...' : 'Sign In' }}
          </button>
        </form>

        <div class="pt-2 text-center text-xs text-muted-gray">
          Don't have an account?
          <router-link to="/register" class="text-forest hover:text-dark-green font-semibold ml-1">
            Register now
          </router-link>
        </div>

      </div>

    </div>
  </div>
</template>
