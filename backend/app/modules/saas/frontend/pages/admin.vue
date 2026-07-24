<script setup lang="ts">
import type { SaasClinicDirectoryEntry, SaasLead, SaasPricingPlan, SaasSubscription } from '~/composables/useSaasAdmin'

definePageMeta({
  title: 'Platform Administration'
})

const { t } = useI18n()
const { format: formatCurrency } = useCurrency()
const {
  leads,
  clinics,
  plans,
  isLoading,
  fetchAll,
  updateLeadStatus,
  provisionTenant,
  fetchClinicSubscriptions,
  grantSubscription,
  createPlan,
  togglePlanActive
} = useSaasAdmin()

const tabs = computed(() => [
  { label: t('saasAdmin.tabs.leads'), icon: 'i-lucide-users' },
  { label: t('saasAdmin.tabs.clinics'), icon: 'i-lucide-building' },
  { label: t('saasAdmin.tabs.plans'), icon: 'i-lucide-tags' }
])
const activeTab = ref(0)

onMounted(fetchAll)

function fmtDate(value: string | null): string {
  if (!value) return '—'
  return new Date(value).toLocaleDateString()
}

// ───────────────────────── Leads ─────────────────────────
const leadStatusColor: Record<SaasLead['status'], 'warning' | 'info' | 'success' | 'error'> = {
  pending: 'warning',
  contacted: 'info',
  processed: 'success',
  rejected: 'error'
}
const updatingLeadId = ref<string | null>(null)
const leadStatusOptions = computed(() => (['pending', 'contacted', 'processed', 'rejected'] as const).map(value => ({
  value,
  label: t(`saasAdmin.leads.status.${value}`)
})))

async function handleLeadStatus(lead: SaasLead, status: SaasLead['status']) {
  updatingLeadId.value = lead.id
  await updateLeadStatus(lead.id, status)
  updatingLeadId.value = null
}

// ───────────────────────── Provisioning ─────────────────────────
const showProvision = ref(false)
const isProvisioning = ref(false)
const provisionForm = ref({
  clinic_name: '',
  tax_id: '',
  admin_first_name: '',
  admin_last_name: '',
  admin_email: '',
  admin_password: '',
  currency: 'USD',
  timezone: 'UTC'
})

function openProvision() {
  provisionForm.value = {
    clinic_name: '',
    tax_id: '',
    admin_first_name: '',
    admin_last_name: '',
    admin_email: '',
    admin_password: '',
    currency: 'USD',
    timezone: 'UTC'
  }
  showProvision.value = true
}

async function handleProvision() {
  isProvisioning.value = true
  const ok = await provisionTenant(provisionForm.value)
  isProvisioning.value = false
  if (ok) showProvision.value = false
}

// ───────────────────────── Clinic directory + history ─────────────────────────
const selectedClinic = ref<SaasClinicDirectoryEntry | null>(null)
const showClinicDetail = ref(false)
const clinicHistory = ref<SaasSubscription[]>([])
const isLoadingHistory = ref(false)
const grantForm = ref({ duration_months: 1 })
const isGranting = ref(false)

async function openClinicDetail(clinic: SaasClinicDirectoryEntry) {
  selectedClinic.value = clinic
  showClinicDetail.value = true
  grantForm.value = { duration_months: 1 }
  isLoadingHistory.value = true
  clinicHistory.value = await fetchClinicSubscriptions(clinic.id)
  isLoadingHistory.value = false
}

async function handleGrant() {
  if (!selectedClinic.value) return
  isGranting.value = true
  const sub = await grantSubscription(selectedClinic.value.id, grantForm.value.duration_months)
  isGranting.value = false
  if (sub) {
    clinicHistory.value = await fetchClinicSubscriptions(selectedClinic.value.id)
    // Reflect the refreshed directory entry in the open slideover.
    const refreshed = clinics.value.find(c => c.id === selectedClinic.value?.id)
    if (refreshed) selectedClinic.value = refreshed
  }
}

const subStatusColor: Record<SaasSubscription['effective_status'], 'success' | 'neutral' | 'error'> = {
  active: 'success',
  upcoming: 'neutral',
  expired: 'error'
}

// ───────────────────────── Pricing plans ─────────────────────────
const showNewPlan = ref(false)
const isCreatingPlan = ref(false)
const planForm = ref({ name: '', duration_months: 1, price: 0, is_active: true })
const togglingPlanId = ref<string | null>(null)

function openNewPlan() {
  planForm.value = { name: '', duration_months: 1, price: 0, is_active: true }
  showNewPlan.value = true
}

async function handleCreatePlan() {
  isCreatingPlan.value = true
  const ok = await createPlan(planForm.value)
  isCreatingPlan.value = false
  if (ok) showNewPlan.value = false
}

async function handleTogglePlan(plan: SaasPricingPlan) {
  togglingPlanId.value = plan.id
  await togglePlanActive(plan)
  togglingPlanId.value = null
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
        {{ t('saasAdmin.title') }}
      </h1>
      <p class="text-sm text-gray-500 dark:text-gray-400">
        {{ t('saasAdmin.subtitle') }}
      </p>
    </div>

    <UTabs
      v-model="activeTab"
      :items="tabs"
      class="w-full"
    />

    <UCard
      v-if="!isLoading"
      class="mt-4 shadow-sm border-t-4 border-t-primary-500"
    >
      <!-- Leads Tab -->
      <div v-if="activeTab === 0">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
                {{ t('saasAdmin.leads.heading') }}
              </h2>
              <UButton
                color="primary"
                icon="i-lucide-refresh-cw"
                variant="ghost"
                @click="fetchAll"
              >
                {{ t('common.refresh') }}
              </UButton>
            </div>

            <div
              v-if="leads.length === 0"
              class="py-8 text-center text-gray-500"
            >
              {{ t('saasAdmin.leads.empty') }}
            </div>
            <div
              v-else
              class="divide-y divide-[var(--color-border-subtle)]"
            >
              <div
                v-for="lead in leads"
                :key="lead.id"
                class="flex items-center justify-between gap-3 py-3 flex-wrap"
              >
                <div class="min-w-0">
                  <p class="font-medium text-default truncate">
                    {{ lead.contact_name }} · {{ lead.clinic_name }}
                  </p>
                  <p class="text-caption text-subtle truncate">
                    {{ lead.email }}<span v-if="lead.phone"> · {{ lead.phone }}</span>
                    <span v-if="lead.expected_users"> · {{ t('saasAdmin.leads.expectedUsers', { count: lead.expected_users }) }}</span>
                  </p>
                </div>
                <div class="flex items-center gap-2 shrink-0">
                  <UBadge
                    :color="leadStatusColor[lead.status]"
                    variant="subtle"
                  >
                    {{ t(`saasAdmin.leads.status.${lead.status}`) }}
                  </UBadge>
                  <USelect
                    :model-value="lead.status"
                    :items="leadStatusOptions"
                    value-key="value"
                    label-key="label"
                    :disabled="updatingLeadId === lead.id"
                    size="xs"
                    class="w-36"
                    @update:model-value="(v: string) => handleLeadStatus(lead, v as SaasLead['status'])"
                  />
                </div>
              </div>
            </div>
          </div>

          <!-- Clinics & Subscriptions Tab -->
          <div v-else-if="activeTab === 1">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
                {{ t('saasAdmin.clinics.heading') }}
              </h2>
              <UButton
                color="primary"
                icon="i-lucide-plus"
                @click="openProvision"
              >
                {{ t('saasAdmin.clinics.provision') }}
              </UButton>
            </div>

            <div
              v-if="clinics.length === 0"
              class="py-8 text-center text-gray-500"
            >
              {{ t('saasAdmin.clinics.empty') }}
            </div>
            <div
              v-else
              class="divide-y divide-[var(--color-border-subtle)]"
            >
              <button
                v-for="clinic in clinics"
                :key="clinic.id"
                type="button"
                class="flex w-full items-center justify-between gap-3 py-3 text-left hover:bg-elevated/50 rounded-md px-2 -mx-2 transition-colors"
                @click="openClinicDetail(clinic)"
              >
                <div class="min-w-0">
                  <p class="font-medium text-default truncate">
                    {{ clinic.name }}
                  </p>
                  <p class="text-caption text-subtle truncate">
                    {{ clinic.tax_id }} · {{ t('saasAdmin.clinics.subscriptionCount', { count: clinic.subscription_count }) }}
                  </p>
                </div>
                <div class="flex items-center gap-2 shrink-0">
                  <UBadge
                    :color="clinic.subscription_active ? 'success' : 'error'"
                    variant="subtle"
                  >
                    {{ clinic.subscription_active ? t('saasAdmin.clinics.active') : t('saasAdmin.clinics.inactive') }}
                  </UBadge>
                  <span class="text-caption text-subtle">{{ fmtDate(clinic.subscription_end_date) }}</span>
                  <UIcon
                    name="i-lucide-chevron-right"
                    class="w-4 h-4 text-subtle"
                  />
                </div>
              </button>
            </div>
          </div>

          <!-- Pricing Plans Tab -->
          <div v-else-if="activeTab === 2">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
                {{ t('saasAdmin.plans.heading') }}
              </h2>
              <UButton
                color="primary"
                icon="i-lucide-plus"
                @click="openNewPlan"
              >
                {{ t('saasAdmin.plans.newPlan') }}
              </UButton>
            </div>

            <div
              v-if="plans.length === 0"
              class="py-8 text-center text-gray-500"
            >
              {{ t('saasAdmin.plans.empty') }}
            </div>
            <div
              v-else
              class="divide-y divide-[var(--color-border-subtle)]"
            >
              <div
                v-for="plan in plans"
                :key="plan.id"
                class="flex items-center justify-between gap-3 py-3"
              >
                <div class="min-w-0">
                  <p class="font-medium text-default truncate">
                    {{ plan.name }}
                  </p>
                  <p class="text-caption text-subtle truncate">
                    {{ t('saasAdmin.plans.durationMonths', { count: plan.duration_months }) }} · {{ formatCurrency(plan.price) }}
                  </p>
                </div>
                <UButton
                  :icon="plan.is_active ? 'i-lucide-toggle-right' : 'i-lucide-toggle-left'"
                  :color="plan.is_active ? 'success' : 'neutral'"
                  variant="ghost"
                  size="sm"
                  :loading="togglingPlanId === plan.id"
                  @click="handleTogglePlan(plan)"
                >
                  {{ plan.is_active ? t('saasAdmin.plans.active') : t('saasAdmin.plans.inactive') }}
                </UButton>
              </div>
            </div>
          </div>
        </UCard>

        <!-- Loading Skeleton -->
        <UCard
          v-else
          class="mt-4"
        >
          <div class="space-y-4">
            <USkeleton class="h-8 w-1/4" />
            <USkeleton class="h-10 w-full" />
            <USkeleton class="h-10 w-full" />
            <USkeleton class="h-10 w-full" />
          </div>
        </UCard>


    <!-- Provision clinic modal -->
    <UModal v-model:open="showProvision">
      <template #content>
        <UCard>
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon
                name="i-lucide-building-2"
                class="w-5 h-5 text-primary-accent"
              />
              <h3 class="font-semibold text-default">
                {{ t('saasAdmin.clinics.provision') }}
              </h3>
            </div>
          </template>

          <form
            class="space-y-4"
            @submit.prevent="handleProvision"
          >
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <UFormField :label="t('saasAdmin.form.clinicName')">
                <UInput
                  v-model="provisionForm.clinic_name"
                  required
                />
              </UFormField>
              <UFormField :label="t('saasAdmin.form.taxId')">
                <UInput
                  v-model="provisionForm.tax_id"
                  required
                />
              </UFormField>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <UFormField :label="t('common.firstName')">
                <UInput
                  v-model="provisionForm.admin_first_name"
                  required
                />
              </UFormField>
              <UFormField :label="t('common.lastName')">
                <UInput
                  v-model="provisionForm.admin_last_name"
                  required
                />
              </UFormField>
            </div>

            <UFormField :label="t('common.email')">
              <UInput
                v-model="provisionForm.admin_email"
                type="email"
                required
              />
            </UFormField>

            <UFormField
              :label="t('common.password')"
              :help="t('saasAdmin.form.passwordHelp')"
            >
              <UInput
                v-model="provisionForm.admin_password"
                type="password"
                minlength="8"
                required
              />
            </UFormField>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <UFormField :label="t('settings.currency')">
                <UInput v-model="provisionForm.currency" />
              </UFormField>
              <UFormField :label="t('settings.timezone')">
                <UInput v-model="provisionForm.timezone" />
              </UFormField>
            </div>

            <div class="flex justify-end gap-2 pt-4">
              <UButton
                variant="ghost"
                @click="showProvision = false"
              >
                {{ t('common.cancel') }}
              </UButton>
              <UButton
                type="submit"
                :loading="isProvisioning"
              >
                {{ t('saasAdmin.clinics.provision') }}
              </UButton>
            </div>
          </form>
        </UCard>
      </template>
    </UModal>

    <!-- New pricing plan modal -->
    <UModal v-model:open="showNewPlan">
      <template #content>
        <UCard>
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon
                name="i-lucide-tag"
                class="w-5 h-5 text-primary-accent"
              />
              <h3 class="font-semibold text-default">
                {{ t('saasAdmin.plans.newPlan') }}
              </h3>
            </div>
          </template>

          <form
            class="space-y-4"
            @submit.prevent="handleCreatePlan"
          >
            <UFormField :label="t('saasAdmin.form.planName')">
              <UInput
                v-model="planForm.name"
                required
              />
            </UFormField>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <UFormField :label="t('saasAdmin.form.durationMonths')">
                <UInput
                  v-model.number="planForm.duration_months"
                  type="number"
                  min="1"
                  required
                />
              </UFormField>
              <UFormField :label="t('saasAdmin.form.price')">
                <UInput
                  v-model.number="planForm.price"
                  type="number"
                  min="0"
                  step="0.01"
                  required
                />
              </UFormField>
            </div>
            <div class="flex items-center gap-3">
              <USwitch v-model="planForm.is_active" />
              <span class="text-sm text-muted">{{ t('saasAdmin.plans.active') }}</span>
            </div>

            <div class="flex justify-end gap-2 pt-4">
              <UButton
                variant="ghost"
                @click="showNewPlan = false"
              >
                {{ t('common.cancel') }}
              </UButton>
              <UButton
                type="submit"
                :loading="isCreatingPlan"
              >
                {{ t('saasAdmin.plans.newPlan') }}
              </UButton>
            </div>
          </form>
        </UCard>
      </template>
    </UModal>

    <!-- Clinic detail slideover -->
    <USlideover
      :open="showClinicDetail"
      side="right"
      :title="selectedClinic?.name"
      :ui="{ content: 'w-[480px] max-w-[95vw]' }"
      @update:open="showClinicDetail = $event"
    >
      <template #content>
        <div
          v-if="selectedClinic"
          class="flex flex-col h-full"
        >
          <header class="flex items-center justify-between px-4 h-14 border-b border-default shrink-0">
            <div class="min-w-0">
              <p class="text-h3 text-default truncate">
                {{ selectedClinic.name }}
              </p>
              <p class="text-caption text-subtle">
                {{ selectedClinic.tax_id }}
              </p>
            </div>
            <UButton
              icon="i-lucide-x"
              variant="ghost"
              color="neutral"
              size="sm"
              @click="showClinicDetail = false"
            />
          </header>

          <div class="flex-1 overflow-y-auto p-4 space-y-6">
            <!-- Grant / renew -->
            <section>
              <h4 class="text-sm font-semibold text-default mb-2">
                {{ t('saasAdmin.clinics.grantRenew') }}
              </h4>
              <p class="text-caption text-subtle mb-3">
                {{ t('saasAdmin.clinics.grantRenewHelp') }}
              </p>
              <form
                class="flex items-end gap-2"
                @submit.prevent="handleGrant"
              >
                <UFormField
                  :label="t('saasAdmin.form.durationMonths')"
                  class="flex-1"
                >
                  <UInput
                    v-model.number="grantForm.duration_months"
                    type="number"
                    min="1"
                    required
                  />
                </UFormField>
                <UButton
                  type="submit"
                  icon="i-lucide-check"
                  :loading="isGranting"
                >
                  {{ t('saasAdmin.clinics.grant') }}
                </UButton>
              </form>
            </section>

            <!-- History -->
            <section>
              <h4 class="text-sm font-semibold text-default mb-2">
                {{ t('saasAdmin.clinics.history') }}
              </h4>
              <div
                v-if="isLoadingHistory"
                class="space-y-2"
              >
                <USkeleton class="h-10 w-full" />
                <USkeleton class="h-10 w-full" />
              </div>
              <div
                v-else-if="clinicHistory.length === 0"
                class="text-caption text-subtle py-4 text-center"
              >
                {{ t('saasAdmin.clinics.noHistory') }}
              </div>
              <div
                v-else
                class="space-y-2"
              >
                <div
                  v-for="sub in clinicHistory"
                  :key="sub.id"
                  class="flex items-center justify-between gap-2 rounded-md border border-default px-3 py-2"
                >
                  <div class="min-w-0 text-caption text-default">
                    {{ fmtDate(sub.start_date) }} → {{ fmtDate(sub.end_date) }}
                  </div>
                  <UBadge
                    :color="subStatusColor[sub.effective_status]"
                    variant="subtle"
                  >
                    {{ t(`saasAdmin.clinics.subStatus.${sub.effective_status}`) }}
                  </UBadge>
                </div>
              </div>
            </section>
          </div>
        </div>
      </template>
    </USlideover>
  </div>
</template>
