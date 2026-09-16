<script setup lang="ts">
import type { Patient, PatientCreate, PaginatedResponse, ApiResponse } from '~~/app/types'
import { PATIENT_STATUS_ROLE, type PatientStatus } from '~~/app/config/severity'
import { PERMISSIONS } from '~~/app/config/permissions'

/**
 * /patients — list page.
 *
 * Filter + enrichment design:
 *   - Native filters (status, city, do_not_contact, search, sort) hit
 *     ``GET /api/v1/patients`` directly.
 *   - Cross-module enrichment (debt, on-account credit) is rendered via
 *     the ``patients.list.row.financial`` slot. Payments registers the
 *     slot filler. The page fetches the payment summary in bulk after
 *     the patient page loads and passes it into each slot's ctx.
 *   - Cross-module filter "Con deuda" uses ``patients.list.filter``
 *     slot. The page translates the filter into a payments-side call
 *     (``/api/v1/payments/filters/patients-with-debt``) returning the
 *     patient_ids set, which is then intersected with /patients via
 *     ``?patient_ids=`` query params.
 *
 * Patients module never imports payments code — both calls go through
 * ``useApi()`` against the public HTTP surface.
 */

interface PatientDebtSummary {
  total_paid: string
  debt: string
  on_account_balance: string
}

const { t, locale } = useI18n()
const api = useApi()
const toast = useToast()
const router = useRouter()
const route = useRoute()
const { can } = usePermissions()
const canWrite = computed(() => can(PERMISSIONS.patients.write))

// --- Filter shape (URL-synced) ------------------------------------------
interface PatientListFilters {
  q: string
  status: string[]
  city: string
  do_not_contact: boolean | null
  with_debt: boolean
}

const defaults: PatientListFilters = {
  q: '',
  status: ['active'],
  city: '',
  do_not_contact: null,
  with_debt: false,
}

// Map of patient_id → payment summary; filled after each page load and
// passed into the slot via ctx.
const debtSummaries = ref<Record<string, PatientDebtSummary | null>>({})

async function fetcher(q: {
  filters: PatientListFilters
  page: number
  pageSize: number
  sort: string
}) {
  // Step 1: when "with_debt" is on, resolve the candidate ids through
  // the payments-side filter endpoint. Public HTTP — no code-level
  // dependency on the payments module.
  let patientIdsIntersect: string[] | undefined
  if (q.filters.with_debt) {
    try {
      const res = await api.get<ApiResponse<{ patient_ids: string[]; truncated: boolean }>>(
        '/api/v1/payments/filters/patients-with-debt?min_debt=0.01',
      )
      patientIdsIntersect = res.data.patient_ids ?? []
      if (res.data.truncated) {
        toast.add({ title: t('lists.truncatedWarning'), color: 'warning' })
      }
      if (!patientIdsIntersect.length) {
        debtSummaries.value = {}
        return { data: [], total: 0 }
      }
    } catch {
      // Permission denied or payments uninstalled → ignore the filter.
      patientIdsIntersect = undefined
    }
  }

  // Step 2: query /patients with the optional intersect + native filters.
  const params = new URLSearchParams()
  params.set('page', String(q.page))
  params.set('page_size', String(q.pageSize))
  if (q.filters.q) params.set('search', q.filters.q)
  if (q.filters.city) params.set('city', q.filters.city)
  if (q.filters.do_not_contact !== null) {
    params.set('do_not_contact', q.filters.do_not_contact ? 'true' : 'false')
  }
  if (q.filters.status.includes('archived')) params.set('include_archived', 'true')
  if (patientIdsIntersect) {
    for (const id of patientIdsIntersect) params.append('patient_ids', id)
  }
  if (q.sort) params.set('sort', q.sort)

  const response = await api.get<PaginatedResponse<Patient>>(`/api/v1/patients?${params.toString()}`)

  // Step 3: bulk-fetch payment summaries for the page rows (when the
  // user has permission). The slot renders nothing for ids missing
  // from the map.
  if (can(PERMISSIONS.payments.recordRead) && response.data.length) {
    try {
      const summaryRes = await api.post<ApiResponse<{ summaries: Record<string, PatientDebtSummary> }>>(
        '/api/v1/payments/summary/by-patients',
        { patient_ids: response.data.map((x) => x.id) },
      )
      debtSummaries.value = summaryRes.data.summaries
    } catch {
      debtSummaries.value = {}
    }
  } else {
    debtSummaries.value = {}
  }

  return { data: response.data, total: response.total }
}

const {
  filters,
  page,
  pageSize,
  sort,
  rows: patients,
  total,
  totalPages,
  isLoading,
  error,
  setFilter,
  resetFilters,
  refresh,
} = useListQuery<PatientListFilters, Patient>({
  defaults,
  pageSize: 20,
  sortable: ['last_visit', 'last_name', 'first_name', 'created_at', 'updated_at'],
  defaultSort: 'last_visit:desc',
  searchKey: 'q',
  fetcher,
})

const statusTab = computed({
  get: () => (filters.value.status.includes('archived') ? 'archived' : 'active'),
  set: (value: string) => setFilter('status', [value]),
})

const statusTabs = computed(() => [
  { label: t('patients.status.active'), value: 'active' },
  { label: t('patients.status.archived'), value: 'archived' },
])

const sortOptions = computed(() => [
  { field: 'last_visit', label: t('patients.sort.lastVisit'), defaultDir: 'desc' as const },
  { field: 'last_name', label: t('patients.sort.lastName'), defaultDir: 'asc' as const },
  { field: 'first_name', label: t('patients.sort.firstName'), defaultDir: 'asc' as const },
  { field: 'created_at', label: t('patients.sort.createdAt'), defaultDir: 'desc' as const },
  { field: 'updated_at', label: t('patients.sort.updatedAt'), defaultDir: 'desc' as const },
])

const activeFilterCount = computed(() => {
  let n = 0
  if (filters.value.city) n++
  if (filters.value.do_not_contact !== null) n++
  if (filters.value.with_debt) n++
  if (filters.value.q) n++
  return n
})

const selectedIds = ref<Set<string>>(new Set())

watch(patients, () => {
  selectedIds.value = new Set()
})

const allPageSelected = computed(() =>
  patients.value.length > 0 && patients.value.every(p => selectedIds.value.has(p.id)),
)

const somePageSelected = computed(() =>
  patients.value.some(p => selectedIds.value.has(p.id)) && !allPageSelected.value,
)

function toggleSelected(id: string, checked: boolean) {
  const next = new Set(selectedIds.value)
  if (checked) next.add(id)
  else next.delete(id)
  selectedIds.value = next
}

function toggleSelectAll(checked: boolean) {
  selectedIds.value = checked ? new Set(patients.value.map(p => p.id)) : new Set()
}

const AVATAR_TONES = [
  'bg-violet-100 text-violet-700',
  'bg-sky-100 text-sky-700',
  'bg-blue-100 text-blue-700',
  'bg-pink-100 text-pink-700',
  'bg-emerald-100 text-emerald-800',
  'bg-amber-100 text-amber-800',
  'bg-rose-100 text-rose-700',
] as const

function patientInitials(p: Patient): string {
  const a = (p.first_name || '').trim().charAt(0)
  const b = (p.last_name || '').trim().charAt(0)
  return `${a}${b}`.toUpperCase() || '?'
}

function avatarTone(id: string): string {
  let h = 0
  for (let i = 0; i < id.length; i++) h = (h + id.charCodeAt(i) * (i + 1)) % AVATAR_TONES.length
  return AVATAR_TONES[h] ?? AVATAR_TONES[0]
}

function formatListDate(value?: string | null): string {
  if (!value) return '—'
  const d = new Date(value)
  if (Number.isNaN(d.getTime())) return '—'
  return new Intl.DateTimeFormat(locale.value, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(d)
}

function sortField(): string {
  return sort.value.split(':')[0] ?? ''
}

function sortDir(): string {
  return sort.value.split(':')[1] ?? 'asc'
}

function toggleSort(field: string, defaultDir: 'asc' | 'desc') {
  if (sortField() === field) {
    sort.value = `${field}:${sortDir() === 'asc' ? 'desc' : 'asc'}`
    return
  }
  sort.value = `${field}:${defaultDir}`
}

function debtFilterCtx() {
  return {
    value: filters.value.with_debt,
    onChange: (v: boolean | null) => setFilter('with_debt', Boolean(v)),
  }
}

// --- Create modal (preserved) -------------------------------------------
const isCreateModalOpen = ref(false)
const isSubmitting = ref(false)
const newPatient = reactive<PatientCreate>({
  first_name: '',
  last_name: '',
  phone: '',
  email: '',
  date_of_birth: '',
  notes: '',
})

onMounted(() => {
  if (route.query.new === '1') {
    isCreateModalOpen.value = true
    router.replace({ query: { ...route.query, new: undefined } })
  }
})

function resetForm() {
  Object.assign(newPatient, {
    first_name: '',
    last_name: '',
    phone: '',
    email: '',
    date_of_birth: '',
    notes: '',
  })
}

async function createPatient() {
  isSubmitting.value = true
  try {
    const response = await api.post<ApiResponse<Patient>>('/api/v1/patients', {
      first_name: newPatient.first_name,
      last_name: newPatient.last_name,
      phone: newPatient.phone || null,
      email: newPatient.email || null,
      date_of_birth: newPatient.date_of_birth || null,
      notes: newPatient.notes || null,
    })
    toast.add({
      title: t('common.success'),
      description: t('patients.created'),
      color: 'success',
    })
    isCreateModalOpen.value = false
    resetForm()
    await refresh()
    await router.push(`/patients/${response.data.id}`)
  } catch (e: unknown) {
    const fetchError = e as { statusCode?: number; data?: { message?: string } }
    toast.add({
      title: t('common.error'),
      description: fetchError.data?.message || t('common.serverError'),
      color: 'error',
    })
  } finally {
    isSubmitting.value = false
  }
}

</script>

<template>
  <DataListLayout
    :title="t('patients.title')"
    :show-title="false"
    :noun="t('lists.noun.patients')"
    :loading="isLoading"
    :empty="!patients.length"
    :error="error"
    :page="page"
    :page-size="pageSize"
    :total="total"
    :total-pages="totalPages"
    @update:page="(v) => (page = v)"
  >
    <template #tabs>
      <div
        class="flex items-center gap-6 border-b border-[var(--color-border-subtle)]"
        role="tablist"
      >
        <button
          v-for="tab in statusTabs"
          :key="tab.value"
          type="button"
          role="tab"
          class="relative pb-3 text-sm transition-colors"
          :class="statusTab === tab.value
            ? 'font-medium text-primary'
            : 'text-muted hover:text-default'"
          :aria-selected="statusTab === tab.value"
          @click="statusTab = tab.value"
        >
          {{ tab.label }}
          <span
            v-if="statusTab === tab.value"
            class="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary"
          />
        </button>
      </div>
    </template>

    <template #actions>
      <DensityToggle />
      <UButton
        v-if="canWrite"
        color="primary"
        variant="solid"
        icon="i-lucide-plus"
        class="rounded-full"
        @click="isCreateModalOpen = true"
      >
        {{ t('patients.addPatient') }}
      </UButton>
    </template>

    <template #toolbar>
      <FilterBar
        always-collapsed
        :active-count="activeFilterCount"
        @reset="resetFilters"
      >
        <template #search>
          <SearchBar
            :model-value="filters.q"
            :placeholder="t('patients.searchPlaceholder')"
            max-width="max-w-sm"
            @update:model-value="(v) => setFilter('q', v)"
          />
        </template>
        <FilterToggle
          :model-value="filters.do_not_contact"
          :label="t('patients.filters.doNotContactOnly')"
          :label-false="t('patients.filters.doNotContactOnlyContactable')"
          icon="i-lucide-bell-off"
          tristate
          @update:model-value="(v) => setFilter('do_not_contact', v)"
        />
        <ModuleSlot
          name="patients.list.filter"
          :ctx="debtFilterCtx()"
        />
        <template #right>
          <SortMenu
            :model-value="sort"
            :options="sortOptions"
            @update:model-value="(v) => (sort = v)"
          />
        </template>
      </FilterBar>
    </template>

    <template #empty>
      <EmptyState
        icon="i-lucide-users"
        :title="activeFilterCount || filters.q ? t('patients.noResults') : t('patients.empty')"
        :description="activeFilterCount || filters.q ? undefined : t('dashboard.welcomeMessage')"
      >
        <template
          v-if="canWrite && !activeFilterCount && !filters.q"
          #actions
        >
          <UButton
            color="primary"
            variant="solid"
            icon="i-lucide-plus"
            class="rounded-full"
            @click="isCreateModalOpen = true"
          >
            {{ t('patients.emptyAction') }}
          </UButton>
        </template>
      </EmptyState>
    </template>

    <template #columns>
      <span
        class="w-10 shrink-0"
        @click.stop
      >
        <UCheckbox
          :model-value="allPageSelected"
          :indeterminate="somePageSelected"
          :aria-label="t('patients.columns.selectAll')"
          @update:model-value="(v: boolean | 'indeterminate') => toggleSelectAll(v === true)"
        />
      </span>
      <button
        type="button"
        class="flex-1 min-w-0 inline-flex items-center gap-1 uppercase tracking-[0.08em] hover:text-default"
        @click="toggleSort('last_name', 'asc')"
      >
        {{ t('patients.columns.patientName') }}
        <UIcon
          name="i-lucide-arrow-up-down"
          class="w-3 h-3"
          :class="sortField() === 'last_name' ? 'text-primary' : 'opacity-40'"
        />
      </button>
      <span class="hidden md:inline w-40 shrink-0">{{ t('patients.phone') }}</span>
      <span class="hidden xl:inline w-52 shrink-0">{{ t('patients.email') }}</span>
      <button
        type="button"
        class="hidden lg:inline-flex w-32 shrink-0 items-center gap-1 uppercase tracking-[0.08em] hover:text-default"
        @click="toggleSort('created_at', 'desc')"
      >
        {{ t('patients.columns.registered') }}
        <UIcon
          name="i-lucide-arrow-up-down"
          class="w-3 h-3"
          :class="sortField() === 'created_at' ? 'text-primary' : 'opacity-40'"
        />
      </button>
      <span class="w-28 shrink-0 text-right">{{ t('patients.columns.debt') }}</span>
    </template>

    <template #rows>
      <DataListItem
        v-for="patient in patients"
        :key="patient.id"
        :to="`/patients/${patient.id}`"
      >
        <template #row>
          <div
            class="w-10 shrink-0"
            @click.prevent.stop
          >
            <UCheckbox
              :model-value="selectedIds.has(patient.id)"
              :aria-label="t('patients.columns.select')"
              @update:model-value="(v: boolean | 'indeterminate') => toggleSelected(patient.id, v === true)"
            />
          </div>
          <div class="flex-1 min-w-0 flex items-center gap-3">
            <div
              class="w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-semibold shrink-0"
              :class="avatarTone(patient.id)"
            >
              {{ patientInitials(patient) }}
            </div>
            <div class="min-w-0">
              <div class="text-ui text-default truncate flex items-center gap-1.5">
                {{ patient.first_name }} {{ patient.last_name }}
                <UIcon
                  v-if="patient.do_not_contact"
                  name="i-lucide-bell-off"
                  class="w-3.5 h-3.5 text-warning shrink-0"
                  :title="t('patients.doNotContact.label')"
                />
              </div>
              <div
                v-if="patient.patient_number"
                class="text-caption text-subtle font-mono truncate"
              >
                {{ patient.patient_number }}
              </div>
            </div>
          </div>
          <div class="hidden md:flex w-40 shrink-0 items-center gap-1.5 text-caption text-muted">
            <template v-if="patient.phone">
              <UIcon
                name="i-lucide-phone"
                class="w-3.5 h-3.5 text-subtle shrink-0"
              />
              <span class="truncate">{{ patient.phone }}</span>
            </template>
            <span v-else class="text-subtle">—</span>
          </div>
          <div class="hidden xl:flex w-52 shrink-0 items-center gap-1.5 text-caption text-muted">
            <template v-if="patient.email">
              <UIcon
                name="i-lucide-mail"
                class="w-3.5 h-3.5 text-subtle shrink-0"
              />
              <span class="truncate">{{ patient.email }}</span>
            </template>
            <span v-else class="text-subtle">—</span>
          </div>
          <div class="hidden lg:block w-32 shrink-0 text-caption text-muted whitespace-nowrap">
            {{ formatListDate(patient.created_at) }}
          </div>
          <div
            class="w-28 shrink-0 flex justify-end"
            @click.prevent.stop
          >
            <ModuleSlot
              name="patients.list.row.financial"
              :ctx="{ patient_id: patient.id, summary: debtSummaries[patient.id] ?? null }"
            />
          </div>
        </template>

        <template #card>
          <div class="flex items-center gap-3">
            <div
              class="w-10 h-10 rounded-full flex items-center justify-center text-xs font-semibold shrink-0"
              :class="avatarTone(patient.id)"
            >
              {{ patientInitials(patient) }}
            </div>
            <div class="flex-1 min-w-0">
              <div class="font-medium text-default truncate flex items-center gap-2">
                {{ patient.first_name }} {{ patient.last_name }}
                <UIcon
                  v-if="patient.do_not_contact"
                  name="i-lucide-bell-off"
                  class="w-3.5 h-3.5 text-warning shrink-0"
                />
              </div>
              <div class="text-caption text-subtle truncate flex items-center gap-2 mt-0.5">
                <span
                  v-if="patient.phone"
                  class="inline-flex items-center gap-1"
                >
                  <UIcon
                    name="i-lucide-phone"
                    class="w-3 h-3"
                  />
                  {{ patient.phone }}
                </span>
                <span
                  v-else-if="patient.email"
                  class="inline-flex items-center gap-1"
                >
                  <UIcon
                    name="i-lucide-mail"
                    class="w-3 h-3"
                  />
                  {{ patient.email }}
                </span>
              </div>
            </div>
            <StatusBadge
              :role="PATIENT_STATUS_ROLE[patient.status as PatientStatus] || 'neutral'"
              :label="t(`patients.status.${patient.status}`)"
              class="shrink-0"
            />
          </div>
          <div class="flex items-center justify-between gap-2">
            <span class="text-caption text-subtle">
              {{ formatListDate(patient.created_at) }}
            </span>
            <ModuleSlot
              name="patients.list.row.financial"
              :ctx="{ patient_id: patient.id, summary: debtSummaries[patient.id] ?? null }"
            />
          </div>
        </template>
      </DataListItem>
    </template>
  </DataListLayout>

  <UModal v-model:open="isCreateModalOpen">
    <template #content>
      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <h2 class="text-h1 text-default">
              {{ t('patients.create') }}
            </h2>
            <UButton
              variant="ghost"
              color="neutral"
              icon="i-lucide-x"
              :aria-label="t('common.close', 'Cerrar')"
              @click="isCreateModalOpen = false"
            />
          </div>
        </template>

        <form
          class="space-y-4"
          @submit.prevent="createPatient"
        >
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <UFormField
              :label="t('patients.firstName')"
              required
            >
              <UInput
                v-model="newPatient.first_name"
                :placeholder="t('patients.firstName')"
                required
              />
            </UFormField>
            <UFormField
              :label="t('patients.lastName')"
              required
            >
              <UInput
                v-model="newPatient.last_name"
                :placeholder="t('patients.lastName')"
                required
              />
            </UFormField>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <UFormField :label="t('patients.phone')">
              <UInput
                v-model="newPatient.phone"
                :placeholder="t('patients.phone')"
                type="tel"
              />
            </UFormField>
            <UFormField :label="t('patients.email')">
              <UInput
                v-model="newPatient.email"
                :placeholder="t('patients.email')"
                type="email"
              />
            </UFormField>
          </div>

          <UFormField :label="t('patients.dateOfBirth')">
            <UInput
              v-model="newPatient.date_of_birth"
              type="date"
            />
          </UFormField>

          <UFormField :label="t('patients.notes')">
            <UTextarea
              v-model="newPatient.notes"
              :placeholder="t('patients.notes')"
              :rows="3"
            />
          </UFormField>
        </form>

        <template #footer>
          <div class="flex justify-end gap-3">
            <UButton
              variant="outline"
              color="neutral"
              @click="isCreateModalOpen = false"
            >
              {{ t('common.cancel') }}
            </UButton>
            <UButton
              color="primary"
              variant="solid"
              :loading="isSubmitting"
              :disabled="!newPatient.first_name || !newPatient.last_name"
              @click="createPatient"
            >
              {{ t('common.save') }}
            </UButton>
          </div>
        </template>
      </UCard>
    </template>
  </UModal>
</template>
