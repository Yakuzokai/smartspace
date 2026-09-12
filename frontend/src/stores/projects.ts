import { defineStore } from 'pinia'
import { ref } from 'vue'
import { projectService } from '@/services/projectService'
import { useAuthStore } from './auth'
import type { RoomProject, CreateProjectPayload } from '@/types/project'

export const useProjectsStore = defineStore('projects', () => {
  const projects = ref<RoomProject[]>([])
  const currentProject = ref<RoomProject | null>(null)
  const loading = ref<boolean>(false)
  const error = ref<string | null>(null)

  async function fetchProjects() {
    const authStore = useAuthStore()
    if (!authStore.isAuthenticated) return

    loading.value = true
    error.value = null
    try {
      projects.value = await projectService.getProjects()
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to load projects'
    } finally {
      loading.value = false
    }
  }

  async function createProject(payload: CreateProjectPayload) {
    loading.value = true
    error.value = null
    try {
      const newProject = await projectService.createProject(payload)
      projects.value.unshift(newProject)
      currentProject.value = newProject
      return newProject
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to create room project'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function selectProject(id: number | string) {
    loading.value = true
    error.value = null
    try {
      const proj = await projectService.getProject(id)
      currentProject.value = proj
      return proj
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to load room project'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateProjectLayout(id: number | string, items: Array<{
    furniture_id: number
    position_x: number
    position_y?: number
    position_z: number
    rotation_y?: number
  }>) {
    loading.value = true
    error.value = null
    try {
      const updated = await projectService.updateLayout(id, { items })
      currentProject.value = updated
      // Update in projects list
      const idx = projects.value.findIndex(p => p.id === updated.id)
      if (idx !== -1) {
        projects.value[idx] = updated
      }
      return updated
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to update layout'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function validateProjectLayout(id: number | string) {
    try {
      const res = await projectService.validateLayout(id)
      if (currentProject.value && currentProject.value.id === res.project_id) {
        currentProject.value.compatibility_score = res.evaluation.total_score
        currentProject.value.score_breakdown = res.evaluation
      }
      return res.evaluation
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to validate layout'
      throw err
    }
  }

  async function deleteProject(id: number | string) {
    loading.value = true
    try {
      await projectService.deleteProject(id)
      projects.value = projects.value.filter(p => p.id !== Number(id))
      if (currentProject.value?.id === Number(id)) {
        currentProject.value = null
      }
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to delete room project'
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    projects,
    currentProject,
    loading,
    error,
    fetchProjects,
    createProject,
    selectProject,
    updateProjectLayout,
    validateProjectLayout,
    deleteProject,
  }
})
