<script setup lang="ts">
import type { PipelineTab } from '~/composables/usePipeline'
import { PERMISSIONS } from '~~/app/config/permissions'

type ActiveTab = PipelineTab | 'listado'

const PIPELINE_TABS: PipelineTab[] = [
  'por_presupuestar',
  'esperando_paciente',
  'sin_cita',
  'sin_proxima_cita',
  'cerrados',
]

const ALL_TABS: ActiveTab[] = [...PIPELINE_TABS, 'listado']

function isValidTab(value: string | null | undefined): value is ActiveTab {
  return !!value && (ALL_TABS as string[]).includes(value)
}

const { t } = useI18n()
const router = useRouter()
const route = useRoute()
const { can } = usePermissions()

const initialTab: ActiveTab = isValidTab(route.query.tab as string)
  ? (route.query.tab as ActiveTab)
  : 'por_presupuestar'

const activeTab = ref<ActiveTab>(initialTab)
const searchQuery = ref('')
const debouncedSearch = ref('')
let searchTimer: ReturnType<typeof setTimeout> | null = null

watch(searchQuery, (val) => {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    debouncedSearch.value = val
  }, 300)
})

watch(activeTab, async (next) => {
  await router.replace({ query: { ...route.query, tab: next } })
})

const tabItems = computed(() => [
  ...PIPELINE_TABS.map((id) => ({
    label: t(`pipeline.tabs.${id}`),
    value: id,
  })),
  {
    label: t('pipeline.tabs.listado'),
    value: 'listado' as const,
  },
])

function createPlan() {
  router.push('/treatment-plans/new')
}
</script>

<template>
  <div
    class="overflow-hidden bg-[var(--color-surface)]"
    style="border-radius: var(--radius-xl)"
  >
    <header class="px-5 sm:px-6 pt-5 sm:pt-6">
      <h1 class="sr-only">
        {{ t('treatmentPlans.title') }}
      </h1>
      <p class="text-body text-muted text-pretty">
        {{ t('pipeline.description') }}
      </p>
      <div class="mt-4">
        <UTabs
          v-model="activeTab"
          :items="tabItems"
          class="w-full"
        />
      </div>
    </header>

    <div class="px-5 sm:px-6 py-4 flex flex-col gap-3 sm:flex-row sm:items-center">
      <UInput
        v-model="searchQuery"
        :placeholder="t('pipeline.search')"
        icon="i-lucide-search"
        class="max-w-sm rounded-full w-full"
      />
      <div class="sm:ml-auto shrink-0">
        <UButton
          v-if="can(PERMISSIONS.treatmentPlans.write)"
          color="primary"
          variant="solid"
          icon="i-lucide-plus"
          class="rounded-full"
          @click="createPlan"
        >
          {{ t('treatmentPlans.new') }}
        </UButton>
      </div>
    </div>

    <div class="border-t border-[var(--color-border-subtle)]">
      <PlansListPanel
        v-if="activeTab === 'listado'"
        :q="debouncedSearch"
      />
      <PipelineTabPanel
        v-else
        :tab="activeTab"
        :q="debouncedSearch"
      />
    </div>
  </div>
</template>
