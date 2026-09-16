<script setup lang="ts">
import type { PatientExtended } from '~~/app/types'
import { patientAvatarTone, patientInitials } from '../../../utils/avatarTone'
import { computeAge, formatPatientDate } from '../../../utils/medicalSnapshot'

interface Props {
  patient: PatientExtended
  canEdit: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{ edit: [] }>()

const { t, locale } = useI18n()

const age = computed(() => computeAge(props.patient.date_of_birth))

const initials = computed(() => patientInitials(props.patient.first_name, props.patient.last_name))
const avatarTone = computed(() => patientAvatarTone(props.patient.id))

const statusColor = computed<'success' | 'neutral'>(() =>
  props.patient.status === 'active' ? 'success' : 'neutral',
)

const birthDisplay = computed(() => {
  const formatted = formatPatientDate(props.patient.date_of_birth, locale.value === 'en' ? 'en-US' : 'es-ES')
  if (!formatted) return null
  if (age.value === null) return formatted
  return t('patients.personalInfo.birthWithAge', { date: formatted, age: age.value })
})

const documentDisplay = computed(() => {
  if (!props.patient.national_id) return null
  const type = props.patient.national_id_type?.toUpperCase() ?? ''
  return type ? `${type}: ${props.patient.national_id}` : props.patient.national_id
})

const genderLabel = computed(() =>
  props.patient.gender ? t(`patients.gender.${props.patient.gender}`) : null,
)
</script>

<template>
  <UCard
    role="region"
    aria-labelledby="personal-info-title"
    :ui="{ root: 'rounded-[var(--radius-xl)]', header: 'px-5 py-4', body: 'px-5 py-2' }"
  >
    <template #header>
      <div class="flex items-center justify-between gap-3">
        <h2
          id="personal-info-title"
          class="text-[11px] font-semibold uppercase tracking-wide text-muted truncate"
        >
          {{ t('patients.personalInfo.title') }}
        </h2>
        <UButton
          v-if="canEdit"
          variant="ghost"
          color="neutral"
          icon="i-lucide-pencil"
          size="sm"
          class="rounded-full"
          :aria-label="t('patients.editDemographics')"
          @click="emit('edit')"
        >
          <span class="hidden lg:inline">{{ t('common.edit') }}</span>
        </UButton>
      </div>
    </template>

    <div class="flex items-center gap-3 py-3 border-b border-[var(--color-border-subtle)]">
      <img
        v-if="patient.photo_url"
        :src="patient.photo_url"
        :alt="`${patient.first_name} ${patient.last_name}`"
        class="w-10 h-10 rounded-full object-cover shrink-0"
      >
      <div
        v-else
        class="w-10 h-10 rounded-full flex items-center justify-center text-xs font-semibold shrink-0"
        :class="avatarTone"
        aria-hidden="true"
      >
        {{ initials }}
      </div>
      <div class="min-w-0 flex-1">
        <p class="text-sm font-medium text-default break-words">
          {{ patient.first_name }} {{ patient.last_name }}
        </p>
        <p class="text-caption text-muted mt-0.5 flex flex-wrap items-center gap-2">
          <span v-if="age !== null">{{ t('patients.personalInfo.ageLabel', { age }) }}</span>
          <UBadge
            :color="statusColor"
            variant="subtle"
            size="sm"
          >
            {{ patient.status === 'active' ? t('patients.status.active') : t('patients.status.archived') }}
          </UBadge>
        </p>
      </div>
    </div>

    <dl class="divide-y divide-[var(--color-border-subtle)]">
      <div class="flex items-center gap-3 py-3">
        <UIcon
          name="i-lucide-cake"
          class="w-3.5 h-3.5 text-subtle shrink-0"
          aria-hidden="true"
        />
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-28 shrink-0">
          {{ t('patients.dateOfBirth') }}
        </dt>
        <dd class="text-sm text-muted min-w-0 break-words">
          {{ birthDisplay ?? '—' }}
        </dd>
      </div>

      <div
        v-if="genderLabel"
        class="flex items-center gap-3 py-3"
      >
        <UIcon
          name="i-lucide-user-2"
          class="w-3.5 h-3.5 text-subtle shrink-0"
          aria-hidden="true"
        />
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-28 shrink-0">
          {{ t('patients.gender.label') }}
        </dt>
        <dd class="text-sm text-muted min-w-0 break-words">
          {{ genderLabel }}
        </dd>
      </div>

      <div
        v-if="documentDisplay"
        class="flex items-center gap-3 py-3"
      >
        <UIcon
          name="i-lucide-id-card"
          class="w-3.5 h-3.5 text-subtle shrink-0"
          aria-hidden="true"
        />
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-28 shrink-0">
          {{ t('patients.nationalId') }}
        </dt>
        <dd class="text-sm text-muted min-w-0 break-words">
          {{ documentDisplay }}
        </dd>
      </div>

      <div
        v-if="patient.profession"
        class="flex items-center gap-3 py-3"
      >
        <UIcon
          name="i-lucide-briefcase"
          class="w-3.5 h-3.5 text-subtle shrink-0"
          aria-hidden="true"
        />
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-28 shrink-0">
          {{ t('patients.profession') }}
        </dt>
        <dd class="text-sm text-muted min-w-0 break-words">
          {{ patient.profession }}
        </dd>
      </div>

      <div
        v-if="patient.workplace"
        class="flex items-center gap-3 py-3"
      >
        <UIcon
          name="i-lucide-building-2"
          class="w-3.5 h-3.5 text-subtle shrink-0"
          aria-hidden="true"
        />
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-28 shrink-0">
          {{ t('patients.workplace') }}
        </dt>
        <dd class="text-sm text-muted min-w-0 break-words">
          {{ patient.workplace }}
        </dd>
      </div>
    </dl>

    <div
      v-if="patient.notes"
      class="py-3 border-t border-[var(--color-border-subtle)]"
    >
      <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted mb-1">
        {{ t('patients.notes') }}
      </dt>
      <dd class="text-sm text-muted whitespace-pre-wrap break-words">
        {{ patient.notes }}
      </dd>
    </div>
  </UCard>
</template>
