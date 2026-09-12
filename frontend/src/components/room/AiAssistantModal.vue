<script setup lang="ts">
import { ref, watch } from 'vue'
import { aiService, type RoomAnalysisData, type RecommendedFurnitureItem } from '@/services/aiService'
import type { Furniture } from '@/types/furniture'
import type { RoomProject } from '@/types/project'

const props = defineProps<{
  show: boolean
  project: RoomProject
}>()

const emit = defineEmits<{
  (e: 'close'): void
  (e: 'add-furniture', furniture: Furniture): void
}>()

const activeTab = ref<'vision' | 'recommendations'>('vision')

// Vision analysis state
const selectedFile = ref<File | null>(null)
const previewUrl = ref<string | null>(null)
const hint = ref<string>(props.project.room_type || 'Living Room')
const analyzing = ref(false)
const analysisError = ref<string | null>(null)
const analysisResult = ref<RoomAnalysisData | null>(null)

// Recommendations state
const loadingRecs = ref(false)
const recsError = ref<string | null>(null)
const recommendations = ref<RecommendedFurnitureItem[]>([])
const activePalette = ref<string[]>([])
const detectedStyle = ref<string>(props.project.style || 'Scandinavian')
const activeProvider = ref<string>('')
const isMock = ref<boolean>(false)
const addedItemIds = ref<Set<number>>(new Set())

watch(
  () => props.show,
  (newVal) => {
    if (newVal) {
      const projAny = props.project as any
      if (!analysisResult.value && projAny.room_analyses && projAny.room_analyses.length > 0) {
        // If project already has previous analysis, load it
        const prev = projAny.room_analyses[0]
        analysisResult.value = {
          id: prev.id,
          image_url: prev.image_url || '',
          detected_room_type: prev.detected_room_type || props.project.room_type,
          detected_style: prev.detected_style || props.project.style || 'Scandinavian',
          dominant_colors: prev.detected_colors || [],
          detected_objects: prev.detected_objects || [],
          confidence: prev.confidence || 0.90,
          visual_clutter: 'Low',
          summary: 'Cached room analysis profile.',
          provider: prev.ai_provider || 'mock',
          is_mock: prev.ai_provider === 'mock',
          created_at: prev.created_at || '',
        }
        detectedStyle.value = analysisResult.value.detected_style
        activePalette.value = analysisResult.value.dominant_colors
      }

      if (recommendations.value.length === 0 && !loadingRecs.value) {
        fetchRecommendations()
      }
    }
  }
)

watch(activeTab, (tab) => {
  if (tab === 'recommendations' && recommendations.value.length === 0 && !loadingRecs.value) {
    fetchRecommendations()
  }
})

async function loadDemoPhoto() {
  try {
    const res = await fetch('/storage/furniture/images/SOFA-001-primary.webp')
    const blob = await res.blob()
    const file = new File([blob], 'demo_living_room.webp', { type: 'image/webp' })
    setFile(file)
    await runVisionAnalysis()
  } catch (err) {
    console.error('Failed to load demo photo', err)
  }
}

function handleFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    setFile(target.files[0])
  }
}

function handleDrop(event: DragEvent) {
  event.preventDefault()
  if (event.dataTransfer && event.dataTransfer.files && event.dataTransfer.files[0]) {
    setFile(event.dataTransfer.files[0])
  }
}

function setFile(file: File) {
  if (!file.type.startsWith('image/')) {
    analysisError.value = 'Please select a valid image file (JPEG, PNG, WebP).'
    return
  }
  selectedFile.value = file
  analysisError.value = null
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value)
  }
  previewUrl.value = URL.createObjectURL(file)
}

async function runVisionAnalysis() {
  if (!selectedFile.value) return
  analyzing.value = true
  analysisError.value = null

  try {
    const result = await aiService.analyzeRoomPhoto(
      selectedFile.value,
      hint.value,
      props.project.id
    )
    analysisResult.value = result
    detectedStyle.value = result.detected_style
    activePalette.value = result.dominant_colors
    activeProvider.value = result.provider
    isMock.value = result.is_mock

    // Auto-fetch matching recommendations
    await fetchRecommendations()
  } catch (err: any) {
    console.error('Vision analysis error:', err)
    analysisError.value = err.response?.data?.message || 'Failed to analyze room photo. Please try again.'
  } finally {
    analyzing.value = false
  }
}

async function fetchRecommendations() {
  loadingRecs.value = true
  recsError.value = null

  try {
    const res = await aiService.getRecommendations({
      room_type: analysisResult.value?.detected_room_type || props.project.room_type,
      style: detectedStyle.value,
      dominant_colors: activePalette.value,
      room_project_id: props.project.id,
    })
    recommendations.value = res.recommendations
    activeProvider.value = res.provider
    isMock.value = res.is_mock
  } catch (err: any) {
    console.error('Failed to fetch recommendations:', err)
    recsError.value = err.response?.data?.message || 'Could not load geometry-constrained recommendations.'
  } finally {
    loadingRecs.value = false
  }
}

function getImageUrl(img: any): string | null {
  if (!img) return null
  if (typeof img === 'string') return img
  if (typeof img === 'object' && typeof img.image_path === 'string') return img.image_path
  return null
}

function handleAdd(item: RecommendedFurnitureItem) {
  emit('add-furniture', item.furniture)
  addedItemIds.value.add(item.furniture.id)
}
</script>

<template>
  <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 bg-charcoal/60 backdrop-blur-sm animate-fade-in">
    <div
      class="relative w-full max-w-4xl max-h-[90vh] bg-cream rounded-3xl border border-light-border shadow-2xl flex flex-col overflow-hidden text-charcoal"
      @click.stop
    >
      <!-- Modal Header -->
      <div class="px-6 py-4 bg-off-white border-b border-light-border/70 flex items-center justify-between shrink-0">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl bg-forest/10 border border-forest/20 flex items-center justify-center text-lg text-forest">
            ✨
          </div>
          <div>
            <h2 class="font-display font-bold text-base text-forest flex items-center gap-2">
              <span>AI Spatial Room Assistant</span>
              <span
                v-if="activeProvider"
                class="px-2 py-0.5 rounded-full text-[10px] font-mono font-semibold"
                :class="isMock ? 'bg-amber-100 text-amber-800 border border-amber-300' : 'bg-forest/15 text-forest border border-forest/30'"
              >
                {{ isMock ? 'Offline Demonstration Mode' : 'Gemini 2.0 Flash Perception' }}
              </span>
            </h2>
            <p class="text-[11px] font-mono text-muted-gray">
              Visual perception meets deterministic geometry validation
            </p>
          </div>
        </div>

        <!-- Close Button -->
        <button
          type="button"
          class="p-2 rounded-xl text-muted-gray hover:text-forest hover:bg-cream transition-colors cursor-pointer"
          @click="emit('close')"
        >
          <i class="bi bi-x-lg text-base"></i>
        </button>
      </div>

      <!-- Navigation Tabs -->
      <div class="px-6 pt-3 bg-off-white/50 border-b border-light-border/60 flex items-center gap-2 text-xs font-semibold">
        <button
          type="button"
          class="pb-2.5 px-3 border-b-2 transition-all flex items-center gap-1.5 cursor-pointer"
          :class="activeTab === 'vision' ? 'border-forest text-forest' : 'border-transparent text-muted-gray hover:text-charcoal'"
          @click="activeTab = 'vision'"
        >
          <i class="bi bi-camera"></i>
          <span>1. Room Vision Perception</span>
        </button>
        <button
          type="button"
          class="pb-2.5 px-3 border-b-2 transition-all flex items-center gap-1.5 cursor-pointer"
          :class="activeTab === 'recommendations' ? 'border-forest text-forest' : 'border-transparent text-muted-gray hover:text-charcoal'"
          @click="activeTab = 'recommendations'"
        >
          <i class="bi bi-stars"></i>
          <span>2. Geometry-Constrained Recommendations</span>
          <span
            v-if="recommendations.length > 0"
            class="px-1.5 py-0.2 rounded-full text-[10px] bg-forest text-cream font-mono"
          >
            {{ recommendations.length }}
          </span>
        </button>
      </div>

      <!-- Modal Body (Scrollable) -->
      <div class="flex-1 overflow-y-auto p-6 space-y-6">
        
        <!-- TAB 1: Room Vision Analysis -->
        <div v-if="activeTab === 'vision'" class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-12 gap-6 items-start">
            
            <!-- Left: Upload Zone -->
            <div class="md:col-span-6 space-y-4">
              <label class="block text-xs font-mono font-semibold text-forest uppercase tracking-wider">
                Upload Physical Room Photo
              </label>

              <!-- Drag & Drop Zone -->
              <div
                class="border-2 border-dashed rounded-2xl p-6 text-center transition-all cursor-pointer relative overflow-hidden bg-off-white/60 hover:bg-off-white flex flex-col items-center justify-center min-h-[220px]"
                :class="selectedFile ? 'border-forest/60' : 'border-light-border hover:border-forest/40'"
                @dragover.prevent
                @drop="handleDrop"
                @click="($refs.fileInput as HTMLInputElement)?.click()"
              >
                <input
                  ref="fileInput"
                  type="file"
                  accept="image/jpeg,image/png,image/webp"
                  class="hidden"
                  @change="handleFileChange"
                />

                <div v-if="previewUrl" class="relative w-full h-44 rounded-xl overflow-hidden shadow-subtle group">
                  <img :src="previewUrl" alt="Room Preview" class="w-full h-full object-cover" />
                  <div class="absolute inset-0 bg-charcoal/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-cream text-xs font-semibold gap-2">
                    <i class="bi bi-arrow-repeat"></i> Click to Replace Photo
                  </div>
                </div>

                <div v-else class="space-y-2 py-4">
                  <div class="w-12 h-12 rounded-2xl bg-forest/10 border border-forest/20 text-forest text-2xl flex items-center justify-center mx-auto shadow-subtle">
                    <i class="bi bi-cloud-arrow-up"></i>
                  </div>
                  <p class="text-xs font-medium text-forest">
                    Drag & drop your room photo here, or <span class="underline">browse</span>
                  </p>
                  <p class="text-[10px] font-mono text-muted-gray">
                    Supports JPEG, PNG, WebP up to 10MB
                  </p>
                </div>
              </div>

              <!-- Instant Demo Button -->
              <div class="flex items-center justify-between px-1">
                <span class="text-[10px] font-mono text-muted-gray">No photo?</span>
                <button
                  type="button"
                  class="text-[11px] font-mono font-medium text-dark-green hover:text-forest flex items-center gap-1.5 cursor-pointer bg-forest/5 hover:bg-forest/10 px-3 py-1 rounded-lg border border-forest/15 transition-all"
                  :disabled="analyzing"
                  @click="loadDemoPhoto"
                >
                  <i class="bi bi-magic"></i> Try Demo Room Photo
                </button>
              </div>

              <!-- Context Hint Input -->
              <div class="space-y-1.5">
                <label class="block text-[11px] font-mono text-muted-gray">Room Type Hint</label>
                <select
                  v-model="hint"
                  class="w-full px-3 py-2 rounded-xl bg-off-white border border-light-border text-xs text-charcoal focus:outline-none focus:border-forest"
                >
                  <option value="Living Room">Living Room</option>
                  <option value="Bedroom">Bedroom</option>
                  <option value="Home Office">Home Office</option>
                  <option value="Dining Room">Dining Room</option>
                  <option value="Studio">Studio Apartment</option>
                </select>
              </div>

              <!-- Action Button -->
              <button
                type="button"
                class="w-full py-2.5 px-4 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50"
                :disabled="!selectedFile || analyzing"
                @click="runVisionAnalysis"
              >
                <span v-if="analyzing" class="w-4 h-4 border-2 border-cream border-t-transparent rounded-full animate-spin"></span>
                <span>{{ analyzing ? 'Extracting Architectural Perception...' : 'Analyze Room Photo with AI' }}</span>
              </button>

              <p v-if="analysisError" class="text-xs text-rose-600 bg-rose-50 border border-rose-200 p-2.5 rounded-xl font-mono">
                {{ analysisError }}
              </p>
            </div>

            <!-- Right: Perceptual Results -->
            <div class="md:col-span-6 space-y-4">
              <label class="block text-xs font-mono font-semibold text-forest uppercase tracking-wider">
                Extracted Architectural Perception
              </label>

              <div v-if="analysisResult" class="p-5 rounded-2xl bg-off-white border border-light-border shadow-subtle space-y-4 animate-fade-in">
                
                <!-- Room & Style Badges -->
                <div class="flex items-center justify-between gap-2">
                  <div>
                    <span class="text-[10px] font-mono text-muted-gray uppercase block">Detected Style</span>
                    <span class="font-display font-bold text-lg text-forest">{{ analysisResult.detected_style }}</span>
                  </div>
                  <div class="text-right">
                    <span class="text-[10px] font-mono text-muted-gray uppercase block">Room Category</span>
                    <span class="px-2.5 py-1 rounded-full text-xs font-mono font-semibold bg-warm-beige/25 border border-warm-beige/60 text-forest inline-block">
                      {{ analysisResult.detected_room_type }}
                    </span>
                  </div>
                </div>

                <!-- Dominant Palette -->
                <div class="space-y-1.5">
                  <span class="text-[11px] font-mono text-muted-gray block">Dominant Color Palette</span>
                  <div class="flex items-center gap-2">
                    <div
                      v-for="(color, idx) in analysisResult.dominant_colors"
                      :key="idx"
                      class="flex-1 flex flex-col items-center gap-1 p-1.5 rounded-xl bg-cream border border-light-border/80 shadow-subtle"
                    >
                      <div
                        class="w-full h-8 rounded-lg border border-black/10 shadow-inner"
                        :style="{ backgroundColor: color }"
                      ></div>
                      <span class="text-[10px] font-mono font-bold text-charcoal">{{ color }}</span>
                    </div>
                  </div>
                </div>

                <!-- Perceptual Observations & Clutter -->
                <div class="space-y-1 text-xs">
                  <div class="flex items-center justify-between text-[11px] font-mono text-muted-gray border-t border-light-border/60 pt-2">
                    <span>Visual Clutter: <strong class="text-forest">{{ analysisResult.visual_clutter }}</strong></span>
                    <span>Confidence: <strong class="text-forest">{{ Math.round(analysisResult.confidence * 100) }}%</strong></span>
                  </div>
                  <p v-if="analysisResult.summary" class="text-xs text-charcoal/90 italic bg-cream/70 p-2.5 rounded-xl border border-light-border/60">
                    "{{ analysisResult.summary }}"
                  </p>
                </div>

                <!-- Forward to Recommendations Action -->
                <button
                  type="button"
                  class="w-full py-2 px-4 rounded-xl bg-warm-beige hover:bg-warm-beige/90 text-forest text-xs font-semibold shadow-subtle transition-all flex items-center justify-center gap-1.5 cursor-pointer"
                  @click="activeTab = 'recommendations'"
                >
                  <span>Explore Matched Recommendations</span>
                  <span>➔</span>
                </button>
              </div>

              <!-- Placeholder when no photo analyzed yet -->
              <div v-else class="p-8 rounded-2xl bg-off-white/40 border border-dashed border-light-border text-center space-y-2">
                <div class="w-10 h-10 rounded-xl bg-forest/5 text-forest/40 flex items-center justify-center mx-auto text-xl">
                  <i class="bi bi-eye"></i>
                </div>
                <p class="text-xs font-mono text-muted-gray">
                  Upload a room photo to extract interior style tags, color harmony, and clutter metrics.
                </p>
              </div>
            </div>

          </div>
        </div>

        <!-- TAB 2: Geometry-Constrained Recommendations -->
        <div v-if="activeTab === 'recommendations'" class="space-y-4">
          <div class="flex items-center justify-between gap-3 bg-off-white p-3.5 rounded-2xl border border-light-border shadow-subtle text-xs">
            <div>
              <span class="text-[11px] font-mono text-muted-gray block">Design Constraint Filter</span>
              <span class="font-semibold text-forest">
                Style: <strong>{{ detectedStyle }}</strong> • Room: <strong>{{ props.project.width_cm }} × {{ props.project.length_cm }} cm</strong>
              </span>
            </div>
            <button
              type="button"
              class="px-3 py-1.5 rounded-xl bg-cream border border-light-border hover:border-forest text-forest font-mono text-xs transition-all flex items-center gap-1 cursor-pointer"
              :disabled="loadingRecs"
              @click="fetchRecommendations"
            >
              <i class="bi bi-arrow-clockwise" :class="loadingRecs ? 'animate-spin' : ''"></i>
              <span>Refresh</span>
            </button>
          </div>

          <!-- Loading Recommendations -->
          <div v-if="loadingRecs" class="py-16 text-center space-y-3">
            <div class="w-8 h-8 border-2 border-forest border-t-transparent rounded-full animate-spin mx-auto"></div>
            <p class="text-xs font-mono text-muted-gray">Querying catalog and evaluating physical room boundaries...</p>
          </div>

          <!-- Recommendations Error -->
          <div v-else-if="recsError" class="p-4 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-mono">
            {{ recsError }}
          </div>

          <!-- Empty Recommendations -->
          <div v-else-if="recommendations.length === 0" class="py-12 text-center space-y-2 bg-off-white/50 rounded-2xl border border-dashed border-light-border">
            <i class="bi bi-box-seam text-3xl text-muted-gray"></i>
            <p class="text-xs font-medium text-forest">No matching furniture pieces found</p>
            <p class="text-[11px] font-mono text-muted-gray">All items in catalog might already be placed in this room.</p>
          </div>

          <!-- Recommendations Grid -->
          <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <div
              v-for="rec in recommendations"
              :key="rec.furniture.id"
              class="rounded-2xl bg-off-white border border-light-border shadow-subtle p-3.5 flex flex-col justify-between hover:shadow-card hover:border-forest/40 transition-all space-y-3"
            >
              <!-- Thumbnail & Dimension Pill -->
              <div class="space-y-2">
                <div class="relative w-full h-32 rounded-xl overflow-hidden bg-cream border border-light-border/60 flex items-center justify-center">
                  <img
                    v-if="getImageUrl(rec.furniture.primary_image)"
                    :src="getImageUrl(rec.furniture.primary_image)!.startsWith('/') ? getImageUrl(rec.furniture.primary_image)! : '/' + getImageUrl(rec.furniture.primary_image)"
                    :alt="rec.furniture.name"
                    class="w-full h-full object-contain p-2"
                    @error="(e: Event) => {
                      const target = e.target as HTMLImageElement;
                      target.style.display = 'none';
                      const fallback = target.nextElementSibling as HTMLElement;
                      if (fallback) fallback.style.display = 'flex';
                    }"
                  />
                  <div
                    class="text-forest/40 text-3xl items-center justify-center"
                    :style="{ display: getImageUrl(rec.furniture.primary_image) ? 'none' : 'flex' }"
                  >
                    <i class="bi bi-box"></i>
                  </div>

                  <!-- Certified Physical Dimension Badge -->
                  <div class="absolute bottom-1.5 left-1.5 px-2 py-0.5 rounded-md bg-cream/90 backdrop-blur-sm border border-light-border text-[9px] font-mono text-forest font-semibold">
                    {{ Math.round(rec.furniture.dimensions?.width_cm ?? 100) }}W × {{ Math.round(rec.furniture.dimensions?.depth_cm ?? 80) }}D cm
                  </div>

                  <!-- Fit Room Bounds Badge -->
                  <div class="absolute top-1.5 right-1.5 px-2 py-0.5 rounded-md bg-emerald-50 border border-emerald-300 text-emerald-700 text-[9px] font-mono font-semibold flex items-center gap-1">
                    <i class="bi bi-check2"></i>
                    <span>Fits Bounds</span>
                  </div>
                </div>

                <!-- Info -->
                <div>
                  <div class="flex items-center justify-between text-[11px] font-mono text-muted-gray">
                    <span>{{ rec.furniture.category?.name || 'Furniture' }}</span>
                    <span class="font-bold text-forest">₱{{ Number(rec.furniture.price).toLocaleString() }}</span>
                  </div>
                  <h3 class="font-display font-bold text-sm text-forest truncate" :title="rec.furniture.name">
                    {{ rec.furniture.name }}
                  </h3>
                </div>

                <!-- Match Reasons -->
                <ul class="text-[10px] text-muted-gray space-y-0.5 font-mono">
                  <li v-for="(reason, rIdx) in rec.match_reasons.slice(0, 2)" :key="rIdx" class="flex items-center gap-1 text-forest/80">
                    <span>•</span>
                    <span class="truncate">{{ reason }}</span>
                  </li>
                </ul>
              </div>

              <!-- Action: Add to Room -->
              <button
                type="button"
                class="w-full py-2 px-3 rounded-xl font-mono text-xs font-semibold transition-all flex items-center justify-center gap-1.5 cursor-pointer shadow-subtle"
                :class="addedItemIds.has(rec.furniture.id) ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-forest hover:bg-dark-green text-cream'"
                @click="handleAdd(rec)"
              >
                <i class="bi" :class="addedItemIds.has(rec.furniture.id) ? 'bi-check2' : 'bi-plus-lg'"></i>
                <span>{{ addedItemIds.has(rec.furniture.id) ? 'Added to Canvas' : '+ Add to 3D Canvas' }}</span>
              </button>
            </div>
          </div>

        </div>

      </div>

      <!-- Modal Footer -->
      <div class="px-6 py-3 bg-off-white border-t border-light-border/70 flex items-center justify-between text-xs text-muted-gray shrink-0 font-mono">
        <div class="flex items-center gap-1.5">
          <i class="bi bi-shield-lock-fill text-forest"></i>
          <span>Scale locked 1.000 • Added items start in uncertified preview state</span>
        </div>
        <button
          type="button"
          class="px-4 py-1.5 rounded-xl border border-light-border hover:bg-cream text-charcoal font-semibold transition-colors cursor-pointer"
          @click="emit('close')"
        >
          Close
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.18s ease-out;
}
@keyframes fadeIn {
  from { opacity: 0; transform: scale(0.98); }
  to { opacity: 1; transform: scale(1); }
}
</style>
