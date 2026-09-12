<script setup lang="ts">
import { ref, computed } from 'vue'
import type { RoomProject, ClientPlacedFurniture, CompatibilityBreakdown } from '@/types/project'

const props = defineProps<{
  project: RoomProject
  placedItems: ClientPlacedFurniture[]
  selectedUuid: string | null
  isDirty: boolean
  saving: boolean
  authoritativeEvaluation: CompatibilityBreakdown | null
}>()

defineEmits<{
  (e: 'select', uuid: string): void
  (e: 'remove', uuid: string): void
  (e: 'focus', x: number, z: number): void
  (e: 'saveAndCertify'): void
}>()

const isOpen = ref(true)
const activeTab = ref<'geometry' | 'items' | 'budget'>('geometry')

// Optional user-specified room budget target
const budgetTarget = ref<number>(85000)

// Calculate total furniture cost
const totalCost = computed(() => {
  return props.placedItems.reduce((sum, item) => {
    return sum + Number(item.furniture?.price || 0)
  }, 0)
})

const budgetRemaining = computed(() => {
  return budgetTarget.value - totalCost.value
})

const budgetUsedPercent = computed(() => {
  if (budgetTarget.value <= 0) return 0
  return Math.min(100, Math.round((totalCost.value / budgetTarget.value) * 100))
})

// Check if any item currently has client preview violations
const hasPreviewViolations = computed(() => {
  return props.placedItems.some(
    (i) => i.status === 'collision' || i.status === 'out_of_bounds'
  )
})

const hasClearanceWarnings = computed(() => {
  return props.placedItems.some((i) => i.status === 'clearance_warning')
})

// Current authoritative evaluation (falls back to project.score_breakdown if not freshly evaluated)
const evaluation = computed<CompatibilityBreakdown | null>(() => {
  return props.authoritativeEvaluation || props.project.score_breakdown || null
})

// 5-factor breakdown scores from authoritative Laravel SpaceCompatibilityService
const boundaryScore = computed(() => {
  return evaluation.value?.breakdown?.boundary_fit?.score ?? (props.isDirty ? '—' : 30)
})

const collisionScore = computed(() => {
  return evaluation.value?.breakdown?.collision?.score ?? (props.isDirty ? '—' : 25)
})

const clearanceScore = computed(() => {
  return evaluation.value?.breakdown?.clearance?.score ?? (props.isDirty ? '—' : 25)
})

const utilizationScore = computed(() => {
  return evaluation.value?.breakdown?.utilization?.score ?? (props.isDirty ? '—' : 10)
})

const fitnessScore = computed(() => {
  return evaluation.value?.breakdown?.room_fitness?.score ?? (props.isDirty ? '—' : 10)
})

const certifiedScore = computed(() => {
  if (props.isDirty) return null
  return evaluation.value?.total_score ?? props.project.compatibility_score ?? 100
})
</script>

<template>
  <div class="relative flex h-full z-20">
    <!-- Main Inspector Drawer -->
    <div
      class="h-full bg-cream/95 backdrop-blur-md border-l border-light-border flex flex-col transition-all duration-300 shadow-card"
      :class="isOpen ? 'w-84 sm:w-96' : 'w-0 overflow-hidden border-none'"
    >
      <!-- Header -->
      <div class="p-4 border-b border-light-border space-y-3 shrink-0">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="text-lg">📐</span>
            <div>
              <h2 class="font-display font-bold text-base text-forest leading-tight">
                Spatial Engine
              </h2>
              <span class="text-[10px] font-mono text-muted-gray block">
                Deterministic Verification HUD
              </span>
            </div>
          </div>
          <button
            type="button"
            class="p-1 rounded-lg text-muted-gray hover:text-charcoal hover:bg-off-white text-xs cursor-pointer"
            title="Collapse Inspector"
            @click="isOpen = false"
          >
            ▶
          </button>
        </div>

        <!-- Mode / Status Header Card -->
        <div
          class="p-3.5 rounded-2xl border transition-all"
          :class="
            isDirty
              ? 'bg-amber-50/80 border-amber-200'
              : 'bg-emerald-50/80 border-emerald-200'
          "
        >
          <div class="flex items-start justify-between">
            <div>
              <span
                class="text-[10px] font-mono uppercase tracking-wider font-bold block"
                :class="isDirty ? 'text-amber-800' : 'text-emerald-800'"
              >
                {{ isDirty ? 'Preview — Not Yet Certified' : 'Spatial Engine Certified ✓' }}
              </span>
              <div class="flex items-baseline gap-1.5 mt-0.5">
                <span
                  class="font-display font-extrabold text-3xl"
                  :class="isDirty ? 'text-amber-900' : 'text-emerald-900'"
                >
                  {{ certifiedScore !== null ? certifiedScore : '—' }}
                </span>
                <span class="text-xs font-mono font-semibold text-muted-gray">/ 100</span>
              </div>
            </div>

            <!-- Certified Badge -->
            <span
              class="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold uppercase"
              :class="
                isDirty
                  ? 'bg-amber-200/60 text-amber-900'
                  : 'bg-emerald-200/60 text-emerald-900'
              "
            >
              {{ isDirty ? 'Draft Edits' : (evaluation?.badge || 'VERIFIED') }}
            </span>
          </div>

          <!-- Helper Description -->
          <p class="text-[11px] leading-relaxed mt-2 text-charcoal/80">
            <template v-if="isDirty">
              <span v-if="hasPreviewViolations" class="text-red-700 font-semibold block">
                ⚠️ Client preview detected potential wall breaches or collisions.
              </span>
              <span v-else-if="hasClearanceWarnings" class="text-amber-800 font-semibold block">
                ⚠️ Client preview detected clearance proximity warnings. Click "Save & Certify" to evaluate.
              </span>
              <span v-else class="text-amber-800 block">
                Instant client preview active. Click "Save & Certify" to execute Laravel's authoritative spatial calculation.
              </span>
            </template>
            <template v-else>
              {{ evaluation?.description || 'All placed furniture complies with boundary, clearance, and collision rules.' }}
            </template>
          </p>
        </div>

        <!-- Primary Action: Save & Certify -->
        <button
          type="button"
          class="w-full py-2.5 px-4 rounded-xl font-semibold text-xs transition-all shadow-glow flex items-center justify-center gap-2 cursor-pointer"
          :class="
            isDirty
              ? 'bg-forest hover:bg-dark-green text-cream'
              : 'bg-off-white hover:bg-light-border/40 text-forest border border-light-border'
          "
          :disabled="saving"
          @click="$emit('saveAndCertify')"
        >
          <span v-if="saving" class="w-3.5 h-3.5 border-2 border-current border-t-transparent rounded-full animate-spin"></span>
          <span>{{ saving ? 'Verifying with Laravel...' : (isDirty ? 'Save & Certify Geometry' : 'Re-verify Geometry') }}</span>
        </button>

        <!-- Tab Selector -->
        <div class="flex items-center bg-off-white rounded-xl p-0.5 border border-light-border text-xs">
          <button
            type="button"
            class="flex-1 py-1.5 rounded-lg font-medium transition-all cursor-pointer text-center"
            :class="
              activeTab === 'geometry'
                ? 'bg-forest text-cream font-semibold shadow-sm'
                : 'text-charcoal hover:text-forest'
            "
            @click="activeTab = 'geometry'"
          >
            5 Factors
          </button>
          <button
            type="button"
            class="flex-1 py-1.5 rounded-lg font-medium transition-all cursor-pointer text-center"
            :class="
              activeTab === 'items'
                ? 'bg-forest text-cream font-semibold shadow-sm'
                : 'text-charcoal hover:text-forest'
            "
            @click="activeTab = 'items'"
          >
            Items ({{ placedItems.length }})
          </button>
          <button
            type="button"
            class="flex-1 py-1.5 rounded-lg font-medium transition-all cursor-pointer text-center"
            :class="
              activeTab === 'budget'
                ? 'bg-forest text-cream font-semibold shadow-sm'
                : 'text-charcoal hover:text-forest'
            "
            @click="activeTab = 'budget'"
          >
            Budget
          </button>
        </div>
      </div>

      <!-- Tab 1: 5 Factors Breakdown -->
      <div v-if="activeTab === 'geometry'" class="flex-1 overflow-y-auto p-4 space-y-4">
        <!-- Factor 1: Boundary Fit (30 pts) -->
        <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-2 shadow-subtle">
          <div class="flex items-center justify-between text-xs">
            <div class="flex items-center gap-1.5">
              <span>🔲</span>
              <span class="font-semibold text-forest">Boundary Fit</span>
            </div>
            <span class="font-mono font-bold text-xs" :class="boundaryScore === 30 ? 'text-emerald-700' : 'text-red-700'">
              {{ boundaryScore }} / 30 pts
            </span>
          </div>
          <div class="w-full h-1.5 bg-light-border rounded-full overflow-hidden">
            <div
              class="h-full transition-all duration-500 rounded-full"
              :class="boundaryScore === 30 ? 'bg-emerald-600' : 'bg-red-500'"
              :style="{ width: `${typeof boundaryScore === 'number' ? (boundaryScore / 30) * 100 : 100}%` }"
            ></div>
          </div>
          <p class="text-[11px] text-muted-gray leading-tight">
            Verifies that all furniture resides completely inside the room's walls and ceiling perimeter.
          </p>
        </div>

        <!-- Factor 2: Collision Free (25 pts) -->
        <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-2 shadow-subtle">
          <div class="flex items-center justify-between text-xs">
            <div class="flex items-center gap-1.5">
              <span>⚡</span>
              <span class="font-semibold text-forest">Collision Free</span>
            </div>
            <span class="font-mono font-bold text-xs" :class="collisionScore === 25 ? 'text-emerald-700' : 'text-red-700'">
              {{ collisionScore }} / 25 pts
            </span>
          </div>
          <div class="w-full h-1.5 bg-light-border rounded-full overflow-hidden">
            <div
              class="h-full transition-all duration-500 rounded-full"
              :class="collisionScore === 25 ? 'bg-emerald-600' : 'bg-red-500'"
              :style="{ width: `${typeof collisionScore === 'number' ? (collisionScore / 25) * 100 : 100}%` }"
            ></div>
          </div>
          <p class="text-[11px] text-muted-gray leading-tight">
            Separating axis theorem (OBB) overlap check ensuring furniture items never physically intersect.
          </p>
        </div>

        <!-- Factor 3: Clearance & Circulation (25 pts) -->
        <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-2 shadow-subtle">
          <div class="flex items-center justify-between text-xs">
            <div class="flex items-center gap-1.5">
              <span>🚶</span>
              <span class="font-semibold text-forest">Clearance & Walkways</span>
            </div>
            <span class="font-mono font-bold text-xs text-charcoal">
              {{ clearanceScore }} / 25 pts
            </span>
          </div>
          <div class="w-full h-1.5 bg-light-border rounded-full overflow-hidden">
            <div
              class="h-full bg-forest transition-all duration-500 rounded-full"
              :style="{ width: `${typeof clearanceScore === 'number' ? (clearanceScore / 25) * 100 : 100}%` }"
            ></div>
          </div>
          <p class="text-[11px] text-muted-gray leading-tight">
            Functional clearance envelopes (e.g. 75 cm in front of sofas, 60 cm beside beds).
          </p>
        </div>

        <!-- Factor 4: Space Utilization (10 pts) -->
        <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-2 shadow-subtle">
          <div class="flex items-center justify-between text-xs">
            <div class="flex items-center gap-1.5">
              <span>📐</span>
              <span class="font-semibold text-forest">Space Utilization</span>
            </div>
            <span class="font-mono font-bold text-xs text-charcoal">
              {{ utilizationScore }} / 10 pts
            </span>
          </div>
          <div class="w-full h-1.5 bg-light-border rounded-full overflow-hidden">
            <div
              class="h-full bg-warm-beige transition-all duration-500 rounded-full"
              :style="{ width: `${typeof utilizationScore === 'number' ? (utilizationScore / 10) * 100 : 80}%` }"
            ></div>
          </div>
          <p class="text-[11px] text-muted-gray leading-tight">
            Ratio of occupied floor area versus comfortable circulation (optimal range: 25% – 45%).
          </p>
        </div>

        <!-- Factor 5: Room Fitness (10 pts) -->
        <div class="p-3 rounded-2xl bg-off-white border border-light-border space-y-2 shadow-subtle">
          <div class="flex items-center justify-between text-xs">
            <div class="flex items-center gap-1.5">
              <span>🏷️</span>
              <span class="font-semibold text-forest">Room Type Fitness</span>
            </div>
            <span class="font-mono font-bold text-xs text-charcoal">
              {{ fitnessScore }} / 10 pts
            </span>
          </div>
          <div class="w-full h-1.5 bg-light-border rounded-full overflow-hidden">
            <div
              class="h-full bg-forest transition-all duration-500 rounded-full"
              :style="{ width: `${typeof fitnessScore === 'number' ? (fitnessScore / 10) * 100 : 100}%` }"
            ></div>
          </div>
          <p class="text-[11px] text-muted-gray leading-tight">
            Categorical compatibility of placed pieces for {{ project.room_type.replace('_', ' ') }}.
          </p>
        </div>

        <!-- Authoritative Notes / Violations -->
        <div v-if="evaluation?.evaluation_notes && evaluation.evaluation_notes.length > 0" class="space-y-1.5 pt-2">
          <span class="text-[11px] font-mono text-muted-gray uppercase block font-semibold">
            Engine Notes
          </span>
          <div
            v-for="(note, idx) in evaluation.evaluation_notes"
            :key="idx"
            class="p-2.5 rounded-xl bg-off-white border border-light-border text-[11px] text-charcoal flex items-start gap-2"
          >
            <span>ℹ️</span>
            <span>{{ note }}</span>
          </div>
        </div>
      </div>

      <!-- Tab 2: Placed Items List -->
      <div v-else-if="activeTab === 'items'" class="flex-1 overflow-y-auto p-4 space-y-3">
        <div v-if="placedItems.length === 0" class="py-12 text-center space-y-2">
          <p class="text-xs text-muted-gray">No furniture placed in room yet.</p>
          <p class="text-[11px] text-muted-gray">Select items from the catalog on the left to add.</p>
        </div>

        <div
          v-else
          v-for="item in placedItems"
          :key="item.uuid"
          class="p-3 rounded-2xl border transition-all space-y-2 cursor-pointer"
          :class="
            item.uuid === selectedUuid
              ? 'bg-cream border-forest shadow-card'
              : 'bg-off-white border-light-border hover:border-warm-beige'
          "
          @click="$emit('select', item.uuid)"
        >
          <div class="flex items-start justify-between">
            <div class="space-y-0.5 text-left">
              <span class="font-display font-semibold text-xs text-forest block">
                {{ item.furniture?.name }}
              </span>
              <span class="text-[10px] font-mono text-muted-gray">
                {{ item.furniture?.dimensions?.width_cm }}W × {{ item.furniture?.dimensions?.depth_cm }}D cm · Rot {{ item.rotation_y }}°
              </span>
            </div>

            <!-- Status Indicator -->
            <div>
              <span
                v-if="item.status === 'valid'"
                class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-emerald-100 text-emerald-800"
              >
                Valid
              </span>
              <span
                v-else-if="item.status === 'out_of_bounds'"
                class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-red-100 text-red-800"
              >
                Wall Breach
              </span>
              <span
                v-else-if="item.status === 'collision'"
                class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-red-100 text-red-800"
              >
                Collision
              </span>
              <span
                v-else
                class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold bg-amber-100 text-amber-800"
              >
                Clearance
              </span>
            </div>
          </div>

          <!-- Position & Action Row -->
          <div class="flex items-center justify-between text-[11px] pt-1 border-t border-light-border/60">
            <span class="font-mono text-muted-gray">
              ({{ item.position_x.toFixed(2) }}m, {{ item.position_z.toFixed(2) }}m)
            </span>

            <div class="flex items-center gap-2">
              <button
                type="button"
                class="text-forest hover:text-dark-green font-semibold text-xs cursor-pointer"
                title="Focus Camera"
                @click.stop="$emit('focus', item.position_x, item.position_z)"
              >
                Focus
              </button>
              <button
                type="button"
                class="text-red-600 hover:text-red-800 text-xs cursor-pointer"
                title="Remove"
                @click.stop="$emit('remove', item.uuid)"
              >
                Remove
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab 3: Decoupled Budget Tracker -->
      <div v-else-if="activeTab === 'budget'" class="flex-1 overflow-y-auto p-4 space-y-4">
        <!-- Budget Overview Card -->
        <div class="p-4 rounded-2xl bg-off-white border border-light-border space-y-3 shadow-subtle">
          <span class="text-[10px] font-mono uppercase text-muted-gray font-semibold block">
            Room Financial Target
          </span>

          <div class="grid grid-cols-2 gap-2 text-left">
            <div>
              <span class="text-[10px] text-muted-gray block">Target Budget</span>
              <div class="flex items-center gap-1 mt-0.5">
                <span class="text-xs text-charcoal font-mono">₱</span>
                <input
                  v-model.number="budgetTarget"
                  type="number"
                  step="5000"
                  class="w-24 px-1.5 py-0.5 rounded bg-cream border border-light-border text-xs font-mono font-bold text-forest focus:outline-none"
                />
              </div>
            </div>

            <div>
              <span class="text-[10px] text-muted-gray block">Total Selected</span>
              <span class="text-sm font-mono font-bold text-warm-beige block mt-0.5">
                ₱{{ totalCost.toLocaleString() }}
              </span>
            </div>
          </div>

          <!-- Progress Bar -->
          <div class="space-y-1 pt-1">
            <div class="flex justify-between text-[10px] font-mono text-muted-gray">
              <span>{{ budgetUsedPercent }}% Used</span>
              <span :class="budgetRemaining >= 0 ? 'text-emerald-700' : 'text-red-700'">
                {{ budgetRemaining >= 0 ? `₱${budgetRemaining.toLocaleString()} remaining` : `₱${Math.abs(budgetRemaining).toLocaleString()} over budget` }}
              </span>
            </div>
            <div class="w-full h-2 bg-light-border rounded-full overflow-hidden">
              <div
                class="h-full rounded-full transition-all duration-300"
                :class="budgetUsedPercent > 100 ? 'bg-red-500' : 'bg-warm-beige'"
                :style="{ width: `${Math.min(100, budgetUsedPercent)}%` }"
              ></div>
            </div>
          </div>
        </div>

        <!-- Itemized Cost List -->
        <div class="space-y-2">
          <span class="text-[11px] font-mono text-muted-gray uppercase font-semibold block">
            Itemized Cost
          </span>

          <div
            v-for="item in placedItems"
            :key="item.uuid"
            class="p-2.5 rounded-xl bg-off-white border border-light-border flex items-center justify-between text-xs"
          >
            <span class="truncate pr-2 text-charcoal">{{ item.furniture?.name }}</span>
            <span class="font-mono font-bold text-forest shrink-0">
              ₱{{ Number(item.furniture?.price || 0).toLocaleString() }}
            </span>
          </div>
        </div>
      </div>

      <!-- Footer Room Dimensions Summary -->
      <div class="p-3 border-t border-light-border bg-cream text-[10px] font-mono text-muted-gray flex items-center justify-between">
        <span>Room: {{ project.width_cm }} × {{ project.length_cm }} cm</span>
        <span class="text-forest font-semibold">{{ project.room_area_sqm }} m²</span>
      </div>
    </div>

    <!-- Toggle Button (when collapsed) -->
    <button
      v-if="!isOpen"
      type="button"
      class="absolute right-3 top-20 z-30 p-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs shadow-glow transition-all flex items-center gap-1.5 cursor-pointer"
      title="Open Spatial Inspector"
      @click="isOpen = true"
    >
      <span>📐</span>
      <span class="font-semibold hidden sm:inline">Spatial Engine</span>
    </button>
  </div>
</template>
