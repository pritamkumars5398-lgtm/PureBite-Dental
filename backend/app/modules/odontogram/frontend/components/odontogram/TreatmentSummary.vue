<script setup lang="ts">
import type { ToothTreatmentView, Treatment, TreatmentStatus, TreatmentType } from '~~/app/types'
import { TREATMENT_COLORS, STATUS_STYLES } from './ToothSVGPaths'
import { viewForTooth } from '~~/app/utils/treatmentView'

const props = defineProps<{
  treatments: Treatment[]
}>()

const emit = defineEmits<{
  highlightTeeth: [teeth: number[]]
  clearHighlight: []
  filterStatus: [status: TreatmentStatus | null]
}>()

const { t } = useI18n()

const activeStatusFilter = ref<TreatmentStatus | null>(null)

/** Flatten Treatment[] into per-tooth rows. */
const perToothTreatments = computed<ToothTreatmentView[]>(() => {
  const rows: ToothTreatmentView[] = []
  for (const treatment of props.treatments) {
    for (const tooth of treatment.teeth) {
      const v = viewForTooth(treatment, tooth.tooth_number)
      if (v) rows.push(v)
    }
  }
  return rows
})

const treatmentsByType = computed(() => {
  const grouped: Record<
    string,
    { count: number, teeth: number[], treatments: ToothTreatmentView[] }
  > = {}

  for (const treatment of perToothTreatments.value) {
    if (!grouped[treatment.treatment_type]) {
      grouped[treatment.treatment_type] = { count: 0, teeth: [], treatments: [] }
    }
    grouped[treatment.treatment_type].count++
    if (!grouped[treatment.treatment_type].teeth.includes(treatment.tooth_number)) {
      grouped[treatment.treatment_type].teeth.push(treatment.tooth_number)
    }
    grouped[treatment.treatment_type].treatments.push(treatment)
  }

  return Object.entries(grouped)
    .sort(([, a], [, b]) => b.count - a.count)
    .map(([type, data]) => ({ type: type as TreatmentType, ...data }))
})

// Group per-tooth rows by status
const treatmentsByStatus = computed(() => {
  const grouped: Record<TreatmentStatus, number> = { planned: 0, existing: 0 }
  for (const treatment of perToothTreatments.value) {
    grouped[treatment.status]++
  }
  return grouped
})

const totalTreatments = computed(() => perToothTreatments.value.length)

const filteredTreatments = computed(() => {
  if (!activeStatusFilter.value) return perToothTreatments.value
  return perToothTreatments.value.filter(t => t.status === activeStatusFilter.value)
})

const uniqueTeethCount = computed(() => {
  const teeth = new Set<number>()
  for (const treatment of filteredTreatments.value) {
    teeth.add(treatment.tooth_number)
  }
  return teeth.size
})

function toggleStatusFilter(status: TreatmentStatus) {
  if (activeStatusFilter.value === status) {
    activeStatusFilter.value = null
  } else {
    activeStatusFilter.value = status
  }
  emit('filterStatus', activeStatusFilter.value)
}

function highlightTreatmentTeeth(type: TreatmentType) {
  const entry = treatmentsByType.value.find(e => e.type === type)
  if (entry) {
    emit('highlightTeeth', entry.teeth)
  }
}

function clearHighlight() {
  emit('clearHighlight')
}

function getTreatmentLabel(type: string): string {
  return t(`odontogram.treatments.types.${type}`, type)
}
</script>

<template>
  <div class="treatment-summary rounded-[20px] bg-surface ring-1 ring-[var(--color-border-subtle)] p-5">
    <!-- Header -->
    <div class="summary-header">
      <h4 class="text-h3 text-default">
        {{ t('odontogram.treatments.title') }}
      </h4>
      <span class="text-caption text-subtle">
        {{ t('odontogram.summary.total', { n: totalTreatments }) }}
      </span>
    </div>

    <!-- Status filters -->
    <div class="status-filters">
      <button
        v-for="(count, status) in treatmentsByStatus"
        :key="status"
        type="button"
        class="status-badge"
        :class="{
          active: activeStatusFilter === status,
          planned: status === 'planned',
          existing: status === 'existing'
        }"
        @click="toggleStatusFilter(status)"
      >
        <span
          class="status-dot"
          :style="{ backgroundColor: STATUS_STYLES[status].border }"
        />
        <span class="status-count">{{ count }}</span>
        <span class="status-label">{{ t(`odontogram.status.${status}`) }}</span>
      </button>
    </div>

    <!-- Divider -->
    <div class="divider" />

    <!-- Treatments by type -->
    <div class="treatments-list">
      <div
        v-for="entry in treatmentsByType"
        :key="entry.type"
        class="treatment-row"
        @mouseenter="highlightTreatmentTeeth(entry.type)"
        @mouseleave="clearHighlight"
      >
        <div class="treatment-info">
          <span
            class="treatment-dot"
            :style="{ backgroundColor: TREATMENT_COLORS[entry.type] || '#9CA3AF' }"
          />
          <span class="treatment-name">{{ getTreatmentLabel(entry.type) }}</span>
        </div>
        <div class="treatment-stats">
          <span class="treatment-count">{{ entry.count }}</span>
          <span class="teeth-count">{{ t('odontogram.summary.toothCount', entry.teeth.length) }}</span>
        </div>
      </div>

      <!-- Empty state -->
      <div
        v-if="treatmentsByType.length === 0"
        class="empty-state"
      >
        <UIcon
          name="i-lucide-clipboard-list"
          class="w-8 h-8 text-subtle"
        />
        <span class="text-caption text-subtle">{{ t('odontogram.treatments.noTreatments') }}</span>
      </div>
    </div>

    <!-- Footer stats -->
    <div
      v-if="totalTreatments > 0"
      class="summary-footer"
    >
      <div class="stat">
        <span class="stat-value">{{ uniqueTeethCount }}</span>
        <span class="stat-label">{{ t('odontogram.summary.teethLabel', uniqueTeethCount) }}</span>
      </div>
      <div class="stat">
        <span class="stat-value">{{ treatmentsByStatus.planned }}</span>
        <span class="stat-label">{{ t('odontogram.status.planned') }}</span>
      </div>
      <div class="stat">
        <span class="stat-value">{{ treatmentsByStatus.existing }}</span>
        <span class="stat-label">{{ t('odontogram.status.existing') }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.summary-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

/* Status filters */
.status-filters {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.status-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 10px;
  border-radius: var(--radius-md);
  font-size: 12px;
  background: var(--color-canvas);
  border: 1px solid transparent;
  transition: background var(--motion-base) var(--motion-ease), border-color var(--motion-base) var(--motion-ease);
}

.status-badge:hover {
  background: var(--color-surface-muted);
}

.status-badge.active {
  border-color: currentColor;
}

.status-badge.active.planned {
  background: var(--color-warning-soft);
  color: var(--color-warning-text);
}

.status-badge.active.existing {
  background: var(--color-canvas);
  color: var(--color-text);
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-count {
  font-weight: 600;
}

.status-label {
  color: var(--color-text-muted);
}

.divider {
  height: 1px;
  background: var(--color-border-subtle);
  margin: 12px 0;
}

/* Treatments list */
.treatments-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 200px;
  overflow-y: auto;
}

.treatment-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 10px;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background var(--motion-base) var(--motion-ease);
}

.treatment-row:hover {
  background: var(--color-canvas);
}

.treatment-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.treatment-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
}

.treatment-name {
  font-size: 13px;
  font-weight: 500;
  color: var(--color-text);
}

.treatment-stats {
  display: flex;
  align-items: center;
  gap: 8px;
}

.treatment-count {
  font-size: 14px;
  font-weight: 600;
  color: var(--color-text);
}

.teeth-count {
  font-size: 11px;
  color: var(--color-text-subtle);
}

/* Empty state */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 24px;
}

/* Footer stats */
.summary-footer {
  display: flex;
  justify-content: space-around;
  padding-top: 12px;
  margin-top: 12px;
  border-top: 1px solid var(--color-border-subtle);
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-value {
  font-size: 22px;
  font-weight: 700;
  color: var(--color-text);
  letter-spacing: -0.02em;
}

.stat-label {
  font-size: 10px;
  text-transform: uppercase;
  color: var(--color-text-subtle);
  letter-spacing: 0.05em;
  text-align: center;
}
</style>
