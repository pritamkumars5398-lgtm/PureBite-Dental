<script setup lang="ts">
import type { PatientBrief, PlannedTreatmentItem } from '~~/app/types'

const route = useRoute()
const router = useRouter()
const { t, locale } = useI18n()
const toast = useToast()
const { format: formatCurrency } = useCurrency()

const {
  currentPlan,
  loading,
  fetchPlan,
  generateBudget,
} = useTreatmentPlans()

const planId = computed(() => route.params.id as string)

onMounted(async () => {
  await fetchPlan(planId.value)
})

watch(planId, async (newId) => {
  if (newId) await fetchPlan(newId)
})

const patientId = computed(() => currentPlan.value?.patient_id || '')

const AVATAR_TONES = [
  'bg-violet-100 text-violet-700',
  'bg-sky-100 text-sky-700',
  'bg-blue-100 text-blue-700',
  'bg-pink-100 text-pink-700',
  'bg-emerald-100 text-emerald-800',
  'bg-amber-100 text-amber-800',
  'bg-rose-100 text-rose-700',
] as const

function initials(person?: { first_name?: string, last_name?: string } | null): string {
  if (!person) return '?'
  const a = (person.first_name || '').trim().charAt(0)
  const b = (person.last_name || '').trim().charAt(0)
  return `${a}${b}`.toUpperCase() || '?'
}

function avatarTone(id?: string): string {
  if (!id) return AVATAR_TONES[0]
  let h = 0
  for (let i = 0; i < id.length; i++) h = (h + id.charCodeAt(i) * (i + 1)) % AVATAR_TONES.length
  return AVATAR_TONES[h] ?? AVATAR_TONES[0]
}

function formatListDate(value?: string | null): string {
  if (!value) return '—'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return '—'
  return new Intl.DateTimeFormat(locale.value, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(d)
}

const statusColor = computed(() => {
  const map: Record<string, string> = {
    draft: 'neutral',
    pending: 'warning',
    active: 'info',
    completed: 'success',
    closed: 'neutral',
    archived: 'neutral',
    cancelled: 'error',
  }
  const status = currentPlan.value?.status
  return (status && map[status]) || 'neutral'
})

const sortedItems = computed(() => {
  const items = currentPlan.value?.items ?? []
  return [...items].sort((a, b) => a.sequence_order - b.sequence_order)
})

const lastTreatmentAt = computed(() => {
  const dates = (currentPlan.value?.items ?? [])
    .map(item => item.completed_at)
    .filter((value): value is string => !!value)
    .map(value => new Date(value).getTime())
    .filter(time => Number.isFinite(time))
  if (!dates.length) return null
  return new Date(Math.max(...dates)).toISOString()
})

function getItemName(item: PlannedTreatmentItem): string {
  const names = item.catalog_item?.names || item.treatment?.catalog_item?.names
  if (names) {
    const name = names[locale.value] || names.es
    if (name) return name
  }
  const clinicalType = item.treatment?.clinical_type
  if (clinicalType === 'migrated' && item.treatment?.notes) {
    const trimmed = item.treatment.notes.trim()
    if (trimmed.length > 0) {
      return trimmed.length > 60 ? `${trimmed.slice(0, 60)}…` : trimmed
    }
  }
  if (clinicalType) {
    const key = `odontogram.treatments.types.${clinicalType}`
    const translated = t(key)
    if (translated !== key) return translated
    return clinicalType
  }
  return t('treatmentPlans.unknownTreatment')
}

function getItemTeeth(item: PlannedTreatmentItem): string {
  const teeth = item.treatment?.teeth?.map(tooth => tooth.tooth_number) ?? []
  if (!teeth.length) return '—'
  return teeth.join(', ')
}

function getItemPrice(item: PlannedTreatmentItem): string {
  const snap = item.treatment?.price_snapshot
  if (snap != null && snap !== '') {
    const parsed = Number(snap)
    if (Number.isFinite(parsed)) return formatCurrency(parsed)
  }
  const def = item.catalog_item?.default_price
  if (typeof def === 'number' && Number.isFinite(def)) return formatCurrency(def)
  return '—'
}

function itemStatusColor(status: string): string {
  if (status === 'completed') return 'success'
  if (status === 'cancelled') return 'neutral'
  return 'warning'
}

const patient = computed<PatientBrief | undefined>(() => currentPlan.value?.patient)

async function handleUpdated() {
  await fetchPlan(planId.value)
  await nextTick()
}

async function handleGenerateBudget() {
  const result = await generateBudget(planId.value)
  if (result?.budget_id) {
    toast.add({
      title: t('common.success'),
      description: t('treatmentPlans.actions.generateBudget'),
      color: 'success'
    })
    router.push(`/budgets/${result.budget_id}`)
  }
}

function handleSchedule() {
  if (patientId.value) {
    router.push(`/appointments?patient_id=${patientId.value}`)
  }
}

function handleCancelled() {
  if (patientId.value) {
    router.push(`/patients/${patientId.value}?tab=clinical&clinicalMode=plans`)
  } else {
    router.push('/treatment-plans')
  }
}
</script>

<template>
  <div
    class="overflow-hidden bg-[var(--color-surface)]"
    style="border-radius: var(--radius-xl)"
  >
    <div
      v-if="loading && !currentPlan"
      class="px-5 sm:px-6 py-6 space-y-4"
    >
      <USkeleton class="h-5 w-32" />
      <USkeleton class="h-9 w-1/3" />
      <USkeleton class="h-4 w-1/2" />
      <div class="border-t border-[var(--color-border-subtle)] -mx-5 sm:-mx-6">
        <USkeleton class="h-12 w-full rounded-none" />
        <USkeleton class="h-14 w-full rounded-none" />
        <USkeleton class="h-14 w-full rounded-none" />
        <USkeleton class="h-14 w-full rounded-none" />
      </div>
    </div>

    <div
      v-else-if="!currentPlan"
      class="px-5 sm:px-6 py-16 text-center"
    >
      <UIcon
        name="i-lucide-file-x"
        class="w-12 h-12 text-subtle mx-auto mb-4"
      />
      <p class="text-subtle">
        {{ t('common.notFound') }}
      </p>
      <UButton
        class="mt-4 rounded-full"
        to="/treatment-plans"
      >
        {{ t('treatmentPlans.title') }}
      </UButton>
    </div>

    <template v-else>
      <header class="px-5 sm:px-6 pt-5 sm:pt-6">
        <UButton
          variant="ghost"
          color="neutral"
          icon="i-lucide-arrow-left"
          size="sm"
          class="-ml-2 mb-3"
          to="/treatment-plans"
        >
          {{ t('clinical.plans.backToList') }}
        </UButton>

        <div class="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div class="min-w-0">
            <div class="flex flex-wrap items-center gap-2">
              <h1 class="text-display text-default text-pretty">
                {{ currentPlan.title || currentPlan.plan_number }}
              </h1>
              <UBadge
                :color="statusColor"
                variant="subtle"
                class="rounded-full"
              >
                {{ t(`treatmentPlans.status.${currentPlan.status}`) }}
              </UBadge>
            </div>
            <p class="mt-1 text-body text-muted text-pretty">
              {{ t('treatmentPlans.pageSubtitle') }}
            </p>
          </div>

          <NuxtLink
            v-if="patient"
            :to="`/patients/${patientId}`"
            class="inline-flex items-center gap-3 min-w-0 sm:justify-end"
          >
            <div
              class="w-10 h-10 rounded-full flex items-center justify-center text-xs font-semibold shrink-0"
              :class="avatarTone(patient.id)"
            >
              {{ initials(patient) }}
            </div>
            <div class="min-w-0 text-left sm:text-right">
              <div class="text-sm font-medium text-default truncate">
                {{ patient.first_name }} {{ patient.last_name }}
              </div>
              <div class="text-caption text-subtle truncate">
                {{ patient.patient_number || patient.phone || t('treatmentPlans.patient') }}
              </div>
            </div>
          </NuxtLink>
        </div>
      </header>

      <div class="px-5 sm:px-6 py-4 flex flex-col gap-2 sm:flex-row sm:items-baseline">
        <p class="text-lg text-default">
          <span class="font-semibold tnum">{{ currentPlan.items.length }}</span>
          <span class="text-muted"> {{ t('lists.totalSuffix', { noun: t('lists.noun.treatments') }) }}</span>
        </p>
        <p class="text-caption text-muted sm:ml-auto">
          {{ t('treatmentPlans.progress') }}
          {{ currentPlan.completed_count }}/{{ currentPlan.item_count || currentPlan.items.length }}
        </p>
      </div>

      <div class="hidden md:block overflow-x-auto border-t border-[var(--color-border-subtle)]">
        <table class="w-full min-w-[720px] text-left border-collapse">
          <thead>
            <tr class="border-b border-subtle">
              <th class="px-5 sm:px-6 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                {{ t('treatmentPlans.planNumber') }}
              </th>
              <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                {{ t('treatmentPlans.patient') }}
              </th>
              <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                {{ t('lists.columns.status') }}
              </th>
              <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                {{ t('patients.columns.registered') }}
              </th>
              <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                {{ t('treatmentPlans.lastTreatment') }}
              </th>
              <th class="px-5 sm:px-6 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                {{ t('treatmentPlans.linkedBudget') }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr class="border-b border-subtle">
              <td class="px-5 sm:px-6 py-3.5 text-sm font-mono text-default whitespace-nowrap">
                {{ currentPlan.plan_number }}
              </td>
              <td class="px-3 py-3.5 text-sm text-muted">
                <span v-if="patient">{{ patient.last_name }}, {{ patient.first_name }}</span>
                <span v-else>—</span>
              </td>
              <td class="px-3 py-3.5">
                <UBadge
                  :color="statusColor"
                  variant="subtle"
                  size="sm"
                  class="rounded-full"
                >
                  {{ t(`treatmentPlans.status.${currentPlan.status}`) }}
                </UBadge>
              </td>
              <td class="px-3 py-3.5 text-sm text-muted whitespace-nowrap">
                {{ formatListDate(currentPlan.created_at) }}
              </td>
              <td class="px-3 py-3.5 text-sm text-muted whitespace-nowrap">
                {{ formatListDate(lastTreatmentAt) }}
              </td>
              <td class="px-5 sm:px-6 py-3.5 text-sm">
                <NuxtLink
                  v-if="currentPlan.budget_id && currentPlan.budget"
                  :to="`/budgets/${currentPlan.budget_id}`"
                  class="text-primary-accent hover:underline"
                >
                  {{ currentPlan.budget.budget_number }}
                </NuxtLink>
                <span
                  v-else
                  class="text-subtle"
                >—</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="md:hidden border-t border-[var(--color-border-subtle)] px-5 py-4 space-y-3 text-sm">
        <div class="flex justify-between gap-3">
          <span class="text-caption text-muted uppercase tracking-wide">{{ t('treatmentPlans.planNumber') }}</span>
          <span class="font-mono text-default">{{ currentPlan.plan_number }}</span>
        </div>
        <div class="flex justify-between gap-3">
          <span class="text-caption text-muted uppercase tracking-wide">{{ t('patients.columns.registered') }}</span>
          <span class="text-muted">{{ formatListDate(currentPlan.created_at) }}</span>
        </div>
        <div class="flex justify-between gap-3">
          <span class="text-caption text-muted uppercase tracking-wide">{{ t('treatmentPlans.lastTreatment') }}</span>
          <span class="text-muted">{{ formatListDate(lastTreatmentAt) }}</span>
        </div>
        <div class="flex justify-between gap-3">
          <span class="text-caption text-muted uppercase tracking-wide">{{ t('treatmentPlans.linkedBudget') }}</span>
          <NuxtLink
            v-if="currentPlan.budget_id && currentPlan.budget"
            :to="`/budgets/${currentPlan.budget_id}`"
            class="text-primary-accent hover:underline"
          >
            {{ currentPlan.budget.budget_number }}
          </NuxtLink>
          <span
            v-else
            class="text-subtle"
          >—</span>
        </div>
      </div>

      <div
        v-if="currentPlan.diagnosis_notes || currentPlan.internal_notes"
        class="grid grid-cols-1 md:grid-cols-2 gap-4 px-5 sm:px-6 py-4 border-t border-[var(--color-border-subtle)]"
      >
        <div
          v-if="currentPlan.diagnosis_notes"
          class="rounded-[var(--radius-lg)] ring-1 ring-[var(--color-border)] bg-[var(--color-surface)] p-4"
        >
          <p class="text-[11px] font-semibold uppercase tracking-wide text-muted">
            {{ t('treatmentPlans.fields.diagnosisNotes') }}
          </p>
          <p class="mt-2 text-sm text-default whitespace-pre-wrap">
            {{ currentPlan.diagnosis_notes }}
          </p>
        </div>
        <div
          v-if="currentPlan.internal_notes"
          class="rounded-[var(--radius-lg)] ring-1 ring-[var(--color-border)] bg-[var(--color-surface)] p-4"
        >
          <p class="text-[11px] font-semibold uppercase tracking-wide text-muted">
            {{ t('treatmentPlans.fields.internalNotes') }}
          </p>
          <p class="mt-2 text-sm text-default whitespace-pre-wrap">
            {{ currentPlan.internal_notes }}
          </p>
        </div>
      </div>

      <div class="border-t border-[var(--color-border-subtle)]">
        <div class="px-5 sm:px-6 py-4">
          <h2 class="text-sm font-semibold text-default">
            {{ t('treatmentPlans.items.title') }}
          </h2>
        </div>

        <div
          v-if="!sortedItems.length"
          class="px-5 sm:px-6 pb-6 text-sm text-muted"
        >
          {{ t('treatmentPlans.noItems') }}
        </div>

        <div
          v-else
          class="hidden md:block overflow-x-auto"
        >
          <table class="w-full min-w-[640px] text-left border-collapse">
            <thead>
              <tr class="border-y border-subtle">
                <th class="px-5 sm:px-6 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                  {{ t('treatmentPlans.columns.treatment') }}
                </th>
                <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                  {{ t('treatmentPlans.columns.tooth') }}
                </th>
                <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                  {{ t('treatmentPlans.columns.status') }}
                </th>
                <th class="px-5 sm:px-6 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted text-right">
                  {{ t('treatmentPlans.columns.price') }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="item in sortedItems"
                :key="item.id"
                class="border-b border-subtle last:border-b-0"
              >
                <td class="px-5 sm:px-6 py-3.5 text-sm font-medium text-default">
                  {{ getItemName(item) }}
                </td>
                <td class="px-3 py-3.5 text-sm text-muted whitespace-nowrap">
                  {{ getItemTeeth(item) }}
                </td>
                <td class="px-3 py-3.5">
                  <UBadge
                    :color="itemStatusColor(item.status)"
                    variant="subtle"
                    size="sm"
                    class="rounded-full"
                  >
                    {{ t(`treatmentPlans.itemStatus.${item.status}`) }}
                  </UBadge>
                </td>
                <td class="px-5 sm:px-6 py-3.5 text-sm text-muted text-right tnum whitespace-nowrap">
                  {{ getItemPrice(item) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="md:hidden divide-y divide-[var(--color-border-subtle)]">
          <div
            v-for="item in sortedItems"
            :key="item.id"
            class="px-5 py-3.5 flex items-start justify-between gap-3"
          >
            <div class="min-w-0">
              <p class="text-sm font-medium text-default">
                {{ getItemName(item) }}
              </p>
              <p class="text-caption text-subtle mt-0.5">
                {{ t('treatmentPlans.columns.tooth') }} {{ getItemTeeth(item) }}
              </p>
            </div>
            <div class="text-right shrink-0">
              <UBadge
                :color="itemStatusColor(item.status)"
                variant="subtle"
                size="xs"
                class="rounded-full"
              >
                {{ t(`treatmentPlans.itemStatus.${item.status}`) }}
              </UBadge>
              <p class="text-caption text-muted tnum mt-1">
                {{ getItemPrice(item) }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <div class="border-t border-[var(--color-border-subtle)] px-5 sm:px-6 py-5 plan-workspace">
        <h2 class="text-sm font-semibold text-default mb-4">
          {{ t('treatmentPlans.clinicalWorkspace') }}
        </h2>
        <PlanDetailView
          :plan="currentPlan"
          :patient-id="patientId"
          standalone
          @updated="handleUpdated"
          @generate-budget="handleGenerateBudget"
          @schedule="handleSchedule"
          @cancelled="handleCancelled"
        />
      </div>
    </template>
  </div>
</template>

<style scoped>
.plan-workspace :deep(.plan-header-title) {
  display: none;
}

.plan-workspace :deep(.plan-header) {
  grid-template-columns: 1fr auto;
}
</style>
