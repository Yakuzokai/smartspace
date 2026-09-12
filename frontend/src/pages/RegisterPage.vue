<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const name = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const submitting = ref(false)
const errorMessage = ref<string | null>(null)

async function handleRegister() {
  if (!name.value || !email.value || !password.value) {
    errorMessage.value = 'Please complete all required fields.'
    return
  }

  if (password.value !== passwordConfirmation.value) {
    errorMessage.value = 'Password confirmation does not match.'
    return
  }

  submitting.value = true
  errorMessage.value = null

  try {
    await authStore.register(name.value, email.value, password.value, passwordConfirmation.value)
    router.push('/')
  } catch (err: any) {
    errorMessage.value = err.response?.data?.message || 'Registration failed. Please check your details.'
  } finally {
    submitting.value = false
  }
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
        <h1 class="font-display font-bold text-2xl text-forest">Create Your Account</h1>
        <p class="text-xs text-muted-gray">
          Save room designs and certify furniture arrangements.
        </p>
      </div>

      <!-- Register Form Card -->
      <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-4">
        
        <div v-if="errorMessage" class="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs">
          {{ errorMessage }}
        </div>

        <form class="space-y-4 text-xs" @submit.prevent="handleRegister">
          <div>
            <label for="name" class="block text-charcoal font-medium mb-1">Full Name</label>
            <input
              id="name"
              v-model="name"
              type="text"
              placeholder="Alex Rivera"
              required
              class="w-full px-3 py-2.5 rounded-lg bg-off-white border border-light-border text-charcoal placeholder-muted-gray focus:outline-none focus:border-forest font-medium"
            />
          </div>

          <div>
            <label for="reg-email" class="block text-charcoal font-medium mb-1">Email Address</label>
            <input
              id="reg-email"
              v-model="email"
              type="email"
              placeholder="alex@example.com"
              required
              class="w-full px-3 py-2.5 rounded-lg bg-off-white border border-light-border text-charcoal placeholder-muted-gray focus:outline-none focus:border-forest font-medium"
            />
          </div>

          <div>
            <label for="reg-password" class="block text-charcoal font-medium mb-1">Password (min 8 chars)</label>
            <input
              id="reg-password"
              v-model="password"
              type="password"
              placeholder="••••••••"
              required
              minlength="8"
              class="w-full px-3 py-2.5 rounded-lg bg-off-white border border-light-border text-charcoal placeholder-muted-gray focus:outline-none focus:border-forest font-medium"
            />
          </div>

          <div>
            <label for="reg-confirm" class="block text-charcoal font-medium mb-1">Confirm Password</label>
            <input
              id="reg-confirm"
              v-model="passwordConfirmation"
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
            {{ submitting ? 'Creating Account...' : 'Register Account' }}
          </button>
        </form>

        <div class="pt-2 text-center text-xs text-muted-gray">
          Already have an account?
          <router-link to="/login" class="text-forest hover:text-dark-green font-semibold ml-1">
            Sign in
          </router-link>
        </div>

      </div>

    </div>
  </div>
</template>
