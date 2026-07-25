<script setup lang="ts">
import type { SaasLead } from '~/composables/useSaasAdmin'

definePageMeta({
  title: 'Platform Administration - Leads'
})

const { t } = useI18n()
const { leads, isLoading, fetchAll, updateLeadStatus } = useSaasAdmin()

onMounted(fetchAll)

const leadStatusColor: Record<SaasLead['status'], 'warning' | 'info' | 'success' | 'error'> = {
  pending: 'warning',
  contacted: 'info',
  processed: 'success',
  rejected: 'error'
}
const updatingLeadId = ref<string | null>(null)
const leadStatusOptions = computed(() => (['pending', 'contacted', 'processed', 'rejected'] as const).map(value => ({
  value,
  label: t(`saasAdmin.leads.status.${value}`)
})))

async function handleLeadStatus(lead: SaasLead, status: SaasLead['status']) {
  updatingLeadId.value = lead.id
  await updateLeadStatus(lead.id, status)
  updatingLeadId.value = null
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
        {{ t('saasAdmin.leads.heading') }}
      </h1>
      <p class="text-sm text-gray-500 dark:text-gray-400">
        {{ t('saasAdmin.subtitle') }}
      </p>
    </div>

    <UCard class="shadow-sm border-t-4 border-t-primary-500">
      <div v-if="isLoading" class="space-y-4">
        <USkeleton class="h-8 w-1/4" />
        <USkeleton class="h-10 w-full" />
        <USkeleton class="h-10 w-full" />
      </div>
      <div v-else>
        <div class="flex justify-end items-center mb-4">
          <UButton
            color="primary"
            icon="i-lucide-refresh-cw"
            variant="ghost"
            @click="fetchAll"
          >
            {{ t('common.refresh') }}
          </UButton>
        </div>

        <div
          v-if="leads.length === 0"
          class="py-8 text-center text-gray-500"
        >
          {{ t('saasAdmin.leads.empty') }}
        </div>
        <div
          v-else
          class="divide-y divide-[var(--color-border-subtle)]"
        >
          <div
            v-for="lead in leads"
            :key="lead.id"
            class="flex items-center justify-between gap-3 py-3 flex-wrap"
          >
            <div class="min-w-0">
              <p class="font-medium text-default truncate">
                {{ lead.contact_name }} · {{ lead.clinic_name }}
              </p>
              <p class="text-caption text-subtle truncate">
                {{ lead.email }}<span v-if="lead.phone"> · {{ lead.phone }}</span>
                <span v-if="lead.expected_users"> · {{ t('saasAdmin.leads.expectedUsers', { count: lead.expected_users }) }}</span>
              </p>
              <p v-if="lead.message" class="text-sm text-gray-700 dark:text-gray-300 mt-2 italic bg-gray-50 dark:bg-gray-800 p-2 rounded-md border border-gray-100 dark:border-gray-700">
                "{{ lead.message }}"
              </p>
            </div>
            <div class="flex items-center gap-2 shrink-0">
              <UBadge
                :color="leadStatusColor[lead.status]"
                variant="subtle"
              >
                {{ t(`saasAdmin.leads.status.${lead.status}`) }}
              </UBadge>
              <USelect
                :model-value="lead.status"
                :items="leadStatusOptions"
                value-key="value"
                label-key="label"
                :disabled="updatingLeadId === lead.id"
                size="xs"
                class="w-36"
                @update:model-value="(v: string) => handleLeadStatus(lead, v as SaasLead['status'])"
              />
            </div>
          </div>
        </div>
      </div>
    </UCard>
  </div>
</template>
