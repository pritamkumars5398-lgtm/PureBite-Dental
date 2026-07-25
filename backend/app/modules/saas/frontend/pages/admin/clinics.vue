<script setup lang="ts">
import type { SaasClinicDirectoryEntry, SaasSubscription } from '~/composables/useSaasAdmin'

definePageMeta({
  title: 'Platform Administration - Clinics & Subscriptions'
})

const { t } = useI18n()
const {
  clinics,
  isLoading,
  fetchAll,
  provisionTenant,
  fetchClinicSubscriptions,
  grantSubscription,
  plans
} = useSaasAdmin()

const route = useRoute()
const router = useRouter()

onMounted(() => {
  fetchAll()
  if (route.query.provision) {
    // wait a tick for the UI to be ready
    setTimeout(() => {
      openProvision()
      router.replace({ query: {} })
    }, 50)
  }
})

function fmtDate(value: string | null): string {
  if (!value) return '—'
  return new Date(value).toLocaleDateString()
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
  currency: 'INR',
  timezone: 'Asia/Kolkata'
})

const currencyOptions = [
  { label: 'INR (₹)', value: 'INR' },
  { label: 'USD ($)', value: 'USD' },
  { label: 'EUR (€)', value: 'EUR' },
  { label: 'GBP (£)', value: 'GBP' }
]

const timezoneOptions = [
  { label: 'IST (Asia/Kolkata)', value: 'Asia/Kolkata' },
  { label: 'UTC', value: 'UTC' },
  { label: 'EST (America/New_York)', value: 'America/New_York' },
  { label: 'PST (America/Los_Angeles)', value: 'America/Los_Angeles' },
  { label: 'GMT (Europe/London)', value: 'Europe/London' }
]

function openProvision() {
  provisionForm.value = {
    clinic_name: '',
    tax_id: '',
    admin_first_name: '',
    admin_last_name: '',
    admin_email: '',
    admin_password: '',
    currency: 'INR',
    timezone: 'Asia/Kolkata'
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
const grantForm = ref({ plan_id: '', duration_months: 1 })
const isGranting = ref(false)
const showConfirmGrant = ref(false)

const planOptions = computed(() => {
  return plans.value
    .filter(p => p.is_active)
    .map(p => ({
      label: `${p.name} (${p.duration_months} mo - ₹${p.price})`,
      value: p.id,
      duration: p.duration_months
    }))
})

watch(() => grantForm.value.plan_id, (newPlanId) => {
  if (newPlanId) {
    const plan = planOptions.value.find(p => p.value === newPlanId)
    if (plan) grantForm.value.duration_months = plan.duration
  }
})

async function openClinicDetail(clinic: SaasClinicDirectoryEntry) {
  selectedClinic.value = clinic
  showClinicDetail.value = true
  
  if (planOptions.value.length > 0) {
    grantForm.value = { plan_id: planOptions.value[0].value, duration_months: planOptions.value[0].duration }
  } else {
    grantForm.value = { plan_id: '', duration_months: 1 }
  }

  isLoadingHistory.value = true
  clinicHistory.value = await fetchClinicSubscriptions(clinic.id)
  isLoadingHistory.value = false
}

async function handleGrant() {
  if (!selectedClinic.value) return
  isGranting.value = true
  showConfirmGrant.value = false
  const sub = await grantSubscription(
    selectedClinic.value.id, 
    grantForm.value.duration_months, 
    grantForm.value.plan_id
  )
  isGranting.value = false
  if (sub) {
    clinicHistory.value = await fetchClinicSubscriptions(selectedClinic.value.id)
    const refreshed = clinics.value.find(c => c.id === selectedClinic.value?.id)
    if (refreshed) selectedClinic.value = refreshed
  }
}

const subStatusColor: Record<SaasSubscription['effective_status'], 'success' | 'neutral' | 'error'> = {
  active: 'success',
  upcoming: 'neutral',
  expired: 'error'
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
        {{ t('saasAdmin.clinics.heading') }}
      </h1>
      <p class="text-sm text-gray-500 dark:text-gray-400">
        {{ t('saasAdmin.subtitle') }}
      </p>
    </div>

    <UCard class="shadow-sm border-t-4 border-t-primary-500">
      <div v-if="isLoading" class="space-y-4">
        <USkeleton class="h-8 w-1/4" />
        <USkeleton class="h-10 w-full" />
        <USkeleton class="h-10 w-full" />
      </div>
      <div v-else>
        <div class="flex justify-between items-center mb-4">
          <div></div>
          <UButton
            color="primary"
            variant="solid"
            size="md"
            class="shadow-sm"
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
                <USelect
                  v-model="provisionForm.currency"
                  :items="currencyOptions"
                  value-key="value"
                  label-key="label"
                />
              </UFormField>
              <UFormField :label="t('settings.timezone')">
                <USelect
                  v-model="provisionForm.timezone"
                  :items="timezoneOptions"
                  value-key="value"
                  label-key="label"
                />
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
                class="flex flex-col gap-3"
                @submit.prevent="showConfirmGrant = true"
              >
                <UFormField
                  label="Select Pricing Plan"
                >
                  <USelect
                    v-model="grantForm.plan_id"
                    :items="planOptions"
                    class="w-full"
                  />
                </UFormField>


                
                <div class="flex justify-end">
                  <UButton
                    type="submit"
                    icon="i-lucide-check"
                    :loading="isGranting"
                  >
                    {{ t('saasAdmin.clinics.grant') }}
                  </UButton>
                </div>
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
                class="space-y-2 max-h-64 overflow-y-auto pr-2 custom-scrollbar"
              >
                <div
                  v-for="sub in clinicHistory"
                  :key="sub.id"
                  class="flex flex-col gap-2 p-3 bg-gray-50 dark:bg-gray-800/50 rounded-md border border-[var(--color-border-subtle)]"
                >
                  <div class="flex items-center justify-between">
                    <span class="text-sm font-medium text-default">
                      {{ fmtDate(sub.start_date) }} – {{ fmtDate(sub.end_date) }}
                    </span>
                    <UBadge
                      :color="subStatusColor[sub.effective_status]"
                      variant="subtle"
                      size="sm"
                      class="capitalize"
                    >
                      {{ sub.effective_status }}
                    </UBadge>
                  </div>
                  <div class="flex items-center gap-2 text-xs text-subtle" v-if="sub.plan">
                    <UIcon name="i-lucide-tag" class="w-3.5 h-3.5" />
                    <span class="font-medium">{{ sub.plan.name }}</span>
                    <span>·</span>
                    <span>₹{{ sub.plan.price }} for {{ sub.plan.duration_months }} mo</span>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>
      </template>
    </USlideover>
    <!-- Confirm Grant modal -->
    <UModal v-model:open="showConfirmGrant">
      <template #content>
        <UCard>
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-alert-circle" class="w-5 h-5 text-warning-500" />
              <h3 class="font-semibold text-default">Confirm Subscription Grant</h3>
            </div>
          </template>
          
          <div class="py-2 space-y-4">
            <p class="text-sm text-subtle">
              Are you sure you want to grant this subscription to <strong>{{ selectedClinic?.name }}</strong>?
            </p>
            
            <div class="p-3 bg-gray-50 dark:bg-gray-800 rounded-md text-sm border border-[var(--color-border-subtle)]">
              <div v-if="grantForm.plan_id && grantForm.plan_id !== 'custom'" class="flex items-start gap-2">
                <UIcon name="i-lucide-tag" class="w-4 h-4 mt-0.5 text-primary-500" />
                <div>
                  <div class="font-medium text-default">{{ planOptions.find(p => p.value === grantForm.plan_id)?.label.split('(')[0].trim() }}</div>
                  <div class="text-xs text-subtle mt-0.5">{{ planOptions.find(p => p.value === grantForm.plan_id)?.label.split('(')[1].replace(')', '') }}</div>
                </div>
              </div>
              <div v-else class="flex items-start gap-2">
                <UIcon name="i-lucide-calendar" class="w-4 h-4 mt-0.5 text-primary-500" />
                <div>
                  <div class="font-medium text-default">Custom Duration</div>
                  <div class="text-xs text-subtle mt-0.5">{{ grantForm.duration_months }} month(s)</div>
                </div>
              </div>
            </div>
          </div>

          <div class="flex justify-end gap-2 pt-4">
            <UButton variant="ghost" @click="showConfirmGrant = false">
              Cancel
            </UButton>
            <UButton color="primary" @click="handleGrant" :loading="isGranting">
              Yes, Grant Subscription
            </UButton>
          </div>
        </UCard>
      </template>
    </UModal>
  </div>
</template>
