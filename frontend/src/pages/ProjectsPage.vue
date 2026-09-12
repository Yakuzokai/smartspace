<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useProjectsStore } from '@/stores/projects'
import RoomCreationModal from '@/components/room/RoomCreationModal.vue'

const projectsStore = useProjectsStore()
const showCreateModal = ref(false)

onMounted(() => {
  projectsStore.fetchProjects()
})
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
    
    <!-- Page Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div class="space-y-1">
        <div class="flex items-center gap-2 text-xs font-mono text-muted-gray">
          <router-link to="/" class="hover:text-forest">Home</router-link>
          <span>/</span>
          <span class="text-forest font-semibold">Room Projects</span>
        </div>
        <h1 class="font-display font-bold text-3xl text-forest">Spatial Room Projects</h1>
        <p class="text-xs text-muted-gray">
          Certified 3D environments evaluated with deterministic boundary and collision checks.
        </p>
      </div>

      <button
        type="button"
        class="px-5 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all flex items-center gap-2 self-start sm:self-auto cursor-pointer"
        @click="showCreateModal = true"
      >
        <span>+</span>
        <span>Create Room Project</span>
      </button>
    </div>

    <!-- Milestone 5 Live Banner -->
    <div class="p-5 rounded-2xl bg-cream border border-light-border flex items-center justify-between text-xs shadow-card">
      <div class="flex items-center gap-3">
        <span class="text-2xl">🎮</span>
        <div>
          <span class="text-forest font-semibold block text-sm">Interactive 3D Room Planner is Live</span>
          <span class="text-muted-gray text-[11px] leading-relaxed">
            Drag, rotate, and arrange catalog furniture in your 3D room canvas with real-time collision feedback and deterministic Laravel spatial certification.
          </span>
        </div>
      </div>
      <span class="hidden md:inline font-mono text-[10px] text-forest uppercase px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 border border-emerald-300 font-semibold">
        Engine Certified
      </span>
    </div>

    <!-- Loading State -->
    <div v-if="projectsStore.loading" class="py-16 text-center space-y-3">
      <div class="w-10 h-10 rounded-full border-2 border-forest border-t-transparent animate-spin mx-auto"></div>
      <p class="text-xs font-mono text-muted-gray">Loading spatial room projects...</p>
    </div>

    <!-- Empty State -->
    <div
      v-else-if="projectsStore.projects.length === 0"
      class="p-12 rounded-3xl bg-cream border border-light-border text-center space-y-4 my-8 max-w-lg mx-auto shadow-card"
    >
      <div class="w-16 h-16 rounded-full bg-off-white border border-light-border flex items-center justify-center mx-auto text-forest text-2xl shadow-subtle">
        📐
      </div>
      <div class="space-y-1">
        <h3 class="font-display font-bold text-lg text-forest">No Room Projects Created</h3>
        <p class="text-xs text-muted-gray leading-relaxed">
          Create a room project using either AI-Assisted photo reconstruction or manual dimensional planning to test catalog furniture in 3D.
        </p>
      </div>
      <button
        type="button"
        class="px-5 py-2.5 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all cursor-pointer"
        @click="showCreateModal = true"
      >
        Start First Room
      </button>
    </div>

    <!-- Projects Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div
        v-for="project in projectsStore.projects"
        :key="project.id"
        class="p-6 rounded-3xl bg-cream border border-light-border hover:border-warm-beige space-y-4 shadow-card hover:shadow-card-hover transition-all flex flex-col justify-between"
      >
        <div class="space-y-4">
          <div class="flex items-start justify-between">
            <div>
              <span class="text-[10px] font-mono uppercase tracking-widest text-warm-beige font-semibold">
                {{ project.room_type.replace('_', ' ') }}
              </span>
              <h3 class="font-display font-bold text-lg text-forest mt-0.5">{{ project.name }}</h3>
            </div>
            <!-- Compatibility Score Pill -->
            <div class="text-right">
              <span
                class="px-2.5 py-1 rounded-full text-xs font-mono font-bold"
                :class="project.compatibility_score >= 80 ? 'bg-emerald-50 text-emerald-800 border border-emerald-200' : 'bg-amber-50 text-amber-800 border border-amber-200'"
              >
                {{ project.compatibility_score }}/100 Fit
              </span>
            </div>
          </div>

          <!-- Spatial Specs -->
          <div class="grid grid-cols-3 gap-2 p-3 rounded-xl bg-off-white border border-light-border text-center font-mono text-xs shadow-subtle">
            <div>
              <span class="text-[10px] text-muted-gray block uppercase">Width</span>
              <span class="text-charcoal font-semibold">{{ project.width_cm }} cm</span>
            </div>
            <div>
              <span class="text-[10px] text-muted-gray block uppercase">Length</span>
              <span class="text-charcoal font-semibold">{{ project.length_cm }} cm</span>
            </div>
            <div>
              <span class="text-[10px] text-muted-gray block uppercase">Area</span>
              <span class="text-forest font-semibold">{{ project.room_area_sqm }} m²</span>
            </div>
          </div>

          <!-- Placements Summary -->
          <div class="flex items-center justify-between text-xs text-muted-gray pt-1">
            <span>Placed Furniture:</span>
            <span class="font-mono text-charcoal font-semibold">
              {{ project.placements?.length || 0 }} Items
            </span>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="pt-3 border-t border-light-border flex items-center justify-between">
          <button
            type="button"
            class="text-xs text-red-500 hover:text-red-700 cursor-pointer"
            title="Delete Project"
            @click="projectsStore.deleteProject(project.id)"
          >
            Delete
          </button>

          <router-link
            :to="`/room-planner/${project.id}`"
            class="px-4 py-2 rounded-xl bg-forest hover:bg-dark-green text-cream text-xs font-semibold shadow-glow transition-all flex items-center gap-1.5"
          >
            <span>Open 3D Planner</span>
            <span>&rarr;</span>
          </router-link>
        </div>
      </div>
    </div>

    <!-- Create Room Modal -->
    <RoomCreationModal
      v-if="showCreateModal"
      @close="showCreateModal = false"
    />

  </div>
</template>
