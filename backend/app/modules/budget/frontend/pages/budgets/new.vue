<script setup lang="ts">
import type { Patient, BudgetCreate } from '~~/app/types'
import { PERMISSIONS } from '~~/app/config/permissions'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()
const toast = useToast()
const { can } = usePermissions()
const { createBudget } = useBudgets()

const clinicCardClass = '!rounded-[20px] border-subtle ring-1 ring-[var(--color-border-subtle)] bg-surface'

// Track if coming from patient page
const comesFromPatient = computed(() => route.query.from === 'patient' && route.query.patient_id)
const backLabel = computed(() => comesFromPatient.value ? t('actions.back') : t('budget.title'))

function goBack() {
  if (comesFromPatient.value) {
    router.push(`/patients/${route.query.patient_id}`)
  } else {
    router.push('/budgets')
  }
}

// Check permission
if (!can(PERMISSIONS.budget.write)) {
  router.push('/budgets')
}

// Form state
const selectedPatient = ref<Patient | null>(null)
const isCreating = ref(false)

const form = reactive({
  valid_from: new Date().toISOString().split('T')[0],
  valid_until: '',
  patient_notes: '',
  internal_notes: ''
})

// Computed: can submit if patient is selected
const canSubmit = computed(() => !!selectedPatient.value && !isCreating.value)

async function handleCreate() {
  if (!selectedPatient.value) return

  isCreating.value = true

  try {
    const data: BudgetCreate = {
      patient_id: selectedPatient.value.id,
      valid_from: form.valid_from,
      valid_until: form.valid_until || undefined,
      patient_notes: form.patient_notes || undefined,
      internal_notes: form.internal_notes || undefined
    }

    const budget = await createBudget(data)

    toast.add({
      title: t('common.success'),
      description: t('budget.messages.created'),
      color: 'success'
    })

    // Navigate to the new budget to add items (preserve patient context)
    const queryParams = comesFromPatient.value
      ? `?from=patient&patientId=${route.query.patient_id}`
      : ''
    router.push(`/budgets/${budget.id}${queryParams}`)
  } catch {
    toast.add({
      title: t('common.error'),
      description: t('budget.errors.create'),
      color: 'error'
    })
  } finally {
    isCreating.value = false
  }
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center gap-4">
      <UButton
        variant="ghost"
        color="neutral"
        icon="i-lucide-arrow-left"
        @click="goBack"
      >
        {{ backLabel }}
      </UButton>
      <div class="min-w-0">
        <h1 class="text-display text-default">
          {{ t('budget.new') }}
        </h1>
        <p class="mt-1 text-caption text-muted">
          {{ t('budget.newHint') }}
        </p>
      </div>
    </div>

    <form
      class="grid grid-cols-1 lg:grid-cols-3 gap-6"
      @submit.prevent="handleCreate"
    >
      <div class="lg:col-span-2 space-y-6">
        <UCard :class="clinicCardClass">
          <template #header>
            <h2 class="text-h2 text-default">
              {{ t('budget.patient') }}
            </h2>
          </template>

          <UFormField
            :label="t('budget.selectPatient')"
            required
          >
            <PatientVisualSelector
              v-model="selectedPatient"
              :placeholder="t('budget.selectPatient')"
            />
            <p class="text-caption text-subtle mt-1">
              {{ t('budget.selectPatientHint') }}
            </p>
          </UFormField>
        </UCard>

        <UCard :class="clinicCardClass">
          <template #header>
            <h2 class="text-h2 text-default">
              {{ t('budget.details') }}
            </h2>
          </template>

          <div class="space-y-6">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <UFormField
                :label="t('budget.validFrom')"
                required
              >
                <UInput
                  v-model="form.valid_from"
                  type="date"
                  required
                />
              </UFormField>
              <UFormField :label="t('budget.validUntil')">
                <UInput
                  v-model="form.valid_until"
                  type="date"
                />
                <p class="text-caption text-subtle mt-1">
                  {{ t('budget.validUntilHint') }}
                </p>
              </UFormField>
            </div>

            <UFormField :label="t('budget.patientNotes')">
              <UTextarea
                v-model="form.patient_notes"
                :placeholder="t('budget.patientNotesPlaceholder')"
                :rows="3"
              />
            </UFormField>

            <UFormField :label="t('budget.internalNotes')">
              <UTextarea
                v-model="form.internal_notes"
                :placeholder="t('budget.internalNotesPlaceholder')"
                :rows="3"
              />
            </UFormField>
          </div>
        </UCard>
      </div>

      <aside class="space-y-6">
        <div :class="clinicCardClass" class="p-5">
          <p class="text-caption text-subtle">
            {{ t('budget.items.title') }}
          </p>
          <p class="mt-1 text-h2 text-default">
            {{ t('budget.createAndAddItems') }}
          </p>
          <p class="mt-2 text-caption text-muted">
            {{ t('budget.newHint') }}
          </p>
        </div>

        <div class="flex flex-col-reverse sm:flex-row lg:flex-col-reverse gap-3">
          <UButton
            variant="outline"
            color="neutral"
            block
            @click="goBack"
          >
            {{ t('common.cancel') }}
          </UButton>
          <UButton
            type="submit"
            color="primary"
            icon="i-lucide-plus"
            block
            :disabled="!canSubmit"
            :loading="isCreating"
          >
            {{ t('budget.createAndAddItems') }}
          </UButton>
        </div>
      </aside>
    </form>
  </div>
</template>
