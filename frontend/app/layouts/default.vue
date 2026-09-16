<script setup lang="ts">
import { PERMISSIONS } from '~/config/permissions'
import type { NavigationItem } from '~/types'

const { t } = useI18n()
const auth = useAuth()
const clinic = useClinic()
const theme = useClinicTheme()
const { can } = usePermissions()
const { navigationItems, ensureLoaded } = useModules()
const { init: initDensity } = useDensity()
const route = useRoute()
const runtimeConfig = useRuntimeConfig()
const appVersion = computed(() => String(runtimeConfig.public.appVersion || '2.0.0'))
const clinicLogoFailed = ref(false)
const clinicLogoSrc = computed(() => {
  if (clinicLogoFailed.value) return ''
  return String(unref(theme.clinicLogo) || '')
})

watch(
  () => String(unref(theme.clinicLogo) || ''),
  () => {
    clinicLogoFailed.value = false
  }
)

type NavGroupId = 'home' | 'clinic' | 'finance' | 'other'

interface NavSection {
  id: Exclude<NavGroupId, 'home'>
  label: string
  items: NavigationItem[]
}

// Pull the backend-driven nav on mount + on every route change, so
// sidebar reflects module installs/upgrades without a full reload.
// ensureLoaded enforces a 60s freshness window internally.
// Await on server so modules:active lands in the SSR payload — otherwise
// the client hydrates with active=null, then flips branches once the
// fetch resolves, briefly filtering the sidebar down to just Inicio.
if (import.meta.server) {
  await ensureLoaded()
} else {
  ensureLoaded()
}

watch(
  () => auth.accessToken.value,
  (token) => {
    if (token) ensureLoaded(true)
  }
)

watch(
  () => route.path,
  () => {
    ensureLoaded()
    // Close mobile drawer on any navigation
    if (mobileNavOpen.value) mobileNavOpen.value = false
    searchQuery.value = ''
    searchOpen.value = false
  }
)

// Mobile drawer state (ephemeral — does not persist)
const mobileNavOpen = ref(false)
const searchQuery = ref('')
const searchOpen = ref(false)

// Subscription days remaining
const daysRemaining = computed(() => {
  const currentClinic = auth.clinics.value?.[0]
  if (!currentClinic?.subscription_active || !currentClinic?.subscription_end_date) return null
  const end = new Date(currentClinic.subscription_end_date)
  const now = new Date()
  const diffTime = end.getTime() - now.getTime()
  return Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)))
})

const displayName = computed(() => {
  const user = auth.user.value
  if (!user) return ''
  return `${user.first_name} ${user.last_name}`.trim()
})

const userRoleLabel = computed(() => {
  const role = auth.clinics.value?.[0]?.role
  if (!role) return ''
  return t(`settings.roles.${role}`, role)
})

const displayClinicName = computed(() => {
  const fromMembership = String(auth.clinics.value?.[0]?.name || '').trim()
  if (fromMembership) return fromMembership
  const fromClinic = String(unref(clinic.clinicName) || '').trim()
  if (fromClinic) return fromClinic
  return t('nav.clinicFallback')
})

onMounted(() => {
  initDensity()
})

async function handleLogout() {
  await auth.logout()
}

const settingsItem = computed(() => navigationItems.value.find(i => i.to === '/settings'))
const adminItem = computed(() => navigationItems.value.find(i => i.to === '/admin'))
const mainNavItems = computed(() =>
  navigationItems.value.filter(i => i.to !== '/settings' && i.to !== '/admin')
)

function navGroupForPath(to: string): NavGroupId {
  const segment = to.split('/').filter(Boolean)[0] ?? ''
  if (!segment) return 'home'
  if (['patients', 'appointments', 'recalls', 'treatment-plans'].includes(segment)) return 'clinic'
  if (['budgets', 'invoices', 'payments'].includes(segment)) return 'finance'
  return 'other'
}

const homeNavItems = computed(() =>
  mainNavItems.value.filter(item => navGroupForPath(item.to) === 'home')
)

const navSections = computed<NavSection[]>(() => {
  const buckets: Record<NavSection['id'], NavigationItem[]> = {
    clinic: [],
    finance: [],
    other: []
  }
  for (const item of mainNavItems.value) {
    const group = navGroupForPath(item.to)
    if (group === 'home') continue
    buckets[group].push(item)
  }
  return (['clinic', 'finance', 'other'] as const)
    .filter(id => buckets[id].length > 0)
    .map(id => ({
      id,
      label: t(`nav.groups.${id}`),
      items: buckets[id]
    }))
})

const pageTitle = computed(() => {
  const match = navigationItems.value.find(item => isActive(item.to))
  return match?.label || t('app.name')
})

const searchResults = computed(() => {
  const query = searchQuery.value.trim().toLowerCase()
  if (!query) return mainNavItems.value
  return mainNavItems.value.filter(item => item.label.toLowerCase().includes(query))
})

const canWritePatients = computed(() => can(PERMISSIONS.patients.write))
const canWriteAppointments = computed(() => can(PERMISSIONS.appointments.write))
const showQuickAdd = computed(() => canWritePatients.value || canWriteAppointments.value)

const quickAddItems = computed(() => {
  const items = []
  if (canWritePatients.value) {
    items.push({
      label: t('dashboard.quickActions.newPatient'),
      icon: 'i-lucide-user-plus',
      onSelect: () => navigateTo('/patients?new=1')
    })
  }
  if (canWriteAppointments.value) {
    items.push({
      label: t('dashboard.quickActions.newAppointment'),
      icon: 'i-lucide-calendar-plus',
      onSelect: () => navigateTo('/appointments?new=1')
    })
  }
  return items.length ? [items] : []
})

const userMenuItems = computed(() => {
  const settings = settingsItem.value
    ? [{
        label: settingsItem.value.label,
        icon: settingsItem.value.icon,
        onSelect: () => navigateTo(settingsItem.value!.to)
      }]
    : []
  const session = [{
    label: t('auth.logout'),
    icon: 'i-lucide-log-out',
    onSelect: () => handleLogout()
  }]
  return [settings, session].filter(group => group.length > 0)
})

const navLinkClass = (to: string) => [
  'group flex items-center gap-3 px-3 py-2 rounded-token-xl text-ui transition-colors',
  isActive(to)
    ? 'bg-[var(--color-primary-soft)] text-[var(--color-primary-soft-text)]'
    : 'text-muted hover:bg-canvas hover:text-default'
]

// Check if nav item is active
function isActive(to: string): boolean {
  if (to === '/') {
    return route.path === '/'
  }
  if (route.path === to) {
    return true
  }
  if (route.path.startsWith(to + '/')) {
    const moreSpecificNavItem = navigationItems.value.find(item =>
      item.to !== to
      && item.to.length > to.length
      && route.path.startsWith(item.to)
    )
    return !moreSpecificNavItem
  }
  return false
}

function goToSearchResult(item: NavigationItem) {
  searchOpen.value = false
  searchQuery.value = ''
  return navigateTo(item.to)
}

function submitSearch() {
  const first = searchResults.value[0]
  if (first) goToSearchResult(first)
}

function onSearchFocus() {
  searchOpen.value = true
}

function onSearchBlur() {
  window.setTimeout(() => {
    searchOpen.value = false
  }, 120)
}
</script>

<template>
  <div class="h-svh overflow-hidden bg-canvas">
    <div class="flex h-full overflow-hidden bg-surface">
      <!-- Desktop/tablet sidebar — fixed width, pinned while the page scrolls -->
      <aside class="hidden md:flex relative z-20 w-64 shrink-0 flex-col bg-surface">
        <!-- Clinic identity only — never the product name -->
        <div class="px-3 pt-4 pb-3 shrink-0">
          <NuxtLink
            to="/"
            class="flex items-center gap-2 rounded-token-pill bg-canvas px-2.5 py-1.5 min-w-0"
            :aria-label="displayClinicName"
          >
            <div class="flex items-center justify-center w-7 h-7 rounded-full bg-surface shrink-0 overflow-hidden">
              <img
                v-if="clinicLogoSrc"
                :src="clinicLogoSrc"
                alt=""
                width="28"
                height="28"
                class="w-7 h-7 object-contain"
                @error="clinicLogoFailed = true"
              >
              <UIcon
                v-else
                name="i-lucide-building-2"
                class="w-3.5 h-3.5 text-muted"
              />
            </div>
            <span class="text-ui font-medium text-default truncate min-w-0">
              {{ displayClinicName }}
            </span>
          </NuxtLink>
        </div>

        <!-- Navigation -->
        <nav
          class="flex-1 min-h-0 px-2 pb-3 space-y-4 overflow-y-auto"
          :aria-label="t('nav.menu')"
        >
          <div
            v-if="homeNavItems.length"
            class="space-y-1"
          >
            <NuxtLink
              v-for="item in homeNavItems"
              :key="item.to"
              :to="item.to"
              :class="navLinkClass(item.to)"
            >
              <UIcon
                :name="item.icon"
                class="w-[18px] h-[18px] shrink-0"
              />
              <span class="truncate">
                {{ item.label }}
              </span>
            </NuxtLink>
          </div>

          <div
            v-for="section in navSections"
            :key="section.id"
            class="space-y-1"
          >
            <p class="px-3 pt-1 pb-1 text-[11px] font-semibold uppercase tracking-[0.12em] text-subtle">
              {{ section.label }}
            </p>
            <NuxtLink
              v-for="item in section.items"
              :key="item.to"
              :to="item.to"
              :class="navLinkClass(item.to)"
            >
              <UIcon
                :name="item.icon"
                class="w-[18px] h-[18px] shrink-0"
              />
              <span class="truncate">
                {{ item.label }}
              </span>
            </NuxtLink>
          </div>
        </nav>

        <div class="shrink-0 mt-auto px-3 py-2.5 border-t border-subtle">
          <p class="text-[11px] font-medium text-muted truncate leading-tight">
            {{ t('app.name') }}
          </p>
          <p class="text-[10px] text-subtle tabular-nums leading-tight">
            {{ t('app.version', { version: appVersion }) }}
          </p>
        </div>
      </aside>

      <!-- Mobile drawer nav -->
      <USlideover
        v-model:open="mobileNavOpen"
        side="left"
        :ui="{ content: 'w-72 max-w-[80vw] bg-surface', header: 'hidden' }"
      >
        <template #content>
          <div class="flex flex-col h-full">
            <div class="flex items-center justify-between gap-2 px-3 pt-4 pb-3 shrink-0">
              <NuxtLink
                to="/"
                class="flex items-center gap-2 rounded-token-pill bg-canvas px-2.5 py-1.5 min-w-0 flex-1"
                :aria-label="displayClinicName"
              >
                <div class="flex items-center justify-center w-7 h-7 rounded-full bg-surface shrink-0 overflow-hidden">
                  <img
                    v-if="clinicLogoSrc"
                    :src="clinicLogoSrc"
                    alt=""
                    width="28"
                    height="28"
                    class="w-7 h-7 object-contain"
                    @error="clinicLogoFailed = true"
                  >
                  <UIcon
                    v-else
                    name="i-lucide-building-2"
                    class="w-3.5 h-3.5 text-muted"
                  />
                </div>
                <span class="text-ui font-medium text-default truncate min-w-0">
                  {{ displayClinicName }}
                </span>
              </NuxtLink>
              <UButton
                variant="ghost"
                color="neutral"
                size="sm"
                icon="i-lucide-x"
                :aria-label="t('nav.close')"
                @click="() => { mobileNavOpen = false }"
              />
            </div>

            <nav
              class="flex-1 px-2 pb-3 space-y-4 overflow-y-auto"
              :aria-label="t('nav.menu')"
            >
              <div
                v-if="homeNavItems.length"
                class="space-y-1"
              >
                <NuxtLink
                  v-for="item in homeNavItems"
                  :key="item.to"
                  :to="item.to"
                  :class="[...navLinkClass(item.to), 'py-3']"
                >
                  <UIcon
                    :name="item.icon"
                    class="w-5 h-5 shrink-0"
                  />
                  <span class="truncate">{{ item.label }}</span>
                </NuxtLink>
              </div>

              <div
                v-for="section in navSections"
                :key="section.id"
                class="space-y-1"
              >
                <p class="px-3 pt-1 pb-1 text-[11px] font-semibold uppercase tracking-[0.12em] text-subtle">
                  {{ section.label }}
                </p>
                <NuxtLink
                  v-for="item in section.items"
                  :key="item.to"
                  :to="item.to"
                  :class="[...navLinkClass(item.to), 'py-3']"
                >
                  <UIcon
                    :name="item.icon"
                    class="w-5 h-5 shrink-0"
                  />
                  <span class="truncate">{{ item.label }}</span>
                </NuxtLink>
              </div>
            </nav>

            <div class="shrink-0 mt-auto px-3 py-2.5 border-t border-subtle">
              <p class="text-[11px] font-medium text-muted truncate leading-tight">
                {{ t('app.name') }}
              </p>
              <p class="text-[10px] text-subtle tabular-nums leading-tight">
                {{ t('app.version', { version: appVersion }) }}
              </p>
            </div>
          </div>
        </template>
      </USlideover>

      <!-- Main column -->
      <div class="flex-1 flex flex-col min-w-0 min-h-0 overflow-hidden bg-surface">
        <DemoBanner />

        <!-- Header -->
        <header class="shrink-0 z-40 flex items-center gap-2 sm:gap-3 h-16 px-3 sm:px-5 bg-surface">
          <!-- Mobile hamburger -->
          <UButton
            class="md:hidden rounded-full"
            variant="ghost"
            color="neutral"
            size="sm"
            icon="i-lucide-menu"
            :aria-label="t('nav.openMenu')"
            @click="() => { mobileNavOpen = true }"
          />

          <p class="text-h2 text-default truncate min-w-0">
            {{ pageTitle }}
          </p>

          <div class="flex-1 min-w-0 max-w-xl mx-auto relative">
            <div class="relative">
              <UIcon
                name="i-lucide-search"
                class="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-subtle"
              />
              <input
                v-model="searchQuery"
                type="search"
                class="w-full h-10 rounded-token-pill bg-canvas text-ui text-default placeholder:text-subtle pl-9 pr-4 outline-none ring-1 ring-transparent focus:ring-[var(--color-border)]"
                :placeholder="t('nav.searchPlaceholder')"
                :aria-label="t('nav.searchPlaceholder')"
                autocomplete="off"
                @focus="onSearchFocus"
                @blur="onSearchBlur"
                @keydown.enter.prevent="submitSearch"
              >
            </div>
            <div
              v-if="searchOpen && searchResults.length"
              class="absolute left-0 right-0 mt-2 py-1 bg-surface rounded-token-xl shadow-token-lg ring-1 ring-[var(--color-border-subtle)] z-50 max-h-72 overflow-y-auto"
            >
              <button
                v-for="item in searchResults"
                :key="item.to"
                type="button"
                class="flex w-full items-center gap-2.5 px-3 py-2 text-left text-ui text-default hover:bg-canvas"
                @mousedown.prevent="goToSearchResult(item)"
              >
                <UIcon
                  :name="item.icon"
                  class="w-4 h-4 text-muted shrink-0"
                />
                <span class="truncate">{{ item.label }}</span>
              </button>
            </div>
          </div>

          <!-- Right actions -->
          <div class="flex items-center gap-1 shrink-0">
            <UDropdownMenu
              v-if="showQuickAdd"
              :items="quickAddItems"
            >
              <UButton
                color="primary"
                variant="solid"
                size="sm"
                icon="i-lucide-plus"
                class="rounded-full"
                :aria-label="t('nav.quickAdd')"
              />
            </UDropdownMenu>

            <HelpButton />
            <NuxtLink
              v-if="adminItem"
              :to="adminItem.to"
              :title="t('nav.saas_admin')"
              :aria-label="t('nav.saas_admin')"
              class="hidden sm:inline-flex items-center justify-center w-9 h-9 rounded-full transition-colors"
              :class="[
                isActive(adminItem.to)
                  ? 'bg-[var(--color-primary-soft)] text-[var(--color-primary-soft-text)]'
                  : 'text-muted hover:bg-canvas hover:text-default'
              ]"
            >
              <UIcon
                :name="adminItem.icon"
                class="w-[18px] h-[18px]"
              />
            </NuxtLink>
            <DensityToggle />
            <UColorModeButton class="rounded-full" />

            <NuxtLink
              v-if="settingsItem"
              :to="settingsItem.to"
              :title="settingsItem.label"
              :aria-label="settingsItem.label"
              class="hidden sm:inline-flex items-center justify-center w-9 h-9 rounded-full transition-colors"
              :class="[
                isActive(settingsItem.to)
                  ? 'bg-[var(--color-primary-soft)] text-[var(--color-primary-soft-text)]'
                  : 'text-muted hover:bg-canvas hover:text-default'
              ]"
            >
              <UIcon
                :name="settingsItem.icon"
                class="w-[18px] h-[18px]"
              />
            </NuxtLink>

            <UDropdownMenu
              v-if="auth.user.value"
              :items="userMenuItems"
            >
              <button
                type="button"
                class="flex items-center gap-2 pl-1 pr-1.5 py-1 rounded-token-pill hover:bg-canvas transition-colors min-w-0"
                :title="daysRemaining !== null ? t('nav.daysRemaining', { n: daysRemaining }) : undefined"
              >
                <UAvatar
                  :alt="displayName"
                  size="sm"
                  class="shrink-0"
                />
                <span class="hidden lg:flex flex-col items-start min-w-0 max-w-[9.5rem]">
                  <span class="text-ui text-default truncate w-full leading-tight">
                    {{ displayName }}
                  </span>
                  <span
                    v-if="userRoleLabel"
                    class="text-caption text-subtle truncate w-full leading-tight"
                  >
                    {{ userRoleLabel }}
                  </span>
                  <span
                    v-else-if="daysRemaining !== null"
                    class="text-caption text-subtle truncate w-full leading-tight"
                  >
                    {{ t('nav.daysRemaining', { n: daysRemaining }) }}
                  </span>
                </span>
                <UIcon
                  name="i-lucide-chevron-down"
                  class="hidden lg:block w-4 h-4 text-subtle shrink-0"
                />
              </button>
            </UDropdownMenu>
          </div>
        </header>

        <!-- Page content -->
        <main class="flex-1 min-h-0 p-3 min-w-0 overflow-y-auto overflow-x-hidden bg-canvas">
          <!--
            Global banner slot for compliance modules (Verifactu rejected
            alerts, certificate expiry warnings, etc.). Modules register
            their banners via `useModuleSlots`; the layout knows nothing
            about them.
          -->
          <ModuleSlot
            name="app.banners"
            :ctx="{}"
          />
          <slot />
        </main>

        <!--
          Global overlay slot for agent surfaces (the copilot drawer, and
          future voice). Registered components teleport to <body>; nothing
          renders inline here. The layout knows nothing about them.
        -->
        <ModuleSlot
          name="app.overlays"
          :ctx="{}"
        />
      </div>
    </div>
  </div>
</template>
