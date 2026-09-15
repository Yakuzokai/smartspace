<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useCheckoutStore } from '@/stores/checkout'

const router = useRouter()
const checkoutStore = useCheckoutStore()

const order = computed(() => {
  return checkoutStore.latestOrder
})

const estimatedDeliveryDate = computed(() => {
  const date = new Date()
  date.setDate(date.getDate() + 4)
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
})

function printReceipt() {
  window.print()
}

function openRoomPlanner() {
  router.push({ name: 'projects' })
}
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    
    <!-- If Order Data Exists -->
    <div v-if="order" class="space-y-8">
      
      <!-- Top Success Header -->
      <div class="p-8 sm:p-10 rounded-3xl bg-cream border border-light-border shadow-card text-center space-y-4">
        <div class="w-16 h-16 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-600 flex items-center justify-center mx-auto text-2xl shadow-subtle animate-in zoom-in-50 duration-300">
          <i class="bi bi-check-lg text-3xl font-bold"></i>
        </div>

        <div class="space-y-1">
          <span class="text-xs font-mono uppercase tracking-widest text-emerald-700 font-semibold">
            Order Confirmed
          </span>
          <h1 class="font-display font-bold text-3xl sm:text-4xl text-forest tracking-tight">
            Thank you, {{ order.shipping.first_name }}!
          </h1>
          <p class="text-xs sm:text-sm text-muted-gray max-w-md mx-auto leading-relaxed">
            Your furniture order has been verified. We are preparing your pieces for white-glove delivery.
          </p>
        </div>

        <!-- Order Reference Badge Strip -->
        <div class="pt-3 flex flex-wrap items-center justify-center gap-3 text-xs">
          <div class="px-4 py-2 rounded-xl bg-off-white border border-light-border font-mono">
            <span class="text-muted-gray">Order Reference: </span>
            <strong class="text-forest">{{ order.order_number }}</strong>
          </div>
          <div class="px-4 py-2 rounded-xl bg-off-white border border-light-border font-mono">
            <span class="text-muted-gray">Estimated Delivery: </span>
            <strong class="text-forest">{{ estimatedDeliveryDate }}</strong>
          </div>
        </div>
      </div>

      <!-- SmartSpace Differentiator Banner: 3D Room Planner While You Wait -->
      <div class="p-6 sm:p-8 rounded-3xl bg-forest text-cream relative overflow-hidden shadow-card">
        <div class="absolute -right-8 -bottom-8 text-cream/5 text-[140px] pointer-events-none font-mono select-none">
          3D
        </div>
        <div class="relative z-10 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
          <div class="space-y-2 max-w-lg">
            <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-cream/15 text-[10px] font-mono text-warm-beige uppercase tracking-wider">
              <i class="bi bi-box text-xs"></i>
              <span>Spatial Planning Differentiator</span>
            </div>
            <h2 class="font-display font-bold text-xl sm:text-2xl text-cream tracking-tight">
              Test-Fit Your Purchases in 3D While You Wait
            </h2>
            <p class="text-xs text-cream/80 leading-relaxed">
              Open the 3D Room Planner to arrange your newly purchased furniture with guaranteed 1.000 scale in your floor plan right now.
            </p>
          </div>

          <button
            type="button"
            class="px-6 py-3.5 rounded-xl bg-warm-beige hover:bg-warm-beige-hover text-forest font-semibold text-xs shadow-glow-warm transition-all shrink-0 cursor-pointer flex items-center gap-2"
            @click="openRoomPlanner"
          >
            <span>Open 3D Room Planner</span>
            <i class="bi bi-arrow-right text-xs"></i>
          </button>
        </div>
      </div>

      <!-- Order Details Grid (2 Columns) -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        
        <!-- Column 1: Shipping & Delivery Info -->
        <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-4 text-xs">
          <h3 class="font-display font-bold text-sm text-forest uppercase tracking-wider">
            Delivery Destination
          </h3>
          <div class="space-y-1 text-charcoal">
            <p class="font-semibold">{{ order.shipping.first_name }} {{ order.shipping.last_name }}</p>
            <p class="text-muted-gray">{{ order.shipping.address_line1 }}</p>
            <p v-if="order.shipping.address_line2" class="text-muted-gray">{{ order.shipping.address_line2 }}</p>
            <p class="text-muted-gray">{{ order.shipping.city }}, {{ order.shipping.province }} {{ order.shipping.postal_code }}</p>
            <p class="text-muted-gray pt-2 font-mono text-[11px]">Phone: {{ order.shipping.phone }}</p>
            <p class="text-muted-gray font-mono text-[11px]">Email: {{ order.shipping.email }}</p>
          </div>

          <div class="pt-3 border-t border-light-border space-y-1">
            <h4 class="font-semibold text-forest">Payment Method</h4>
            <p class="text-muted-gray uppercase font-mono text-[11px]">
              {{ order.payment_method === 'cod' ? 'Cash on Delivery (COD)' : order.payment_method === 'gcash' ? 'GCash / Maya Mobile Wallet' : 'Credit / Debit Card' }}
            </p>
          </div>
        </div>

        <!-- Column 2: Order Financial Summary -->
        <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-4 text-xs">
          <h3 class="font-display font-bold text-sm text-forest uppercase tracking-wider">
            Payment Summary
          </h3>

          <div class="space-y-2.5">
            <div class="flex items-center justify-between text-muted-gray">
              <span>Items Subtotal</span>
              <span class="font-display font-semibold text-charcoal">₱{{ order.subtotal.toLocaleString() }}</span>
            </div>
            <div class="flex items-center justify-between text-muted-gray">
              <span>Delivery Fee</span>
              <span class="text-charcoal font-semibold">
                {{ order.shipping_fee === 0 ? 'FREE' : `₱${order.shipping_fee.toLocaleString()}` }}
              </span>
            </div>
            <div v-if="order.discount_amount > 0" class="flex items-center justify-between text-emerald-700 font-medium">
              <span>Discount</span>
              <span>-₱{{ order.discount_amount.toLocaleString() }}</span>
            </div>
            <div class="pt-3 border-t border-light-border flex items-center justify-between text-base">
              <span class="font-bold text-forest">Total Paid / Due</span>
              <span class="font-display font-extrabold text-xl text-forest">
                ₱{{ order.total.toLocaleString() }}
              </span>
            </div>
          </div>

          <div class="pt-3 border-t border-light-border text-[11px] text-muted-gray flex items-center gap-1.5">
            <i class="bi bi-shield-check text-forest"></i>
            <span>30-Day In-Home Trial & 5-Year Craftsmanship Warranty</span>
          </div>
        </div>

      </div>

      <!-- Items Ordered Table -->
      <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-4">
        <h3 class="font-display font-bold text-sm text-forest uppercase tracking-wider">
          Items Ordered ({{ order.items.length }})
        </h3>

        <div class="divide-y divide-light-border border border-light-border rounded-2xl bg-off-white overflow-hidden text-xs">
          <div
            v-for="item in order.items"
            :key="item.id"
            class="p-4 flex items-center justify-between gap-4"
          >
            <div class="flex items-center gap-3">
              <div class="w-14 h-14 rounded-xl bg-cream border border-light-border p-1 overflow-hidden shrink-0 flex items-center justify-center">
                <img
                  v-if="item.primary_image"
                  :src="item.primary_image"
                  :alt="item.name"
                  class="w-full h-full object-contain mix-blend-multiply"
                />
                <i v-else class="bi bi-box text-muted-gray"></i>
              </div>
              <div>
                <h4 class="font-medium text-charcoal text-sm">{{ item.name }}</h4>
                <p class="text-[11px] font-mono text-muted-gray">
                  {{ item.dimensions.width_cm }} × {{ item.dimensions.depth_cm }} × {{ item.dimensions.height_cm }} cm
                </p>
                <p class="text-[11px] font-mono text-muted-gray mt-0.5">
                  Qty: {{ item.quantity }} × ₱{{ item.price.toLocaleString() }}
                </p>
              </div>
            </div>
            <span class="font-display font-semibold text-base text-forest">
              ₱{{ (item.price * item.quantity).toLocaleString() }}
            </span>
          </div>
        </div>
      </div>

      <!-- Bottom Actions -->
      <div class="flex flex-wrap items-center justify-between gap-4 pt-4">
        <button
          type="button"
          class="px-5 py-2.5 rounded-xl border border-light-border text-xs text-charcoal hover:bg-cream transition-all flex items-center gap-2 cursor-pointer"
          @click="printReceipt"
        >
          <i class="bi bi-printer"></i>
          <span>Print Receipt</span>
        </button>

        <router-link
          to="/catalog"
          class="px-7 py-3 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-glow transition-all flex items-center gap-2"
        >
          <span>Continue Shopping</span>
          <i class="bi bi-arrow-right text-xs"></i>
        </router-link>
      </div>

    </div>

    <!-- Fallback if no order in store -->
    <div v-else class="p-16 rounded-3xl bg-cream border border-light-border text-center space-y-4 shadow-card">
      <div class="w-16 h-16 rounded-full bg-off-white border border-light-border flex items-center justify-center text-forest text-2xl mx-auto">
        <i class="bi bi-receipt"></i>
      </div>
      <h2 class="font-display font-bold text-2xl text-forest">No Recent Order Found</h2>
      <p class="text-xs text-muted-gray max-w-sm mx-auto">
        We couldn't locate recent order details in this session. You can browse our collection or view your saved room projects.
      </p>
      <router-link
        to="/catalog"
        class="inline-block px-6 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-subtle transition-all"
      >
        Go to Shop
      </router-link>
    </div>

  </div>
</template>
