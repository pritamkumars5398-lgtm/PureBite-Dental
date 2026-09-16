<script setup lang="ts">
import type { TreatmentPlan, TreatmentPlanStatus } from '~~/app/types'
import { PERMISSIONS } from '~~/app/config/permissions'

const props = defineProps<{
  q: string
}>()

const { t, locale } = useI18n()
const router = useRouter()
const toast = useToast()
const { can } = usePermissions()
const {
  plans,
  total,
  loading,
  fetchPlans,
  deletePlan,
} = useTreatmentPlans()

const selectedStatuses = ref<TreatmentPlanStatus[]>([])
const currentPage = ref(1)
const pageSize = 20

const statusOptions = computed(() => [
  { label: t('treatmentPlans.status.draft'), value: 'draft' as TreatmentPlanStatus },
  { label: t('treatmentPlans.status.pending'), value: 'pending' as TreatmentPlanStatus },
  { label: t('treatmentPlans.status.active'), value: 'active' as TreatmentPlanStatus },
  { label: t('treatmentPlans.status.completed'), value: 'completed' as TreatmentPlanStatus },
  { label: t('treatmentPlans.status.closed'), value: 'closed' as TreatmentPlanStatus },
  { label: t('treatmentPlans.status.archived'), value: 'archived' as TreatmentPlanStatus },
])

async function loadPlans() {
  await fetchPlans({
    page: currentPage.value,
    page_size: pageSize,
    search: props.q || undefined,
    status: selectedStatuses.value.length > 0 ? selectedStatuses.value : undefined,
  })
}

onMounted(() => {
  loadPlans()
})

watch(
  () => props.q,
  () => {
    currentPage.value = 1
    loadPlans()
  }
)

watch([currentPage, selectedStatuses], () => {
  loadPlans()
})

const totalPages = computed(() => Math.ceil(total.value / pageSize))

function createPlan() {
  router.push('/treatment-plans/new')
}

async function handleDelete(plan: TreatmentPlan, event: Event) {
  event.stopPropagation()
  if (!confirm(t('treatmentPlans.confirmations.delete'))) return

  try {
    await deletePlan(plan.id)
    toast.add({
      title: t('common.success'),
      description: t('treatmentPlans.messages.deleted'),
      color: 'success',
    })
  } catch {
    toast.add({
      title: t('common.error'),
      description: t('treatmentPlans.errors.delete'),
      color: 'error',
    })
  }
}

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString(locale.value)
}

function getPatientName(plan: TreatmentPlan): string {
  if (!plan.patient) return '-'
  return `${plan.patient.last_name}, ${plan.patient.first_name}`
}

function getItemCount(plan: TreatmentPlan): number {
  return plan.item_count || 0
}
</script>

<template>
  <div>
    <div class="flex flex-wrap items-center justify-between gap-3 px-5 sm:px-6 py-3">
      <p class="text-lg text-default">
        <span class="font-semibold tnum">{{ total }}</span>
        <span class="text-muted"> {{ t('lists.totalSuffix', { noun: t('lists.noun.plans') }) }}</span>
      </p>
      <USelectMenu
        v-model="selectedStatuses"
        :items="statusOptions"
        value-key="value"
        multiple
        :placeholder="t('treatmentPlans.filters.allStatuses')"
        class="w-64"
      />
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
      v-else-if="plans.length === 0"
      icon="i-lucide-clipboard-list"
      :title="props.q || selectedStatuses.length > 0 ? t('treatmentPlans.noItems') : t('treatmentPlans.empty')"
    >
      <template
        v-if="!props.q && selectedStatuses.length === 0 && can(PERMISSIONS.treatmentPlans.write)"
        #actions
      >
        <UButton
          color="primary"
          variant="solid"
          icon="i-lucide-plus"
          class="rounded-full"
          @click="createPlan"
        >
          {{ t('treatmentPlans.emptyAction') }}
        </UButton>
      </template>
    </EmptyState>

    <template v-else>
      <div class="hidden md:flex items-center gap-3 px-5 sm:px-6 py-2.5 border-t border-b border-[var(--color-border-subtle)] text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]">
        <span class="w-9 shrink-0" />
        <span class="flex-1">{{ t('lists.columns.patient') }}</span>
        <span class="w-28">{{ t('lists.columns.number') }}</span>
        <span class="w-24">{{ t('lists.columns.status') }}</span>
        <span class="hidden sm:inline w-28">{{ t('lists.columns.date') }}</span>
      </div>

      <DataListItem
        v-for="plan in plans"
        :key="plan.id"
        :to="`/treatment-plans/${plan.id}`"
      >
        <template #row>
          <UAvatar
            :alt="getPatientName(plan)"
            size="sm"
          />
          <div class="flex-1 min-w-0">
            <div class="text-ui text-default flex items-center gap-2 flex-wrap">
              <span class="tnum">{{ plan.plan_number }}</span>
              <TreatmentPlanStatusBadge :status="plan.status" />
              <span class="truncate">{{ plan.title || t('treatmentPlans.untitled') }}</span>
            </div>
            <div class="text-caption text-subtle truncate">
              {{ getPatientName(plan) }}
            </div>
          </div>
          <span class="hidden sm:inline text-caption text-subtle tnum">
            {{ t('treatmentPlans.itemCount', { count: getItemCount(plan) }, getItemCount(plan)) }}
          </span>
          <span class="hidden sm:inline text-caption text-subtle tnum w-28">
            {{ formatDate(plan.created_at) }}
          </span>
          <UButton
            v-if="can(PERMISSIONS.treatmentPlans.write) && plan.status === 'draft'"
            variant="ghost"
            color="error"
            icon="i-lucide-trash-2"
            size="xs"
            :aria-label="t('treatmentPlans.delete')"
            :title="t('treatmentPlans.delete')"
            @click.prevent.stop="handleDelete(plan, $event)"
          />
          <UIcon
            name="i-lucide-chevron-right"
            class="text-subtle"
          />
        </template>
        <template #card>
          <div class="flex items-center gap-3">
            <UAvatar
              :alt="getPatientName(plan)"
              size="md"
            />
            <div class="flex-1 min-w-0">
              <div class="font-medium text-default truncate">
                {{ plan.plan_number }} · {{ plan.title || t('treatmentPlans.untitled') }}
              </div>
              <div class="text-caption text-subtle truncate">
                {{ getPatientName(plan) }}
              </div>
            </div>
            <TreatmentPlanStatusBadge :status="plan.status" />
          </div>
        </template>
      </DataListItem>

      <div class="px-5 sm:px-6 py-3">
        <PaginationBar
          v-model:page="currentPage"
          :total-pages="totalPages"
        />
      </div>
    </template>
  </div>
</template>
