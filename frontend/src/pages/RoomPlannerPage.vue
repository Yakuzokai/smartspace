<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useProjectsStore } from '@/stores/projects'
import { useFurniturePlacement } from '@/composables/useFurniturePlacement'
import Room3DCanvas from '@/components/room/Room3DCanvas.vue'
import FurniturePickerSidebar from '@/components/room/FurniturePickerSidebar.vue'
import CompatibilityInspector from '@/components/room/CompatibilityInspector.vue'
import type { Furniture } from '@/types/furniture'
import type { CompatibilityBreakdown } from '@/types/project'

const route = useRoute()
const router = useRouter()
const projectsStore = useProjectsStore()

const projectId = computed(() => route.params.id as string)
const loading = ref(true)
const saving = ref(false)
const authoritativeEvaluation = ref<CompatibilityBreakdown | null>(null)
const canvasRef = ref<any>(null)

// Current project
const project = computed(() => projectsStore.currentProject)

// Initialize furniture placement composable
const {
  placedItems,
  selectedUuid,
  isDirty,
  addFurniture,
  removeItem,
  duplicateItem,
  moveItem,
  rotateItem,
  snapInsideRoom,
  loadFromPlacements,
  getPayloadForBackend,
} = useFurniturePlacement(() => ({
  width_m: (project.value?.width_cm ?? 400) / 100,
  length_m: (project.value?.length_cm ?? 500) / 100,
  height_m: (project.value?.height_cm ?? 280) / 100,
}))

onMounted(async () => {
  try {
    const proj = await projectsStore.selectProject(projectId.value)
    if (proj && proj.placements) {
      loadFromPlacements(proj.placements)
      if (proj.score_breakdown) {
        authoritativeEvaluation.value = proj.score_breakdown
      }
    }
  } catch (err) {
    console.error('Failed to load room project', err)
    router.push({ name: 'projects' })
  } finally {
    loading.value = false
  }
})

function handleAddFurniture(furniture: Furniture) {
  addFurniture(furniture)
}

function handleSelect(uuid: string | null) {
  selectedUuid.value = uuid
}

function handleMove(uuid: string, x: number, z: number) {
  moveItem(uuid, x, z)
}

function handleRotate(uuid: string, deg: number, isAbsolute = false) {
  rotateItem(uuid, deg, isAbsolute)
}

function handleDuplicate(uuid: string) {
  duplicateItem(uuid)
}

function handleRemove(uuid: string) {
  removeItem(uuid)
}

function handleSnapInside(uuid: string) {
  snapInsideRoom(uuid)
}

function handleFocus(x: number, z: number) {
  if (canvasRef.value) {
    canvasRef.value.sceneCtx?.focusItem(x, z)
  }
}

async function handleSaveAndCertify() {
  if (!project.value) return
  saving.value = true

  try {
    const payload = getPayloadForBackend()
    const updated = await projectsStore.updateProjectLayout(project.value.id, payload)
    if (updated.score_breakdown) {
      authoritativeEvaluation.value = updated.score_breakdown
    }
    isDirty.value = false
  } catch (err) {
    console.error('Failed to save layout and certify', err)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="h-screen w-screen flex flex-col overflow-hidden bg-off-white">
    <!-- Top Studio Navbar -->
    <header class="h-14 bg-cream border-b border-light-border px-4 flex items-center justify-between z-30 shrink-0 shadow-subtle">
      <!-- Left: Back & Project Title -->
      <div class="flex items-center gap-3">
        <router-link
          to="/projects"
          class="p-2 rounded-xl text-forest hover:bg-off-white border border-transparent hover:border-light-border text-xs flex items-center gap-1.5 transition-all font-semibold"
          title="Return to Projects List"
        >
          <span>←</span>
          <span class="hidden sm:inline">My Spaces</span>
        </router-link>

        <div class="h-5 w-px bg-light-border"></div>

        <div v-if="project" class="flex items-center gap-2">
          <h1 class="font-display font-bold text-base text-forest">
            {{ project.name }}
          </h1>
          <span class="px-2.5 py-0.5 rounded-full text-[10px] font-mono font-semibold uppercase bg-warm-beige/25 text-forest border border-warm-beige/60">
            {{ project.room_type.replace('_', ' ') }}
          </span>
          <span class="hidden md:inline text-xs font-mono text-muted-gray">
            {{ project.width_cm }} × {{ project.length_cm }} cm ({{ project.room_area_sqm }} m²)
          </span>
        </div>
      </div>

      <!-- Right: Status Indicator & Save Button -->
      <div class="flex items-center gap-3">
        <!-- Draft / Certified Indicator -->
        <div class="hidden sm:flex items-center gap-1.5 text-xs font-mono">
          <span
            class="w-2 h-2 rounded-full"
            :class="isDirty ? 'bg-amber-500 animate-pulse' : 'bg-emerald-500'"
          ></span>
          <span class="text-muted-gray">
            {{ isDirty ? 'Unsaved Edits (Preview)' : 'Certified by Laravel' }}
          </span>
        </div>

        <button
          type="button"
          class="px-4 py-2 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all flex items-center gap-2 cursor-pointer"
          :disabled="saving"
          @click="handleSaveAndCertify"
        >
          <span v-if="saving" class="w-3.5 h-3.5 border-2 border-cream border-t-transparent rounded-full animate-spin"></span>
          <span>{{ saving ? 'Certifying...' : 'Save & Certify' }}</span>
        </button>
      </div>
    </header>

    <!-- Loading State -->
    <div v-if="loading" class="flex-1 flex flex-col items-center justify-center space-y-3">
      <div class="w-10 h-10 border-2 border-forest border-t-transparent rounded-full animate-spin"></div>
      <p class="text-xs font-mono text-muted-gray">Initializing 3D Spatial Canvas...</p>
    </div>

    <!-- Main Studio Viewport -->
    <main v-else-if="project" class="flex-1 relative flex overflow-hidden">
      <!-- Left: Furniture Catalog Picker Drawer -->
      <FurniturePickerSidebar
        :room-type="project.room_type"
        @add="handleAddFurniture"
      />

      <!-- Center: 3D Room Canvas -->
      <div class="flex-1 h-full relative">
        <Room3DCanvas
          ref="canvasRef"
          :project="project"
          :placed-items="placedItems"
          :selected-uuid="selectedUuid"
          @select="handleSelect"
          @move="handleMove"
          @rotate="handleRotate"
          @duplicate="handleDuplicate"
          @remove="handleRemove"
          @snap-inside="handleSnapInside"
        />
      </div>

      <!-- Right: Spatial Compatibility & Budget Inspector -->
      <CompatibilityInspector
        :project="project"
        :placed-items="placedItems"
        :selected-uuid="selectedUuid"
        :is-dirty="isDirty"
        :saving="saving"
        :authoritative-evaluation="authoritativeEvaluation"
        @select="handleSelect"
        @remove="handleRemove"
        @focus="handleFocus"
        @save-and-certify="handleSaveAndCertify"
      />
    </main>
  </div>
</template>
