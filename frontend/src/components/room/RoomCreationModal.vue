<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useProjectsStore } from '@/stores/projects'
import type { Furniture } from '@/types/furniture'
import type { CreateProjectPayload } from '@/types/project'

defineProps<{
  selectedFurniture?: Furniture
}>()

const emit = defineEmits<{
  (e: 'close'): void
}>()

const router = useRouter()
const authStore = useAuthStore()
const projectsStore = useProjectsStore()

const activeTab = ref<'ai' | 'manual' | 'existing'>('ai')

// Form model
const projectName = ref('My Living Room')
const roomType = ref('living_room')
const widthCm = ref(420)
const lengthCm = ref(500)
const heightCm = ref(280)
const style = ref('scandinavian')

// AI Analysis Simulation state
const photoUploaded = ref(false)
const photoFileName = ref('')
const aiAnalyzing = ref(false)
const aiSuggestions = ref<any>(null)

const submitting = ref(false)
const submitSuccess = ref(false)
const errorMessage = ref<string | null>(null)

onMounted(() => {
  if (authStore.isAuthenticated) {
    projectsStore.fetchProjects()
  }
})

function onSimulatePhotoUpload(e: Event) {
  const target = e.target as HTMLInputElement
  if (target.files && target.files[0]) {
    photoFileName.value = target.files[0].name
    photoUploaded.value = true
    aiAnalyzing.value = true

    // Simulate AI vision analysis
    setTimeout(() => {
      aiAnalyzing.value = false
      aiSuggestions.value = {
        detected_room_type: 'Living Room',
        detected_style: 'Scandinavian / Modern',
        estimated_palette: ['#F5F5F0', '#A8A6A1', '#4A3525'],
        suggested_width_cm: 420,
        suggested_length_cm: 500,
        suggested_height_cm: 280,
        confidence_notes: 'Visual characteristics analyzed. Authoritative measurements confirmed by user below.',
      }
      projectName.value = 'AI-Assisted Living Space'
      roomType.value = 'living_room'
      style.value = 'scandinavian'
      widthCm.value = 420
      lengthCm.value = 500
      heightCm.value = 280
    }, 1200)
  }
}

async function handleCreateRoom() {
  if (!authStore.isAuthenticated) {
    emit('close')
    router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
    return
  }

  submitting.value = true
  errorMessage.value = null

  const payload: CreateProjectPayload = {
    name: projectName.value,
    room_type: roomType.value,
    width_cm: Number(widthCm.value),
    length_cm: Number(lengthCm.value),
    height_cm: Number(heightCm.value),
    style: style.value,
  }

  try {
    const newProj = await projectsStore.createProject(payload)
    submitSuccess.value = true
    setTimeout(() => {
      emit('close')
      if (newProj && newProj.id) {
        router.push(`/room-planner/${newProj.id}`)
      } else {
        router.push({ name: 'projects' })
      }
    }, 1200)
  } catch (err: any) {
    errorMessage.value = err.response?.data?.message || 'Failed to create room project'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-charcoal/60 backdrop-blur-md animate-in fade-in duration-200">
    <div
      class="relative w-full max-w-2xl rounded-3xl bg-cream border border-light-border shadow-2xl overflow-hidden flex flex-col max-h-[90vh]"
      @click.stop
    >
      <!-- Modal Header -->
      <div class="px-6 py-4 border-b border-light-border flex items-center justify-between bg-off-white">
        <div>
          <h3 class="font-display font-bold text-forest text-base">Room Planning Gateway</h3>
          <p class="text-xs text-muted-gray">Choose your design path into the 3D Room Planner</p>
        </div>
        <button
          type="button"
          class="p-1.5 rounded-lg text-muted-gray hover:text-charcoal hover:bg-cream transition-colors cursor-pointer"
          @click="emit('close')"
        >
          <i class="bi bi-x-lg text-sm"></i>
        </button>
      </div>

      <!-- Mode Selector Tabs -->
      <div class="flex border-b border-light-border bg-off-white text-xs font-medium">
        <button
          type="button"
          class="flex-1 py-3 px-4 flex items-center justify-center gap-2 border-b-2 transition-all cursor-pointer"
          :class="activeTab === 'ai' ? 'border-forest text-forest bg-cream font-semibold' : 'border-transparent text-muted-gray hover:text-charcoal'"
          @click="activeTab = 'ai'"
        >
          <i class="bi bi-robot text-sm"></i>
          <span>AI-Assisted Reconstruction</span>
        </button>
        <button
          type="button"
          class="flex-1 py-3 px-4 flex items-center justify-center gap-2 border-b-2 transition-all cursor-pointer"
          :class="activeTab === 'manual' ? 'border-forest text-forest bg-cream font-semibold' : 'border-transparent text-muted-gray hover:text-charcoal'"
          @click="activeTab = 'manual'"
        >
          <i class="bi bi-hand-index-thumb text-sm"></i>
          <span>Manual Spatial Planning</span>
        </button>
        <button
          v-if="projectsStore.projects.length > 0"
          type="button"
          class="py-3 px-4 flex items-center justify-center gap-1.5 border-b-2 transition-all cursor-pointer"
          :class="activeTab === 'existing' ? 'border-forest text-forest bg-cream font-semibold' : 'border-transparent text-muted-gray hover:text-charcoal'"
          @click="activeTab = 'existing'"
        >
          <i class="bi bi-grid text-sm"></i>
          <span>My Rooms</span>
          <span class="px-1.5 py-0.2 rounded-full bg-light-border text-forest text-[10px] font-mono">{{ projectsStore.projects.length }}</span>
        </button>
      </div>

      <!-- Modal Body -->
      <div class="p-6 overflow-y-auto space-y-5 text-charcoal text-xs">
        
        <!-- Error Alert -->
        <div v-if="errorMessage" class="p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700">
          {{ errorMessage }}
        </div>

        <!-- Success Alert -->
        <div v-if="submitSuccess" class="p-4 rounded-xl bg-forest/10 border border-forest/30 text-forest text-center space-y-1 animate-in zoom-in-95">
          <p class="font-semibold text-sm">Room Project Created Successfully!</p>
          <p class="text-xs text-muted-gray">3D Canvas & Collision Engine will load this space in Milestone 5.</p>
        </div>

        <!-- TAB 1: AI-ASSISTED FLOW -->
        <div v-if="activeTab === 'ai'" class="space-y-4">
          <div class="p-3.5 rounded-xl bg-off-white border border-light-border space-y-1">
            <h4 class="font-semibold text-forest text-xs">How AI-Assisted Planning Works:</h4>
            <p class="text-muted-gray text-[11px] leading-relaxed">
              AI analyzes the room photo and provides estimated visual characteristics and optional dimension suggestions → you confirm or override dimensions → 3D room is generated.
            </p>
          </div>

          <!-- Photo Upload Simulator -->
          <div class="p-6 rounded-2xl border-2 border-dashed border-light-border bg-off-white flex flex-col items-center justify-center text-center space-y-2 cursor-pointer hover:border-forest/60 transition-colors">
            <input
              type="file"
              accept="image/*"
              class="hidden"
              id="room-photo-input"
              @change="onSimulatePhotoUpload"
            />
            <label for="room-photo-input" class="cursor-pointer flex flex-col items-center space-y-2">
              <div class="w-12 h-12 rounded-full bg-cream border border-light-border flex items-center justify-center text-forest">
                <i class="bi bi-cloud-arrow-up text-2xl"></i>
              </div>
              <div>
                <span class="text-xs font-semibold text-forest">Upload Room Photo</span>
                <span class="text-muted-gray block text-[11px]">PNG, JPG, WebP up to 10MB</span>
              </div>
            </label>

            <div v-if="photoUploaded" class="mt-2 text-xs font-mono text-forest font-semibold flex items-center gap-1.5">
              <i class="bi bi-check2-circle"></i>
              <span>Photo attached:</span>
              <span class="text-charcoal font-normal">{{ photoFileName }}</span>
            </div>
          </div>

          <!-- AI Analyzing Spinner -->
          <div v-if="aiAnalyzing" class="p-4 rounded-xl bg-off-white border border-forest/30 flex items-center justify-center gap-3 text-forest">
            <i class="bi bi-arrow-repeat animate-spin text-lg"></i>
            <span class="text-xs font-medium">AI analyzing visual characteristics, style, and room bounds...</span>
          </div>

          <!-- AI Inference Results -->
          <div v-if="aiSuggestions" class="p-4 rounded-xl bg-off-white border border-forest/30 space-y-2 text-xs">
            <div class="flex items-center justify-between text-forest font-semibold">
              <span>AI Vision Inferences (Assistive)</span>
              <span class="text-[10px] uppercase font-mono px-2 py-0.5 rounded bg-cream border border-light-border text-forest">Confidence: High</span>
            </div>
            <div class="grid grid-cols-2 gap-2 text-[11px] text-charcoal pt-1">
              <div>Type: <span class="text-forest font-medium">{{ aiSuggestions.detected_room_type }}</span></div>
              <div>Style: <span class="text-forest font-medium">{{ aiSuggestions.detected_style }}</span></div>
            </div>
            <p class="text-[10px] text-muted-gray italic pt-1">
              * Please confirm your measured dimensions below. User-confirmed dimensions remain authoritative.
            </p>
          </div>
        </div>

        <!-- TAB 2: MANUAL PLANNING FLOW -->
        <div v-if="activeTab === 'manual'" class="space-y-3">
          <div class="p-3.5 rounded-xl bg-off-white border border-light-border space-y-1">
            <h4 class="font-semibold text-forest text-xs">Manual Spatial Planning:</h4>
            <p class="text-muted-gray text-[11px] leading-relaxed">
              Enter your room's physical dimensions directly. These dimensions are used authoritatively by the deterministic geometry engine.
            </p>
          </div>
        </div>

        <!-- SHARED: AUTHORITATIVE DIMENSION CONFIRMATION -->
        <div v-if="activeTab !== 'existing'" class="space-y-4 pt-2 border-t border-light-border">
          <h4 class="font-semibold text-forest text-xs uppercase tracking-wider">
            {{ activeTab === 'ai' ? 'Step 2: Confirm Authoritative Room Dimensions' : 'Room Parameters' }}
          </h4>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label class="block text-muted-gray mb-1">Room Name</label>
              <input
                v-model="projectName"
                type="text"
                class="w-full px-3 py-2 rounded-lg bg-off-white border border-light-border text-charcoal focus:outline-none focus:border-forest font-medium"
              />
            </div>
            <div>
              <label class="block text-muted-gray mb-1">Room Archetype</label>
              <select
                v-model="roomType"
                class="w-full px-3 py-2 rounded-lg bg-off-white border border-light-border text-charcoal focus:outline-none focus:border-forest cursor-pointer"
              >
                <option value="living_room">Living Room</option>
                <option value="bedroom">Bedroom</option>
                <option value="home_office">Home Office</option>
                <option value="dining_room">Dining Room</option>
                <option value="studio">Studio Apartment</option>
              </select>
            </div>
          </div>

          <!-- 3-Axis Dimensions (cm) -->
          <div class="grid grid-cols-3 gap-3 font-mono">
            <div>
              <label class="block text-muted-gray mb-1 text-[11px]">Width (cm)</label>
              <input
                v-model.number="widthCm"
                type="number"
                min="150"
                max="2000"
                class="w-full px-3 py-2 rounded-lg bg-off-white border border-light-border text-charcoal focus:outline-none focus:border-forest font-semibold"
              />
            </div>
            <div>
              <label class="block text-muted-gray mb-1 text-[11px]">Length (cm)</label>
              <input
                v-model.number="lengthCm"
                type="number"
                min="150"
                max="2000"
                class="w-full px-3 py-2 rounded-lg bg-off-white border border-light-border text-charcoal focus:outline-none focus:border-forest font-semibold"
              />
            </div>
            <div>
              <label class="block text-muted-gray mb-1 text-[11px]">Height (cm)</label>
              <input
                v-model.number="heightCm"
                type="number"
                min="200"
                max="500"
                class="w-full px-3 py-2 rounded-lg bg-off-white border border-light-border text-charcoal focus:outline-none focus:border-forest font-semibold"
              />
            </div>
          </div>

          <div class="p-3 rounded-lg bg-off-white border border-light-border text-[11px] text-muted-gray flex items-center justify-between">
            <span>Calculated Floor Area:</span>
            <span class="text-forest font-mono font-bold">
              {{ ((widthCm * lengthCm) / 10000).toFixed(2) }} m²
            </span>
          </div>
        </div>

        <!-- TAB 3: EXISTING ROOMS -->
        <div v-if="activeTab === 'existing'" class="space-y-3">
          <p class="text-xs text-muted-gray">Select an existing room project to add this piece to:</p>
          <div class="space-y-2 max-h-60 overflow-y-auto">
            <div
              v-for="proj in projectsStore.projects"
              :key="proj.id"
              class="p-3 rounded-xl bg-off-white border border-light-border hover:border-forest flex items-center justify-between cursor-pointer transition-colors"
              @click="router.push({ name: 'projects' }); emit('close')"
            >
              <div>
                <h5 class="font-semibold text-forest text-xs">{{ proj.name }}</h5>
                <span class="text-[11px] font-mono text-muted-gray">
                  {{ proj.width_cm }}×{{ proj.length_cm }} cm • {{ proj.room_area_sqm }} m²
                </span>
              </div>
              <div class="text-right">
                <span class="text-xs font-mono font-bold text-forest">
                  {{ proj.compatibility_score }}/100 Fit
                </span>
              </div>
            </div>
          </div>
        </div>

      </div>

      <!-- Modal Footer -->
      <div class="px-6 py-4 border-t border-light-border bg-off-white flex items-center justify-between">
        <button
          type="button"
          class="px-4 py-2 rounded-lg text-xs font-medium text-muted-gray hover:text-charcoal cursor-pointer"
          @click="emit('close')"
        >
          Cancel
        </button>

        <button
          v-if="activeTab !== 'existing'"
          type="button"
          :disabled="submitting || submitSuccess"
          class="px-5 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all disabled:opacity-50 flex items-center gap-2 cursor-pointer"
          @click="handleCreateRoom"
        >
          <span v-if="submitting">Creating Space...</span>
          <span v-else>Generate 3D Room Project</span>
          <i class="bi bi-arrow-right text-xs"></i>
        </button>
      </div>

    </div>
  </div>
</template>
