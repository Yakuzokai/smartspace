<template>
  <footer class="mt-20 border-t border-light-border bg-cream text-charcoal text-xs">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-8 mb-12">
        
        <!-- Column 1: System Info & Thesis -->
        <div class="space-y-3 md:col-span-2">
          <div class="flex items-center gap-2">
            <div class="w-7 h-7 rounded-lg bg-off-white border border-light-border p-0.5 flex items-center justify-center shadow-subtle">
              <img src="/logo.png" alt="SmartSpace" class="w-full h-full object-contain" />
            </div>
            <span class="font-display font-bold text-forest text-base">SmartSpace</span>
          </div>
          <p class="font-display font-medium text-forest text-sm italic">
            “AI recommends. You decide. Geometry verifies.”
          </p>
          <p class="text-muted-gray text-xs leading-relaxed max-w-md">
            An authoritative spatial planning system pairing AI aesthetic understanding with a deterministic mathematical geometry engine, ensuring furniture recommendations physically fit your room's real-world constraints.
          </p>
          <div class="flex flex-wrap gap-2 pt-1 font-mono text-[11px]">
            <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-charcoal">Laravel 11</span>
            <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-charcoal">Vue 3 + Vite</span>
            <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-charcoal">Three.js</span>
            <span class="px-2 py-0.5 rounded bg-off-white border border-light-border text-forest font-semibold">Deterministic Engine</span>
          </div>
        </div>

        <!-- Column 2: Architecture & Milestones -->
        <div class="space-y-2">
          <h4 class="text-forest font-semibold uppercase tracking-wider text-[11px]">System Milestones</h4>
          <ul class="space-y-1.5 text-muted-gray text-xs">
            <li class="flex items-center gap-1.5 text-emerald-700 font-medium">
              <i class="bi bi-check-circle-fill text-xs text-emerald-600"></i> M1: DB & Curated Items (40)
            </li>
            <li class="flex items-center gap-1.5 text-emerald-700 font-medium">
              <i class="bi bi-check-circle-fill text-xs text-emerald-600"></i> M2A: Geometry Engine (5-Step)
            </li>
            <li class="flex items-center gap-1.5 text-emerald-700 font-medium">
              <i class="bi bi-check-circle-fill text-xs text-emerald-600"></i> M2B: REST API & Sanctum
            </li>
            <li class="flex items-center gap-1.5 text-forest font-semibold">
              <i class="bi bi-record-circle text-xs text-forest animate-pulse"></i> M3: Vue 3 Catalog UI (Now)
            </li>
            <li class="flex items-center gap-1.5 text-muted-gray">
              <i class="bi bi-circle text-xs"></i> M4: 3D Product Viewer (GLB)
            </li>
            <li class="flex items-center gap-1.5 text-muted-gray">
              <i class="bi bi-circle text-xs"></i> M5: 3D Room Planner + HUD
            </li>
          </ul>
        </div>

        <!-- Column 3: Design Principles -->
        <div class="space-y-2">
          <h4 class="text-forest font-semibold uppercase tracking-wider text-[11px]">Core Thesis</h4>
          <p class="text-muted-gray text-xs leading-relaxed">
            <span class="text-charcoal font-medium">Physical Truth:</span> Furniture models maintain locked 1.0 scale with real millimeter bounds.
          </p>
          <p class="text-muted-gray text-xs leading-relaxed">
            <span class="text-charcoal font-medium">Explainable Scores:</span> Clear breakdown across boundary, collision, clearances, and walkability.
          </p>
        </div>
      </div>

      <div class="pt-8 border-t border-light-border flex flex-col sm:flex-row items-center justify-between gap-4 text-muted-gray">
        <p>© 2026 SmartSpace Capstone Project. Physical dimensions authoritative.</p>
        <p class="font-mono text-[11px] text-forest font-semibold">Authoritative Scale Locked: 1.000</p>
      </div>
    </div>
  </footer>
</template>
