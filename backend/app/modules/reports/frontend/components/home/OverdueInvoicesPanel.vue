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

const topFive = computed(() => overdue.value.slice(0, 5))

const { format: formatMoney } = useCurrency()
</script>

<template>
  <DashboardCard
    :title="t('dashboard.overdue.title')"
    :caption="t('dashboard.caption.open')"
    class="h-full"
  >
    <template
      v-if="!pending && overdue.length > 0"
      #actions
    >
      <UButton
        to="/invoices?filter=overdue"
        variant="link"
        color="neutral"
        size="xs"
        class="text-caption text-subtle"
      >
        {{ t('dashboard.overdue.viewAll') }}
      </UButton>
    </template>

    <div
      v-if="pending"
      class="space-y-2"
    >
      <USkeleton
        v-for="i in 4"
        :key="i"
        class="h-11 w-full rounded-xl"
      />
    </div>

    <EmptyState
      v-else-if="overdue.length === 0"
      compact
      icon="i-lucide-check-check"
      :title="t('dashboard.overdue.empty')"
    />

    <ul
      v-else
      class="flex flex-col gap-1"
    >
      <li
        v-for="inv in topFive"
        :key="inv.id"
      >
        <NuxtLink
          :to="`/invoices/${inv.id}`"
          class="flex items-center gap-3 min-h-11 px-2 py-2 -mx-2 rounded-xl hover:bg-[var(--color-surface-muted)] focus:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-primary)]"
        >
          <span
            class="w-1 self-stretch min-h-8 rounded-full bg-[var(--color-danger-accent)] shrink-0"
            aria-hidden="true"
          />
          <div class="min-w-0 flex-1">
            <p class="text-ui text-default truncate">
              {{ inv.patient_name }}
            </p>
            <p class="text-caption text-subtle tnum truncate">
              {{ inv.invoice_number }}
              <span class="text-danger-accent">
                · {{ t('dashboard.overdue.daysOverdue', { n: inv.days_overdue }) }}
              </span>
            </p>
          </div>
          <span class="text-ui tnum text-default font-semibold shrink-0">
            {{ formatMoney(inv.balance_due) }}
          </span>
        </NuxtLink>
      </li>
    </ul>
  </DashboardCard>
</template>
