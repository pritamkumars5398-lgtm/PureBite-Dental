<script setup lang="ts">
const { resolve } = useModuleSlots()
const { t } = useI18n()

const heroEntries = computed(() => resolve('dashboard.hero', {}))
const timelineEntries = computed(() => resolve('dashboard.timeline', {}))
const attentionEntries = computed(() => resolve('dashboard.attention', {}))
const activityEntries = computed(() => resolve('dashboard.activity', {}))
const widgetEntries = computed(() => resolve('dashboard.widgets', {}))

const hasAnyContent = computed(() =>
  heroEntries.value.length
  + timelineEntries.value.length
  + attentionEntries.value.length
  + activityEntries.value.length
  + widgetEntries.value.length > 0
)

const heroStacked = computed(() => timelineEntries.value.length > 0)
</script>

<template>
  <div class="space-y-6">
    <HomeGreeting />

    <div
      v-if="hasAnyContent"
      class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 items-stretch"
    >
      <section
        v-if="timelineEntries.length > 0"
        class="md:col-span-2 min-w-0"
        :aria-label="t('dashboard.timeline.title')"
      >
        <ModuleSlot
          name="dashboard.timeline"
          :ctx="{}"
        />
      </section>

      <section
        v-if="heroEntries.length > 0"
        class="min-w-0"
        :class="heroStacked
          ? 'md:col-span-2 xl:col-span-1 grid grid-cols-1 md:grid-cols-3 xl:grid-cols-1 gap-4'
          : 'md:col-span-2 xl:col-span-3 grid grid-cols-1 md:grid-cols-3 gap-4'"
        :aria-label="t('dashboard.todayKpi.title')"
      >
        <ModuleSlot
          name="dashboard.hero"
          :ctx="{}"
        />
      </section>

      <ModuleSlot
        v-if="activityEntries.length > 0"
        name="dashboard.activity"
        :ctx="{}"
      />

      <ModuleSlot
        v-if="attentionEntries.length > 0"
        name="dashboard.attention"
        :ctx="{}"
      />

      <ModuleSlot
        v-if="widgetEntries.length > 0"
        name="dashboard.widgets"
        :ctx="{}"
      />
    </div>

    <DashboardCard v-else>
      <EmptyState
        icon="i-lucide-smile"
        compact
        :title="t('dashboard.welcome')"
        :description="t('dashboard.welcomeMessage')"
      />
    </DashboardCard>
  </div>
</template>
