<script setup lang="ts">
import type { Appointment } from '~~/app/types'
import { formatPatientDate, nextAppointmentProximity } from '../../../utils/medicalSnapshot'

interface Props {
  lastVisit: Appointment | null
  nextAppointment: Appointment | null
}

const props = defineProps<Props>()

const { t, locale } = useI18n()

function appointmentDate(a: Appointment): string | null {
  return formatPatientDate(a.start_time, locale.value === 'en' ? 'en-US' : 'es-ES')
}

function appointmentTime(a: Appointment): string | null {
  if (!a.start_time) return null
  const d = new Date(a.start_time)
  if (Number.isNaN(d.getTime())) return null
  return d.toLocaleTimeString(locale.value === 'en' ? 'en-US' : 'es-ES', {
    hour: '2-digit',
    minute: '2-digit',
  })
}

function appointmentTreatment(a: Appointment): string | null {
  if (a.treatments?.length) return a.treatments[0]?.name ?? null
  return a.treatment_type ?? null
}

function appointmentProfessional(a: Appointment): string | null {
  if (!a.professional) return null
  const u = a.professional
  const full = [u.first_name, u.last_name].filter(Boolean).join(' ').trim()
  return full || u.email || null
}

const proximityBadge = computed(() => {
  if (!props.nextAppointment) return null
  return nextAppointmentProximity(props.nextAppointment.start_time, t)
})
</script>

<template>
  <UCard
    role="region"
    aria-labelledby="visit-summary-title"
    :ui="{ root: 'rounded-[var(--radius-xl)]', header: 'px-5 py-4', body: 'p-5' }"
  >
    <template #header>
      <h2
        id="visit-summary-title"
        class="text-[11px] font-semibold uppercase tracking-wide text-muted"
      >
        {{ t('patients.visitSummary.title') }}
      </h2>
    </template>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-8 divide-y md:divide-y-0 md:divide-x divide-[var(--color-border-subtle)]">
      <!-- Last visit -->
      <section class="md:pr-8 pb-4 md:pb-0">
        <div class="flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-wide text-muted mb-2">
          <UIcon
            name="i-lucide-history"
            class="w-3.5 h-3.5"
            aria-hidden="true"
          />
          {{ t('patients.visitSummary.lastVisit') }}
        </div>
        <div v-if="lastVisit">
          <p class="text-sm font-medium text-default">
            {{ appointmentDate(lastVisit) }}
          </p>
          <p
            v-if="appointmentTreatment(lastVisit)"
            class="text-sm text-muted"
          >
            {{ appointmentTreatment(lastVisit) }}
          </p>
          <p
            v-if="appointmentProfessional(lastVisit)"
            class="text-caption text-muted"
          >
            {{ appointmentProfessional(lastVisit) }}
          </p>
        </div>
        <p
          v-else
          class="text-sm text-muted"
        >
          {{ t('patients.visitSummary.noLastVisit') }}
        </p>
      </section>

      <!-- Next appointment -->
      <section class="md:pl-6 pt-4 md:pt-0">
        <div class="flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-wide text-muted mb-2">
          <UIcon
            name="i-lucide-calendar-clock"
            class="w-3.5 h-3.5"
            aria-hidden="true"
          />
          {{ t('patients.visitSummary.nextAppointment') }}
          <UBadge
            v-if="proximityBadge"
            :color="proximityBadge.color"
            variant="subtle"
            size="sm"
            class="ml-1 normal-case"
          >
            {{ proximityBadge.label }}
          </UBadge>
        </div>
        <div v-if="nextAppointment">
          <p class="text-sm font-medium text-default">
            {{ appointmentDate(nextAppointment) }}
            <span
              v-if="appointmentTime(nextAppointment)"
              class="text-muted font-normal"
            >· {{ appointmentTime(nextAppointment) }}</span>
          </p>
          <p
            v-if="appointmentTreatment(nextAppointment)"
            class="text-sm text-muted"
          >
            {{ appointmentTreatment(nextAppointment) }}
          </p>
          <p
            v-if="appointmentProfessional(nextAppointment)"
            class="text-caption text-muted"
          >
            {{ appointmentProfessional(nextAppointment) }}
          </p>
          <p
            v-if="nextAppointment.cabinet"
            class="text-caption text-muted"
          >
            {{ nextAppointment.cabinet }}
          </p>
        </div>
        <p
          v-else
          class="text-sm text-muted"
        >
          {{ t('patients.visitSummary.noNextAppointment') }}
        </p>
      </section>
    </div>
  </UCard>
</template>
