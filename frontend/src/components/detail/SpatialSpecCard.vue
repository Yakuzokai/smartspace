<script setup lang="ts">
import type { Dimensions, ClearanceEnvelope } from '@/types/furniture'

defineProps<{
  dimensions: Dimensions
  clearanceEnvelope: ClearanceEnvelope
}>()
</script>

<template>
  <div class="p-6 rounded-3xl bg-cream border border-light-border shadow-card space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between pb-4 border-b border-light-border">
      <div class="flex items-center gap-2.5">
        <div class="w-8 h-8 rounded-lg bg-off-white border border-light-border flex items-center justify-center text-forest shadow-subtle">
          <i class="bi bi-aspect-ratio text-sm"></i>
        </div>
        <div>
          <h3 class="font-display font-semibold text-forest text-base">Authoritative Physical Specifications</h3>
          <p class="text-xs text-muted-gray">Deterministic bounds evaluated by mathematical geometry engine</p>
        </div>
      </div>

      <span class="px-2.5 py-1 rounded-full text-[11px] font-mono tracking-wide bg-warm-beige/25 border border-warm-beige/60 text-forest font-semibold">
        Scale: 1.000 Fixed
      </span>
    </div>

    <!-- 3D Bounding Dimensions Grid -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
      <!-- Width -->
      <div class="p-3.5 rounded-xl bg-off-white border border-light-border flex flex-col shadow-subtle">
        <span class="text-[11px] font-mono text-muted-gray uppercase tracking-wider">Width (X)</span>
        <span class="font-display font-bold text-xl text-charcoal mt-1">
          {{ dimensions.width_cm }} <span class="text-xs font-normal text-muted-gray font-sans">cm</span>
        </span>
        <span class="text-[11px] font-mono text-muted-gray mt-0.5">{{ dimensions.width_m }} m</span>
      </div>

      <!-- Depth -->
      <div class="p-3.5 rounded-xl bg-off-white border border-light-border flex flex-col shadow-subtle">
        <span class="text-[11px] font-mono text-muted-gray uppercase tracking-wider">Depth (Z)</span>
        <span class="font-display font-bold text-xl text-charcoal mt-1">
          {{ dimensions.depth_cm }} <span class="text-xs font-normal text-muted-gray font-sans">cm</span>
        </span>
        <span class="text-[11px] font-mono text-muted-gray mt-0.5">{{ dimensions.depth_m }} m</span>
      </div>

      <!-- Height -->
      <div class="p-3.5 rounded-xl bg-off-white border border-light-border flex flex-col shadow-subtle">
        <span class="text-[11px] font-mono text-muted-gray uppercase tracking-wider">Height (Y)</span>
        <span class="font-display font-bold text-xl text-charcoal mt-1">
          {{ dimensions.height_cm }} <span class="text-xs font-normal text-muted-gray font-sans">cm</span>
        </span>
        <span class="text-[11px] font-mono text-muted-gray mt-0.5">{{ dimensions.height_m }} m</span>
      </div>

      <!-- Footprint Area -->
      <div class="p-3.5 rounded-xl bg-off-white border border-light-border flex flex-col shadow-subtle">
        <span class="text-[11px] font-mono text-muted-gray uppercase tracking-wider">Floor Footprint</span>
        <span class="font-display font-bold text-xl text-forest mt-1">
          {{ dimensions.footprint_area_sqm }} <span class="text-xs font-normal text-muted-gray font-sans">m²</span>
        </span>
        <span class="text-[11px] font-mono text-muted-gray mt-0.5">Floor Required</span>
      </div>
    </div>

    <!-- Clearance Envelope Corridors -->
    <div class="p-4 rounded-2xl bg-off-white border border-light-border space-y-3 shadow-subtle">
      <div class="flex items-center justify-between">
        <h4 class="text-xs font-semibold text-forest uppercase tracking-wider flex items-center gap-2">
          <i class="bi bi-shield-check text-emerald-600"></i>
          Functional Clearance Corridors
        </h4>
        <span class="text-[11px] font-mono text-emerald-700 font-semibold">Ergonomic Standard</span>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
        <div class="flex items-center justify-between p-2.5 rounded-lg bg-cream border border-light-border">
          <span class="text-muted-gray">Front Clearance Required:</span>
          <span class="font-mono font-semibold text-charcoal">{{ clearanceEnvelope.front_m * 100 }} cm</span>
        </div>
        <div class="flex items-center justify-between p-2.5 rounded-lg bg-cream border border-light-border">
          <span class="text-muted-gray">Side Clearance Required:</span>
          <span class="font-mono font-semibold text-charcoal">{{ clearanceEnvelope.side_m * 100 }} cm</span>
        </div>
      </div>

      <p class="text-[11px] text-muted-gray leading-relaxed italic">
        * Clearances guarantee human circulation paths (c_front ≥ 75 cm, c_side ≥ 60 cm) evaluated during room layout placement.
      </p>
    </div>

  </div>
</template>
