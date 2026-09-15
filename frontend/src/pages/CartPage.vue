<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'
import { useCheckoutStore } from '@/stores/checkout'

const router = useRouter()
const cartStore = useCartStore()
const checkoutStore = useCheckoutStore()

const inputPromo = ref('')
const promoMessage = ref<{ text: string; isError: boolean } | null>(null)

function onApplyPromo() {
  if (!inputPromo.value.trim()) return
  const res = checkoutStore.applyPromo(inputPromo.value)
  promoMessage.value = {
    text: res.message,
    isError: !res.success,
  }
}

function onRemovePromo() {
  checkoutStore.removePromo()
  inputPromo.value = ''
  promoMessage.value = null
}

function proceedToCheckout() {
  router.push({ name: 'checkout' })
}
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
    <!-- Breadcrumbs -->
    <nav class="flex items-center gap-2 text-xs font-mono text-muted-gray mb-6">
      <router-link to="/" class="hover:text-forest">Home</router-link>
      <span>/</span>
      <router-link to="/catalog" class="hover:text-forest">Shop</router-link>
      <span>/</span>
      <span class="text-forest font-semibold">Shopping Bag</span>
    </nav>

    <!-- Page Header -->
    <div class="flex flex-col sm:flex-row sm:items-baseline justify-between gap-2 border-b border-light-border pb-6 mb-8">
      <div>
        <h1 class="font-display font-bold text-3xl sm:text-4xl text-forest tracking-tight">Shopping Bag</h1>
        <p class="text-xs text-muted-gray mt-1">Review your curated pieces before checkout.</p>
      </div>
      <span class="font-mono text-xs text-muted-gray">
        {{ cartStore.count }} {{ cartStore.count === 1 ? 'item' : 'items' }} selected
      </span>
    </div>

    <!-- Main Content: Cart or Empty -->
    <div v-if="cartStore.items.length > 0" class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
      
      <!-- Left Column: Line Items & Promo Box (lg: 8 cols) -->
      <div class="lg:col-span-8 space-y-6">
        
        <!-- Line Items Table/List -->
        <div class="bg-cream rounded-3xl border border-light-border overflow-hidden shadow-card divide-y divide-light-border">
          <div
            v-for="item in cartStore.items"
            :key="item.id"
            class="p-5 sm:p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-5 transition-colors hover:bg-cream/40"
          >
            <!-- Product Info (Image + Title) -->
            <div class="flex items-center gap-4 flex-1">
              <router-link
                :to="{ name: 'product-detail', params: { id: item.id } }"
                class="w-20 h-20 sm:w-24 sm:h-24 rounded-2xl bg-off-white border border-light-border p-2 flex items-center justify-center overflow-hidden shrink-0 group"
              >
                <img
                  v-if="item.primary_image"
                  :src="item.primary_image"
                  :alt="item.name"
                  class="w-full h-full object-contain mix-blend-multiply group-hover:scale-105 transition-transform"
                />
                <i v-else class="bi bi-box text-2xl text-muted-gray"></i>
              </router-link>

              <div class="space-y-1">
                <div class="flex items-center gap-2 text-[11px] font-mono text-muted-gray">
                  <span>{{ item.category_name || 'Furniture' }}</span>
                  <span>•</span>
                  <span>{{ item.sku }}</span>
                </div>
                <router-link
                  :to="{ name: 'product-detail', params: { id: item.id } }"
                  class="font-display font-semibold text-base text-charcoal hover:text-forest transition-colors block"
                >
                  {{ item.name }}
                </router-link>
                <p class="text-xs font-mono text-muted-gray">
                  {{ item.dimensions.width_cm }} × {{ item.dimensions.depth_cm }} × {{ item.dimensions.height_cm }} cm
                </p>
                <div class="flex items-center gap-2 pt-0.5 text-xs text-muted-gray">
                  <span>Unit Price:</span>
                  <span class="font-medium text-charcoal">₱{{ item.price.toLocaleString() }}</span>
                </div>
              </div>
            </div>

            <!-- Controls (Quantity Stepper, Total, Remove) -->
            <div class="flex items-center justify-between sm:justify-end gap-6 w-full sm:w-auto pt-3 sm:pt-0 border-t sm:border-t-0 border-light-border">
              <!-- Stepper -->
              <div class="flex items-center border border-light-border rounded-xl bg-off-white text-xs">
                <button
                  type="button"
                  class="w-8 h-8 flex items-center justify-center text-charcoal hover:bg-cream transition-colors cursor-pointer"
                  @click="cartStore.updateQuantity(item.id, item.quantity - 1)"
                >
                  −
                </button>
                <span class="w-9 text-center font-mono font-semibold text-charcoal">{{ item.quantity }}</span>
                <button
                  type="button"
                  class="w-8 h-8 flex items-center justify-center text-charcoal hover:bg-cream transition-colors cursor-pointer"
                  @click="cartStore.updateQuantity(item.id, item.quantity + 1)"
                >
                  +
                </button>
              </div>

              <!-- Line Total -->
              <div class="text-right min-w-[90px]">
                <span class="font-display font-bold text-base text-forest">
                  ₱{{ (item.price * item.quantity).toLocaleString() }}
                </span>
              </div>

              <!-- Remove Button -->
              <button
                type="button"
                class="w-8 h-8 rounded-full flex items-center justify-center text-muted-gray hover:text-rose-600 hover:bg-rose-50 transition-colors cursor-pointer"
                title="Remove item"
                @click="cartStore.removeItem(item.id)"
              >
                <i class="bi bi-trash3 text-sm"></i>
              </button>
            </div>

          </div>
        </div>

        <!-- Promo Code & Back Link -->
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 p-5 rounded-2xl bg-cream border border-light-border">
          <router-link
            to="/catalog"
            class="text-xs font-semibold text-forest hover:text-dark-green flex items-center gap-1.5"
          >
            <i class="bi bi-arrow-left text-xs"></i>
            <span>Continue Shopping</span>
          </router-link>

          <!-- Promo Input Form -->
          <div class="w-full sm:w-auto">
            <div v-if="!checkoutStore.promoApplied" class="flex items-center gap-2">
              <input
                v-model="inputPromo"
                type="text"
                placeholder="Promo code (e.g. WELCOME10)"
                class="px-3.5 py-1.5 text-xs rounded-xl bg-off-white border border-light-border focus:outline-none focus:border-forest"
                @keyup.enter="onApplyPromo"
              />
              <button
                type="button"
                class="px-4 py-1.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-subtle transition-all cursor-pointer"
                @click="onApplyPromo"
              >
                Apply
              </button>
            </div>
            <div v-else class="flex items-center gap-2 text-xs">
              <span class="px-2.5 py-1 rounded-lg bg-emerald-100 text-emerald-800 font-mono font-semibold">
                {{ checkoutStore.promoCode }} ({{ checkoutStore.discountPercent }}% off)
              </span>
              <button
                type="button"
                class="text-xs text-rose-600 hover:underline cursor-pointer"
                @click="onRemovePromo"
              >
                Remove
              </button>
            </div>
            <p
              v-if="promoMessage"
              class="text-[11px] mt-1"
              :class="promoMessage.isError ? 'text-rose-600' : 'text-emerald-700 font-medium'"
            >
              {{ promoMessage.text }}
            </p>
          </div>
        </div>

      </div>

      <!-- Right Column: Order Summary (lg: 4 cols) -->
      <div class="lg:col-span-4 space-y-6 sticky top-24">
        <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-5">
          <h2 class="font-display font-bold text-lg text-forest tracking-tight">Order Summary</h2>

          <!-- Free Shipping Progress -->
          <div class="p-3.5 rounded-2xl bg-off-white border border-light-border text-xs space-y-1.5">
            <div class="flex items-center justify-between text-[11px]">
              <span v-if="cartStore.isFreeDelivery" class="text-emerald-700 font-semibold flex items-center gap-1">
                <i class="bi bi-check-circle-fill text-xs"></i>
                Free Delivery Unlocked!
              </span>
              <span v-else class="text-muted-gray">
                Add <strong>₱{{ cartStore.amountToFreeDelivery.toLocaleString() }}</strong> for free delivery
              </span>
              <span class="font-mono text-[10px] text-muted-gray">{{ cartStore.freeDeliveryProgress }}%</span>
            </div>
            <div class="w-full h-1.5 bg-light-border/60 rounded-full overflow-hidden">
              <div
                class="h-full rounded-full transition-all duration-500"
                :class="cartStore.isFreeDelivery ? 'bg-emerald-600' : 'bg-forest'"
                :style="{ width: `${cartStore.freeDeliveryProgress}%` }"
              ></div>
            </div>
          </div>

          <!-- Cost Breakdown -->
          <div class="space-y-3 text-xs border-y border-light-border py-4">
            <div class="flex items-center justify-between text-muted-gray">
              <span>Items Subtotal</span>
              <span class="font-display font-semibold text-charcoal">₱{{ cartStore.subtotal.toLocaleString() }}</span>
            </div>

            <div class="flex items-center justify-between text-muted-gray">
              <span>Delivery Fee</span>
              <span :class="cartStore.isFreeDelivery ? 'text-emerald-700 font-semibold' : 'text-charcoal'">
                {{ cartStore.isFreeDelivery ? 'FREE' : `₱${cartStore.shippingFee.toLocaleString()}` }}
              </span>
            </div>

            <div v-if="checkoutStore.discountPercent > 0" class="flex items-center justify-between text-emerald-700 font-medium">
              <span>Discount ({{ checkoutStore.discountPercent }}%)</span>
              <span>-₱{{ Math.round((cartStore.subtotal * checkoutStore.discountPercent) / 100).toLocaleString() }}</span>
            </div>

            <div class="pt-2 border-t border-light-border flex items-center justify-between text-base">
              <span class="font-bold text-forest">Order Total</span>
              <span class="font-display font-extrabold text-xl text-forest">
                ₱{{ Math.max(0, cartStore.subtotal - Math.round((cartStore.subtotal * checkoutStore.discountPercent) / 100) + cartStore.shippingFee).toLocaleString() }}
              </span>
            </div>
          </div>

          <!-- Checkout CTA Button -->
          <button
            type="button"
            class="w-full py-4 px-4 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-glow transition-all flex items-center justify-center gap-2 cursor-pointer"
            @click="proceedToCheckout"
          >
            <span>Proceed to Checkout</span>
            <i class="bi bi-arrow-right text-xs"></i>
          </button>

          <!-- Trust Badges -->
          <div class="pt-2 space-y-2 text-[11px] text-muted-gray border-t border-light-border">
            <div class="flex items-center gap-2">
              <i class="bi bi-shield-check text-forest"></i>
              <span>256-bit Bank Grade Encrypted Checkout</span>
            </div>
            <div class="flex items-center gap-2">
              <i class="bi bi-arrow-counterclockwise text-forest"></i>
              <span>30-Day Hassle-Free In-Home Return</span>
            </div>
            <div class="flex items-center gap-2">
              <i class="bi bi-rulers text-forest"></i>
              <span>1.000 Scale Guaranteed to Match Specs</span>
            </div>
          </div>

        </div>
      </div>

    </div>

    <!-- Empty State -->
    <div v-else class="p-16 rounded-3xl bg-cream border border-light-border text-center max-w-xl mx-auto space-y-5 my-12 shadow-card">
      <div class="w-20 h-20 rounded-full bg-off-white border border-light-border flex items-center justify-center text-forest text-3xl mx-auto shadow-subtle">
        <i class="bi bi-bag"></i>
      </div>
      <div class="space-y-2">
        <h2 class="font-display font-bold text-2xl text-forest">Your shopping bag is empty</h2>
        <p class="text-xs text-muted-gray max-w-sm mx-auto leading-relaxed">
          Looks like you haven't added any pieces to your bag yet. Browse our curated collection of architectural furniture.
        </p>
      </div>
      <router-link
        to="/catalog"
        class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-glow transition-all"
      >
        <span>Explore Collection</span>
        <i class="bi bi-arrow-right text-xs"></i>
      </router-link>
    </div>

  </div>
</template>
