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
  plans,
  updateClinic,
  deleteClinic
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

const themeColorPresets = [
  { name: 'Teal Mint', color: '#0F766E' },
  { name: 'Royal Blue', color: '#2563EB' },
  { name: 'Emerald', color: '#059669' },
  { name: 'Violet', color: '#7C3AED' },
  { name: 'Vibrant Rose', color: '#E11D48' },
  { name: 'Warm Amber', color: '#D97706' },
  { name: 'Luxury Gold', color: '#B39D82' },
  { name: 'Ocean Cyan', color: '#0891B2' },
  { name: 'Deep Indigo', color: '#4F46E5' },
  { name: 'Coral Sunset', color: '#EA580C' }
]

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
  timezone: 'Asia/Kolkata',
  theme_color: '#B39D82'
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
    timezone: 'Asia/Kolkata',
    theme_color: '#B39D82'
  }
  showProvision.value = true
}

async function handleProvision() {
  isProvisioning.value = true
  const ok = await provisionTenant(provisionForm.value)
  isProvisioning.value = false
  if (ok) showProvision.value = false
}

// ───────────────────────── Edit & Delete Clinic ─────────────────────────
const showEditClinic = ref(false)
const isEditingClinic = ref(false)
const editClinicForm = ref({ id: '', name: '', tax_id: '', theme_color: '#B39D82' })

function openEditClinic(clinic: SaasClinicDirectoryEntry) {
  editClinicForm.value = {
    id: clinic.id,
    name: clinic.name,
    tax_id: clinic.tax_id,
    theme_color: clinic.theme_color || '#B39D82'
  }
  showEditClinic.value = true
}

async function handleEditClinic() {
  isEditingClinic.value = true
  const ok = await updateClinic(editClinicForm.value.id, {
    name: editClinicForm.value.name,
    tax_id: editClinicForm.value.tax_id,
    theme_color: editClinicForm.value.theme_color
  })
  isEditingClinic.value = false
  if (ok) showEditClinic.value = false
}

const showDeleteClinic = ref(false)
const isDeletingClinic = ref(false)
const deleteClinicTarget = ref<SaasClinicDirectoryEntry | null>(null)

function confirmDeleteClinic(clinic: SaasClinicDirectoryEntry) {
  deleteClinicTarget.value = clinic
  showDeleteClinic.value = true
}

async function handleDeleteClinic() {
  if (!deleteClinicTarget.value) return
  isDeletingClinic.value = true
  const ok = await deleteClinic(deleteClinicTarget.value.id)
  isDeletingClinic.value = false
  if (ok) {
    showDeleteClinic.value = false
    if (selectedClinic.value?.id === deleteClinicTarget.value.id) {
      showClinicDetail.value = false
    }
  }
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
            <div class="min-w-0 flex items-center gap-3">
              <span
                class="w-3.5 h-3.5 rounded-full shadow-sm shrink-0 ring-1 ring-black/10 dark:ring-white/20"
                :style="{ backgroundColor: clinic.theme_color || '#B39D82' }"
                :title="clinic.theme_color || 'Default Theme'"
              />
              <div class="min-w-0">
                <p class="font-medium text-default truncate">
                  {{ clinic.name }}
                </p>
                <p class="text-caption text-subtle truncate">
                  {{ clinic.tax_id }} · {{ t('saasAdmin.clinics.subscriptionCount', { count: clinic.subscription_count }) }}
                </p>
              </div>
            </div>
            <div class="flex items-center gap-2 shrink-0">
              <UBadge
                :color="clinic.subscription_active ? 'success' : 'error'"
                variant="subtle"
              >
                {{ clinic.subscription_active ? t('saasAdmin.clinics.active') : t('saasAdmin.clinics.inactive') }}
              </UBadge>
              <span class="text-caption text-subtle">{{ fmtDate(clinic.subscription_end_date) }}</span>
              <UButton
                label="Renew"
                variant="soft"
                color="primary"
                size="xs"
                class="ml-2"
                @click.stop="openClinicDetail(clinic)"
              />
              <UButton
                icon="i-lucide-pencil"
                variant="ghost"
                color="neutral"
                size="sm"
                class="ml-2"
                @click.stop="openEditClinic(clinic)"
              />
              <UButton
                icon="i-lucide-trash-2"
                variant="ghost"
                color="error"
                size="sm"
                @click.stop="confirmDeleteClinic(clinic)"
              />
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

            <!-- Provision Theme Color -->
            <div class="space-y-2 pt-2 border-t border-[var(--color-border-subtle)]">
              <label class="block text-sm font-medium text-default">
                Store / Client Theme Color
              </label>
              <div class="flex flex-wrap gap-2 pt-1">
                <button
                  v-for="preset in themeColorPresets"
                  :key="preset.color"
                  type="button"
                  class="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg border text-xs transition-all"
                  :class="provisionForm.theme_color === preset.color
                    ? 'border-neutral-900 dark:border-white ring-2 ring-neutral-900/20 dark:ring-white/20 font-medium'
                    : 'border-neutral-200 dark:border-neutral-800 hover:border-neutral-400'"
                  @click="provisionForm.theme_color = preset.color"
                >
                  <span
                    class="w-3.5 h-3.5 rounded-full shadow-sm"
                    :style="{ backgroundColor: preset.color }"
                  />
                  <span>{{ preset.name }}</span>
                </button>
              </div>
              <div class="flex items-center gap-3 pt-2">
                <input
                  v-model="provisionForm.theme_color"
                  type="color"
                  class="w-9 h-9 p-0.5 rounded-lg border border-neutral-300 dark:border-neutral-700 cursor-pointer bg-transparent"
                >
                <UInput
                  v-model="provisionForm.theme_color"
                  placeholder="#B39D82"
                  class="w-28 uppercase font-mono text-xs"
                />
              </div>
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

    <!-- Edit clinic modal -->
    <UModal v-model:open="showEditClinic">
      <template #content>
        <UCard>
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon
                name="i-lucide-pencil"
                class="w-5 h-5 text-primary-accent"
              />
              <h3 class="font-semibold text-default">
                Edit Clinic
              </h3>
            </div>
          </template>

          <form
            class="space-y-4"
            @submit.prevent="handleEditClinic"
          >
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <UFormField :label="t('saasAdmin.form.clinicName')">
                <UInput
                  v-model="editClinicForm.name"
                  required
                />
              </UFormField>
              <UFormField :label="t('saasAdmin.form.taxId')">
                <UInput
                  v-model="editClinicForm.tax_id"
                  required
                />
              </UFormField>
            </div>

            <!-- Edit Clinic Theme Color Selection -->
            <div class="space-y-2 pt-2 border-t border-[var(--color-border-subtle)]">
              <label class="block text-sm font-medium text-default">
                Client Store Dashboard &amp; Profile Color
              </label>
              <p class="text-xs text-subtle">
                This color dynamically adjusts the client's dashboard, buttons, highlights, badges, and profile accents.
              </p>

              <!-- Color presets -->
              <div class="flex flex-wrap gap-2 pt-1">
                <button
                  v-for="preset in themeColorPresets"
                  :key="preset.color"
                  type="button"
                  class="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg border text-xs transition-all"
                  :class="editClinicForm.theme_color === preset.color
                    ? 'border-neutral-900 dark:border-white ring-2 ring-neutral-900/20 dark:ring-white/20 font-medium shadow-sm'
                    : 'border-neutral-200 dark:border-neutral-800 hover:border-neutral-400'"
                  @click="editClinicForm.theme_color = preset.color"
                >
                  <span
                    class="w-3.5 h-3.5 rounded-full shadow-sm"
                    :style="{ backgroundColor: preset.color }"
                  />
                  <span>{{ preset.name }}</span>
                </button>
              </div>

              <!-- Custom Color Picker + Live Preview -->
              <div class="flex flex-wrap items-center gap-3 pt-2">
                <div class="flex items-center gap-2">
                  <input
                    v-model="editClinicForm.theme_color"
                    type="color"
                    class="w-9 h-9 p-0.5 rounded-lg border border-neutral-300 dark:border-neutral-700 cursor-pointer bg-transparent"
                  >
                  <UInput
                    v-model="editClinicForm.theme_color"
                    placeholder="#B39D82"
                    class="w-28 uppercase font-mono text-xs"
                  />
                </div>
                <div class="flex items-center gap-2 text-xs">
                  <span class="text-subtle">Live Preview:</span>
                  <span
                    class="px-3 py-1 rounded-md text-white text-xs font-semibold shadow-sm transition-all"
                    :style="{ backgroundColor: editClinicForm.theme_color || '#B39D82' }"
                  >
                    Primary Button &amp; Accent
                  </span>
                </div>
              </div>
            </div>

            <div class="flex justify-end gap-2 pt-4">
              <UButton
                variant="ghost"
                @click="showEditClinic = false"
              >
                {{ t('common.cancel') }}
              </UButton>
              <UButton
                type="submit"
                :loading="isEditingClinic"
              >
                Save Changes
              </UButton>
            </div>
          </form>
        </UCard>
      </template>
    </UModal>

    <!-- Delete Clinic Confirmation Modal -->
    <UModal v-model:open="showDeleteClinic">
      <template #content>
        <UCard>
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-alert-triangle" class="w-5 h-5 text-error-500" />
              <h3 class="font-semibold text-error-500">Danger: Delete Clinic</h3>
            </div>
          </template>
          
          <div class="py-2 space-y-4">
            <p class="text-sm text-subtle">
              Are you absolutely sure you want to delete <strong>{{ deleteClinicTarget?.name }}</strong>?
            </p>
            <div class="p-3 bg-error-50 dark:bg-error-500/10 rounded-md text-sm text-error-600 dark:text-error-400 border border-error-200 dark:border-error-500/20">
              <p class="font-medium mb-1">This action is highly destructive.</p>
              <ul class="list-disc pl-4 space-y-1">
                <li>All users associated with this clinic will lose access.</li>
                <li>All patients, budgets, and clinical records will be permanently erased.</li>
                <li>This action cannot be undone.</li>
              </ul>
            </div>
          </div>

          <div class="flex justify-end gap-2 pt-4">
            <UButton variant="ghost" color="neutral" @click="showDeleteClinic = false">
              Cancel
            </UButton>
            <UButton color="error" @click="handleDeleteClinic" :loading="isDeletingClinic">
              Yes, Delete Clinic
            </UButton>
          </div>
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
