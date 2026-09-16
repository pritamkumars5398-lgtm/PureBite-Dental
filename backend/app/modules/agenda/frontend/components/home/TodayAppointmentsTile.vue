<script setup lang="ts">
defineProps<{ ctx?: unknown }>()

const { t } = useI18n()
const { todayAppointments, todayLoaded, fetchToday } = useHomeAgenda()

const pending = computed(() => !todayLoaded.value)

onMounted(() => {
  if (!todayLoaded.value) fetchToday()
})
onActivated(() => {
  fetchToday()
})

const counts = computed(() => {
  const c = { total: 0, completed: 0, inProgress: 0, upcoming: 0, cancelled: 0, noShow: 0 }
  const now = Date.now()
  for (const a of todayAppointments.value) {
    c.total += 1
    if (a.status === 'completed') c.completed += 1
    else if (a.status === 'cancelled') c.cancelled += 1
    else if (a.status === 'no_show') c.noShow += 1
    else if (a.status === 'checked_in' || a.status === 'in_treatment') c.inProgress += 1
    else if (new Date(a.start_time).getTime() >= now) c.upcoming += 1
  }
  return c
})

const stats = computed(() => {
  const c = counts.value
  return [
    { key: 'completed', label: t('dashboard.todayKpi.completed'), value: c.completed },
    { key: 'inProgress', label: t('dashboard.todayKpi.inProgress'), value: c.inProgress },
    { key: 'upcoming', label: t('dashboard.todayKpi.upcoming'), value: c.upcoming },
    { key: 'cancelled', label: t('dashboard.todayKpi.cancelled'), value: c.cancelled },
    { key: 'noShow', label: t('dashboard.todayKpi.noShow'), value: c.noShow }
  ]
})
</script>

<template>
  <DashboardCard
    :title="t('dashboard.todayKpi.title')"
    :caption="t('dashboard.caption.today')"
    class="h-full"
  >
    <div
      v-if="pending"
      class="space-y-3"
    >
      <USkeleton class="h-9 w-16" />
      <USkeleton class="h-4 w-24" />
      <USkeleton class="h-28 w-full" />
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
          {{ counts.total > 0 ? t('dashboard.caption.today') : t('dashboard.todayKpi.empty') }}
        </p>
      </div>

      <div
        v-if="counts.total > 0"
        class="grid grid-cols-2 gap-2"
      >
        <div
          v-for="s in stats"
          :key="s.key"
          class="rounded-2xl bg-[var(--color-canvas)] px-3 py-2.5 shadow-[0_6px_16px_rgba(15,23,42,0.05)]"
        >
          <p class="text-h2 text-default tnum tracking-tight">
            {{ s.value }}
          </p>
          <p class="text-caption text-muted truncate mt-0.5">
            {{ s.label }}
          </p>
        </div>
      </div>
    </div>
  </DashboardCard>
</template>
