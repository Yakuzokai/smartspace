<script setup lang="ts">
import { ref } from 'vue'
import type { Furniture } from '@/types/furniture'
import RoomCreationModal from '@/components/room/RoomCreationModal.vue'

defineProps<{
  furniture: Furniture
}>()

const emit = defineEmits<{
  (e: 'view3d'): void
}>()

const showRoomModal = ref(false)
</script>

<template>
  <div class="space-y-4">
    <!-- Milestone 4: Interactive 3D GLB Model Card -->
    <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card relative overflow-hidden">
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 pb-4 border-b border-light-border">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-off-white border border-light-border flex items-center justify-center text-forest text-xl shadow-subtle">
            <i class="bi bi-box"></i>
          </div>
          <div>
            <div class="flex items-center gap-2">
              <h3 class="font-display font-semibold text-forest text-base">Individual 3D Product Viewer</h3>
              <span class="px-2 py-0.5 rounded text-[10px] font-mono uppercase bg-forest/10 border border-forest/30 text-forest font-semibold">
                Milestone 4 • Active
              </span>
            </div>
            <p class="text-xs text-muted-gray">Interactive 360° Orbit, Bounding Box HUD & Locked 1.000 Scale</p>
          </div>
        </div>

        <button
          type="button"
          class="px-4 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all flex items-center gap-2 cursor-pointer shrink-0"
          @click="emit('view3d')"
        >
          <i class="bi bi-box text-xs"></i>
          <span>Launch 3D Viewer</span>
        </button>
      </div>

      <!-- Quick Feature Specs -->
      <div class="mt-4 grid grid-cols-1 sm:grid-cols-3 gap-2 text-center text-xs font-mono">
        <div class="p-2.5 rounded-xl bg-off-white border border-light-border">
          <span class="text-forest font-bold block">1.000 Scale</span>
          <span class="text-[10px] text-muted-gray">Locked Dimensions</span>
        </div>
        <div class="p-2.5 rounded-xl bg-off-white border border-light-border">
          <span class="text-forest font-bold block">OrbitControls</span>
          <span class="text-[10px] text-muted-gray">360° Rotate & Zoom</span>
        </div>
        <div class="p-2.5 rounded-xl bg-off-white border border-light-border">
          <span class="text-forest font-bold block">3 Lighting Modes</span>
          <span class="text-[10px] text-muted-gray">Showroom / Day / Sun</span>
        </div>
      </div>
    </div>

    <!-- Milestone 5 Bridge: "Visualize in My Room" (Dual AI / Manual Gateway) -->
    <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card relative overflow-hidden">
      <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 pb-4 border-b border-light-border">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-off-white border border-light-border flex items-center justify-center text-forest text-xl shadow-subtle">
            <i class="bi bi-house-door"></i>
          </div>
          <div>
            <div class="flex items-center gap-2">
              <h3 class="font-display font-semibold text-forest text-base">Visualize in My 3D Room</h3>
              <span class="px-2 py-0.5 rounded text-[10px] font-mono uppercase bg-warm-beige/25 border border-warm-beige/60 text-forest font-semibold">
                Milestone 5
              </span>
            </div>
            <p class="text-xs text-muted-gray">Deterministic Boundary, Collision & Live Compatibility HUD</p>
          </div>
        </div>

        <button
          type="button"
          class="px-4 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all flex items-center gap-2 cursor-pointer"
          @click="showRoomModal = true"
        >
          <span>Choose Room Design Flow</span>
          <i class="bi bi-arrow-right text-xs"></i>
        </button>
      </div>

      <!-- Explanation of the Dual Pathway -->
      <div class="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
        <div class="p-4 rounded-2xl bg-off-white border border-light-border space-y-1.5 shadow-subtle">
          <div class="flex items-center gap-1.5 font-semibold text-forest">
            <span class="text-base">🤖</span>
            <span>AI-Assisted Room Reconstruction</span>
          </div>
          <p class="text-muted-gray text-[11px] leading-relaxed">
            Upload your room photo. AI estimates visual characteristics and optional dimension suggestions, while your confirmed dimensions remain authoritative for physical calculations.
          </p>
        </div>

        <div class="p-4 rounded-2xl bg-off-white border border-light-border space-y-1.5 shadow-subtle">
          <div class="flex items-center gap-1.5 font-semibold text-forest">
            <span class="text-base">🖐️</span>
            <span>Manual Spatial Planning</span>
          </div>
          <p class="text-muted-gray text-[11px] leading-relaxed">
            Directly enter your room's physical dimensions (width, length, height). Place this furniture piece into the 3D room canvas and evaluate fit.
          </p>
        </div>
      </div>
    </div>

    <!-- Room Creation Modal (Previewing the Dual Workflow) -->
    <RoomCreationModal
      v-if="showRoomModal"
      :selected-furniture="furniture"
      @close="showRoomModal = false"
    />
  </div>
</template>
