<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useCartStore } from '@/stores/cart'
import { useCheckoutStore } from '@/stores/checkout'

const router = useRouter()
const authStore = useAuthStore()
const cartStore = useCartStore()
const checkoutStore = useCheckoutStore()

const currentStep = ref<1 | 2 | 3>(1)
const submitting = ref(false)
const validationError = ref<string | null>(null)

// Payment Card simulation fields
const cardName = ref('')
const cardNumber = ref('')
const cardExpiry = ref('')
const cardCvc = ref('')
const gcashRef = ref('')

onMounted(() => {
  if (cartStore.items.length === 0) {
    // If no items, redirect to cart or catalog
    router.replace({ name: 'cart' })
    return
  }

  // Pre-fill user data if authenticated
  if (authStore.isAuthenticated && authStore.currentUser) {
    if (!checkoutStore.shipping.email) {
      checkoutStore.shipping.email = authStore.currentUser.email
    }
    if (!checkoutStore.shipping.first_name && authStore.currentUser.name) {
      const parts = authStore.currentUser.name.split(' ')
      checkoutStore.shipping.first_name = parts[0] || ''
      checkoutStore.shipping.last_name = parts.slice(1).join(' ') || ''
    }
  }
})

const calculatedDiscount = computed(() => {
  if (checkoutStore.discountPercent <= 0) return 0
  return Math.round((cartStore.subtotal * checkoutStore.discountPercent) / 100)
})

const finalTotal = computed(() => {
  return Math.max(0, cartStore.subtotal - calculatedDiscount.value + cartStore.shippingFee)
})

function validateStep1(): boolean {
  validationError.value = null
  const s = checkoutStore.shipping
  if (!s.first_name.trim() || !s.last_name.trim()) {
    validationError.value = 'Please enter your full name.'
    return false
  }
  if (!s.email.trim() || !s.email.includes('@')) {
    validationError.value = 'Please enter a valid email address.'
    return false
  }
  if (!s.phone.trim()) {
    validationError.value = 'Please enter a contact phone number.'
    return false
  }
  if (!s.address_line1.trim()) {
    validationError.value = 'Please enter your street address.'
    return false
  }
  if (!s.city.trim()) {
    validationError.value = 'Please enter your city.'
    return false
  }
  return true
}

function proceedToPayment() {
  if (validateStep1()) {
    currentStep.value = 2
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

function proceedToReview() {
  validationError.value = null
  currentStep.value = 3
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

async function placeOrder() {
  submitting.value = true
  validationError.value = null

  try {
    const orderData = await checkoutStore.submitOrder(
      cartStore.items,
      cartStore.subtotal,
      cartStore.shippingFee
    )

    // Clear cart once order is confirmed
    cartStore.clearCart()

    // Navigate to confirmation page
    router.push({
      name: 'order-confirmation',
      query: { order: orderData.order_number },
    })
  } catch (err: any) {
    validationError.value = 'Failed to submit order. Please check your connection and try again.'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
    <!-- Breadcrumbs -->
    <nav class="flex items-center gap-2 text-xs font-mono text-muted-gray mb-6">
      <router-link to="/" class="hover:text-forest">Home</router-link>
      <span>/</span>
      <router-link to="/cart" class="hover:text-forest">Bag</router-link>
      <span>/</span>
      <span class="text-forest font-semibold">Checkout</span>
    </nav>

    <!-- Page Title & Progress Stepper -->
    <div class="border-b border-light-border pb-6 mb-8">
      <h1 class="font-display font-bold text-3xl sm:text-4xl text-forest tracking-tight">Checkout</h1>
      
      <!-- 3-Step Wizard Bar -->
      <div class="flex items-center gap-3 sm:gap-6 pt-6 text-xs font-medium">
        <!-- Step 1 Indicator -->
        <button
          type="button"
          class="flex items-center gap-2 transition-colors cursor-pointer"
          :class="currentStep === 1 ? 'text-forest font-bold' : currentStep > 1 ? 'text-forest font-semibold' : 'text-muted-gray'"
          @click="currentStep = 1"
        >
          <span
            class="w-6 h-6 rounded-full flex items-center justify-center text-[11px] font-mono border"
            :class="currentStep > 1 ? 'bg-forest text-cream border-forest' : currentStep === 1 ? 'bg-warm-beige text-forest border-warm-beige' : 'border-light-border text-muted-gray'"
          >
            <i v-if="currentStep > 1" class="bi bi-check text-xs"></i>
            <span v-else>1</span>
          </span>
          <span>1. Shipping</span>
        </button>

        <div class="w-8 sm:w-12 h-0.5 bg-light-border"></div>

        <!-- Step 2 Indicator -->
        <button
          type="button"
          class="flex items-center gap-2 transition-colors cursor-pointer"
          :class="currentStep === 2 ? 'text-forest font-bold' : currentStep > 2 ? 'text-forest font-semibold' : 'text-muted-gray'"
          :disabled="!validateStep1()"
          @click="validateStep1() && (currentStep = 2)"
        >
          <span
            class="w-6 h-6 rounded-full flex items-center justify-center text-[11px] font-mono border"
            :class="currentStep > 2 ? 'bg-forest text-cream border-forest' : currentStep === 2 ? 'bg-warm-beige text-forest border-warm-beige' : 'border-light-border text-muted-gray'"
          >
            <i v-if="currentStep > 2" class="bi bi-check text-xs"></i>
            <span v-else>2</span>
          </span>
          <span>2. Payment</span>
        </button>

        <div class="w-8 sm:w-12 h-0.5 bg-light-border"></div>

        <!-- Step 3 Indicator -->
        <button
          type="button"
          class="flex items-center gap-2 transition-colors"
          :class="currentStep === 3 ? 'text-forest font-bold' : 'text-muted-gray'"
        >
          <span
            class="w-6 h-6 rounded-full flex items-center justify-center text-[11px] font-mono border"
            :class="currentStep === 3 ? 'bg-forest text-cream border-forest' : 'border-light-border text-muted-gray'"
          >
            3
          </span>
          <span>3. Review</span>
        </button>
      </div>
    </div>

    <!-- Error Alert Box -->
    <div v-if="validationError" class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-700 text-xs flex items-center gap-2 animate-in fade-in duration-150">
      <i class="bi bi-exclamation-triangle-fill text-sm text-rose-600"></i>
      <span>{{ validationError }}</span>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
      
      <!-- Left Column: Checkout Steps (lg: 8 cols) -->
      <div class="lg:col-span-8 space-y-8">
        
        <!-- STEP 1: Shipping Details -->
        <div v-if="currentStep === 1" class="p-6 sm:p-8 rounded-3xl bg-cream border border-light-border shadow-card space-y-6">
          <div class="border-b border-light-border pb-4">
            <h2 class="font-display font-bold text-xl text-forest">Shipping & Delivery Information</h2>
            <p class="text-xs text-muted-gray mt-0.5">Where should we deliver your furniture?</p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
            <div>
              <label class="block font-medium text-charcoal mb-1.5">First Name *</label>
              <input
                v-model="checkoutStore.shipping.first_name"
                type="text"
                placeholder="e.g. Maria"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
                required
              />
            </div>
            <div>
              <label class="block font-medium text-charcoal mb-1.5">Last Name *</label>
              <input
                v-model="checkoutStore.shipping.last_name"
                type="text"
                placeholder="e.g. Santos"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
                required
              />
            </div>
            <div>
              <label class="block font-medium text-charcoal mb-1.5">Email Address *</label>
              <input
                v-model="checkoutStore.shipping.email"
                type="email"
                placeholder="maria@example.com"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
                required
              />
            </div>
            <div>
              <label class="block font-medium text-charcoal mb-1.5">Phone Number *</label>
              <input
                v-model="checkoutStore.shipping.phone"
                type="tel"
                placeholder="+63 917 123 4567"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
                required
              />
            </div>
            <div class="sm:col-span-2">
              <label class="block font-medium text-charcoal mb-1.5">Street Address *</label>
              <input
                v-model="checkoutStore.shipping.address_line1"
                type="text"
                placeholder="Unit/House No., Street Name, Barangay"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
                required
              />
            </div>
            <div class="sm:col-span-2">
              <label class="block font-medium text-charcoal mb-1.5">Apartment, Suite, Unit (Optional)</label>
              <input
                v-model="checkoutStore.shipping.address_line2"
                type="text"
                placeholder="Floor, building, landmarks"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
              />
            </div>
            <div>
              <label class="block font-medium text-charcoal mb-1.5">City *</label>
              <input
                v-model="checkoutStore.shipping.city"
                type="text"
                placeholder="e.g. Makati / Quezon City"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
                required
              />
            </div>
            <div>
              <label class="block font-medium text-charcoal mb-1.5">Province / Region</label>
              <select
                v-model="checkoutStore.shipping.province"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
              >
                <option value="Metro Manila">Metro Manila (NCR)</option>
                <option value="Cebu">Cebu</option>
                <option value="Davao">Davao</option>
                <option value="Cavite">Cavite</option>
                <option value="Laguna">Laguna</option>
                <option value="Rizal">Rizal</option>
                <option value="Pampanga">Pampanga</option>
                <option value="Other">Other Provinces</option>
              </select>
            </div>
            <div>
              <label class="block font-medium text-charcoal mb-1.5">Postal / ZIP Code</label>
              <input
                v-model="checkoutStore.shipping.postal_code"
                type="text"
                placeholder="e.g. 1229"
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest"
              />
            </div>
            <div class="sm:col-span-2">
              <label class="block font-medium text-charcoal mb-1.5">Delivery Notes / Instructions (Optional)</label>
              <textarea
                v-model="checkoutStore.shipping.notes"
                rows="2"
                placeholder="Elevator access, gate code, preferred delivery day..."
                class="w-full px-4 py-2.5 rounded-xl bg-off-white border border-light-border text-xs focus:outline-none focus:border-forest resize-none"
              ></textarea>
            </div>
          </div>

          <div class="pt-4 flex justify-end">
            <button
              type="button"
              class="px-7 py-3.5 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-glow transition-all flex items-center gap-2 cursor-pointer"
              @click="proceedToPayment"
            >
              <span>Continue to Payment</span>
              <i class="bi bi-arrow-right text-xs"></i>
            </button>
          </div>
        </div>

        <!-- STEP 2: Payment Method -->
        <div v-if="currentStep === 2" class="p-6 sm:p-8 rounded-3xl bg-cream border border-light-border shadow-card space-y-6">
          <div class="border-b border-light-border pb-4 flex items-center justify-between">
            <div>
              <h2 class="font-display font-bold text-xl text-forest">Payment Method</h2>
              <p class="text-xs text-muted-gray mt-0.5">Select how you would like to complete your purchase.</p>
            </div>
            <button
              type="button"
              class="text-xs text-forest hover:underline"
              @click="currentStep = 1"
            >
              Edit Shipping
            </button>
          </div>

          <!-- Payment Options -->
          <div class="space-y-3">
            <!-- Option 1: Cash on Delivery (COD) -->
            <label
              class="flex items-start gap-4 p-4 rounded-2xl border transition-all cursor-pointer"
              :class="checkoutStore.paymentMethod === 'cod' ? 'bg-off-white border-forest ring-1 ring-forest' : 'bg-off-white/60 border-light-border hover:bg-off-white'"
            >
              <input
                v-model="checkoutStore.paymentMethod"
                type="radio"
                value="cod"
                class="mt-1 accent-forest"
              />
              <div class="flex-1 space-y-1">
                <div class="flex items-center justify-between">
                  <span class="font-semibold text-charcoal text-xs">Cash on Delivery (COD)</span>
                  <span class="px-2 py-0.5 rounded text-[10px] font-mono bg-cream text-forest border border-light-border">Zero Fee</span>
                </div>
                <p class="text-[11px] text-muted-gray leading-relaxed">
                  Pay securely in cash or via local bank transfer upon white-glove arrival and inspection.
                </p>
              </div>
            </label>

            <!-- Option 2: GCash / Maya Mobile Wallet -->
            <label
              class="flex items-start gap-4 p-4 rounded-2xl border transition-all cursor-pointer"
              :class="checkoutStore.paymentMethod === 'gcash' ? 'bg-off-white border-forest ring-1 ring-forest' : 'bg-off-white/60 border-light-border hover:bg-off-white'"
            >
              <input
                v-model="checkoutStore.paymentMethod"
                type="radio"
                value="gcash"
                class="mt-1 accent-forest"
              />
              <div class="flex-1 space-y-1">
                <div class="flex items-center justify-between">
                  <span class="font-semibold text-charcoal text-xs">GCash / Maya Mobile Wallet</span>
                  <span class="text-[10px] font-mono text-emerald-700 font-semibold">Instant Confirmation</span>
                </div>
                <p class="text-[11px] text-muted-gray leading-relaxed">
                  Scan QR code or send payment to our merchant verification line.
                </p>

                <!-- GCash Expanded Preview -->
                <div v-if="checkoutStore.paymentMethod === 'gcash'" class="mt-3 p-4 rounded-xl bg-cream border border-light-border space-y-2 text-xs">
                  <p class="font-medium text-forest">Merchant: SmartSpace Living Inc.</p>
                  <p class="font-mono text-xs text-charcoal">Account: 0917-888-SPAC (0917-888-7722)</p>
                  <input
                    v-model="gcashRef"
                    type="text"
                    placeholder="Enter Reference Number (Optional)"
                    class="w-full mt-2 px-3 py-2 rounded-lg bg-off-white border border-light-border text-xs"
                  />
                </div>
              </div>
            </label>

            <!-- Option 3: Credit / Debit Card -->
            <label
              class="flex items-start gap-4 p-4 rounded-2xl border transition-all cursor-pointer"
              :class="checkoutStore.paymentMethod === 'card' ? 'bg-off-white border-forest ring-1 ring-forest' : 'bg-off-white/60 border-light-border hover:bg-off-white'"
            >
              <input
                v-model="checkoutStore.paymentMethod"
                type="radio"
                value="card"
                class="mt-1 accent-forest"
              />
              <div class="flex-1 space-y-1">
                <div class="flex items-center justify-between">
                  <span class="font-semibold text-charcoal text-xs">Credit / Debit Card</span>
                  <div class="flex items-center gap-1.5 text-xs text-muted-gray">
                    <i class="bi bi-credit-card"></i>
                    <span>Visa · Mastercard</span>
                  </div>
                </div>
                <p class="text-[11px] text-muted-gray leading-relaxed">
                  Processed via PCI-DSS 256-bit encrypted gateway.
                </p>

                <!-- Card Simulator Form -->
                <div v-if="checkoutStore.paymentMethod === 'card'" class="mt-3 p-4 rounded-xl bg-cream border border-light-border space-y-3 text-xs">
                  <div>
                    <label class="block text-[11px] text-muted-gray mb-1">Cardholder Name</label>
                    <input
                      v-model="cardName"
                      type="text"
                      placeholder="Name on card"
                      class="w-full px-3 py-1.5 rounded-lg bg-off-white border border-light-border text-xs"
                    />
                  </div>
                  <div>
                    <label class="block text-[11px] text-muted-gray mb-1">Card Number</label>
                    <input
                      v-model="cardNumber"
                      type="text"
                      placeholder="•••• •••• •••• ••••"
                      maxlength="19"
                      class="w-full px-3 py-1.5 rounded-lg bg-off-white border border-light-border text-xs font-mono"
                    />
                  </div>
                  <div class="grid grid-cols-2 gap-2">
                    <div>
                      <label class="block text-[11px] text-muted-gray mb-1">Expiry</label>
                      <input
                        v-model="cardExpiry"
                        type="text"
                        placeholder="MM/YY"
                        maxlength="5"
                        class="w-full px-3 py-1.5 rounded-lg bg-off-white border border-light-border text-xs font-mono"
                      />
                    </div>
                    <div>
                      <label class="block text-[11px] text-muted-gray mb-1">CVC</label>
                      <input
                        v-model="cardCvc"
                        type="password"
                        placeholder="•••"
                        maxlength="4"
                        class="w-full px-3 py-1.5 rounded-lg bg-off-white border border-light-border text-xs font-mono"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </label>
          </div>

          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-5 py-2.5 rounded-xl border border-light-border text-xs text-charcoal hover:bg-off-white transition-all cursor-pointer"
              @click="currentStep = 1"
            >
              ← Back to Shipping
            </button>
            <button
              type="button"
              class="px-7 py-3.5 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-glow transition-all flex items-center gap-2 cursor-pointer"
              @click="proceedToReview"
            >
              <span>Review Order</span>
              <i class="bi bi-arrow-right text-xs"></i>
            </button>
          </div>
        </div>

        <!-- STEP 3: Review & Place Order -->
        <div v-if="currentStep === 3" class="p-6 sm:p-8 rounded-3xl bg-cream border border-light-border shadow-card space-y-6">
          <div class="border-b border-light-border pb-4">
            <h2 class="font-display font-bold text-xl text-forest">Review & Confirm Your Order</h2>
            <p class="text-xs text-muted-gray mt-0.5">Please review your delivery details and order summary before placing.</p>
          </div>

          <!-- Shipping Summary Card -->
          <div class="p-4 rounded-2xl bg-off-white border border-light-border space-y-2 text-xs">
            <div class="flex items-center justify-between">
              <span class="font-semibold text-forest flex items-center gap-1.5">
                <i class="bi bi-geo-alt text-forest"></i>
                Delivery Destination
              </span>
              <button
                type="button"
                class="text-forest hover:underline text-[11px]"
                @click="currentStep = 1"
              >
                Change
              </button>
            </div>
            <p class="font-medium text-charcoal">
              {{ checkoutStore.shipping.first_name }} {{ checkoutStore.shipping.last_name }}
            </p>
            <p class="text-muted-gray">
              {{ checkoutStore.shipping.address_line1 }}
              <span v-if="checkoutStore.shipping.address_line2">, {{ checkoutStore.shipping.address_line2 }}</span>
            </p>
            <p class="text-muted-gray">
              {{ checkoutStore.shipping.city }}, {{ checkoutStore.shipping.province }} {{ checkoutStore.shipping.postal_code }}
            </p>
            <p class="text-muted-gray font-mono text-[11px] pt-1">
              Contact: {{ checkoutStore.shipping.phone }} · {{ checkoutStore.shipping.email }}
            </p>
          </div>

          <!-- Payment Method Summary -->
          <div class="p-4 rounded-2xl bg-off-white border border-light-border space-y-1 text-xs">
            <div class="flex items-center justify-between">
              <span class="font-semibold text-forest flex items-center gap-1.5">
                <i class="bi bi-credit-card text-forest"></i>
                Payment Choice
              </span>
              <button
                type="button"
                class="text-forest hover:underline text-[11px]"
                @click="currentStep = 2"
              >
                Change
              </button>
            </div>
            <p class="font-medium text-charcoal uppercase tracking-wider text-[11px] pt-1">
              {{ checkoutStore.paymentMethod === 'cod' ? 'Cash on Delivery' : checkoutStore.paymentMethod === 'gcash' ? 'GCash / Maya Mobile Wallet' : 'Credit / Debit Card' }}
            </p>
          </div>

          <!-- Items Recap Table -->
          <div class="space-y-3">
            <span class="font-semibold text-xs text-charcoal block">Items in this shipment ({{ cartStore.count }})</span>
            <div class="divide-y divide-light-border border border-light-border rounded-2xl bg-off-white overflow-hidden text-xs">
              <div
                v-for="item in cartStore.items"
                :key="item.id"
                class="p-4 flex items-center justify-between gap-4"
              >
                <div class="flex items-center gap-3">
                  <div class="w-12 h-12 rounded-xl bg-cream border border-light-border p-1 overflow-hidden shrink-0 flex items-center justify-center">
                    <img
                      v-if="item.primary_image"
                      :src="item.primary_image"
                      :alt="item.name"
                      class="w-full h-full object-contain mix-blend-multiply"
                    />
                    <i v-else class="bi bi-box text-muted-gray"></i>
                  </div>
                  <div>
                    <h4 class="font-medium text-charcoal">{{ item.name }}</h4>
                    <p class="text-[11px] font-mono text-muted-gray">Qty: {{ item.quantity }} × ₱{{ item.price.toLocaleString() }}</p>
                  </div>
                </div>
                <span class="font-display font-semibold text-forest">
                  ₱{{ (item.price * item.quantity).toLocaleString() }}
                </span>
              </div>
            </div>
          </div>

          <!-- Place Order Button -->
          <div class="pt-4 flex items-center justify-between">
            <button
              type="button"
              class="px-5 py-2.5 rounded-xl border border-light-border text-xs text-charcoal hover:bg-off-white transition-all cursor-pointer"
              @click="currentStep = 2"
            >
              ← Back to Payment
            </button>
            <button
              type="button"
              :disabled="submitting"
              class="px-8 py-4 rounded-xl bg-forest hover:bg-dark-green text-cream font-bold text-xs shadow-glow transition-all flex items-center gap-2 cursor-pointer disabled:opacity-50"
              @click="placeOrder"
            >
              <div v-if="submitting" class="w-4 h-4 border-2 border-cream border-t-transparent rounded-full animate-spin"></div>
              <span>{{ submitting ? 'Processing Order...' : `Place Order (₱${finalTotal.toLocaleString()})` }}</span>
              <i v-if="!submitting" class="bi bi-arrow-right text-xs"></i>
            </button>
          </div>

        </div>

      </div>

      <!-- Right Column: Sticky Summary & Guarantees (lg: 4 cols) -->
      <div class="lg:col-span-4 space-y-6 sticky top-24">
        <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-5">
          <h3 class="font-display font-bold text-base text-forest">Summary & Totals</h3>

          <div class="space-y-2.5 text-xs">
            <div class="flex items-center justify-between text-muted-gray">
              <span>Items Total</span>
              <span class="font-display font-semibold text-charcoal">₱{{ cartStore.subtotal.toLocaleString() }}</span>
            </div>
            <div class="flex items-center justify-between text-muted-gray">
              <span>White-Glove Delivery</span>
              <span :class="cartStore.isFreeDelivery ? 'text-emerald-700 font-semibold' : 'text-charcoal'">
                {{ cartStore.isFreeDelivery ? 'FREE' : `₱${cartStore.shippingFee.toLocaleString()}` }}
              </span>
            </div>
            <div v-if="calculatedDiscount > 0" class="flex items-center justify-between text-emerald-700 font-medium">
              <span>Discount ({{ checkoutStore.discountPercent }}%)</span>
              <span>-₱{{ calculatedDiscount.toLocaleString() }}</span>
            </div>
            <div class="pt-3 border-t border-light-border flex items-center justify-between text-base">
              <span class="font-bold text-forest">Total Due</span>
              <span class="font-display font-extrabold text-xl text-forest">
                ₱{{ finalTotal.toLocaleString() }}
              </span>
            </div>
          </div>

          <div class="p-4 rounded-2xl bg-off-white border border-light-border space-y-2 text-[11px] text-muted-gray">
            <p class="font-semibold text-forest flex items-center gap-1.5">
              <i class="bi bi-truck text-forest"></i>
              Estimated White-Glove Timeline
            </p>
            <p>Delivery in 3–5 business days with in-room assembly and packaging removal included.</p>
          </div>

          <div class="space-y-2 text-[11px] text-muted-gray">
            <div class="flex items-center gap-2">
              <i class="bi bi-shield-check text-forest"></i>
              <span>Guaranteed 1:1 Scale Fit Confirmation</span>
            </div>
            <div class="flex items-center gap-2">
              <i class="bi bi-arrow-counterclockwise text-forest"></i>
              <span>30-Day In-Home Return Trial</span>
            </div>
          </div>
        </div>
      </div>

    </div>

  </div>
</template>
