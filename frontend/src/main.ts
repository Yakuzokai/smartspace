import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'
import 'bootstrap-icons/font/bootstrap-icons.css'
import './index.css'

// Protect Vue Router history.state from external browser extensions or devtools that call replaceState/pushState without preserving state
if (typeof window !== 'undefined' && window.history) {
  const originalReplaceState = window.history.replaceState.bind(window.history)
  window.history.replaceState = function (state: any, unused: string, url?: string | URL | null) {
    const preservedState = state !== null && typeof state === 'object'
      ? { ...(window.history.state || {}), ...state }
      : (window.history.state || {})
    return originalReplaceState(preservedState, unused, url)
  }
}

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

app.mount('#app')
