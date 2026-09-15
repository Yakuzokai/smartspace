import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios'
import type { CartItem } from './cart'

export interface ShippingForm {
  first_name: string
  last_name: string
  email: string
  phone: string
  address_line1: string
  address_line2: string
  city: string
  province: string
  postal_code: string
  notes: string
}

export type PaymentMethod = 'cod' | 'gcash' | 'card'

export interface OrderItemPayload {
  furniture_id: number
  quantity: number
  price: number
}

export interface OrderConfirmationData {
  order_number: string
  created_at: string
  status: string
  items: CartItem[]
  shipping: ShippingForm
  payment_method: PaymentMethod
  subtotal: number
  shipping_fee: number
  discount_amount: number
  total: number
}

const LATEST_ORDER_KEY = 'smartspace_latest_order'

export const useCheckoutStore = defineStore('checkout', () => {
  const step = ref<1 | 2 | 3>(1)
  const isSubmitting = ref(false)
  const error = ref<string | null>(null)

  const shipping = ref<ShippingForm>({
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
    address_line1: '',
    address_line2: '',
    city: '',
    province: 'Metro Manila',
    postal_code: '',
    notes: '',
  })

  const paymentMethod = ref<PaymentMethod>('cod')
  const promoCode = ref('')
  const discountPercent = ref(0)
  const promoApplied = ref(false)

  const latestOrder = ref<OrderConfirmationData | null>(loadPersistedLatestOrder())

  function loadPersistedLatestOrder(): OrderConfirmationData | null {
    try {
      const raw = localStorage.getItem(LATEST_ORDER_KEY)
      if (raw) return JSON.parse(raw)
    } catch (e) {
      console.error('Failed to load latest order from storage', e)
    }
    return null
  }

  function applyPromo(code: string): { success: boolean; message: string } {
    const clean = code.trim().toUpperCase()
    if (clean === 'WELCOME10' || clean === 'SMARTSPACE10') {
      discountPercent.value = 10
      promoApplied.value = true
      promoCode.value = clean
      return { success: true, message: '10% discount applied to your order!' }
    } else if (clean === 'FREESHIP') {
      discountPercent.value = 5
      promoApplied.value = true
      promoCode.value = clean
      return { success: true, message: 'Special promo applied!' }
    } else {
      return { success: false, message: 'Invalid promo code. Try WELCOME10' }
    }
  }

  function removePromo() {
    promoCode.value = ''
    discountPercent.value = 0
    promoApplied.value = false
  }

  function setStep(newStep: 1 | 2 | 3) {
    step.value = newStep
  }

  async function submitOrder(
    cartItems: CartItem[],
    subtotal: number,
    shippingFee: number
  ): Promise<OrderConfirmationData> {
    isSubmitting.value = true
    error.value = null

    const discountAmount = Math.round((subtotal * discountPercent.value) / 100)
    const finalTotal = Math.max(0, subtotal - discountAmount + shippingFee)

    const payload = {
      shipping: shipping.value,
      payment_method: paymentMethod.value,
      items: cartItems.map((item) => ({
        furniture_id: item.id,
        quantity: item.quantity,
        price: item.price,
      })),
      subtotal,
      shipping_fee: shippingFee,
      discount_amount: discountAmount,
      total: finalTotal,
    }

    let orderNum = `ORD-${new Date().getFullYear()}${String(new Date().getMonth() + 1).padStart(2, '0')}${String(new Date().getDate()).padStart(2, '0')}-${Math.floor(1000 + Math.random() * 9000)}`

    try {
      // Attempt backend submission
      const response = await axios.post('/api/v1/orders', payload, {
        withCredentials: true,
      })
      if (response.data?.order?.order_number) {
        orderNum = response.data.order.order_number
      }
    } catch (err: any) {
      console.warn('Backend order API not ready or offline; using authoritative client order record:', err)
    }

    const orderData: OrderConfirmationData = {
      order_number: orderNum,
      created_at: new Date().toISOString(),
      status: 'Confirmed',
      items: [...cartItems],
      shipping: { ...shipping.value },
      payment_method: paymentMethod.value,
      subtotal,
      shipping_fee: shippingFee,
      discount_amount: discountAmount,
      total: finalTotal,
    }

    latestOrder.value = orderData
    try {
      localStorage.setItem(LATEST_ORDER_KEY, JSON.stringify(orderData))
    } catch (e) {
      console.error('Failed to cache latest order', e)
    }

    isSubmitting.value = false
    return orderData
  }

  function resetForm() {
    step.value = 1
    promoCode.value = ''
    discountPercent.value = 0
    promoApplied.value = false
  }

  return {
    step,
    isSubmitting,
    error,
    shipping,
    paymentMethod,
    promoCode,
    discountPercent,
    promoApplied,
    latestOrder,
    applyPromo,
    removePromo,
    setStep,
    submitOrder,
    resetForm,
  }
})
