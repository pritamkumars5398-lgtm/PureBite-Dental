<script setup lang="ts">
defineProps<{ ctx?: unknown }>()

const { t } = useI18n()
const { overdue, overdueLoaded, loadOverdue } = useHomeReports()
const pending = computed(() => !overdueLoaded.value)

onMounted(() => {
  if (!overdueLoaded.value) loadOverdue()
})
onActivated(() => {
  loadOverdue()
})

const total = computed(() => overdue.value.length)
const balance = computed(() =>
  overdue.value.reduce((sum, i) => sum + Number(i.balance_due ?? 0), 0)
)

const { format: formatMoney } = useCurrency()

const agingSlices = computed(() => {
  const buckets = [
    { key: '0_30', tone: 'warning' as const, label: t('reports.dashboard.aging.bucket0_30') },
    { key: '31_60', tone: 'danger' as const, label: t('reports.dashboard.aging.bucket31_60') },
    { key: '61_90', tone: 'info' as const, label: t('reports.dashboard.aging.bucket61_90') },
    { key: '90plus', tone: 'neutral' as const, label: t('reports.dashboard.aging.bucket90plus') }
  ]
  const counts = [0, 0, 0, 0]
  for (const inv of overdue.value) {
    const days = Number(inv.days_overdue ?? 0)
    if (days <= 30) counts[0]! += 1
    else if (days <= 60) counts[1]! += 1
    else if (days <= 90) counts[2]! += 1
    else counts[3]! += 1
  }
  return buckets
    .map((b, i) => ({
      key: b.key,
      label: b.label,
      value: counts[i]!,
      tone: b.tone,
      hint: counts[i] ? `${Math.round((counts[i]! / Math.max(total.value, 1)) * 100)}%` : undefined
    }))
    .filter(s => s.value > 0)
})
</script>

<template>
  <DashboardCard
    :title="t('dashboard.overdue.title')"
    :caption="t('dashboard.caption.open')"
    to="/invoices?filter=overdue"
    class="h-full"
  >
    <div
      v-if="pending"
      class="space-y-4"
    >
      <USkeleton class="h-3 w-24" />
      <USkeleton class="h-8 w-28" />
      <USkeleton class="h-28 w-full" />
    </div>

    <div
      v-else
      class="flex flex-col gap-4"
    >
      <div>
        <p class="text-micro uppercase tracking-wide text-subtle">
          {{ t('invoices.reports.pending') }}
        </p>
        <p class="text-display text-default tnum mt-1">
          {{ formatMoney(balance) }}
        </p>
        <p class="text-caption text-muted tnum mt-1">
          {{ total }} {{ t('invoices.reports.invoices') }}
        </p>
      </div>

      <DonutChart
        v-if="total > 0 && agingSlices.length > 0"
        :slices="agingSlices"
        :size="120"
        :thickness="14"
        :center-label="t('reports.dashboard.kpi.total')"
      />
      <p
        v-else
        class="text-caption text-subtle"
      >
        {{ t('dashboard.overdue.empty') }}
      </p>
    </div>
  </DashboardCard>
</template>
