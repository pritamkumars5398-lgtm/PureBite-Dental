<script setup lang="ts">
import type { Patient } from '~~/app/types'

const router = useRouter()
const { t } = useI18n()
const { createPlan, loading } = useTreatmentPlans()
const { professionals, fetchProfessionals } = useProfessionals()
const api = useApi()

// Patient search
const searchQuery = ref('')
const patients = ref<Patient[]>([])
const selectedPatient = ref<Patient | null>(null)
const searchLoading = ref(false)

// Form data
const form = ref({
  title: '',
  assigned_professional_id: undefined as string | undefined,
  diagnosis_notes: '',
  internal_notes: ''
})

const AVATAR_TONES = [
  'bg-violet-100 text-violet-700',
  'bg-sky-100 text-sky-700',
  'bg-blue-100 text-blue-700',
  'bg-pink-100 text-pink-700',
  'bg-emerald-100 text-emerald-800',
  'bg-amber-100 text-amber-800',
  'bg-rose-100 text-rose-700',
] as const

function patientInitials(p: Patient): string {
  const a = (p.first_name || '').trim().charAt(0)
  const b = (p.last_name || '').trim().charAt(0)
  return `${a}${b}`.toUpperCase() || '?'
}

function avatarTone(id: string): string {
  let h = 0
  for (let i = 0; i < id.length; i++) h = (h + id.charCodeAt(i) * (i + 1)) % AVATAR_TONES.length
  return AVATAR_TONES[h] ?? AVATAR_TONES[0]
}

// Fetch professionals on mount
onMounted(() => {
  fetchProfessionals()
})

// Search patients
async function searchPatients(query: string) {
  if (!query || query.length < 2) {
    patients.value = []
    return
  }

  searchLoading.value = true
  try {
    const response = await api.get<{ data: Patient[] }>(
      `/api/v1/patients?search=${encodeURIComponent(query)}&page_size=10`
    )
    patients.value = response.data
  } catch {
    patients.value = []
  } finally {
    searchLoading.value = false
  }
}

// Debounced search
let searchTimeout: ReturnType<typeof setTimeout> | null = null
watch(searchQuery, (val) => {
  if (searchTimeout) clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    searchPatients(val)
  }, 300)
})

function selectPatient(patient: Patient) {
  selectedPatient.value = patient
  searchQuery.value = ''
  patients.value = []
}

function clearPatient() {
  selectedPatient.value = null
}

const professionalOptions = computed(() => {
  return professionals.value.map(p => ({
    label: `${p.first_name} ${p.last_name}`,
    value: p.id
  }))
})

async function handleSubmit() {
  if (!selectedPatient.value) return

  const plan = await createPlan({
    patient_id: selectedPatient.value.id,
    title: form.value.title || undefined,
    assigned_professional_id: form.value.assigned_professional_id || undefined,
    diagnosis_notes: form.value.diagnosis_notes || undefined,
    internal_notes: form.value.internal_notes || undefined
  })

  if (plan) {
    router.push(`/treatment-plans/${plan.id}`)
  }
}

function goBack() {
  router.push('/treatment-plans')
}
</script>

<template>
  <div
    class="overflow-hidden bg-[var(--color-surface)]"
    style="border-radius: var(--radius-xl)"
  >
    <header class="px-5 sm:px-6 pt-5 sm:pt-6">
      <UButton
        variant="ghost"
        color="neutral"
        icon="i-lucide-arrow-left"
        size="sm"
        class="-ml-2 mb-3"
        @click="goBack"
      >
        {{ t('clinical.plans.backToList') }}
      </UButton>
      <h1 class="text-display text-default text-pretty">
        {{ t('treatmentPlans.create') }}
      </h1>
      <p class="mt-1 text-body text-muted text-pretty">
        {{ t('treatmentPlans.createSubtitle') }}
      </p>
    </header>

    <form @submit.prevent="handleSubmit">
      <div class="px-5 sm:px-6 py-4 border-t border-[var(--color-border-subtle)] mt-4">
        <p class="text-[11px] font-semibold uppercase tracking-wide text-muted mb-3">
          {{ t('treatmentPlans.patient') }}
        </p>

        <div
          v-if="selectedPatient"
          class="overflow-hidden rounded-[var(--radius-lg)] ring-1 ring-[var(--color-border)]"
        >
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="border-b border-subtle">
                <th class="px-4 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                  {{ t('patients.columns.patientName') }}
                </th>
                <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted hidden sm:table-cell">
                  {{ t('patients.phone') }}
                </th>
                <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted hidden md:table-cell">
                  {{ t('patients.email') }}
                </th>
                <th class="w-24 px-3 py-3" />
              </tr>
            </thead>
            <tbody>
              <tr>
                <td class="px-4 py-3.5">
                  <div class="flex items-center gap-3 min-w-0">
                    <div
                      class="w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-semibold shrink-0"
                      :class="avatarTone(selectedPatient.id)"
                    >
                      {{ patientInitials(selectedPatient) }}
                    </div>
                    <div class="min-w-0">
                      <div class="text-sm font-medium text-default truncate">
                        {{ selectedPatient.first_name }} {{ selectedPatient.last_name }}
                      </div>
                      <div
                        v-if="selectedPatient.patient_number"
                        class="text-caption text-subtle font-mono truncate"
                      >
                        {{ selectedPatient.patient_number }}
                      </div>
                    </div>
                  </div>
                </td>
                <td class="px-3 py-3.5 hidden sm:table-cell">
                  <span
                    v-if="selectedPatient.phone"
                    class="inline-flex items-center gap-1.5 text-sm text-muted"
                  >
                    <UIcon
                      name="i-lucide-phone"
                      class="w-3.5 h-3.5 text-subtle shrink-0"
                    />
                    {{ selectedPatient.phone }}
                  </span>
                  <span
                    v-else
                    class="text-sm text-subtle"
                  >—</span>
                </td>
                <td class="px-3 py-3.5 hidden md:table-cell">
                  <span
                    v-if="selectedPatient.email"
                    class="inline-flex items-center gap-1.5 text-sm text-muted"
                  >
                    <UIcon
                      name="i-lucide-mail"
                      class="w-3.5 h-3.5 text-subtle shrink-0"
                    />
                    {{ selectedPatient.email }}
                  </span>
                  <span
                    v-else
                    class="text-sm text-subtle"
                  >—</span>
                </td>
                <td class="px-3 py-3.5 text-right">
                  <UButton
                    type="button"
                    variant="ghost"
                    color="neutral"
                    size="sm"
                    class="rounded-full"
                    @click="clearPatient"
                  >
                    {{ t('treatmentPlans.changePatient') }}
                  </UButton>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div
          v-else
          class="space-y-3"
        >
          <UInput
            v-model="searchQuery"
            :placeholder="t('patients.searchPlaceholder')"
            icon="i-lucide-search"
            :loading="searchLoading"
            class="max-w-sm rounded-full w-full"
          />
          <p class="text-caption text-subtle">
            {{ t('treatmentPlans.selectPatientHint') }}
          </p>

          <div
            v-if="patients.length > 0"
            class="overflow-hidden rounded-[var(--radius-lg)] ring-1 ring-[var(--color-border)]"
          >
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="border-b border-subtle">
                  <th class="px-4 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted">
                    {{ t('patients.columns.patientName') }}
                  </th>
                  <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted hidden sm:table-cell">
                    {{ t('patients.phone') }}
                  </th>
                  <th class="px-3 py-3 text-[11px] font-semibold uppercase tracking-wide text-muted hidden md:table-cell">
                    {{ t('patients.email') }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="patient in patients"
                  :key="patient.id"
                  class="border-b border-subtle last:border-b-0 hover:bg-surface-muted/70 cursor-pointer transition-colors"
                  @click="selectPatient(patient)"
                >
                  <td class="px-4 py-3.5">
                    <div class="flex items-center gap-3 min-w-0">
                      <div
                        class="w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-semibold shrink-0"
                        :class="avatarTone(patient.id)"
                      >
                        {{ patientInitials(patient) }}
                      </div>
                      <div class="min-w-0">
                        <div class="text-sm font-medium text-default truncate">
                          {{ patient.first_name }} {{ patient.last_name }}
                        </div>
                        <div
                          v-if="patient.patient_number"
                          class="text-caption text-subtle font-mono truncate"
                        >
                          {{ patient.patient_number }}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td class="px-3 py-3.5 hidden sm:table-cell">
                    <span
                      v-if="patient.phone"
                      class="inline-flex items-center gap-1.5 text-sm text-muted"
                    >
                      <UIcon
                        name="i-lucide-phone"
                        class="w-3.5 h-3.5 text-subtle shrink-0"
                      />
                      {{ patient.phone }}
                    </span>
                    <span
                      v-else
                      class="text-sm text-subtle"
                    >—</span>
                  </td>
                  <td class="px-3 py-3.5 hidden md:table-cell">
                    <span
                      v-if="patient.email"
                      class="inline-flex items-center gap-1.5 text-sm text-muted"
                    >
                      <UIcon
                        name="i-lucide-mail"
                        class="w-3.5 h-3.5 text-subtle shrink-0"
                      />
                      {{ patient.email }}
                    </span>
                    <span
                      v-else
                      class="text-sm text-subtle"
                    >—</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <p
            v-else-if="searchQuery.length >= 2 && !searchLoading"
            class="text-sm text-muted"
          >
            {{ t('treatmentPlans.noPatientResults') }}
          </p>
        </div>
      </div>

      <div class="px-5 sm:px-6 py-5 border-t border-[var(--color-border-subtle)] space-y-5">
        <UFormField :label="t('treatmentPlans.fields.title')">
          <UInput
            v-model="form.title"
            :placeholder="t('treatmentPlans.fields.titlePlaceholder')"
          />
        </UFormField>

        <UFormField :label="t('treatmentPlans.fields.assignedProfessional')">
          <USelect
            v-model="form.assigned_professional_id"
            :items="professionalOptions"
            :placeholder="t('treatmentPlans.fields.selectProfessional')"
            value-key="value"
          />
        </UFormField>

        <UFormField :label="t('treatmentPlans.fields.diagnosisNotes')">
          <UTextarea
            v-model="form.diagnosis_notes"
            :rows="3"
            :placeholder="t('treatmentPlans.fields.diagnosisNotesPlaceholder')"
          />
        </UFormField>

        <UFormField :label="t('treatmentPlans.fields.internalNotes')">
          <UTextarea
            v-model="form.internal_notes"
            :rows="3"
            :placeholder="t('treatmentPlans.fields.internalNotesPlaceholder')"
          />
        </UFormField>
      </div>

      <div class="px-5 sm:px-6 py-4 border-t border-[var(--color-border-subtle)] flex justify-end gap-3">
        <UButton
          type="button"
          variant="ghost"
          color="neutral"
          class="rounded-full"
          @click="goBack"
        >
          {{ t('actions.cancel') }}
        </UButton>
        <UButton
          type="submit"
          color="primary"
          class="rounded-full"
          :loading="loading"
          :disabled="!selectedPatient"
        >
          {{ t('actions.create') }}
        </UButton>
      </div>
    </form>
  </div>
</template>
