<script setup lang="ts">
import type { ToothTreatmentView, Treatment, TreatmentStatus } from '~~/app/types'
import { TREATMENT_COLORS } from './ToothSVGPaths'
import { viewForTooth } from '~~/app/utils/treatmentView'

const props = defineProps<{
  treatments: Treatment[]
  toothNumber: number
  loading?: boolean
  readonly?: boolean
}>()

const emit = defineEmits<{
  addTreatment: []
  performTreatment: [treatment: ToothTreatmentView]
  deleteTreatment: [treatment: ToothTreatmentView]
  selectTreatment: [treatment: ToothTreatmentView]
}>()

const { t } = useI18n()

// Flatten Treatment[] into per-tooth rows, then group by status.
const groupedTreatments = computed(() => {
  const groups: Record<TreatmentStatus, ToothTreatmentView[]> = {
    planned: [],
    existing: []
  }
  for (const treatment of props.treatments) {
    const v = viewForTooth(treatment, props.toothNumber)
    if (v) groups[v.status]?.push(v)
  }
  return groups
})

function getTreatmentLabel(type: string): string {
  return t(`odontogram.treatments.types.${type}`, type)
}

function getStatusLabel(status: TreatmentStatus): string {
  return t(`odontogram.status.${status}`, status)
}

function _getStatusColor(status: TreatmentStatus): string {
  const colorMap: Record<TreatmentStatus, string> = {
    existing: 'neutral',
    planned: 'warning'
  }
  return colorMap[status] || 'neutral'
}

function getTreatmentColor(type: string): string {
  return TREATMENT_COLORS[type] || '#9CA3AF'
}

function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString()
}
</script>

<template>
  <div class="treatment-panel rounded-[20px] bg-surface ring-1 ring-[var(--color-border-subtle)] p-5">
    <div class="flex items-center justify-between mb-3">
      <h4 class="text-h3 text-default flex items-center gap-2">
        {{ t('odontogram.treatments.title') }}
        <UBadge
          color="neutral"
          variant="subtle"
          size="xs"
        >
          {{ toothNumber }}
        </UBadge>
      </h4>
      <UButton
        v-if="!readonly"
        icon="i-lucide-plus"
        size="xs"
        variant="soft"
        @click="emit('addTreatment')"
      >
        {{ t('odontogram.treatments.addTreatment') }}
      </UButton>
    </div>

    <!-- Loading state -->
    <div
      v-if="loading"
      class="flex justify-center py-4"
    >
      <UIcon
        name="i-lucide-loader-2"
        class="w-5 h-5 animate-spin text-subtle"
      />
    </div>

    <!-- Empty state -->
    <div
      v-else-if="treatments.length === 0"
      class="text-center py-6 text-subtle text-sm"
    >
      {{ t('odontogram.treatments.noTreatments') }}
    </div>

    <!-- Treatment list by status -->
    <div
      v-else
      class="space-y-4"
    >
      <!-- Planned treatments (show first, most actionable) -->
      <div v-if="groupedTreatments.planned.length > 0">
        <div class="text-xs font-medium text-warning-accent mb-2 flex items-center gap-1">
          <UIcon
            name="i-lucide-clock"
            class="w-3 h-3"
          />
          {{ getStatusLabel('planned') }}
        </div>
        <div class="space-y-2">
          <div
            v-for="treatment in groupedTreatments.planned"
            :key="treatment.id"
            class="treatment-item treatment-planned"
            @click="emit('selectTreatment', treatment)"
          >
            <div class="flex items-center gap-2">
              <div
                class="w-3 h-3 rounded-full"
                :style="{ backgroundColor: getTreatmentColor(treatment.treatment_type) }"
              />
              <span class="text-sm font-medium">{{ getTreatmentLabel(treatment.treatment_type) }}</span>
              <UBadge
                v-if="treatment.surfaces?.length"
                color="neutral"
                variant="subtle"
                size="xs"
              >
                {{ treatment.surfaces.join('-') }}
              </UBadge>
            </div>
            <div class="flex items-center gap-1 mt-1">
              <UButton
                v-if="!readonly"
                icon="i-lucide-check"
                size="xs"
                color="success"
                variant="soft"
                @click.stop="emit('performTreatment', treatment)"
              >
                {{ t('odontogram.treatments.markPerformed') }}
              </UButton>
              <UButton
                v-if="!readonly"
                icon="i-lucide-trash-2"
                size="xs"
                color="error"
                variant="ghost"
                @click.stop="emit('deleteTreatment', treatment)"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Existing treatments -->
      <div v-if="groupedTreatments.existing.length > 0">
        <div class="text-xs font-medium text-muted mb-2 flex items-center gap-1">
          <UIcon
            name="i-lucide-check-circle"
            class="w-3 h-3"
          />
          {{ getStatusLabel('existing') }}
        </div>
        <div class="space-y-2">
          <div
            v-for="treatment in groupedTreatments.existing"
            :key="treatment.id"
            class="treatment-item treatment-existing"
            @click="emit('selectTreatment', treatment)"
          >
            <div class="flex items-center gap-2">
              <div
                class="w-3 h-3 rounded-full"
                :style="{ backgroundColor: getTreatmentColor(treatment.treatment_type) }"
              />
              <span class="text-sm">{{ getTreatmentLabel(treatment.treatment_type) }}</span>
              <UBadge
                v-if="treatment.surfaces?.length"
                color="neutral"
                variant="subtle"
                size="xs"
              >
                {{ treatment.surfaces.join('-') }}
              </UBadge>
            </div>
            <div class="text-caption text-subtle mt-1">
              {{ formatDate(treatment.performed_at || treatment.recorded_at) }}
              <span v-if="treatment.performed_by_name"> - {{ treatment.performed_by_name }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.treatment-item {
  padding: 0.5rem 0.75rem;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background-color var(--motion-base) var(--motion-ease);
}

.treatment-item:hover {
  background-color: var(--color-canvas);
}

.treatment-planned {
  border-left: 2px solid var(--color-warning-accent);
}

.treatment-existing {
  border-left: 2px solid var(--color-border-strong);
}
</style>
