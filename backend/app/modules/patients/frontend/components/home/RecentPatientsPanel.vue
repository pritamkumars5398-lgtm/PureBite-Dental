<script setup lang="ts">
import type { Patient, ApiResponse, PaginatedResponse } from '~~/app/types'

defineProps<{ ctx?: unknown }>()

interface FirstVisitsSummary {
  new_patients: number
  total_appointments: number
  first_visit_rate: number
}

const { t, locale } = useI18n()
const api = useApi()

const patients = ref<Patient[]>([])
const total = ref<number | null>(null)
const firstVisits = ref<FirstVisitsSummary | null>(null)
const pending = ref(true)

function isoDate(d: Date): string {
  return d.toISOString().split('T')[0] as string
}

function monthRange(): { from: string, to: string } {
  const now = new Date()
  const start = new Date(now.getFullYear(), now.getMonth(), 1)
  return { from: isoDate(start), to: isoDate(now) }
}

async function load() {
  const { from, to } = monthRange()

  const [recentRes, countRes, visitsRes] = await Promise.all([
    api.get<ApiResponse<Patient[]>>('/api/v1/patients/recent?limit=8').catch(() => null),
    api.get<PaginatedResponse<Patient>>('/api/v1/patients?page=1&page_size=1').catch(() => null),
    api.get<ApiResponse<FirstVisitsSummary>>(
      `/api/v1/reports/scheduling/first-visits?date_from=${from}&date_to=${to}`
    ).catch(() => null)
  ])

  patients.value = recentRes?.data ?? []
  total.value = typeof countRes?.total === 'number' ? countRes.total : null
  firstVisits.value = visitsRes?.data ?? null
  pending.value = false
}

onMounted(load)
onActivated(load)

function initials(p: Patient): string {
  return [p.first_name?.[0], p.last_name?.[0]].filter(Boolean).join('').toUpperCase() || '?'
}

function fullName(p: Patient): string {
  return `${p.first_name} ${p.last_name}`.trim()
}

function formatCount(n: number): string {
  return n.toLocaleString(locale.value)
}

const mix = computed(() => {
  const fv = firstVisits.value
  if (!fv) return null
  const newCount = fv.new_patients
  const returningCount = Math.max(0, fv.total_appointments - fv.new_patients)
  if (newCount <= 0 && returningCount <= 0) return null
  const newPct = fv.first_visit_rate
  const returningPct = fv.total_appointments > 0
    ? Math.round((returningCount / fv.total_appointments) * 1000) / 10
    : 0
  return { newCount, returningCount, newPct, returningPct }
})

const isEmpty = computed(() =>
  !pending.value && patients.value.length === 0 && (total.value === 0 || total.value === null)
)

const displayTotal = computed(() => {
  if (total.value !== null) return total.value
  return patients.value.length
})
</script>

<template>
  <DashboardCard
    :title="t('dashboard.recent.title')"
    :caption="t('dashboard.caption.thisMonth')"
    class="h-full"
  >
    <template #actions>
      <UButton
        to="/patients"
        variant="ghost"
        color="neutral"
        size="xs"
        trailing-icon="i-lucide-arrow-right"
      />
    </template>

    <div
      v-if="pending"
      class="space-y-4"
    >
      <USkeleton class="h-8 w-20" />
      <div class="grid grid-cols-2 gap-4">
        <USkeleton class="h-16 w-full" />
        <USkeleton class="h-16 w-full" />
      </div>
      <USkeleton class="h-8 w-40" />
    </div>

    <EmptyState
      v-else-if="isEmpty"
      compact
      icon="i-lucide-users"
      :title="t('dashboard.recent.empty')"
    />

    <div
      v-else
      class="flex flex-col gap-5"
    >
      <p class="text-display text-default tnum">
        {{ formatCount(displayTotal) }}
      </p>

      <div
        v-if="mix"
        class="grid grid-cols-2 gap-5"
      >
        <div class="min-w-0">
          <p class="text-h1 text-default tnum">
            {{ formatCount(mix.newCount) }}
          </p>
          <p class="text-caption text-subtle tnum mt-0.5">
            {{ mix.newPct.toFixed(1) }}%
          </p>
          <div class="h-1.5 rounded-full bg-[var(--color-surface-muted)] overflow-hidden mt-2">
            <div
              class="h-full rounded-full bg-[var(--color-primary)]"
              :style="{ width: `${Math.min(mix.newPct, 100)}%` }"
            />
          </div>
          <p class="text-caption text-muted mt-2">
            {{ t('dashboard.recent.new') }}
          </p>
        </div>

        <div class="min-w-0">
          <p class="text-h1 text-default tnum">
            {{ formatCount(mix.returningCount) }}
          </p>
          <p class="text-caption text-subtle tnum mt-0.5">
            {{ mix.returningPct.toFixed(1) }}%
          </p>
          <div class="h-1.5 rounded-full bg-[var(--color-surface-muted)] overflow-hidden mt-2">
            <div
              class="h-full rounded-full bg-[var(--color-primary)]"
              :style="{ width: `${Math.min(mix.returningPct, 100)}%` }"
            />
          </div>
          <p class="text-caption text-muted mt-2">
            {{ t('dashboard.recent.returning') }}
          </p>
        </div>
      </div>

      <div
        v-if="patients.length"
        class="flex items-center"
      >
        <NuxtLink
          v-for="(p, i) in patients"
          :key="p.id"
          :to="`/patients/${p.id}`"
          class="relative rounded-full focus:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-primary)]"
          :style="{ marginLeft: i === 0 ? '0' : '-0.5rem', zIndex: patients.length - i }"
          :title="fullName(p)"
          :aria-label="fullName(p)"
        >
          <UAvatar
            :alt="fullName(p)"
            :text="initials(p)"
            size="sm"
            class="ring-2 ring-[var(--color-surface)]"
          />
        </NuxtLink>
      </div>
    </div>
  </DashboardCard>
</template>
