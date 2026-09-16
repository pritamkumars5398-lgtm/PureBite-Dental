<script setup lang="ts">
import type { PipelineRow, PipelineTab } from '~/composables/usePipeline'

const props = defineProps<{
  tab: PipelineTab
  q: string
}>()

const { t, locale } = useI18n()
const { format: formatCurrency } = useCurrency()
const router = useRouter()
const toast = useToast()
const {
  rows,
  total,
  page,
  pageSize,
  loading,
  filters,
  fetchPipeline,
} = usePipeline()

watch(
  () => props.tab,
  async (next) => {
    page.value = 1
    await fetchPipeline({ tab: next, page: 1, q: props.q || undefined })
  }
)

watch(
  () => props.q,
  async (val) => {
    filters.q = val || undefined
    page.value = 1
    await fetchPipeline({ tab: props.tab, page: 1, q: val || undefined })
  }
)

onMounted(async () => {
  filters.q = props.q || undefined
  await fetchPipeline({ tab: props.tab, page: 1, q: props.q || undefined })
})

function changePage(next: number) {
  page.value = next
  fetchPipeline({ tab: props.tab, page: next, q: props.q || undefined })
}

function patientName(row: PipelineRow): string {
  return `${row.patient.first_name} ${row.patient.last_name}`.trim()
}

function formatDate(iso: string | null): string {
  if (!iso) return '—'
  try {
    return new Date(iso).toLocaleDateString(locale.value, {
      day: '2-digit',
      month: 'short',
    })
  } catch {
    return iso
  }
}

function statusBadgeColor(status: string): string {
  switch (status) {
    case 'draft':
      return 'neutral'
    case 'pending':
      return 'warning'
    case 'active':
      return 'success'
    case 'completed':
      return 'info'
    case 'closed':
      return 'error'
    case 'archived':
      return 'neutral'
    default:
      return 'neutral'
  }
}

function openPlan(row: PipelineRow) {
  router.push(`/treatment-plans/${row.plan_id}`)
}

function callPatient(row: PipelineRow) {
  if (!row.patient.phone) {
    toast.add({ title: t('pipeline.row.noBudget'), color: 'warning' })
    return
  }
  window.location.href = `tel:${row.patient.phone}`
}

function whatsappPatient(row: PipelineRow) {
  if (!row.patient.phone) return
  const phone = row.patient.phone.replace(/\D/g, '')
  window.open(`https://wa.me/${phone}`, '_blank', 'noopener')
}
</script>

<template>
  <div>
    <div
      v-if="!loading && rows.length"
      class="px-5 sm:px-6 py-3 text-lg text-default"
    >
      <span class="font-semibold tnum">{{ total }}</span>
      <span class="text-muted"> {{ t('lists.totalSuffix', { noun: t('lists.noun.plans') }) }}</span>
    </div>

    <div
      v-if="loading"
      class="px-5 sm:px-6 pb-6 space-y-3"
    >
      <USkeleton
        v-for="i in 5"
        :key="i"
        class="h-16 w-full rounded-[var(--radius-lg)]"
      />
    </div>

    <EmptyState
      v-else-if="rows.length === 0"
      icon="i-lucide-clipboard-list"
      :title="t('pipeline.empty')"
    />

    <template v-else>
      <div class="hidden md:flex items-center gap-3 px-5 sm:px-6 py-2.5 border-t border-b border-[var(--color-border-subtle)] text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]">
        <span class="w-9 shrink-0" />
        <span class="flex-1">{{ t('lists.columns.patient') }}</span>
        <span class="w-24">{{ t('lists.columns.status') }}</span>
        <span class="w-28">{{ t('pipeline.row.items') }}</span>
        <span class="w-32">{{ t('pipeline.row.budget') }}</span>
        <span class="w-24" />
      </div>

      <button
        v-for="row in rows"
        :key="row.plan_id"
        type="button"
        class="w-full text-left hidden md:flex items-center gap-3 px-5 sm:px-6 py-3.5 min-h-[64px] border-b border-[var(--color-border-subtle)] hover:bg-[var(--color-surface-muted)] transition-colors"
        @click="openPlan(row)"
      >
        <UAvatar
          :alt="patientName(row)"
          size="sm"
        />
        <div class="flex-1 min-w-0">
          <div class="text-ui text-default truncate">
            {{ patientName(row) }}
          </div>
          <div class="text-caption text-subtle truncate">
            {{ row.plan_number }}
            · {{ t('pipeline.row.daysIn', { n: row.days_in_status }) }}
            <span v-if="row.next_appointment">
              · {{ t('pipeline.row.nextAppt') }}: {{ formatDate(row.next_appointment.start_at) }}
            </span>
            <span v-else>
              · {{ t('pipeline.row.noNextAppt') }}
            </span>
            <span v-if="row.closure_reason">
              · {{ t(`treatmentPlans.closureReason.${row.closure_reason}`) }}
            </span>
          </div>
        </div>
        <UBadge
          :color="statusBadgeColor(row.plan_status)"
          variant="subtle"
          size="xs"
          class="w-24 justify-center"
        >
          {{ t(`treatmentPlans.status.${row.plan_status}`) }}
        </UBadge>
        <span class="w-28 text-caption text-subtle tnum">
          {{ row.items_completed }} / {{ row.items_total }}
        </span>
        <span class="w-32 text-caption text-subtle truncate">
          <template v-if="row.budget">
            {{ row.budget.status }}
            <span
              v-if="row.budget.total !== null"
              class="tnum"
            > · {{ formatCurrency(row.budget.total) }}</span>
          </template>
          <template v-else>
            {{ t('pipeline.row.noBudget') }}
          </template>
        </span>
        <span class="flex items-center gap-1 shrink-0">
          <UButton
            v-if="row.patient.phone"
            icon="i-lucide-phone"
            variant="ghost"
            color="neutral"
            size="xs"
            :title="t('pipeline.actions.call')"
            @click.stop="callPatient(row)"
          />
          <UButton
            v-if="row.patient.phone"
            icon="i-lucide-message-circle"
            variant="ghost"
            color="neutral"
            size="xs"
            :title="t('pipeline.actions.whatsapp')"
            @click.stop="whatsappPatient(row)"
          />
          <UIcon
            name="i-lucide-chevron-right"
            class="text-subtle"
          />
        </span>
      </button>

      <button
        v-for="row in rows"
        :key="`${row.plan_id}-m`"
        type="button"
        class="w-full md:hidden flex items-center gap-3 px-5 py-4 min-h-[72px] border-b border-[var(--color-border-subtle)] text-left"
        @click="openPlan(row)"
      >
        <UAvatar
          :alt="patientName(row)"
          size="md"
        />
        <div class="flex-1 min-w-0">
          <div class="font-medium text-default truncate">
            {{ patientName(row) }}
          </div>
          <div class="text-caption text-subtle truncate">
            {{ row.plan_number }} · {{ t(`treatmentPlans.status.${row.plan_status}`) }}
          </div>
        </div>
        <UIcon
          name="i-lucide-chevron-right"
          class="text-subtle"
        />
      </button>
    </template>

    <div
      v-if="total > pageSize"
      class="flex justify-center px-5 py-4"
    >
      <UPagination
        :model-value="page"
        :total="total"
        :page-count="pageSize"
        @update:model-value="changePage"
      />
    </div>
  </div>
</template>
