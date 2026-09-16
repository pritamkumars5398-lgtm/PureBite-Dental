<script setup lang="ts">
/**
 * AdministrationModeToggle — full-width pill-bar over administration
 * tab modes with contextual badges (budgets count, debt amount).
 *
 * The `payments` mode is contributed by the `payments` module via the
 * `patient.detail.administracion.payments` slot. The pill only appears
 * when the slot has at least one provider that the current user can see
 * — i.e. the module is installed AND the user has `payments.record.read`.
 * No direct dependency from `patients` to `payments`: we only probe the
 * slot registry.
 */
import { useModuleSlots } from '~~/app/composables/useModuleSlots'

export type AdministrationMode = 'budgets' | 'billing' | 'payments' | 'documents'

interface ModeBadges {
  budgets?: string | number
  billing?: string | number
  payments?: string | number
  documents?: string | number
}

interface ModeBadgeColors {
  budgets?: 'neutral' | 'primary' | 'success' | 'warning' | 'error' | 'info'
  billing?: 'neutral' | 'primary' | 'success' | 'warning' | 'error' | 'info'
  payments?: 'neutral' | 'primary' | 'success' | 'warning' | 'error' | 'info'
  documents?: 'neutral' | 'primary' | 'success' | 'warning' | 'error' | 'info'
}

const props = defineProps<{
  modelValue: AdministrationMode
  badges?: ModeBadges
  badgeColors?: ModeBadgeColors
}>()

const emit = defineEmits<{
  'update:modelValue': [mode: AdministrationMode]
}>()

const { t } = useI18n()
const { resolve } = useModuleSlots()

const paymentsAvailable = computed(() =>
  resolve('patient.detail.administracion.payments', {}).length > 0
)

const options = computed(() => {
  const base = [
    {
      value: 'budgets',
      label: t('patientDetail.tabs.budgets'),
      icon: 'i-lucide-file-text',
      badge: props.badges?.budgets,
      badgeColor: props.badgeColors?.budgets ?? 'neutral'
    },
    {
      value: 'billing',
      label: t('patientDetail.tabs.billing'),
      icon: 'i-lucide-receipt',
      badge: props.badges?.billing,
      badgeColor: props.badgeColors?.billing ?? 'neutral'
    }
  ]
  if (paymentsAvailable.value) {
    base.push({
      value: 'payments',
      label: t('patientDetail.tabs.payments'),
      icon: 'i-lucide-wallet',
      badge: props.badges?.payments,
      badgeColor: props.badgeColors?.payments ?? 'neutral'
    })
  }
  base.push({
    value: 'documents',
    label: t('patientDetail.tabs.documents'),
    icon: 'i-lucide-files',
    badge: props.badges?.documents,
    badgeColor: props.badgeColors?.documents ?? 'neutral'
  })
  return base
})
</script>

<template>
  <div
    class="flex items-center gap-6 overflow-x-auto border-b border-[var(--color-border-subtle)]"
    role="tablist"
  >
    <button
      v-for="opt in options"
      :key="opt.value"
      type="button"
      role="tab"
      :aria-selected="modelValue === opt.value"
      class="relative pb-3 text-sm whitespace-nowrap transition-colors shrink-0 inline-flex items-center gap-1.5"
      :class="modelValue === opt.value
        ? 'font-medium text-[var(--color-primary)]'
        : 'text-muted hover:text-default'"
      @click="emit('update:modelValue', opt.value as AdministrationMode)"
    >
      {{ opt.label }}
      <UBadge
        v-if="opt.badge != null && opt.badge !== ''"
        :color="opt.badgeColor ?? 'neutral'"
        variant="subtle"
        size="xs"
        class="tnum"
      >
        {{ opt.badge }}
      </UBadge>
      <span
        v-if="modelValue === opt.value"
        class="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-[var(--color-primary)]"
      />
    </button>
  </div>
</template>
