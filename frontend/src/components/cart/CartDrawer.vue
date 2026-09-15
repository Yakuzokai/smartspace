<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'

const router = useRouter()
const cartStore = useCartStore()

function navigateToCheckout() {
  cartStore.closeDrawer()
  router.push({ name: 'checkout' })
}

function navigateToCart() {
  cartStore.closeDrawer()
  router.push({ name: 'cart' })
}

function continueShopping() {
  cartStore.closeDrawer()
  router.push({ name: 'catalog' })
}
</script>

<template>
  <!-- Teleport to body for top-level stacking -->
  <Teleport to="body">
    <div v-if="cartStore.isDrawerOpen" class="fixed inset-0 z-50 overflow-hidden">
      <!-- Dark Backdrop with Smooth Fade -->
      <div
        class="fixed inset-0 bg-charcoal/40 backdrop-blur-sm transition-opacity duration-300"
        @click="cartStore.closeDrawer"
      ></div>

      <div class="fixed inset-y-0 right-0 flex max-w-full pl-10">
        <div
          class="w-screen max-w-md bg-off-white shadow-2xl flex flex-col border-l border-light-border transform transition-transform duration-300 ease-out"
        >
          <!-- Drawer Header -->
          <div class="px-6 py-5 border-b border-light-border bg-cream flex items-center justify-between">
            <div class="flex items-center gap-2.5">
              <i class="bi bi-bag text-lg text-forest"></i>
              <h2 class="font-display font-bold text-lg text-forest tracking-tight">Shopping Bag</h2>
              <span class="px-2 py-0.5 rounded-full bg-warm-beige/30 text-forest font-mono text-xs font-semibold">
                {{ cartStore.count }}
              </span>
            </div>
            <button
              type="button"
              class="w-8 h-8 rounded-full flex items-center justify-center text-muted-gray hover:text-charcoal hover:bg-light-border/40 transition-colors"
              title="Close bag"
              @click="cartStore.closeDrawer"
            >
              <i class="bi bi-x-lg text-sm"></i>
            </button>
          </div>

          <!-- Free Delivery Progress Bar -->
          <div class="px-6 py-3.5 bg-cream/60 border-b border-light-border text-xs">
            <div class="flex items-center justify-between text-[11px] mb-1.5">
              <span v-if="cartStore.isFreeDelivery" class="text-emerald-700 font-semibold flex items-center gap-1">
                <i class="bi bi-check-circle-fill text-xs"></i>
                You've earned Free White-Glove Delivery!
              </span>
              <span v-else class="text-muted-gray">
                Add <strong class="text-forest">₱{{ cartStore.amountToFreeDelivery.toLocaleString() }}</strong> more for Free Delivery
              </span>
              <span class="font-mono text-[10px] text-muted-gray">{{ cartStore.freeDeliveryProgress }}%</span>
            </div>
            <div class="w-full h-1.5 bg-light-border/70 rounded-full overflow-hidden">
              <div
                class="h-full rounded-full transition-all duration-500"
                :class="cartStore.isFreeDelivery ? 'bg-emerald-600' : 'bg-forest'"
                :style="{ width: `${cartStore.freeDeliveryProgress}%` }"
              ></div>
            </div>
          </div>

          <!-- Line Items List (Scrollable) -->
          <div v-if="cartStore.items.length > 0" class="flex-1 overflow-y-auto px-6 py-4 divide-y divide-light-border/60">
            <div
              v-for="item in cartStore.items"
              :key="item.id"
              class="py-4 flex gap-4 group"
            >
              <!-- Thumbnail -->
              <div class="w-20 h-20 rounded-xl bg-cream border border-light-border overflow-hidden shrink-0 flex items-center justify-center p-1">
                <img
                  v-if="item.primary_image"
                  :src="item.primary_image"
                  :alt="item.name"
                  class="w-full h-full object-contain mix-blend-multiply"
                />
                <div v-else class="w-full h-full flex items-center justify-center text-muted-gray text-xl">
                  <i class="bi bi-box"></i>
                </div>
              </div>

              <!-- Item Details -->
              <div class="flex-1 flex flex-col justify-between">
                <div>
                  <div class="flex items-start justify-between gap-2">
                    <h3 class="font-display font-semibold text-sm text-charcoal group-hover:text-forest transition-colors line-clamp-1">
                      {{ item.name }}
                    </h3>
                    <button
                      type="button"
                      class="text-muted-gray hover:text-rose-600 transition-colors p-0.5"
                      title="Remove item"
                      @click="cartStore.removeItem(item.id)"
                    >
                      <i class="bi bi-trash3 text-xs"></i>
                    </button>
                  </div>
                  <p class="text-[11px] font-mono text-muted-gray mt-0.5">
                    {{ item.dimensions.width_cm }} × {{ item.dimensions.depth_cm }} × {{ item.dimensions.height_cm }} cm
                  </p>
                </div>

                <!-- Price and Quantity Stepper -->
                <div class="flex items-center justify-between pt-2">
                  <div class="flex items-center border border-light-border rounded-lg bg-cream/70 text-xs">
                    <button
                      type="button"
                      class="w-6 h-6 flex items-center justify-center text-muted-gray hover:text-forest hover:bg-light-border/50 rounded-l-lg transition-colors"
                      @click="cartStore.updateQuantity(item.id, item.quantity - 1)"
                    >
                      −
                    </button>
                    <span class="w-8 text-center font-mono font-medium text-charcoal">{{ item.quantity }}</span>
                    <button
                      type="button"
                      class="w-6 h-6 flex items-center justify-center text-muted-gray hover:text-forest hover:bg-light-border/50 rounded-r-lg transition-colors"
                      @click="cartStore.updateQuantity(item.id, item.quantity + 1)"
                    >
                      +
                    </button>
                  </div>

                  <span class="font-display font-bold text-sm text-forest">
                    ₱{{ (item.price * item.quantity).toLocaleString() }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Empty Cart State -->
          <div v-else class="flex-1 flex flex-col items-center justify-center p-8 text-center space-y-4">
            <div class="w-16 h-16 rounded-full bg-cream border border-light-border flex items-center justify-center text-muted-gray text-2xl">
              <i class="bi bi-bag"></i>
            </div>
            <div class="space-y-1">
              <h3 class="font-display font-bold text-lg text-forest">Your bag is empty</h3>
              <p class="text-xs text-muted-gray max-w-xs leading-relaxed">
                Explore our minimalist furniture collection crafted with authoritative 1:1 scale specifications.
              </p>
            </div>
            <button
              type="button"
              class="px-6 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-subtle transition-all"
              @click="continueShopping"
            >
              Explore Collection
            </button>
          </div>

          <!-- Drawer Footer -->
          <div v-if="cartStore.items.length > 0" class="p-6 border-t border-light-border bg-cream/60 space-y-4">
            <div class="space-y-1.5 text-xs">
              <div class="flex items-center justify-between text-muted-gray">
                <span>Subtotal</span>
                <span class="font-display font-semibold text-charcoal">₱{{ cartStore.subtotal.toLocaleString() }}</span>
              </div>
              <div class="flex items-center justify-between text-muted-gray">
                <span>Shipping</span>
                <span :class="cartStore.isFreeDelivery ? 'text-emerald-700 font-semibold' : 'text-charcoal'">
                  {{ cartStore.isFreeDelivery ? 'FREE' : `₱${cartStore.shippingFee.toLocaleString()}` }}
                </span>
              </div>
              <div class="pt-2 border-t border-light-border flex items-center justify-between text-sm">
                <span class="font-semibold text-forest">Estimated Total</span>
                <span class="font-display font-bold text-lg text-forest">
                  ₱{{ cartStore.estimatedTotal.toLocaleString() }}
                </span>
              </div>
            </div>

            <!-- Primary CTAs -->
            <div class="space-y-2 pt-1">
              <button
                type="button"
                class="w-full py-3.5 px-4 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-glow transition-all flex items-center justify-center gap-2 cursor-pointer"
                @click="navigateToCheckout"
              >
                <span>Proceed to Checkout</span>
                <i class="bi bi-arrow-right text-xs"></i>
              </button>

              <button
                type="button"
                class="w-full py-2.5 px-4 rounded-xl border border-light-border hover:border-forest text-charcoal hover:text-forest bg-off-white text-xs font-medium transition-all text-center block"
                @click="navigateToCart"
              >
                View Full Shopping Bag
              </button>
            </div>

            <p class="text-[10px] font-mono text-center text-muted-gray flex items-center justify-center gap-1.5">
              <i class="bi bi-shield-check text-forest"></i>
              <span>Guaranteed Scale Fit · 30-Day In-Home Trial</span>
            </p>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
