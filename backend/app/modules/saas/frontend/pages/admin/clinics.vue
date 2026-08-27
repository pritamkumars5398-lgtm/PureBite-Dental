<script setup lang="ts">
import type { SaasClinicDirectoryEntry, SaasSubscription } from '~/composables/useSaasAdmin'
import { THEME_PRESETS } from '~/composables/useClinicTheme'

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
  logo_url: '',
  primary_color: '#0284C7',
  theme_preset: 'ocean_blue'
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
    logo_url: '',
    primary_color: '#0284C7',
    theme_preset: 'ocean_blue'
  }
  showProvision.value = true
}

async function handleProvision() {
  isProvisioning.value = true
  const ok = await provisionTenant({
    ...provisionForm.value,
    logo_url: provisionForm.value.logo_url.trim() || null
  })
  isProvisioning.value = false
  if (ok) showProvision.value = false
}

// ───────────────────────── Edit & Delete Clinic ─────────────────────────
const showEditClinic = ref(false)
const isEditingClinic = ref(false)
const editClinicForm = ref({
  id: '',
  name: '',
  tax_id: '',
  logo_url: '',
  primary_color: '#0284C7',
  theme_preset: 'ocean_blue'
})

function openEditClinic(clinic: SaasClinicDirectoryEntry) {
  editClinicForm.value = {
    id: clinic.id,
    name: clinic.name,
    tax_id: clinic.tax_id,
    logo_url: clinic.logo_url || '',
    primary_color: clinic.primary_color || '#0284C7',
    theme_preset: clinic.theme_preset || 'ocean_blue'
  }
  showEditClinic.value = true
}

function selectEditTheme(presetId: string) {
  editClinicForm.value.theme_preset = presetId
  const found = THEME_PRESETS.find(p => p.id === presetId)
  if (found) {
    editClinicForm.value.primary_color = found.primaryColor
  }
}

function selectProvisionTheme(presetId: string) {
  provisionForm.value.theme_preset = presetId
  const found = THEME_PRESETS.find(p => p.id === presetId)
  if (found) {
    provisionForm.value.primary_color = found.primaryColor
  }
}

const provisionFileInput = ref<HTMLInputElement | null>(null)
const editFileInput = ref<HTMLInputElement | null>(null)

function handleProvisionFileUpload(event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  if (!file.type.startsWith('image/')) return

  const reader = new FileReader()
  reader.onload = (e) => {
    const result = e.target?.result as string
    if (result) {
      provisionForm.value.logo_url = result
    }
  }
  reader.readAsDataURL(file)
}

function handleEditFileUpload(event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  if (!file.type.startsWith('image/')) return

  const reader = new FileReader()
  reader.onload = (e) => {
    const result = e.target?.result as string
    if (result) {
      editClinicForm.value.logo_url = result
    }
  }
  reader.readAsDataURL(file)
}

async function handleEditClinic() {
  isEditingClinic.value = true
  const ok = await updateClinic(editClinicForm.value.id, {
    name: editClinicForm.value.name,
    tax_id: editClinicForm.value.tax_id,
    logo_url: editClinicForm.value.logo_url.trim() || null,
    primary_color: editClinicForm.value.primary_color,
    theme_preset: editClinicForm.value.theme_preset
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
            <div class="flex items-center gap-3 min-w-0">
              <div class="w-10 h-10 rounded-token-md border border-subtle bg-surface flex items-center justify-center overflow-hidden shrink-0 shadow-xs">
                <img
                  v-if="clinic.logo_url"
                  :src="clinic.logo_url"
                  alt=""
                  class="w-full h-full object-contain p-0.5"
                >
                <div v-else class="w-full h-full flex items-center justify-center text-muted">
                  <UIcon name="i-lucide-building" class="w-5 h-5 text-subtle" />
                </div>
              </div>
              <div class="min-w-0">
                <div class="flex items-center gap-2">
                  <p class="font-medium text-default truncate">
                    {{ clinic.name }}
                  </p>
                  <span
                    v-if="clinic.primary_color"
                    class="w-2.5 h-2.5 rounded-full shrink-0 border border-black/10 shadow-xs"
                    :style="{ backgroundColor: clinic.primary_color }"
                    :title="`Theme: ${clinic.theme_preset || clinic.primary_color}`"
                  />
                </div>
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
                class="ml-1 text-error-500 hover:text-error-600 hover:bg-error-50 dark:hover:bg-error-500/10"
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
    <UModal
      v-model:open="showProvision"
      :title="t('saasAdmin.clinics.provision')"
      description="Provision a new clinic tenant"
    >
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

            <!-- Branding: Logo URL & Theme Preset -->
            <div class="space-y-3 pt-2 border-t border-subtle">
              <p class="text-caption font-semibold text-default">Clinic Branding & Color Theme</p>
              
              <!-- Logo Preview & Upload -->
              <div class="flex items-center gap-3">
                <div class="w-12 h-12 rounded-token-md border border-subtle bg-surface flex items-center justify-center overflow-hidden shrink-0 shadow-xs">
                  <img
                    v-if="provisionForm.logo_url"
                    :src="provisionForm.logo_url"
                    alt="Logo Preview"
                    class="w-full h-full object-contain p-0.5"
                  >
                  <UIcon v-else name="i-lucide-building" class="w-6 h-6 text-subtle" />
                </div>
                <div class="flex-1 space-y-1.5">
                  <label class="block text-caption font-medium text-default">Logo Image (URL or Upload)</label>
                  <div class="flex items-center gap-2">
                    <UInput
                      v-model="provisionForm.logo_url"
                      placeholder="https://example.com/logo.png or upload below"
                      icon="i-lucide-image"
                      class="flex-1"
                    />
                    <input
                      ref="provisionFileInput"
                      type="file"
                      accept="image/png, image/jpeg, image/svg+xml, image/webp"
                      class="hidden"
                      @change="handleProvisionFileUpload"
                    >
                    <UButton
                      type="button"
                      size="sm"
                      color="primary"
                      variant="soft"
                      icon="i-lucide-upload"
                      @click="provisionFileInput?.click()"
                    >
                      Upload local
                    </UButton>
                    <UButton
                      v-if="provisionForm.logo_url"
                      type="button"
                      size="sm"
                      color="neutral"
                      variant="ghost"
                      icon="i-lucide-trash-2"
                      @click="provisionForm.logo_url = ''"
                    />
                  </div>
                </div>
              </div>
              <div>
                <label class="block text-caption font-medium text-default mb-2">Select Theme Preset</label>
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
                  <button
                    v-for="preset in THEME_PRESETS"
                    :key="preset.id"
                    type="button"
                    class="flex items-center gap-2 p-2 rounded-token-md border text-left transition-all"
                    :class="provisionForm.theme_preset === preset.id ? 'border-primary ring-1 ring-primary bg-primary-50 dark:bg-primary-950/30' : 'border-subtle hover:bg-surface-muted'"
                    @click="selectProvisionTheme(preset.id)"
                  >
                    <span class="w-4 h-4 rounded-full shrink-0 shadow-xs" :style="{ backgroundColor: preset.primaryColor }" />
                    <span class="text-caption font-medium truncate">{{ t(preset.nameKey) }}</span>
                  </button>
                </div>
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
    <UModal
      v-model:open="showEditClinic"
      title="Edit Clinic"
      description="Update clinic metadata, logo, and brand theme"
    >
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

            <!-- Branding: Logo URL & Theme Preset -->
            <div class="space-y-3 pt-2 border-t border-subtle">
              <p class="text-caption font-semibold text-default">Clinic Branding & Color Theme</p>
              
              <!-- Logo Preview & Input -->
              <div class="flex items-center gap-3">
                <div class="w-12 h-12 rounded-token-md border border-subtle bg-surface flex items-center justify-center overflow-hidden shrink-0 shadow-xs">
                  <img
                    v-if="editClinicForm.logo_url"
                    :src="editClinicForm.logo_url"
                    alt=""
                    class="w-full h-full object-contain p-0.5"
                  >
                  <UIcon v-else name="i-lucide-building" class="w-6 h-6 text-subtle" />
                </div>
                <div class="flex-1 space-y-1.5">
                  <label class="block text-caption font-medium text-default">Logo Image (URL or Upload)</label>
                  <div class="flex items-center gap-2">
                    <UInput
                      v-model="editClinicForm.logo_url"
                      placeholder="https://example.com/logo.png or upload below"
                      icon="i-lucide-image"
                      class="flex-1"
                    />
                    <input
                      ref="editFileInput"
                      type="file"
                      accept="image/png, image/jpeg, image/svg+xml, image/webp"
                      class="hidden"
                      @change="handleEditFileUpload"
                    >
                    <UButton
                      type="button"
                      size="sm"
                      color="primary"
                      variant="soft"
                      icon="i-lucide-upload"
                      @click="editFileInput?.click()"
                    >
                      Upload local
                    </UButton>
                    <UButton
                      v-if="editClinicForm.logo_url"
                      type="button"
                      size="sm"
                      color="neutral"
                      variant="ghost"
                      icon="i-lucide-trash-2"
                      @click="editClinicForm.logo_url = ''"
                    />
                  </div>
                </div>
              </div>

              <!-- Theme Presets Grid -->
              <div>
                <label class="block text-caption font-medium text-default mb-2">Theme Preset</label>
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
                  <button
                    v-for="preset in THEME_PRESETS"
                    :key="preset.id"
                    type="button"
                    class="flex items-center gap-2 p-2 rounded-token-md border text-left transition-all"
                    :class="editClinicForm.theme_preset === preset.id ? 'border-primary ring-1 ring-primary bg-primary-50 dark:bg-primary-950/30' : 'border-subtle hover:bg-surface-muted'"
                    @click="selectEditTheme(preset.id)"
                  >
                    <span class="w-4 h-4 rounded-full shrink-0 shadow-xs" :style="{ backgroundColor: preset.primaryColor }" />
                    <span class="text-caption font-medium truncate">{{ t(preset.nameKey) }}</span>
                  </button>
                </div>
              </div>

              <!-- Custom HEX input -->
              <div class="flex items-center gap-3 pt-1">
                <div class="w-8 h-8 rounded-token-md border border-subtle overflow-hidden shrink-0 shadow-xs cursor-pointer relative">
                  <input
                    type="color"
                    v-model="editClinicForm.primary_color"
                    class="absolute -top-3 -left-3 w-14 h-14 cursor-pointer border-0"
                  >
                </div>
                <div class="flex-1 max-w-xs">
                  <UInput
                    v-model="editClinicForm.primary_color"
                    placeholder="#0284C7"
                    icon="i-lucide-hash"
                  />
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
    <UModal
      v-model:open="showDeleteClinic"
      title="Delete Clinic"
      description="Permanently remove clinic tenant"
    >
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
    <UModal
      v-model:open="showConfirmGrant"
      title="Confirm Subscription Grant"
      description="Grant a new subscription plan to the selected clinic"
    >
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
