<script setup lang="ts">
import { ref } from 'vue'

const newsletterEmail = ref('')
const subscribed = ref(false)

function onSubscribe() {
  if (newsletterEmail.value.includes('@')) {
    subscribed.value = true
  }
}
</script>

<template>
  <footer class="mt-20 border-t border-light-border bg-cream text-charcoal text-xs">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 mb-12">
        
        <!-- Column 1 & 2: Brand Story & Values -->
        <div class="space-y-4 lg:col-span-2">
          <div class="flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-xl bg-off-white border border-light-border p-1 flex items-center justify-center shadow-subtle">
              <img src="/logo.png" alt="SmartSpace" class="w-full h-full object-contain" />
            </div>
            <span class="font-display font-bold text-forest text-lg tracking-tight">SmartSpace</span>
          </div>

          <p class="font-serif italic text-forest text-sm">
            “Architectural simplicity. Certified physical scale.”
          </p>

          <p class="text-muted-gray text-xs leading-relaxed max-w-sm">
            SmartSpace is an architectural furniture atelier pairing Japanese and Scandinavian minimalism with 3D spatial intelligence. Every piece in our store is backed by locked 1.000 scale 3D geometry so you know it fits before it ships.
          </p>

          <div class="flex items-center gap-3 pt-2 text-forest text-base">
            <a href="#" class="w-8 h-8 rounded-full bg-off-white border border-light-border flex items-center justify-center hover:bg-forest hover:text-cream transition-colors" title="Instagram">
              <i class="bi bi-instagram"></i>
            </a>
            <a href="#" class="w-8 h-8 rounded-full bg-off-white border border-light-border flex items-center justify-center hover:bg-forest hover:text-cream transition-colors" title="Pinterest">
              <i class="bi bi-pinterest"></i>
            </a>
            <a href="#" class="w-8 h-8 rounded-full bg-off-white border border-light-border flex items-center justify-center hover:bg-forest hover:text-cream transition-colors" title="Facebook">
              <i class="bi bi-facebook"></i>
            </a>
          </div>
        </div>

        <!-- Column 3: Shop -->
        <div class="space-y-3">
          <h4 class="text-forest font-semibold uppercase tracking-wider text-[11px]">Shop Collection</h4>
          <ul class="space-y-2 text-muted-gray text-xs">
            <li>
              <router-link to="/catalog?category=living-room" class="hover:text-forest transition-colors">Living Room</router-link>
            </li>
            <li>
              <router-link to="/catalog?category=bedroom" class="hover:text-forest transition-colors">Bedroom</router-link>
            </li>
            <li>
              <router-link to="/catalog?category=home-office" class="hover:text-forest transition-colors">Home Office</router-link>
            </li>
            <li>
              <router-link to="/catalog?category=dining-room" class="hover:text-forest transition-colors">Dining Room</router-link>
            </li>
            <li>
              <router-link to="/catalog" class="hover:text-forest transition-colors font-medium text-forest">All Furniture (40 Pieces)</router-link>
            </li>
          </ul>
        </div>

        <!-- Column 4: Customer Services & 3D Tools -->
        <div class="space-y-3">
          <h4 class="text-forest font-semibold uppercase tracking-wider text-[11px]">Customer Care</h4>
          <ul class="space-y-2 text-muted-gray text-xs">
            <li>
              <router-link to="/projects" class="hover:text-forest transition-colors flex items-center gap-1">
                <span>3D Room Planner</span>
                <span class="px-1.5 py-0.2 rounded text-[9px] font-mono bg-warm-beige/40 text-forest">Free</span>
              </router-link>
            </li>
            <li>
              <span class="hover:text-forest cursor-pointer">White-Glove Delivery</span>
            </li>
            <li>
              <span class="hover:text-forest cursor-pointer">30-Day In-Home Trial</span>
            </li>
            <li>
              <span class="hover:text-forest cursor-pointer">Hardwood Care Guide</span>
            </li>
            <li>
              <span class="hover:text-forest cursor-pointer">Help & FAQs</span>
            </li>
          </ul>
        </div>

        <!-- Column 5: Newsletter Subscription -->
        <div class="space-y-3">
          <h4 class="text-forest font-semibold uppercase tracking-wider text-[11px]">Join Our Circle</h4>
          <p class="text-muted-gray text-xs leading-relaxed">
            Receive 10% off your first order, private collection drops, and spatial design edits.
          </p>

          <div v-if="!subscribed" class="space-y-2">
            <input
              v-model="newsletterEmail"
              type="email"
              placeholder="Your email address"
              class="w-full px-3.5 py-2 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
            />
            <button
              type="button"
              class="w-full py-2 px-4 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-subtle transition-all cursor-pointer"
              @click="onSubscribe"
            >
              Subscribe (10% Off)
            </button>
          </div>

          <div v-else class="p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs">
            <i class="bi bi-check-circle-fill text-emerald-600 mr-1"></i>
            <span>Thank you! Use promo code <strong>WELCOME10</strong> at checkout.</span>
          </div>
        </div>

      </div>

      <!-- Bottom Legal & Payment Badges -->
      <div class="pt-8 border-t border-light-border flex flex-col sm:flex-row items-center justify-between gap-4 text-muted-gray">
        <p>© 2026 SmartSpace Furniture & Design. Authoritative dimensions 1.000 scale locked.</p>

        <!-- Payment Badges -->
        <div class="flex items-center gap-2 text-xs">
          <span class="text-[10px] uppercase font-mono text-muted-gray/80 mr-1">Accepted:</span>
          <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-[10px] font-mono text-charcoal">Visa</span>
          <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-[10px] font-mono text-charcoal">Mastercard</span>
          <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-[10px] font-mono text-charcoal">GCash</span>
          <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-[10px] font-mono text-charcoal">Maya</span>
          <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-[10px] font-mono text-charcoal">COD</span>
        </div>
      </div>
    </div>
  </footer>
</template>
