import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/pages/HomePage.vue'),
    meta: { title: 'SmartSpace — Minimalist Furniture & Spatial Planning' },
  },
  {
    path: '/catalog',
    name: 'catalog',
    component: () => import('@/pages/CatalogPage.vue'),
    meta: { title: 'Furniture Collection — SmartSpace' },
  },
  {
    path: '/furniture/:id',
    name: 'product-detail',
    component: () => import('@/pages/ProductDetailPage.vue'),
    props: true,
    meta: { title: 'Product Details — SmartSpace' },
  },
  {
    path: '/cart',
    name: 'cart',
    component: () => import('@/pages/CartPage.vue'),
    meta: { title: 'Shopping Bag — SmartSpace' },
  },
  {
    path: '/checkout',
    name: 'checkout',
    component: () => import('@/pages/CheckoutPage.vue'),
    meta: { title: 'Checkout — SmartSpace' },
  },
  {
    path: '/order-confirmation',
    name: 'order-confirmation',
    component: () => import('@/pages/OrderConfirmationPage.vue'),
    meta: { title: 'Order Confirmed — SmartSpace' },
  },
  {
    path: '/favorites',
    name: 'favorites',
    component: () => import('@/pages/FavoritesPage.vue'),
    meta: { requiresAuth: true, title: 'My Wishlist — SmartSpace' },
  },
  {
    path: '/projects',
    name: 'projects',
    component: () => import('@/pages/ProjectsPage.vue'),
    meta: { requiresAuth: true, title: 'My Room Projects — SmartSpace' },
  },
  {
    path: '/room-planner/:id',
    alias: '/projects/:id',
    name: 'room-planner',
    component: () => import('@/pages/RoomPlannerPage.vue'),
    props: true,
    meta: { requiresAuth: true, title: '3D Room Planner — SmartSpace' },
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/pages/LoginPage.vue'),
    meta: { guestOnly: true, title: 'Sign In — SmartSpace' },
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('@/pages/RegisterPage.vue'),
    meta: { guestOnly: true, title: 'Register — SmartSpace' },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/pages/NotFoundPage.vue'),
    meta: { title: 'Page Not Found — SmartSpace' },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(_to, _from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  },
})

router.beforeEach((to) => {
  const authStore = useAuthStore()

  // Update document title
  if (to.meta.title) {
    document.title = to.meta.title as string
  }

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  
  if (to.meta.guestOnly && authStore.isAuthenticated) {
    return { name: 'home' }
  }
})

export default router
