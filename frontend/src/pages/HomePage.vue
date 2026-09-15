<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useCatalogStore } from '@/stores/catalog'
import FurnitureCard from '@/components/catalog/FurnitureCard.vue'
import RoomCreationModal from '@/components/room/RoomCreationModal.vue'

const router = useRouter()
const catalogStore = useCatalogStore()

const showCreateModal = ref(false)
const modalInitialTab = ref<'ai' | 'manual'>('ai')

onMounted(() => {
  catalogStore.fetchCategories()
  catalogStore.fetchFeatured()
})

function browseCategory(slug: string) {
  catalogStore.resetFilters()
  catalogStore.setFilter('category_slug', slug)
  router.push({ name: 'catalog' })
}

function openGateway(mode: 'ai' | 'manual') {
  modalInitialTab.value = mode
  showCreateModal.value = true
}
</script>

<template>
  <div class="space-y-16 pb-20">
    
    <!-- Top Announcement Strip -->
    <div class="bg-[#102d26] text-cream text-[11px] py-2 px-4 border-b border-forest/40 text-center font-medium tracking-wide flex items-center justify-center gap-2 sm:gap-4">
      <span class="flex items-center gap-1.5">
        <i class="bi bi-truck text-warm-beige"></i>
        <span>Free White-Glove Delivery on orders over ₱5,000</span>
      </span>
      <span class="hidden md:inline text-warm-beige/60">•</span>
      <span class="hidden md:inline flex items-center gap-1.5">
        <i class="bi bi-arrow-counterclockwise text-warm-beige"></i>
        <span>30-Day In-Home Trial</span>
      </span>
      <span class="hidden md:inline text-warm-beige/60">•</span>
      <span class="hidden md:inline flex items-center gap-1.5">
        <i class="bi bi-rulers text-warm-beige"></i>
        <span>1:1 Scale Fit Guaranteed</span>
      </span>
    </div>

    <!-- 1. Hero Section (Minimalist High-End Furniture Store with CAD Grid) -->
    <section class="relative overflow-hidden bg-[#133930] text-cream pt-10 pb-16 lg:pt-14 lg:pb-24 border-b border-forest bg-[linear-gradient(to_right,rgba(255,255,255,0.03)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.03)_1px,transparent_1px)] bg-[size:40px_40px]">
      <!-- Ambient Lighting -->
      <div class="absolute -top-32 left-1/2 -translate-x-1/2 w-[900px] h-[450px] bg-forest/40 blur-[140px] rounded-full pointer-events-none"></div>
      
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-8 items-center">
          
          <!-- Left Column (Copy & CTAs) -->
          <div class="lg:col-span-6 space-y-6 text-left">
            <!-- Eyebrow Pill -->
            <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-forest/80 border border-warm-beige/30 text-xs font-mono tracking-wider text-warm-beige shadow-subtle">
              <span class="w-2 h-2 rounded-full bg-warm-beige"></span>
              <span>MINIMALIST LIVING · 3D VERIFIED</span>
            </div>

            <!-- Headline with Serif Typography -->
            <div class="space-y-2">
              <h1 class="font-serif font-bold text-4xl sm:text-6xl lg:text-7xl text-cream tracking-tight leading-[1.1]">
                Minimalist Furniture <br />
                <span class="text-warm-beige">Crafted to Fit.</span>
              </h1>
            </div>

            <!-- Subtitle -->
            <p class="text-cream/80 text-base sm:text-lg max-w-lg leading-relaxed font-normal">
              Discover Scandinavian & Japanese minimalist furniture. Test-fit any piece in your room in 1:1 scale 3D before it arrives at your doorstep.
            </p>

            <!-- Action Buttons -->
            <div class="flex flex-wrap items-center gap-4 pt-2">
              <router-link
                to="/catalog"
                class="px-8 py-3.5 rounded-xl bg-warm-beige hover:bg-warm-beige-hover text-forest font-semibold text-xs shadow-glow-warm transition-all hover:scale-105 cursor-pointer flex items-center gap-2"
              >
                <span>Shop Collection</span>
                <i class="bi bi-arrow-right text-xs"></i>
              </router-link>

              <button
                type="button"
                class="px-7 py-3.5 rounded-xl bg-forest/50 border border-cream/20 hover:border-warm-beige/60 text-cream font-medium text-xs transition-all hover:bg-forest/70 flex items-center gap-2 cursor-pointer"
                @click="openGateway('ai')"
              >
                <i class="bi bi-box text-warm-beige"></i>
                <span>Try in 3D Room Planner</span>
              </button>
            </div>

            <!-- Thesis Positioning Statement -->
            <div class="pt-2">
              <p class="text-xs font-mono uppercase tracking-widest text-cream/60 font-semibold">
                CURATED FURNITURE · 1:1 SCALE VERIFICATION · WHITE-GLOVE DELIVERY
              </p>
            </div>
          </div>

          <!-- Right Column (Hero Visual with Badges) -->
          <div class="lg:col-span-6 relative pt-4 lg:pt-0">
            <div class="relative rounded-3xl overflow-visible max-w-lg mx-auto lg:max-w-none">
              
              <!-- Main Living Room Image -->
              <div class="rounded-3xl overflow-hidden border border-cream/10 shadow-2xl bg-forest/60">
                <img
                  src="/hero-room.jpg"
                  alt="Living Room Minimalist Furniture Setup"
                  class="w-full h-[340px] sm:h-[400px] lg:h-[420px] object-cover rounded-3xl hover:scale-105 transition-transform duration-700"
                />
              </div>

              <!-- Top-Right Floating Pill: "3D Ready ✦" -->
              <div class="absolute top-4 right-4 z-20">
                <div class="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-forest/90 backdrop-blur-md border border-light-border/20 text-xs font-semibold text-cream shadow-lg">
                  <span>1:1 3D Scale Locked</span>
                  <span class="text-warm-beige text-sm">✦</span>
                </div>
              </div>

              <!-- Bottom-Left Floating Card: "Verified Room Fit 92%" -->
              <div class="absolute -bottom-6 -left-4 sm:-left-6 z-20 p-5 rounded-2xl bg-cream text-charcoal border border-light-border shadow-2xl space-y-2 min-w-[210px] animate-in fade-in slide-in-from-bottom-4 duration-500">
                <span class="text-[10px] font-mono uppercase tracking-wider text-muted-gray block font-semibold">
                  Spatial Compatibility
                </span>
                <div class="flex items-baseline gap-1">
                  <span class="font-serif font-bold text-3xl text-forest">92</span>
                  <span class="text-xs font-mono text-muted-gray">/ 100</span>
                </div>
                <ul class="space-y-1 text-xs text-charcoal pt-1 font-medium">
                  <li class="flex items-center gap-1.5">
                    <i class="bi bi-check2 text-forest font-bold text-sm"></i>
                    <span class="text-[11px]">Boundary Fit Confirmed</span>
                  </li>
                  <li class="flex items-center gap-1.5">
                    <i class="bi bi-check2 text-forest font-bold text-sm"></i>
                    <span class="text-[11px]">Doorway Clearance Safe</span>
                  </li>
                  <li class="flex items-center gap-1.5">
                    <i class="bi bi-check2 text-forest font-bold text-sm"></i>
                    <span class="text-[11px]">Walking Path Preserved</span>
                  </li>
                </ul>
              </div>

            </div>
          </div>

        </div>

        <!-- Trust Badges Strip (Underneath Hero) -->
        <div class="mt-14 pt-8 border-t border-forest/60 grid grid-cols-2 sm:grid-cols-4 gap-4 max-w-5xl mx-auto text-left">
          <div class="p-4 rounded-xl bg-forest/40 border border-light-border/20 backdrop-blur-sm space-y-1">
            <div class="flex items-center gap-2 text-warm-beige text-sm">
              <i class="bi bi-truck"></i>
              <span class="font-semibold text-cream">Free White-Glove</span>
            </div>
            <span class="text-xs text-cream/70 block">Complimentary delivery over ₱5,000</span>
          </div>

          <div class="p-4 rounded-xl bg-forest/40 border border-light-border/20 backdrop-blur-sm space-y-1">
            <div class="flex items-center gap-2 text-warm-beige text-sm">
              <i class="bi bi-arrow-counterclockwise"></i>
              <span class="font-semibold text-cream">30-Day Trial</span>
            </div>
            <span class="text-xs text-cream/70 block">In-home return guarantee</span>
          </div>

          <div class="p-4 rounded-xl bg-forest/40 border border-light-border/20 backdrop-blur-sm space-y-1">
            <div class="flex items-center gap-2 text-warm-beige text-sm">
              <i class="bi bi-box"></i>
              <span class="font-semibold text-cream">1.000 Scale Locked</span>
            </div>
            <span class="text-xs text-cream/70 block">Every piece has verified 3D GLB</span>
          </div>

          <div class="p-4 rounded-xl bg-forest/40 border border-light-border/20 backdrop-blur-sm space-y-1">
            <div class="flex items-center gap-2 text-warm-beige text-sm">
              <i class="bi bi-shield-check"></i>
              <span class="font-semibold text-cream">5-Year Warranty</span>
            </div>
            <span class="text-xs text-cream/70 block">Solid hardwoods & precision joinery</span>
          </div>
        </div>

      </div>
    </section>

    <!-- 2. Categories Grid Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
      <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-2">
        <div>
          <span class="text-xs font-mono uppercase tracking-widest text-warm-beige font-semibold">Curated Collections</span>
          <h2 class="font-display font-bold text-2xl sm:text-3xl text-forest mt-1">Shop by Room Category</h2>
        </div>
        <router-link to="/catalog" class="text-xs font-semibold text-forest hover:text-dark-green flex items-center gap-1">
          <span>View full collection</span>
          <i class="bi bi-arrow-right text-xs"></i>
        </router-link>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div
          v-for="cat in catalogStore.categories"
          :key="cat.id"
          class="p-6 rounded-2xl bg-cream border border-light-border hover:border-warm-beige transition-all duration-300 hover:-translate-y-1 hover:shadow-card-hover cursor-pointer group flex flex-col justify-between"
          @click="browseCategory(cat.slug)"
        >
          <div class="space-y-3">
            <div class="w-12 h-12 rounded-xl bg-off-white border border-light-border flex items-center justify-center text-forest text-xl group-hover:scale-110 transition-transform shadow-subtle">
              <i v-if="cat.slug === 'living-room'" class="bi bi-lamp"></i>
              <i v-else-if="cat.slug === 'bedroom'" class="bi bi-moon-stars"></i>
              <i v-else-if="cat.slug === 'home-office'" class="bi bi-laptop"></i>
              <i v-else class="bi bi-cup-hot"></i>
            </div>
            <h3 class="font-display font-bold text-lg text-forest group-hover:text-dark-green transition-colors">
              {{ cat.name }}
            </h3>
            <p class="text-xs text-muted-gray leading-relaxed">
              {{ cat.description }}
            </p>
          </div>

          <div class="mt-6 pt-3 border-t border-light-border flex items-center justify-between text-xs font-mono text-muted-gray">
            <span>{{ cat.subcategories?.length || 0 }} Subcategories</span>
            <span class="text-forest group-hover:translate-x-1 transition-transform flex items-center gap-1 font-semibold">
              <span>Shop Now</span>
              <i class="bi bi-arrow-right text-[10px]"></i>
            </span>
          </div>
        </div>
      </div>
    </section>

    <!-- 3. Featured Curated Furniture Showcase (Quick-Add Enabled) -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
      <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-2">
        <div>
          <span class="text-xs font-mono uppercase tracking-widest text-warm-beige font-semibold">Handcrafted Pieces</span>
          <h2 class="font-display font-bold text-2xl sm:text-3xl text-forest mt-1">Featured Minimalist Furniture</h2>
        </div>
        <router-link to="/catalog" class="text-xs font-semibold text-forest hover:text-dark-green flex items-center gap-1">
          <span>Explore All 40 Pieces &rarr;</span>
        </router-link>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <FurnitureCard
          v-for="item in catalogStore.featured"
          :key="item.id"
          :furniture="item"
        />
      </div>
    </section>

    <!-- 4. Premium Differentiator: 3D Room Planning ("Know It Fits Before It Ships") -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
      <div class="p-8 sm:p-12 rounded-3xl bg-cream border border-light-border space-y-8 shadow-card">
        <div class="max-w-3xl space-y-3">
          <span class="text-xs font-mono uppercase tracking-widest text-warm-beige font-semibold">Our Signature Difference</span>
          <h2 class="font-display font-bold text-2xl sm:text-4xl text-forest">
            Never Buy Furniture That Doesn't Fit Again.
          </h2>
          <p class="text-charcoal text-sm leading-relaxed">
            Standard furniture shops leave you guessing if a sofa will block your hallway or dwarf your living room. SmartSpace provides guaranteed 1.000 scale 3D models and geometric verification for every single piece in our store.
          </p>
        </div>

        <!-- 2 Gateway Pathways -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
          <!-- Pathway 1: AI Room Photo Reconstruction -->
          <div
            class="p-6 rounded-2xl bg-off-white border border-light-border hover:border-warm-beige transition-all duration-300 shadow-subtle hover:shadow-card cursor-pointer group space-y-4"
            @click="openGateway('ai')"
          >
            <div class="w-12 h-12 rounded-xl bg-cream border border-light-border flex items-center justify-center text-2xl group-hover:scale-105 transition-transform">
              🤖
            </div>
            <div class="space-y-1">
              <span class="text-[10px] font-mono uppercase text-forest font-semibold">Instant Vision</span>
              <h3 class="font-display font-bold text-lg text-forest">AI Room Reconstruction</h3>
            </div>
            <p class="text-xs text-muted-gray leading-relaxed">
              Upload a snapshot of your room. Our AI detects your room style, natural lighting, and suggests initial floor dimensions.
            </p>
            <button
              type="button"
              class="w-full py-2.5 px-4 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-subtle transition-all flex items-center justify-center gap-2"
            >
              <span>Scan Room with AI</span>
              <i class="bi bi-arrow-right text-xs"></i>
            </button>
          </div>

          <!-- Pathway 2: Manual Precision Planner -->
          <div
            class="p-6 rounded-2xl bg-off-white border border-light-border hover:border-forest transition-all duration-300 shadow-subtle hover:shadow-card cursor-pointer group space-y-4"
            @click="openGateway('manual')"
          >
            <div class="w-12 h-12 rounded-xl bg-cream border border-light-border flex items-center justify-center text-2xl group-hover:scale-105 transition-transform">
              📐
            </div>
            <div class="space-y-1">
              <span class="text-[10px] font-mono uppercase text-forest font-semibold">Millimeter Precision</span>
              <h3 class="font-display font-bold text-lg text-forest">Interactive 3D Room Planner</h3>
            </div>
            <p class="text-xs text-muted-gray leading-relaxed">
              Input your exact room length, width, and ceiling height. Drag and drop any furniture piece with live collision detection.
            </p>
            <button
              type="button"
              class="w-full py-2.5 px-4 rounded-xl border border-forest text-forest hover:bg-forest hover:text-cream font-semibold text-xs transition-all flex items-center justify-center gap-2"
            >
              <span>Open 3D Canvas</span>
              <i class="bi bi-arrow-right text-xs"></i>
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- Room Creation Modal Triggered from Gateway -->
    <RoomCreationModal
      v-if="showCreateModal"
      @close="showCreateModal = false"
    />

  </div>
</template>
