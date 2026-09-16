<script setup lang="ts">
defineProps<{ ctx?: unknown }>()

const { t } = useI18n()
const { todayAppointments, todayLoaded, fetchToday } = useHomeAgenda()

const pending = computed(() => !todayLoaded.value)
let intervalId: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  if (!todayLoaded.value) fetchToday()
  intervalId = setInterval(fetchToday, 60_000)
})
onBeforeUnmount(() => {
  if (intervalId) clearInterval(intervalId)
})

const counts = computed(() => {
  let inTreatment = 0
  let waiting = 0
  for (const a of todayAppointments.value) {
    if (a.status === 'in_treatment') inTreatment += 1
    else if (a.status === 'checked_in') waiting += 1
  }
  return { inTreatment, waiting, total: inTreatment + waiting }
})

const bars = computed(() => {
  const total = Math.max(counts.value.total, 1)
  return [
    {
      key: 'inTreatment',
      value: counts.value.inTreatment,
      pct: (counts.value.inTreatment / total) * 100,
      label: t('dashboard.inClinic.inTreatment', { n: counts.value.inTreatment }),
      barClass: 'bg-[var(--color-primary)]'
    },
    {
      key: 'waiting',
      value: counts.value.waiting,
      pct: (counts.value.waiting / total) * 100,
      label: t('dashboard.inClinic.waiting', { n: counts.value.waiting }),
      barClass: 'bg-[var(--color-info-accent)]'
    }
  ]
})
</script>

<template>
  <DashboardCard
    :title="t('dashboard.inClinic.title')"
    :caption="t('dashboard.caption.now')"
    class="h-full"
  >
    <div v-if="pending">
      <USkeleton class="h-9 w-16 mb-2" />
      <USkeleton class="h-4 w-28 mb-4" />
      <USkeleton class="h-16 w-full" />
    </div>

    <div
      v-else
      class="space-y-4"
    >
      <div>
        <p class="text-display text-default tnum tracking-tight">
          {{ counts.total }}
        </p>
        <p class="text-caption text-muted mt-1">
          {{ counts.total > 0 ? t('dashboard.caption.now') : t('dashboard.inClinic.empty') }}
        </p>
      </div>

      <div
        v-if="counts.total > 0"
        class="grid grid-cols-2 gap-3"
      >
        <div
          v-for="bar in bars"
          :key="bar.key"
          class="rounded-2xl bg-[var(--color-canvas)] px-3 py-3 shadow-[0_6px_16px_rgba(15,23,42,0.05)]"
        >
          <p class="text-display text-default tnum tracking-tight">
            {{ bar.value }}
          </p>
          <div class="mt-2 h-1.5 rounded-full bg-[var(--color-border-subtle)] overflow-hidden">
            <div
              class="h-full rounded-full"
              :class="bar.barClass"
              :style="{ width: `${Math.max(bar.pct, 6)}%` }"
            />
          </div>
          <p class="text-caption text-muted mt-2 truncate">
            {{ bar.label }}
          </p>
        </div>
      </div>
    </div>
  </DashboardCard>
</template>
