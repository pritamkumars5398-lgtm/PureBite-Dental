<script setup lang="ts">
import type { PatientExtended } from '~~/app/types'

interface Props {
  patient: PatientExtended
  canEdit: boolean
}

defineProps<Props>()

const emit = defineEmits<{ edit: [] }>()

const { t } = useI18n()
</script>

<template>
  <UCard
    role="region"
    aria-labelledby="administrative-title"
    :ui="{ root: 'rounded-[var(--radius-xl)]', header: 'px-5 py-4', body: 'px-5 py-2' }"
  >
    <template #header>
      <div class="flex items-center justify-between gap-3">
        <h2
          id="administrative-title"
          class="text-[11px] font-semibold uppercase tracking-wide text-muted truncate"
        >
          {{ t('patients.administrative.title') }}
        </h2>
        <UButton
          v-if="canEdit"
          variant="ghost"
          color="neutral"
          icon="i-lucide-pencil"
          size="sm"
          class="rounded-full"
          :aria-label="t('patients.editBilling')"
          @click="emit('edit')"
        >
          <span class="hidden lg:inline">{{ t('common.edit') }}</span>
        </UButton>
      </div>
    </template>

    <div class="py-3 border-b border-[var(--color-border-subtle)]">
      <UBadge
        v-if="patient.has_complete_billing_info"
        color="success"
        variant="subtle"
        size="md"
      >
        <UIcon
          name="i-lucide-check"
          class="w-3.5 h-3.5 mr-1"
          aria-hidden="true"
        />
        {{ t('patients.billingComplete') }}
      </UBadge>
      <UBadge
        v-else
        color="warning"
        variant="subtle"
        size="md"
      >
        <UIcon
          name="i-lucide-alert-triangle"
          class="w-3.5 h-3.5 mr-1"
          aria-hidden="true"
        />
        {{ t('patients.billingIncomplete') }}
      </UBadge>
    </div>

    <dl class="divide-y divide-[var(--color-border-subtle)]">
      <div class="flex items-start gap-3 py-3">
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-32 shrink-0">
          {{ t('patients.billingName') }}
        </dt>
        <dd class="text-sm text-muted min-w-0 break-words">
          {{ patient.billing_name || '—' }}
        </dd>
      </div>
      <div class="flex items-start gap-3 py-3">
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-32 shrink-0">
          {{ t('patients.billingTaxId') }}
        </dt>
        <dd class="text-sm text-muted min-w-0 break-words">
          {{ patient.billing_tax_id || '—' }}
        </dd>
      </div>
      <div class="flex items-start gap-3 py-3">
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-32 shrink-0">
          {{ t('patients.billingEmail') }}
        </dt>
        <dd class="text-sm text-muted min-w-0 break-words">
          {{ patient.billing_email || '—' }}
        </dd>
      </div>
      <div class="flex items-start gap-3 py-3">
        <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-32 shrink-0">
          {{ t('patients.billingAddress') }}
        </dt>
        <dd class="text-sm text-muted min-w-0">
          <template v-if="patient.billing_address">
            <span class="block break-words">{{ patient.billing_address.street || '' }}</span>
            <span
              v-if="patient.billing_address.city || patient.billing_address.postal_code"
              class="block break-words"
            >{{ patient.billing_address.postal_code }} {{ patient.billing_address.city }}</span>
            <span
              v-if="patient.billing_address.province"
              class="block break-words"
            >{{ patient.billing_address.province }}</span>
          </template>
          <template v-else>
            —
          </template>
        </dd>
      </div>
    </dl>
  </UCard>
</template>
