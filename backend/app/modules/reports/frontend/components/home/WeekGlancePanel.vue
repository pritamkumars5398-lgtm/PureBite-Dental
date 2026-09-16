<script setup lang="ts">
import type { SchedulingSummary } from '../../composables/useReports'
import type { BillingSummary } from '~~/app/types'

defineProps<{ ctx?: unknown }>()

const { t } = useI18n()
const { fetchSchedulingSummary, fetchBillingSummary } = useReports()

const pending = ref(true)
const current = ref<{ sched: SchedulingSummary | null, bill: BillingSummary | null }>({
  sched: null,
  bill: null
})
const previous = ref<{ sched: SchedulingSummary | null, bill: BillingSummary | null }>({
  sched: null,
  bill: null
})

function isoDate(d: Date): string {
  return d.toISOString().split('T')[0] as string
}

async function load() {
  const now = new Date()
  const end = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  const start = new Date(end)
  start.setDate(end.getDate() - 6)
  const prevEnd = new Date(start)
  prevEnd.setDate(start.getDate() - 1)
  const prevStart = new Date(prevEnd)
  prevStart.setDate(prevEnd.getDate() - 6)

  const [cs, cb, ps, pb] = await Promise.all([
    fetchSchedulingSummary(isoDate(start), isoDate(end)),
    fetchBillingSummary(isoDate(start), isoDate(end)),
    fetchSchedulingSummary(isoDate(prevStart), isoDate(prevEnd)),
    fetchBillingSummary(isoDate(prevStart), isoDate(prevEnd))
  ])

  current.value = { sched: cs, bill: cb }
  previous.value = { sched: ps, bill: pb }
  pending.value = false
}

onMounted(load)
onActivated(load)

const { format: formatMoney } = useCurrency()

function delta(cur: number, prev: number): { pct: number | null, dir: 'up' | 'down' | 'flat' } {
  if (!prev) return { pct: null, dir: 'flat' }
  const pct = ((cur - prev) / prev) * 100
  if (Math.abs(pct) < 0.5) return { pct: 0, dir: 'flat' }
  return { pct, dir: pct > 0 ? 'up' : 'down' }
}

const invoiced = computed(() => current.value.bill?.total_invoiced ?? null)
const invoicedDelta = computed(() => {
  const cb = current.value.bill
  const pb = previous.value.bill
  if (!cb || !pb) return null
  return delta(cb.total_invoiced, pb.total_invoiced)
})

const paid = computed(() => current.value.bill?.total_paid ?? null)
const paidDelta = computed(() => {
  const cb = current.value.bill
  const pb = previous.value.bill
  if (!cb || !pb) return null
  return delta(cb.total_paid, pb.total_paid)
})

const bars = computed(() => {
  const cs = current.value.sched
  const ps = previous.value.sched
  const curA = cs?.total_appointments ?? 0
  const prevA = ps?.total_appointments ?? 0
  const curC = cs?.completed ?? 0
  const prevC = ps?.completed ?? 0
  const max = Math.max(curA, prevA, curC, prevC, 1)
  return [
    {
      key: 'appointments',
      label: t('dashboard.weekGlance.appointments'),
      current: curA,
      previous: prevA,
      currentPct: (curA / max) * 100,
      previousPct: (prevA / max) * 100,
      delta: delta(curA, prevA)
    },
    {
      key: 'completed',
      label: t('dashboard.weekGlance.completed'),
      current: curC,
      previous: prevC,
      currentPct: (curC / max) * 100,
      previousPct: (prevC / max) * 100,
      delta: delta(curC, prevC)
    }
  ]
})

const completionRate = computed(() => current.value.sched?.completion_rate ?? null)

const allMissing = computed(() =>
  !pending.value && !current.value.sched && !current.value.bill
)

function deltaLabel(d: { pct: number | null, dir: 'up' | 'down' | 'flat' } | null): string {
  if (!d || d.pct === null) return ''
  if (d.pct === 0) return '0%'
  return `${Math.abs(d.pct).toFixed(1)}%`
}

function deltaClass(dir: 'up' | 'down' | 'flat'): string {
  if (dir === 'up') return 'text-success-accent'
  if (dir === 'down') return 'text-danger-accent'
  return 'text-subtle'
}
</script>

<template>
  <DashboardCard
    :title="t('dashboard.weekGlance.title')"
    :caption="t('dashboard.caption.last7Days')"
    class="h-full md:col-span-2"
  >
    <div
      v-if="pending"
      class="space-y-3"
    >
      <div class="grid grid-cols-2 gap-4">
        <USkeleton class="h-12 w-full" />
        <USkeleton class="h-12 w-full" />
      </div>
      <USkeleton class="h-28 w-full" />
    </div>

    <EmptyState
      v-else-if="allMissing"
      compact
      icon="i-lucide-bar-chart-3"
      :title="t('dashboard.weekGlance.empty')"
    />

    <div
      v-else
      class="space-y-5"
    >
      <div class="grid grid-cols-2 gap-4">
        <div v-if="invoiced !== null">
          <p class="text-micro uppercase tracking-wide text-subtle flex items-center gap-1.5">
            <span class="w-1.5 h-1.5 rounded-full bg-[var(--color-success-accent)]" />
            {{ t('dashboard.weekGlance.invoiced') }}
          </p>
          <div class="flex items-baseline gap-2 mt-1 flex-wrap">
            <p class="text-h1 text-default tnum">
              {{ formatMoney(invoiced) }}
            </p>
            <p
              v-if="invoicedDelta && invoicedDelta.pct !== null"
              class="text-caption tnum inline-flex items-center gap-0.5"
              :class="deltaClass(invoicedDelta.dir)"
            >
              <UIcon
                v-if="invoicedDelta.dir !== 'flat'"
                name="i-lucide-triangle"
                class="w-2.5 h-2.5"
                :class="invoicedDelta.dir === 'down' ? 'rotate-180' : ''"
              />
              {{ deltaLabel(invoicedDelta) }}
            </p>
          </div>
        </div>
        <div v-if="paid !== null">
          <p class="text-micro uppercase tracking-wide text-subtle flex items-center gap-1.5">
            <span class="w-1.5 h-1.5 rounded-full bg-[var(--color-warning-accent)]" />
            {{ t('invoices.reports.totalPaid') }}
          </p>
          <div class="flex items-baseline gap-2 mt-1 flex-wrap">
            <p class="text-h1 text-default tnum">
              {{ formatMoney(paid) }}
            </p>
            <p
              v-if="paidDelta && paidDelta.pct !== null"
              class="text-caption tnum inline-flex items-center gap-0.5"
              :class="deltaClass(paidDelta.dir)"
            >
              <UIcon
                v-if="paidDelta.dir !== 'flat'"
                name="i-lucide-triangle"
                class="w-2.5 h-2.5"
                :class="paidDelta.dir === 'down' ? 'rotate-180' : ''"
              />
              {{ deltaLabel(paidDelta) }}
            </p>
          </div>
        </div>
      </div>

      <div class="flex items-end gap-6 h-32 px-1">
        <div
          v-for="bar in bars"
          :key="bar.key"
          class="flex-1 min-w-0 flex flex-col items-center"
        >
          <div class="flex items-end justify-center gap-1.5 h-24 w-full">
            <div
              class="w-[18px] rounded-t-lg bg-[var(--color-success-accent)]"
              :style="{ height: `${Math.max(bar.currentPct, 6)}%` }"
              :title="`${bar.label}: ${bar.current}`"
            />
            <div
              class="w-[18px] rounded-t-lg bg-[var(--color-warning-accent)]"
              :style="{ height: `${Math.max(bar.previousPct, 6)}%` }"
              :title="`${t('dashboard.weekGlance.previous')}: ${bar.previous}`"
            />
          </div>
          <p class="text-caption text-muted text-center mt-2 truncate w-full">
            {{ bar.label }}
          </p>
          <p class="text-ui text-default tnum text-center inline-flex items-center gap-1">
            {{ bar.current }}
            <span
              v-if="bar.delta.pct !== null"
              class="text-micro"
              :class="deltaClass(bar.delta.dir)"
            >
              {{ deltaLabel(bar.delta) }}
            </span>
          </p>
        </div>
      </div>

      <div
        v-if="completionRate != null && current.sched"
        class="text-caption text-subtle"
      >
        {{ t('reports.dashboard.kpi.funnelHint', { completed: completionRate.toFixed(1) }) }}
      </div>

      <div class="flex items-center gap-4 text-caption text-subtle">
        <span class="flex items-center gap-1.5">
          <span class="w-2 h-2 rounded-full bg-[var(--color-success-accent)]" />
          {{ t('dashboard.caption.last7Days') }}
        </span>
        <span class="flex items-center gap-1.5">
          <span class="w-2 h-2 rounded-full bg-[var(--color-warning-accent)]" />
          {{ t('dashboard.weekGlance.previous') }}
        </span>
      </div>
    </div>
  </DashboardCard>
</template>
