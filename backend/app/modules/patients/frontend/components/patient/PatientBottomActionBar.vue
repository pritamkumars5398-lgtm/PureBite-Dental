<script setup lang="ts">
/**
 * PatientBottomActionBar — sticky bottom bar with the three most-used
 * actions on the patient detail. Visible only on mobile (lg:hidden).
 * The host page wires up handlers; this component is presentational.
 */
import type { PatientExtended } from '~~/app/types'

defineProps<{
  patient: PatientExtended
}>()

const emit = defineEmits<{
  newAppointment: []
  collect: []
  newNote: []
}>()

const { t } = useI18n()
</script>

<template>
  <nav
    class="patient-bottom-bar lg:hidden fixed inset-x-0 bottom-0 z-40 bg-[var(--color-surface)]/95 backdrop-blur border-t border-[var(--color-border)] px-2 py-1.5"
    :style="{ paddingBottom: 'calc(0.375rem + env(safe-area-inset-bottom))' }"
    :aria-label="t('patientDetail.quickActionsAria')"
  >
    <div class="flex items-stretch gap-1">
      <button
        type="button"
        class="flex-1 inline-flex flex-col items-center justify-center gap-0.5 py-1.5 rounded-[var(--radius-md)] hover:bg-[var(--color-surface-muted)] transition-colors min-h-[44px]"
        @click="emit('newAppointment')"
      >
        <UIcon
          name="i-lucide-calendar-plus"
          class="w-5 h-5 text-[var(--color-primary)]"
        />
        <span class="text-caption text-default">
          {{ t('patientDetail.actions.newAppointment') }}
        </span>
      </button>

      <button
        type="button"
        class="flex-1 inline-flex flex-col items-center justify-center gap-0.5 py-1.5 rounded-[var(--radius-md)] hover:bg-[var(--color-surface-muted)] transition-colors min-h-[44px]"
        @click="emit('collect')"
      >
        <UIcon
          name="i-lucide-wallet"
          class="w-5 h-5 text-[var(--color-primary)]"
        />
        <span class="text-caption text-default">
          {{ t('patientDetail.actions.collect') }}
        </span>
      </button>

      <button
        type="button"
        class="flex-1 inline-flex flex-col items-center justify-center gap-0.5 py-1.5 rounded-[var(--radius-md)] hover:bg-[var(--color-surface-muted)] transition-colors min-h-[44px]"
        @click="emit('newNote')"
      >
        <UIcon
          name="i-lucide-edit"
          class="w-5 h-5 text-[var(--color-primary)]"
        />
        <span class="text-caption text-default">
          {{ t('patientDetail.actions.newNote') }}
        </span>
      </button>
    </div>
  </nav>
</template>
