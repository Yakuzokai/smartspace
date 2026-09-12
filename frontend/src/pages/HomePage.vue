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
  <div class="space-y-20 pb-20">
    
    <!-- 1. Hero Section (Exact Figma 2-Column Architectural Layout with CAD Grid) -->
    <section class="relative overflow-hidden bg-[#133930] text-cream pt-12 pb-20 lg:pt-16 lg:pb-28 border-b border-forest bg-[linear-gradient(to_right,rgba(255,255,255,0.04)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.04)_1px,transparent_1px)] bg-[size:40px_40px]">
      <!-- Ambient Lighting -->
      <div class="absolute -top-32 left-1/2 -translate-x-1/2 w-[900px] h-[450px] bg-forest/40 blur-[140px] rounded-full pointer-events-none"></div>
      
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          <!-- Left Column (Copy & CTAs) -->
          <div class="lg:col-span-6 space-y-6 text-left">
            <!-- Eyebrow Pill -->
            <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-forest/80 border border-warm-beige/30 text-xs font-mono tracking-wider text-warm-beige shadow-subtle">
              <span class="w-2 h-2 rounded-full bg-warm-beige"></span>
              <span>AI-ASSISTED SPATIAL PLANNING</span>
            </div>

            <!-- Headline with Serif Typography -->
            <div class="space-y-1">
              <h1 class="font-serif font-bold text-5xl sm:text-6xl lg:text-7xl text-cream tracking-tight leading-[1.1]">
                Design a Space <br />
                <span class="text-warm-beige">That Fits You.</span>
              </h1>
            </div>

            <!-- Subtitle -->
            <p class="text-cream/80 text-base sm:text-lg max-w-lg leading-relaxed font-normal">
              Discover furniture that matches your style, visualize it in your room, and make sure it fits before you buy.
            </p>

            <!-- Buttons -->
            <div class="flex flex-wrap items-center gap-4 pt-2">
              <button
                type="button"
                class="px-7 py-3.5 rounded-xl bg-warm-beige hover:bg-warm-beige-hover text-forest font-semibold text-sm shadow-glow-warm transition-all hover:scale-105 cursor-pointer"
                @click="openGateway('ai')"
              >
                <span>Design My Space</span>
              </button>

              <router-link
                to="/catalog"
                class="px-7 py-3.5 rounded-xl bg-forest/40 border border-cream/20 hover:border-warm-beige/60 text-cream font-medium text-sm transition-all hover:bg-forest/60"
              >
                <span>Explore Furniture</span>
              </router-link>
            </div>

            <!-- Thesis Positioning Statement -->
            <div class="pt-4">
              <p class="text-xs font-mono uppercase tracking-widest text-cream/60 font-semibold">
                AI RECOMMENDS · YOU DECIDE · GEOMETRY VERIFIES
              </p>
            </div>
          </div>

          <!-- Right Column (Hero Visual with Badges) -->
          <div class="lg:col-span-6 relative pt-6 lg:pt-0">
            <div class="relative rounded-3xl overflow-visible max-w-lg mx-auto lg:max-w-none">
              
              <!-- Main Living Room Image -->
              <div class="rounded-3xl overflow-hidden border border-cream/10 shadow-2xl bg-forest/60">
                <img
                  src="/hero-room.jpg"
                  alt="Living Room Spatial Visualization"
                  class="w-full h-[360px] sm:h-[420px] lg:h-[440px] object-cover rounded-3xl hover:scale-105 transition-transform duration-700"
                />
              </div>

              <!-- Top-Right Floating Pill: "AI Powered ✦" -->
              <div class="absolute top-4 right-4 z-20">
                <div class="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-forest/90 backdrop-blur-md border border-light-border/20 text-xs font-semibold text-cream shadow-lg">
                  <span>AI Powered</span>
                  <span class="text-warm-beige text-sm">✦</span>
                </div>
              </div>

              <!-- Bottom-Left Floating Card: "Space Compatibility 92 / 100" -->
              <div class="absolute -bottom-6 -left-4 sm:-left-6 z-20 p-5 rounded-2xl bg-cream text-charcoal border border-light-border shadow-2xl space-y-2 min-w-[210px] animate-in fade-in slide-in-from-bottom-4 duration-500">
                <span class="text-[10px] font-mono uppercase tracking-wider text-muted-gray block font-semibold">
                  Space Compatibility
                </span>
                <div class="flex items-baseline gap-1">
                  <span class="font-serif font-bold text-3xl text-forest">92</span>
                  <span class="text-xs font-mono text-muted-gray">/ 100</span>
                </div>
                <ul class="space-y-1 text-xs text-charcoal pt-1 font-medium">
                  <li class="flex items-center gap-1.5">
                    <i class="bi bi-check2 text-forest font-bold text-sm"></i>
                    <span class="text-[11px]">Boundary Fit</span>
                  </li>
                  <li class="flex items-center gap-1.5">
                    <i class="bi bi-check2 text-forest font-bold text-sm"></i>
                    <span class="text-[11px]">Clearance</span>
                  </li>
                  <li class="flex items-center gap-1.5">
                    <i class="bi bi-check2 text-forest font-bold text-sm"></i>
                    <span class="text-[11px]">Utilization</span>
                  </li>
                </ul>
              </div>

            </div>
          </div>

        </div>

        <!-- Metrics Strip (Seamlessly integrated underneath) -->
        <div class="mt-16 pt-8 border-t border-forest/60 grid grid-cols-2 sm:grid-cols-4 gap-4 max-w-4xl mx-auto text-left">
          <div class="p-4 rounded-xl bg-forest/50 border border-light-border/20 backdrop-blur-sm">
            <span class="font-display font-bold text-2xl text-cream block">40</span>
            <span class="text-xs text-cream/70">Curated 3D Products</span>
          </div>
          <div class="p-4 rounded-xl bg-forest/50 border border-light-border/20 backdrop-blur-sm">
            <span class="font-display font-bold text-2xl text-warm-beige block">1.000</span>
            <span class="text-xs text-cream/70">Authoritative Scale</span>
          </div>
          <div class="p-4 rounded-xl bg-forest/50 border border-light-border/20 backdrop-blur-sm">
            <span class="font-display font-bold text-2xl text-cream block">5-Step</span>
            <span class="text-xs text-cream/70">Geometric Engine</span>
          </div>
          <div class="p-4 rounded-xl bg-forest/50 border border-light-border/20 backdrop-blur-sm">
            <span class="font-display font-bold text-2xl text-warm-beige block">Dual</span>
            <span class="text-xs text-cream/70">AI / Manual Gateway</span>
          </div>
        </div>

      </div>
    </section>

    <!-- 2. SPATIAL PLANNING FIRST (Core Architecture & Gateway) -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
      <div class="text-center max-w-2xl mx-auto space-y-2">
        <span class="text-xs font-mono uppercase tracking-widest text-warm-beige font-semibold">Spatial Planning First</span>
        <h2 class="font-display font-bold text-3xl sm:text-4xl text-forest">
          How Do You Want to Design Your Space?
        </h2>
        <p class="text-muted-gray text-sm leading-relaxed">
          Both pathways converge into the identical 3D Room Planner, backed by deterministic boundary and collision checks.
        </p>
      </div>

      <!-- Gateway 2-Column Cards -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
        <!-- Pathway 1: AI-Assisted -->
        <div
          class="p-8 rounded-3xl bg-cream border border-light-border hover:border-warm-beige transition-all duration-300 shadow-card hover:shadow-card-hover flex flex-col justify-between space-y-6 group cursor-pointer"
          @click="openGateway('ai')"
        >
          <div class="space-y-4">
            <div class="w-14 h-14 rounded-2xl bg-off-white border border-light-border flex items-center justify-center text-3xl shadow-subtle group-hover:scale-110 transition-transform">
              🤖
            </div>
            <div class="space-y-1">
              <span class="text-[11px] font-mono uppercase tracking-wider text-forest font-semibold">Pathway A</span>
              <h3 class="font-display font-bold text-2xl text-forest">AI-Assisted Reconstruction</h3>
            </div>
            <p class="text-charcoal text-xs leading-relaxed">
              Upload a room photo. Our perceptual AI model analyzes lighting, room style, color palette, and suggests preliminary dimensions.
            </p>

            <ul class="space-y-2 text-xs text-muted-gray pt-2">
              <li class="flex items-center gap-2">
                <i class="bi bi-check2 text-forest font-bold"></i>
                <span>Upload real room photograph</span>
              </li>
              <li class="flex items-center gap-2">
                <i class="bi bi-check2 text-forest font-bold"></i>
                <span>AI detects style & dimension suggestions</span>
              </li>
              <li class="flex items-center gap-2">
                <i class="bi bi-check2 text-forest font-bold"></i>
                <span>You confirm authoritative measurements</span>
              </li>
            </ul>
          </div>

          <button
            type="button"
            class="w-full py-3 px-4 rounded-xl bg-forest hover:bg-dark-green text-cream font-semibold text-xs shadow-glow transition-all flex items-center justify-center gap-2"
          >
            <span>Use AI Assistance</span>
            <i class="bi bi-arrow-right text-xs"></i>
          </button>
        </div>

        <!-- Pathway 2: Manual Planning -->
        <div
          class="p-8 rounded-3xl bg-cream border border-light-border hover:border-forest transition-all duration-300 shadow-card hover:shadow-card-hover flex flex-col justify-between space-y-6 group cursor-pointer"
          @click="openGateway('manual')"
        >
          <div class="space-y-4">
            <div class="w-14 h-14 rounded-2xl bg-off-white border border-light-border flex items-center justify-center text-3xl shadow-subtle group-hover:scale-110 transition-transform">
              🖐
            </div>
            <div class="space-y-1">
              <span class="text-[11px] font-mono uppercase tracking-wider text-forest font-semibold">Pathway B</span>
              <h3 class="font-display font-bold text-2xl text-forest">Manual Spatial Planning</h3>
            </div>
            <p class="text-charcoal text-xs leading-relaxed">
              Have your tape measure ready? Enter your exact room length, width, and ceiling height directly to start spatial composition immediately.
            </p>

            <ul class="space-y-2 text-xs text-muted-gray pt-2">
              <li class="flex items-center gap-2">
                <i class="bi bi-check2 text-forest font-bold"></i>
                <span>Direct centimeter & millimeter precision</span>
              </li>
              <li class="flex items-center gap-2">
                <i class="bi bi-check2 text-forest font-bold"></i>
                <span>Custom room shapes & wall limits</span>
              </li>
              <li class="flex items-center gap-2">
                <i class="bi bi-check2 text-forest font-bold"></i>
                <span>Immediate 3D floor boundary generation</span>
              </li>
            </ul>
          </div>

          <button
            type="button"
            class="w-full py-3 px-4 rounded-xl bg-off-white border border-light-border hover:border-forest text-forest hover:bg-cream font-semibold text-xs transition-all flex items-center justify-center gap-2"
          >
            <span>Start Manually</span>
            <i class="bi bi-arrow-right text-xs"></i>
          </button>
        </div>
      </div>

      <!-- Convergence & Pipeline Workflow Visualizer -->
      <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card max-w-4xl mx-auto space-y-4">
        <div class="flex items-center justify-between text-xs font-mono text-muted-gray border-b border-light-border pb-3">
          <span class="text-forest font-bold uppercase tracking-wider flex items-center gap-1.5">
            <i class="bi bi-diagram-3 text-forest"></i>
            Architectural Hierarchy
          </span>
          <span class="text-forest font-semibold">Both Paths Converge Into Three.js Canvas</span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-4 gap-3 text-center text-xs">
          <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-1">
            <span class="text-[10px] font-mono text-warm-beige font-bold block">STEP 1</span>
            <h4 class="font-semibold text-forest">Gateway Ingestion</h4>
            <p class="text-[11px] text-muted-gray">AI Room Reconstruction or Manual Dimension Entry</p>
          </div>
          <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-1">
            <span class="text-[10px] font-mono text-warm-beige font-bold block">STEP 2</span>
            <h4 class="font-semibold text-forest">3D Spatial Planner</h4>
            <p class="text-[11px] text-muted-gray">Interactive Three.js Canvas with 1.000 Scale GLB Models</p>
          </div>
          <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-1">
            <span class="text-[10px] font-mono text-warm-beige font-bold block">STEP 3</span>
            <h4 class="font-semibold text-forest">Deterministic Engine</h4>
            <p class="text-[11px] text-muted-gray">Boundary Fit · AABB Collision · Circulation Clearance</p>
          </div>
          <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-1">
            <span class="text-[10px] font-mono text-warm-beige font-bold block">STEP 4</span>
            <h4 class="font-semibold text-forest">Certified Compatibility</h4>
            <p class="text-[11px] text-muted-gray">0–100% Score & Real Curated Catalog Selection</p>
          </div>
        </div>
      </div>
    </section>

    <!-- 3. Categories Grid Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
      <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-2">
        <div>
          <span class="text-xs font-mono uppercase tracking-widest text-warm-beige font-semibold">Room Environments</span>
          <h2 class="font-display font-bold text-2xl sm:text-3xl text-forest mt-1">Browse by Room Category</h2>
        </div>
        <router-link to="/catalog" class="text-xs font-semibold text-forest hover:text-dark-green flex items-center gap-1">
          <span>View full catalog</span>
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
              <span>Browse</span>
              <i class="bi bi-arrow-right text-[10px]"></i>
            </span>
          </div>
        </div>
      </div>
    </section>

    <!-- 4. Featured Curated Furniture Showcase (Connected to Laravel API) -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-6">
      <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-2">
        <div>
          <span class="text-xs font-mono uppercase tracking-widest text-warm-beige font-semibold">Curated Physical Assets</span>
          <h2 class="font-display font-bold text-2xl sm:text-3xl text-forest mt-1">Featured Spatial Pieces</h2>
        </div>
        <router-link to="/catalog" class="text-xs font-semibold text-forest hover:text-dark-green flex items-center gap-1">
          <span>Open Full Catalog (40 Items) &rarr;</span>
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

    <!-- 5. Architectural Philosophy Section -->
    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="p-8 sm:p-12 rounded-3xl bg-cream border border-light-border space-y-8 shadow-card">
        <div class="max-w-3xl space-y-3">
          <span class="text-xs font-mono uppercase tracking-widest text-warm-beige font-semibold">Authoritative Spatial Philosophy</span>
          <h2 class="font-display font-bold text-2xl sm:text-4xl text-forest">
            Generative AI Images Don't Fit Into Real Rooms. SmartSpace Does.
          </h2>
          <p class="text-charcoal text-sm leading-relaxed">
            Standard AI image generators hallucinate beautiful interiors with nonexistent proportions, impossible clearances, and made-up furniture that cannot be purchased. SmartSpace solves this with an architectural separation of concerns.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 pt-4 text-xs">
          <div class="p-6 rounded-2xl bg-off-white border border-light-border space-y-3 shadow-subtle">
            <div class="w-10 h-10 rounded-xl bg-cream border border-light-border flex items-center justify-center text-forest text-xl">
              <i class="bi bi-robot"></i>
            </div>
            <h4 class="font-semibold text-forest text-sm">1. AI Visual Perception</h4>
            <p class="text-muted-gray leading-relaxed">
              FastAPI & Gemini analyze your room photo to detect aesthetic style, lighting direction, color palettes, and estimated dimensions.
            </p>
          </div>

          <div class="p-6 rounded-2xl bg-off-white border border-light-border space-y-3 shadow-subtle">
            <div class="w-10 h-10 rounded-xl bg-cream border border-light-border flex items-center justify-center text-forest text-xl">
              <i class="bi bi-rulers"></i>
            </div>
            <h4 class="font-semibold text-forest text-sm">2. Authoritative Fit Engine</h4>
            <p class="text-muted-gray leading-relaxed">
              Your confirmed room dimensions and physical catalog bounding boxes are evaluated mathematically for zero collision and unencumbered walking corridors.
            </p>
          </div>

          <div class="p-6 rounded-2xl bg-off-white border border-light-border space-y-3 shadow-subtle">
            <div class="w-10 h-10 rounded-xl bg-cream border border-light-border flex items-center justify-center text-forest text-xl">
              <i class="bi bi-box-seam"></i>
            </div>
            <h4 class="font-semibold text-forest text-sm">3. Curated 3D Assets</h4>
            <p class="text-muted-gray leading-relaxed">
              Every item has an actual GLB model locked to 1.000 scale, verified stock availability, and physical specs in our Laravel database.
            </p>
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
