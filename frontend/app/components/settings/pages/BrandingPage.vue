<script setup lang="ts">
import { THEME_PRESETS, useClinicTheme } from '~/composables/useClinicTheme'

const { t } = useI18n()
const auth = useAuth()
const isSuperadmin = computed(() => {
  const c = auth.clinics.value?.[0]
  return c?.name === 'Platform Administration'
})
const canEdit = computed(() => isSuperadmin.value)

const theme = useClinicTheme()

// Local edit form state
const selectedPreset = ref<string>(theme.currentPreset.value || 'ocean_blue')
const customHex = ref<string>(theme.currentPrimaryColor.value || '#0284C7')
const logoUrl = ref<string>(theme.clinicLogo.value || '')
const isSaving = ref(false)
const uploadInputRef = ref<HTMLInputElement | null>(null)

// Sync with current clinic state on load or when clinic changes
watch(
  () => [theme.currentPreset.value, theme.currentPrimaryColor.value, theme.clinicLogo.value],
  ([preset, color, logo]) => {
    if (!theme.previewColor.value) {
      selectedPreset.value = preset || 'ocean_blue'
      customHex.value = color || '#0284C7'
      logoUrl.value = logo || ''
    }
  },
  { immediate: true }
)

const activeComputedColor = computed(() => {
  if (selectedPreset.value === 'custom') {
    return customHex.value
  }
  const preset = THEME_PRESETS.find(p => p.id === selectedPreset.value)
  return preset ? preset.primaryColor : customHex.value
})

const livePalette = computed(() => {
  return theme.generatePalette(activeComputedColor.value)
})

function selectPreset(presetId: string) {
  selectedPreset.value = presetId
  const preset = THEME_PRESETS.find(p => p.id === presetId)
  if (preset) {
    customHex.value = preset.primaryColor
    theme.previewTheme(preset.primaryColor)
  }
}

function onCustomColorInput(event: Event) {
  const target = event.target as HTMLInputElement
  selectedPreset.value = 'custom'
  customHex.value = target.value
  theme.previewTheme(target.value)
}

function onHexTextInput(val: string) {
  let clean = val.trim()
  if (!clean.startsWith('#')) {
    clean = '#' + clean
  }
  customHex.value = clean
  if (/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(clean)) {
    selectedPreset.value = 'custom'
    theme.previewTheme(clean)
  }
}

function handleFileUpload(event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  if (!file.type.startsWith('image/')) {
    alert(t('settings.branding.invalidImage'))
    return
  }

  const reader = new FileReader()
  reader.onload = (e) => {
    const result = e.target?.result as string
    if (result) {
      logoUrl.value = result
    }
  }
  reader.readAsDataURL(file)
}

function triggerFileInput() {
  uploadInputRef.value?.click()
}

function clearLogo() {
  logoUrl.value = ''
  if (uploadInputRef.value) uploadInputRef.value.value = ''
}

// Sample clinic logos for quick testing
const sampleLogos = [
  { name: 'Teeth Icon', url: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=128&auto=format&fit=crop&q=80' },
  { name: 'Dental Sparkle', url: 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=128&auto=format&fit=crop&q=80' },
  { name: 'Modern Cross', url: 'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?w=128&auto=format&fit=crop&q=80' }
]

function useSampleLogo(url: string) {
  logoUrl.value = url
}

async function handleSave() {
  if (!canEdit.value) return
  isSaving.value = true
  try {
    const success = await theme.saveBranding({
      logo_url: logoUrl.value.trim() || null,
      primary_color: activeComputedColor.value,
      theme_preset: selectedPreset.value
    })
    if (success) {
      theme.resetPreview()
    }
  } finally {
    isSaving.value = false
  }
}

function handleReset() {
  theme.resetPreview()
  selectedPreset.value = theme.currentPreset.value || 'ocean_blue'
  customHex.value = theme.currentPrimaryColor.value || '#0284C7'
  logoUrl.value = theme.clinicLogo.value || ''
}

const hasChanges = computed(() => {
  const currentLogo = theme.clinicLogo.value || ''
  const currentColor = (theme.currentPrimaryColor.value || '#0284C7').toUpperCase()
  const currentP = theme.currentPreset.value || 'ocean_blue'

  return (
    logoUrl.value.trim() !== currentLogo.trim()
    || activeComputedColor.value.toUpperCase() !== currentColor
    || selectedPreset.value !== currentP
  )
})

onUnmounted(() => {
  // Reset any temporary preview when navigating away without saving
  theme.resetPreview()
})
</script>

<template>
  <div class="space-y-8 max-w-5xl">
    <!-- Header info banner -->
    <div class="p-5 sm:p-6 rounded-[var(--radius-xl)] bg-surface flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-h2 font-semibold text-default">
          {{ t('settings.branding.title') }}
        </h2>
        <p class="text-body text-muted mt-0.5">
          {{ t('settings.branding.description') }}
        </p>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-xs px-2.5 py-1 rounded-full font-medium bg-[var(--color-primary-soft)] text-[var(--color-primary-soft-text)] border border-[var(--color-primary)]/20 flex items-center gap-1.5">
          <span
            class="w-2 h-2 rounded-full"
            :style="{ backgroundColor: activeComputedColor }"
          />
          {{ t('settings.branding.liveTheme') }}
        </span>
      </div>
    </div>

    <!-- Managed by Platform Admin Notice -->
    <div
      v-if="!isSuperadmin"
      class="p-4 rounded-[var(--radius-xl)] bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-900/40 flex items-start gap-3 text-amber-800 dark:text-amber-300"
    >
      <UIcon
        name="i-lucide-shield-alert"
        class="w-5 h-5 shrink-0 mt-0.5 text-amber-600 dark:text-amber-400"
      />
      <div class="text-caption">
        <p class="font-semibold text-default">
          {{ t('settings.branding.managedByAdmin') }}
        </p>
        <p class="mt-0.5 text-muted">
          {{ t('settings.branding.managedByAdminDesc') }}
        </p>
      </div>
    </div>
    <div
      v-else
      class="p-4 rounded-token-lg bg-primary-50 dark:bg-primary-950/30 border border-primary/20 flex items-center justify-between gap-3 text-caption"
    >
      <div class="flex items-center gap-2">
        <UIcon
          name="i-lucide-shield-check"
          class="w-5 h-5 text-primary"
        />
        <span class="font-medium text-default">Platform Administrator Mode: You can configure clinic branding.</span>
      </div>
      <UButton
        to="/admin/clinics"
        size="xs"
        color="primary"
        variant="soft"
        icon="i-lucide-arrow-right"
        trailing
      >
        {{ t('settings.branding.goToAdminClinics') }}
      </UButton>
    </div>

    <!-- Main Grid: Controls + Live Preview -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">
      <!-- Left Column: Controls (7 cols) -->
      <div class="lg:col-span-7 space-y-6">
        <!-- 1. Clinic Logo Section -->
        <UCard class="!rounded-[var(--radius-xl)]">
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon
                name="i-lucide-image"
                class="w-5 h-5 text-primary"
              />
              <h3 class="text-h3 font-semibold text-default">
                {{ t('settings.branding.logoSectionTitle') }}
              </h3>
            </div>
            <p class="text-caption text-muted mt-1">
              {{ t('settings.branding.logoSectionDesc') }}
            </p>
          </template>

          <div class="space-y-4">
            <!-- Logo Preview Card -->
            <div class="flex items-center gap-4 p-4 rounded-token-md bg-surface-muted border border-subtle">
              <div class="relative w-16 h-16 rounded-token-md border border-subtle bg-white dark:bg-zinc-900 flex items-center justify-center overflow-hidden shrink-0 shadow-xs">
                <img
                  v-if="logoUrl"
                  :src="logoUrl"
                  alt="Clinic Logo Preview"
                  class="w-full h-full object-contain p-1"
                >
                <div
                  v-else
                  class="flex flex-col items-center justify-center text-muted"
                >
                  <UIcon
                    name="i-lucide-building"
                    class="w-7 h-7 text-subtle"
                  />
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-body font-medium text-default truncate">
                  {{ logoUrl ? t('settings.branding.customLogoSet') : t('settings.branding.defaultLogoInUse') }}
                </p>
                <p class="text-caption text-muted mt-0.5">
                  {{ t('settings.branding.logoRecommendation') }}
                </p>
                <div class="flex items-center gap-2 mt-2">
                  <input
                    ref="uploadInputRef"
                    type="file"
                    accept="image/png, image/jpeg, image/svg+xml, image/webp"
                    class="hidden"
                    @change="handleFileUpload"
                  >
                  <UButton
                    size="xs"
                    color="primary"
                    variant="soft"
                    icon="i-lucide-upload"
                    :disabled="!canEdit"
                    @click="triggerFileInput"
                  >
                    {{ t('settings.branding.uploadImage') }}
                  </UButton>
                  <UButton
                    v-if="logoUrl"
                    size="xs"
                    color="neutral"
                    variant="ghost"
                    icon="i-lucide-trash-2"
                    :disabled="!canEdit"
                    @click="clearLogo"
                  >
                    {{ t('common.remove') }}
                  </UButton>
                </div>
              </div>
            </div>

            <!-- Logo URL input -->
            <div>
              <label class="block text-caption font-medium text-default mb-1.5">
                {{ t('settings.branding.logoUrlLabel') }}
              </label>
              <UInput
                v-model="logoUrl"
                type="url"
                icon="i-lucide-link"
                placeholder="https://example.com/logo.png"
                :disabled="!canEdit"
              />
            </div>

            <!-- Preset Samples -->
            <div>
              <span class="text-caption text-muted block mb-2">{{ t('settings.branding.orUseSample') }}</span>
              <div class="flex flex-wrap gap-2">
                <button
                  v-for="sample in sampleLogos"
                  :key="sample.name"
                  type="button"
                  class="flex items-center gap-1.5 px-2.5 py-1 rounded-token-md border border-subtle bg-surface hover:bg-surface-muted text-caption text-default transition-colors"
                  :disabled="!canEdit"
                  @click="useSampleLogo(sample.url)"
                >
                  <img
                    :src="sample.url"
                    alt=""
                    class="w-4 h-4 rounded-full object-cover"
                  >
                  <span>{{ sample.name }}</span>
                </button>
              </div>
            </div>
          </div>
        </UCard>

        <!-- 2. Theme Presets Section -->
        <UCard class="!rounded-[var(--radius-xl)]">
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon
                name="i-lucide-palette"
                class="w-5 h-5 text-primary"
              />
              <h3 class="text-h3 font-semibold text-default">
                {{ t('settings.branding.themeSectionTitle') }}
              </h3>
            </div>
            <p class="text-caption text-muted mt-1">
              {{ t('settings.branding.themeSectionDesc') }}
            </p>
          </template>

          <div class="space-y-6">
            <!-- Preset Swatches Grid -->
            <div>
              <label class="block text-caption font-medium text-default mb-3">
                {{ t('settings.branding.curatedPresets') }}
              </label>
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <button
                  v-for="preset in THEME_PRESETS"
                  :key="preset.id"
                  type="button"
                  class="group relative flex flex-col items-start p-3 rounded-token-lg border transition-all text-left"
                  :class="[
                    selectedPreset === preset.id
                      ? 'border-primary bg-[var(--color-primary-soft)] ring-2 ring-[var(--color-primary)] ring-offset-1'
                      : 'border-subtle bg-surface hover:border-default hover:bg-surface-muted'
                  ]"
                  :disabled="!canEdit"
                  @click="selectPreset(preset.id)"
                >
                  <div class="flex items-center justify-between w-full mb-2">
                    <div
                      class="w-6 h-6 rounded-full shadow-xs border border-white/40 flex items-center justify-center text-white"
                      :style="{ backgroundColor: preset.primaryColor }"
                    >
                      <UIcon
                        v-if="selectedPreset === preset.id"
                        name="i-lucide-check"
                        class="w-3.5 h-3.5"
                      />
                    </div>
                    <span class="text-[10px] font-mono text-muted uppercase">
                      {{ preset.primaryColor }}
                    </span>
                  </div>
                  <span class="text-caption font-medium text-default truncate w-full">
                    {{ t(preset.nameKey) }}
                  </span>
                  <span class="text-[11px] text-muted truncate w-full mt-0.5">
                    {{ t(preset.descriptionKey) }}
                  </span>
                </button>
              </div>
            </div>

            <!-- Custom HEX Color Picker -->
            <div class="pt-4 border-t border-subtle">
              <label class="block text-caption font-medium text-default mb-2">
                {{ t('settings.branding.customColorOption') }}
              </label>
              <div class="flex items-center gap-3">
                <div class="relative w-11 h-11 rounded-token-md border border-subtle overflow-hidden shrink-0 shadow-xs cursor-pointer">
                  <input
                    type="color"
                    :value="activeComputedColor"
                    class="absolute -top-4 -left-4 w-20 h-20 cursor-pointer border-0"
                    :disabled="!canEdit"
                    @input="onCustomColorInput"
                  >
                </div>
                <div class="flex-1 max-w-xs">
                  <UInput
                    :model-value="customHex"
                    placeholder="#0284C7"
                    icon="i-lucide-hash"
                    :disabled="!canEdit"
                    @update:model-value="onHexTextInput"
                  />
                </div>
                <div class="text-caption text-muted">
                  <span
                    v-if="selectedPreset === 'custom'"
                    class="text-primary font-medium"
                  >
                    ✓ {{ t('settings.branding.customSelected') }}
                  </span>
                  <span v-else>
                    {{ t('settings.branding.pickCustomColor') }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Live 11-step Palette Visualizer -->
            <div class="pt-4 border-t border-subtle">
              <span class="text-caption text-muted block mb-2">{{ t('settings.branding.computedPalette') }}</span>
              <div class="grid grid-cols-11 gap-1 p-2 rounded-token-md bg-surface-muted border border-subtle">
                <div
                  v-for="(hex, step) in livePalette"
                  :key="step"
                  class="flex flex-col items-center gap-1 group/swatch"
                  :title="`${step}: ${hex}`"
                >
                  <div
                    class="w-full h-8 rounded-sm shadow-xs border border-black/5 group-hover/swatch:scale-105 transition-transform"
                    :style="{ backgroundColor: hex }"
                  />
                  <span class="text-[9px] font-mono text-muted">{{ step }}</span>
                </div>
              </div>
            </div>
          </div>
        </UCard>
      </div>

      <!-- Right Column: Live Mockup Card (5 cols) -->
      <div class="lg:col-span-5 space-y-6">
        <UCard class="!rounded-[var(--radius-xl)] sticky top-6 bg-surface">
          <template #header>
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <UIcon
                  name="i-lucide-sparkles"
                  class="w-5 h-5 text-primary"
                />
                <h3 class="text-h3 font-semibold text-default">
                  {{ t('settings.branding.previewTitle') }}
                </h3>
              </div>
              <UBadge
                color="primary"
                variant="soft"
                size="xs"
              >
                {{ t('settings.branding.livePreview') }}
              </UBadge>
            </div>
            <p class="text-caption text-muted mt-1">
              {{ t('settings.branding.previewDesc') }}
            </p>
          </template>

          <div class="space-y-5">
            <!-- Simulated App Top Header / Sidebar Mini Preview -->
            <div class="rounded-token-lg border border-subtle overflow-hidden bg-canvas shadow-xs">
              <!-- Top bar -->
              <div class="px-3 py-2.5 bg-surface border-b border-subtle flex items-center justify-between">
                <div class="flex items-center gap-2">
                  <img
                    v-if="logoUrl"
                    :src="logoUrl"
                    alt=""
                    class="w-6 h-6 object-contain rounded-sm"
                  >
                  <img
                    v-else
                    src="/logo-icon.svg"
                    alt=""
                    class="w-6 h-6 shrink-0"
                  >
                  <span class="text-caption font-semibold text-default font-serif">
                    {{ t('app.tagline') }}
                  </span>
                </div>
                <div class="flex items-center gap-1.5">
                  <div
                    class="w-2.5 h-2.5 rounded-full"
                    :style="{ backgroundColor: activeComputedColor }"
                  />
                  <span class="text-[11px] font-medium text-muted">Online</span>
                </div>
              </div>

              <!-- Main Simulated Content -->
              <div class="p-4 space-y-4 bg-surface-muted">
                <!-- Mini Tab Navigation -->
                <div class="flex items-center gap-2 p-1 bg-surface rounded-token-md border border-subtle">
                  <div class="px-2.5 py-1 text-[11px] font-semibold rounded-token-sm bg-[var(--color-primary-soft)] text-[var(--color-primary-soft-text)]">
                    Dashboard
                  </div>
                  <div class="px-2.5 py-1 text-[11px] font-medium text-muted">
                    Appointments
                  </div>
                  <div class="px-2.5 py-1 text-[11px] font-medium text-muted">
                    Invoices
                  </div>
                </div>

                <!-- Simulated Primary Card with UI elements -->
                <div class="p-3.5 rounded-token-md bg-surface border border-subtle space-y-3">
                  <div class="flex items-center justify-between">
                    <div>
                      <p class="text-caption font-semibold text-default">
                        Dr. Pushpendra Dental Care
                      </p>
                      <p class="text-[11px] text-muted">
                        Next appointment in 15 mins
                      </p>
                    </div>
                    <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-[var(--color-primary-soft)] text-[var(--color-primary-soft-text)] border border-[var(--color-primary)]/20">
                      Confirmed
                    </span>
                  </div>

                  <!-- Action Buttons -->
                  <div class="flex items-center gap-2 pt-1">
                    <button
                      type="button"
                      class="flex-1 px-3 py-1.5 rounded-token-md text-xs font-semibold text-white shadow-xs transition-opacity hover:opacity-90 flex items-center justify-center gap-1.5"
                      :style="{ backgroundColor: activeComputedColor }"
                    >
                      <UIcon
                        name="i-lucide-calendar-plus"
                        class="w-3.5 h-3.5"
                      />
                      <span>Book Slot</span>
                    </button>
                    <button
                      type="button"
                      class="px-3 py-1.5 rounded-token-md text-xs font-medium border border-subtle bg-surface hover:bg-surface-muted text-default"
                    >
                      Details
                    </button>
                  </div>
                </div>

                <!-- Simulated Form Input with Focus Ring -->
                <div class="space-y-1">
                  <label class="text-[11px] font-medium text-muted">Quick Search Patient</label>
                  <div class="flex items-center gap-2 px-2.5 py-1.5 rounded-token-md bg-surface border border-[var(--color-primary)] ring-1 ring-[var(--color-primary)]">
                    <UIcon
                      name="i-lucide-search"
                      class="w-3.5 h-3.5 text-primary"
                    />
                    <span class="text-xs text-default">Kavita Rao (PT-0010)...</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div class="pt-2 flex flex-col gap-2">
              <template v-if="isSuperadmin">
                <UButton
                  block
                  size="md"
                  color="primary"
                  variant="solid"
                  icon="i-lucide-check"
                  :loading="isSaving"
                  :disabled="!hasChanges"
                  @click="handleSave"
                >
                  {{ t('settings.branding.saveChanges') }}
                </UButton>
                <UButton
                  v-if="hasChanges"
                  block
                  size="sm"
                  color="neutral"
                  variant="ghost"
                  icon="i-lucide-rotate-ccw"
                  :disabled="isSaving"
                  @click="handleReset"
                >
                  {{ t('settings.branding.resetChanges') }}
                </UButton>
              </template>
              <div
                v-else
                class="p-3 text-center rounded-token-md bg-surface-muted border border-subtle text-caption text-muted"
              >
                <UIcon
                  name="i-lucide-lock"
                  class="w-4 h-4 inline-block mr-1 text-subtle"
                />
                {{ t('settings.branding.managedByAdmin') }}
              </div>
            </div>
          </div>
        </UCard>
      </div>
    </div>
  </div>
</template>
