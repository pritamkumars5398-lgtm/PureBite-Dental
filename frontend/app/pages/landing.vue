<script setup lang="ts">
definePageMeta({
  layout: false
})

const { t, locale } = useI18n()
const { currentLocale, availableLocales, changeLocale } = useLocale()
const toast = useToast()
const config = useRuntimeConfig()

const formState = reactive({
  contact_name: '',
  clinic_name: '',
  phone: '',
  email: '',
  expected_users: null as number | null,
  message: ''
})

const isSubmitting = ref(false)
const isSuccess = ref(false)

interface PublicPricingPlan {
  id: string
  name: string
  duration_months: number
  price: number
}
const pricingPlans = ref<PublicPricingPlan[]>([])

function formatPlanPrice(price: number): string {
  try {
    return new Intl.NumberFormat(locale.value === 'es' ? 'es-ES' : 'en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0
    }).format(price)
  } catch {
    return `₹${price}`
  }
}

function onViewportChange() {
  if (import.meta.client && window.innerWidth > 1100) {
    navOpen.value = false
  }
}

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape') {
    navOpen.value = false
  }
}

onMounted(async () => {
  window.addEventListener('resize', onViewportChange)
  window.addEventListener('keydown', onKeydown)
  try {
    const runtime = useRuntimeConfig()
    pricingPlans.value = await $fetch<PublicPricingPlan[]>('/api/v1/saas/plans', {
      baseURL: runtime.public.apiBaseUrl
    })
  } catch {
    pricingPlans.value = []
  }
})

onBeforeUnmount(() => {
  if (!import.meta.client) {
    return
  }
  window.removeEventListener('resize', onViewportChange)
  window.removeEventListener('keydown', onKeydown)
})

async function submitLead() {
  if (!formState.contact_name || !formState.clinic_name || !formState.email) {
    toast.add({
      title: t('landing.toast.missingTitle'),
      description: t('landing.toast.missingBody'),
      color: 'error'
    })
    return
  }

  isSubmitting.value = true
  try {
    await $fetch('/api/v1/saas/leads', {
      method: 'POST',
      baseURL: config.public.apiBaseUrl,
      body: formState
    })
    isSuccess.value = true
    toast.add({
      title: t('landing.toast.sentTitle'),
      description: t('landing.toast.sentBody'),
      color: 'success'
    })
  } catch (err: unknown) {
    const fetchError = err as { data?: { message?: string, detail?: string | Array<{ msg: string }> } }
    let errorMessage = t('landing.toast.failFallback')

    if (fetchError.data?.detail) {
      if (Array.isArray(fetchError.data.detail)) {
        errorMessage = fetchError.data.detail.map(d => d.msg).join(', ')
      } else if (typeof fetchError.data.detail === 'string') {
        errorMessage = fetchError.data.detail
      }
    } else if (fetchError.data?.message) {
      errorMessage = fetchError.data.message
    }

    toast.add({
      title: t('landing.toast.failTitle'),
      description: errorMessage,
      color: 'error'
    })
  } finally {
    isSubmitting.value = false
  }
}

const features = [
  { id: 'records', nameKey: 'landing.features.records.title', descKey: 'landing.features.records.body', icon: 'i-lucide-folder-open' },
  { id: 'schedule', nameKey: 'landing.features.schedule.title', descKey: 'landing.features.schedule.body', icon: 'i-lucide-calendar-days' },
  { id: 'odontogram', nameKey: 'landing.features.odontogram.title', descKey: 'landing.features.odontogram.body', icon: 'i-lucide-smile-plus' },
  { id: 'periodontogram', nameKey: 'landing.features.periodontogram.title', descKey: 'landing.features.periodontogram.body', icon: 'i-lucide-activity' },
  { id: 'plans', nameKey: 'landing.features.plans.title', descKey: 'landing.features.plans.body', icon: 'i-lucide-list-checks' },
  { id: 'catalog', nameKey: 'landing.features.catalog.title', descKey: 'landing.features.catalog.body', icon: 'i-lucide-book-open' },
  { id: 'quotes', nameKey: 'landing.features.quotes.title', descKey: 'landing.features.quotes.body', icon: 'i-lucide-file-text' },
  { id: 'billing', nameKey: 'landing.features.billing.title', descKey: 'landing.features.billing.body', icon: 'i-lucide-receipt' },
  { id: 'payments', nameKey: 'landing.features.payments.title', descKey: 'landing.features.payments.body', icon: 'i-lucide-wallet' },
  { id: 'recalls', nameKey: 'landing.features.recalls.title', descKey: 'landing.features.recalls.body', icon: 'i-lucide-bell' },
  { id: 'media', nameKey: 'landing.features.media.title', descKey: 'landing.features.media.body', icon: 'i-lucide-image' },
  { id: 'notes', nameKey: 'landing.features.notes.title', descKey: 'landing.features.notes.body', icon: 'i-lucide-sticky-note' },
  { id: 'reports', nameKey: 'landing.features.reports.title', descKey: 'landing.features.reports.body', icon: 'i-lucide-bar-chart' },
  { id: 'reminders', nameKey: 'landing.features.reminders.title', descKey: 'landing.features.reminders.body', icon: 'i-lucide-mail' },
  { id: 'roles', nameKey: 'landing.features.roles.title', descKey: 'landing.features.roles.body', icon: 'i-lucide-shield-check' },
  { id: 'copilot', nameKey: 'landing.features.copilot.title', descKey: 'landing.features.copilot.body', icon: 'i-lucide-sparkles' }
]

const steps = [
  { id: 'chart', titleKey: 'landing.steps.chart.title', bodyKey: 'landing.steps.chart.body', icon: 'i-lucide-smile-plus' },
  { id: 'plan', titleKey: 'landing.steps.plan.title', bodyKey: 'landing.steps.plan.body', icon: 'i-lucide-list-checks' },
  { id: 'bill', titleKey: 'landing.steps.bill.title', bodyKey: 'landing.steps.bill.body', icon: 'i-lucide-receipt' }
]

const includedKeys = [
  'landing.included.users',
  'landing.included.patients',
  'landing.included.clinical',
  'landing.included.schedule',
  'landing.included.billing',
  'landing.included.export'
]

const navOpen = ref(false)

function closeNav() {
  navOpen.value = false
}
</script>

<template>
  <div class="clinic">
    <header class="nav">
      <div class="nav__shell">
        <a
          href="#top"
          class="mark"
        >
          <span
            class="mark__badge"
            aria-hidden="true"
          >
            <svg
              viewBox="0 0 24 28"
              fill="none"
              stroke="currentColor"
              stroke-width="1.6"
            >
              <path
                d="M12 5.5C9.5 2.5 4 2.8 2.8 7c-1.1 3.9 1 7.2 2 11.4.7 3 1.3 6.4 3.2 6.4 1.7 0 1.8-3.2 2.3-5.6.3-1.4.6-2.4 1.7-2.4s1.4 1 1.7 2.4c.5 2.4.6 5.6 2.3 5.6 1.9 0 2.5-3.4 3.2-6.4 1-4.2 3.1-7.5 2-11.4C20 2.8 14.5 2.5 12 5.5Z"
                stroke-linejoin="round"
              />
            </svg>
          </span>
          <span class="mark__word">{{ t('app.name') }}</span>
        </a>

        <nav
          class="nav__center"
          :aria-label="t('landing.nav.product')"
        >
          <a
            href="#top"
            class="nav__link"
          >{{ t('landing.nav.home') }}</a>
          <a
            href="#remaining"
            class="nav__link"
          >{{ t('landing.nav.chart') }}</a>
          <a
            href="#chart"
            class="nav__link"
          >{{ t('landing.nav.features') }}</a>
          <a
            href="#price"
            class="nav__link"
          >{{ t('landing.nav.pricing') }}</a>
        </nav>

        <div class="nav__actions">
          <button
            v-for="loc in availableLocales"
            :key="loc.code"
            type="button"
            class="nav__locale"
            :class="{ 'nav__locale--on': currentLocale === loc.code }"
            @click="changeLocale(loc.code)"
          >
            {{ loc.code.toUpperCase() }}
          </button>
          <NuxtLink
            to="/login"
            class="btn btn--ghost btn--sm nav__login"
          >
            {{ t('auth.login') }}
          </NuxtLink>
          <a
            href="#request"
            class="btn btn--primary btn--sm nav__cta"
            @click="closeNav"
          >{{ t('landing.cta.request') }}</a>
          <button
            type="button"
            class="nav__toggle"
            :class="{ 'is-open': navOpen }"
            :aria-label="navOpen ? t('nav.close') : t('nav.openMenu')"
            :aria-expanded="navOpen"
            @click="navOpen = !navOpen"
          >
            <span
              class="nav__toggle-bars"
              aria-hidden="true"
            >
              <span></span>
              <span></span>
              <span></span>
            </span>
          </button>
        </div>
      </div>

      <Transition name="nav-drawer">
        <nav
          v-if="navOpen"
          class="nav__drawer"
          :aria-label="t('nav.menu')"
        >
        <a
          href="#top"
          class="nav__drawer-link"
          @click="closeNav"
        >{{ t('landing.nav.home') }}</a>
        <a
          href="#remaining"
          class="nav__drawer-link"
          @click="closeNav"
        >{{ t('landing.nav.chart') }}</a>
        <a
          href="#chart"
          class="nav__drawer-link"
          @click="closeNav"
        >{{ t('landing.nav.features') }}</a>
        <a
          href="#price"
          class="nav__drawer-link"
          @click="closeNav"
        >{{ t('landing.nav.pricing') }}</a>
        <div class="nav__drawer-locales">
          <button
            v-for="loc in availableLocales"
            :key="`drawer-${loc.code}`"
            type="button"
            class="nav__locale"
            :class="{ 'nav__locale--on': currentLocale === loc.code }"
            @click="changeLocale(loc.code)"
          >
            {{ loc.code.toUpperCase() }}
          </button>
        </div>
        <NuxtLink
          to="/login"
          class="btn btn--ghost btn--sm"
          @click="closeNav"
        >
          {{ t('auth.login') }}
        </NuxtLink>
        <a
          href="#request"
          class="btn btn--primary btn--sm"
          @click="closeNav"
        >{{ t('landing.cta.request') }}</a>
        </nav>
      </Transition>
    </header>

    <main id="top">
      <section class="hero">
        <div class="hero__inner">
          <p class="badge">
            <UIcon
              name="i-lucide-sparkles"
              class="w-3.5 h-3.5"
            />
            {{ t('landing.hero.eyebrow') }}
          </p>
          <h1 class="hero__title">
            {{ t('landing.hero.title') }}
            <em>{{ t('landing.hero.titleEm') }}</em>
          </h1>
          <p class="lede">
            {{ t('landing.hero.lede') }}
          </p>
          <div class="hero__actions">
            <a
              href="#remaining"
              class="btn btn--ghost btn--lg"
            >{{ t('landing.cta.seeProduct') }}</a>
            <a
              href="#request"
              class="btn btn--primary btn--lg"
            >{{ t('landing.cta.request') }}</a>
          </div>
        </div>
      </section>

      <section class="preview-wrap">
        <div class="browser">
          <div class="browser__chrome">
            <span class="browser__dot"></span>
            <span class="browser__dot"></span>
            <span class="browser__dot"></span>
            <span class="browser__url">{{ t('app.name') }}</span>
          </div>
          <div class="app-preview">
            <div class="app-preview__bar">
              <span class="mark mark--sm">
                <span class="mark__badge mark__badge--sm" aria-hidden="true">
                  <svg viewBox="0 0 24 28" fill="none" stroke="currentColor" stroke-width="1.8">
                    <path d="M12 5.5C9.5 2.5 4 2.8 2.8 7c-1.1 3.9 1 7.2 2 11.4.7 3 1.3 6.4 3.2 6.4 1.7 0 1.8-3.2 2.3-5.6.3-1.4.6-2.4 1.7-2.4s1.4 1 1.7 2.4c.5 2.4.6 5.6 2.3 5.6 1.9 0 2.5-3.4 3.2-6.4 1-4.2 3.1-7.5 2-11.4C20 2.8 14.5 2.5 12 5.5Z" stroke-linejoin="round" />
                  </svg>
                </span>
                <span class="mark__word">{{ t('app.name') }}</span>
              </span>
              <div class="app-preview__tabs">
                <span class="app-preview__tab app-preview__tab--on">{{ t('landing.preview.overview') }}</span>
                <span class="app-preview__tab">{{ t('landing.preview.patients') }}</span>
                <span class="app-preview__tab">{{ t('landing.preview.appointments') }}</span>
              </div>
            </div>
            <div class="app-preview__body">
              <div class="app-preview__welcome">
                <div>
                  <p class="app-preview__hi">{{ t('landing.preview.welcome') }}</p>
                  <p class="app-preview__sub">{{ t('landing.preview.welcomeSub') }}</p>
                </div>
                <div class="app-preview__search">
                  <UIcon name="i-lucide-search" class="w-3.5 h-3.5" />
                  {{ t('landing.preview.search') }}
                </div>
              </div>
              <div class="kpis">
                <div class="kpi">
                  <UIcon name="i-lucide-calendar-days" class="kpi__icon" />
                  <p class="kpi__label">{{ t('landing.preview.kpiSchedule') }}</p>
                </div>
                <div class="kpi">
                  <UIcon name="i-lucide-users" class="kpi__icon" />
                  <p class="kpi__label">{{ t('landing.preview.kpiPatients') }}</p>
                </div>
                <div class="kpi">
                  <UIcon name="i-lucide-folder-open" class="kpi__icon" />
                  <p class="kpi__label">{{ t('landing.preview.kpiChart') }}</p>
                </div>
                <div class="kpi">
                  <UIcon name="i-lucide-receipt" class="kpi__icon" />
                  <p class="kpi__label">{{ t('landing.preview.kpiBilling') }}</p>
                </div>
              </div>
              <div
                class="arch"
                role="img"
                :aria-label="t('landing.arch.aria')"
              >
                <div class="arch__label">
                  <span class="mono">FDI</span>
                  <span class="arch__labeltext">{{ t('landing.arch.caption') }}</span>
                </div>
                <div class="arch__row">
                  <span
                    v-for="n in ['18', '17', '16', '15', '14', '13', '12', '11', '21', '22', '23', '24', '25', '26', '27', '28']"
                    :key="n"
                    class="tooth"
                    :class="{ 'tooth--on': ['16', '11', '21', '26'].includes(n) }"
                  >{{ n }}</span>
                </div>
                <div class="arch__row arch__row--lower">
                  <span
                    v-for="n in ['48', '47', '46', '45', '44', '43', '42', '41', '31', '32', '33', '34', '35', '36', '37', '38']"
                    :key="n"
                    class="tooth"
                    :class="{ 'tooth--on': ['46', '41', '31', '36'].includes(n) }"
                  >{{ n }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section
        id="remaining"
        class="remaining"
      >
        <div class="wrap remaining__grid">
          <header class="sect remaining__copy">
            <p class="eyebrow">
              {{ t('landing.remaining.eyebrow') }}
            </p>
            <h2 class="sect__title">
              {{ t('landing.remaining.title') }}
            </h2>
            <p class="lede lede--tight">
              {{ t('landing.remaining.lede') }}
            </p>
          </header>
          <div class="remaining__viz card card--flat">
            <RemainingTeethViz />
          </div>
        </div>
      </section>

      <section
        id="how"
        class="how"
      >
        <div class="wrap">
          <header class="sect">
            <p class="eyebrow">
              {{ t('landing.steps.eyebrow') }}
            </p>
            <h2 class="sect__title">
              {{ t('landing.steps.title') }}
            </h2>
          </header>
          <ol class="step-grid">
            <li
              v-for="(step, index) in steps"
              :key="step.id"
              class="step-card card card--flat"
            >
              <div class="step-card__top">
                <div class="feature-card__icon">
                  <UIcon
                    :name="step.icon"
                    class="w-5 h-5"
                  />
                </div>
                <span class="step-card__n mono">{{ String(index + 1).padStart(2, '0') }}</span>
              </div>
              <h3 class="feature-card__name">
                {{ t(step.titleKey) }}
              </h3>
              <p class="feature-card__desc">
                {{ t(step.bodyKey) }}
              </p>
            </li>
          </ol>
        </div>
      </section>

      <section
        id="chart"
        class="chart"
      >
        <div class="wrap">
          <header class="sect">
            <p class="eyebrow">
              {{ t('landing.features.eyebrow') }}
            </p>
            <h2 class="sect__title">
              {{ t('landing.features.title') }}
            </h2>
            <p class="lede">
              {{ t('landing.features.lede') }}
            </p>
          </header>

          <ol class="feature-grid">
            <li
              v-for="f in features"
              :key="f.id"
              class="feature-card card card--flat"
            >
              <div class="feature-card__icon">
                <UIcon
                  :name="f.icon"
                  class="w-5 h-5"
                />
              </div>
              <h3 class="feature-card__name">
                {{ t(f.nameKey) }}
              </h3>
              <p class="feature-card__desc">
                {{ t(f.descKey) }}
              </p>
            </li>
          </ol>
        </div>
      </section>

      <section
        id="price"
        class="price"
      >
        <div class="wrap price__grid">
          <div class="price__left">
            <p class="eyebrow">
              {{ t('landing.pricing.eyebrow') }}
            </p>
            <h2 class="sect__title">
              {{ t('landing.pricing.title') }}
            </h2>
            <p class="lede lede--tight">
              {{ t('landing.pricing.lede') }}
            </p>

            <ul class="incl">
              <li
                v-for="key in includedKeys"
                :key="key"
                class="incl__item"
              >
                <UIcon
                  name="i-lucide-check"
                  class="incl__check"
                />
                {{ t(key) }}
              </li>
            </ul>
          </div>

          <aside
            v-if="pricingPlans.length > 0"
            class="quote card"
          >
            <p class="quote__eyebrow">
              {{ t('landing.pricing.plans') }}
            </p>
            <ul class="plans">
              <li
                v-for="plan in pricingPlans"
                :key="plan.id"
                class="plans__item"
              >
                <span class="plans__name">{{ plan.name }}</span>
                <span class="plans__price">{{ formatPlanPrice(plan.price) }}</span>
                <span class="plans__duration">/ {{ plan.duration_months }} {{ t('landing.pricing.months') }}</span>
              </li>
            </ul>
            <a
              href="#request"
              class="btn btn--primary btn--block"
            >{{ t('landing.cta.request') }}</a>
            <p class="quote__fine">
              {{ t('landing.pricing.fine') }}
            </p>
          </aside>

          <aside
            v-else
            class="quote card"
          >
            <p class="quote__eyebrow">
              {{ t('landing.pricing.quote') }}
            </p>
            <p class="quote__figure">
              {{ t('landing.pricing.perClinic') }}
            </p>
            <p class="quote__note">
              {{ t('landing.pricing.quoteNote') }}
            </p>
            <a
              href="#request"
              class="btn btn--primary btn--block"
            >{{ t('landing.cta.quote') }}</a>
            <p class="quote__fine">
              {{ t('landing.pricing.fine') }}
            </p>
          </aside>
        </div>
      </section>

      <section
        id="request"
        class="req"
      >
        <div class="wrap req__grid">
          <div class="req__intro">
            <p class="eyebrow">
              {{ t('landing.request.eyebrow') }}
            </p>
            <h2 class="sect__title">
              {{ t('landing.request.title') }}
            </h2>
            <p class="lede lede--tight">
              {{ t('landing.request.lede') }}
            </p>
          </div>

          <div class="req__panel card">
            <div
              v-if="isSuccess"
              class="done"
            >
              <div class="done__icon">
                <UIcon
                  name="i-lucide-check"
                  class="w-5 h-5"
                />
              </div>
              <h3 class="done__title">
                {{ t('landing.request.sentTitle') }}
              </h3>
              <p class="done__body">
                {{ t('landing.request.sentBody', { email: formState.email }) }}
              </p>
            </div>

            <form
              v-else
              class="form"
              @submit.prevent="submitLead"
            >
              <div class="form__pair">
                <div class="field">
                  <label
                    for="pb-name"
                    class="field__label"
                  >
                    {{ t('landing.form.name') }}
                    <span class="field__req">{{ t('landing.form.required') }}</span>
                  </label>
                  <input
                    id="pb-name"
                    v-model="formState.contact_name"
                    required
                    type="text"
                    class="field__input"
                    :placeholder="t('landing.form.namePlaceholder')"
                  >
                </div>

                <div class="field">
                  <label
                    for="pb-clinic"
                    class="field__label"
                  >
                    {{ t('landing.form.clinic') }}
                    <span class="field__req">{{ t('landing.form.required') }}</span>
                  </label>
                  <input
                    id="pb-clinic"
                    v-model="formState.clinic_name"
                    required
                    type="text"
                    class="field__input"
                    :placeholder="t('landing.form.clinicPlaceholder')"
                  >
                </div>
              </div>

              <div class="field">
                <label
                  for="pb-email"
                  class="field__label"
                >
                  {{ t('auth.email') }}
                  <span class="field__req">{{ t('landing.form.required') }}</span>
                </label>
                <input
                  id="pb-email"
                  v-model="formState.email"
                  required
                  type="email"
                  class="field__input"
                  :placeholder="t('landing.form.emailPlaceholder')"
                >
              </div>

              <div class="form__pair">
                <div class="field">
                  <label
                    for="pb-phone"
                    class="field__label"
                  >{{ t('landing.form.phone') }}</label>
                  <input
                    id="pb-phone"
                    v-model="formState.phone"
                    type="tel"
                    class="field__input"
                    :placeholder="t('landing.form.phonePlaceholder')"
                  >
                </div>

                <div class="field">
                  <label
                    for="pb-users"
                    class="field__label"
                  >{{ t('landing.form.users') }}</label>
                  <input
                    id="pb-users"
                    v-model="formState.expected_users"
                    type="number"
                    min="1"
                    class="field__input"
                    placeholder="5"
                  >
                </div>
              </div>

              <div class="field">
                <label
                  for="pb-message"
                  class="field__label"
                >{{ t('landing.form.message') }}</label>
                <textarea
                  id="pb-message"
                  v-model="formState.message"
                  class="field__input min-h-[100px] resize-y"
                  :placeholder="t('landing.form.messagePlaceholder')"
                />
              </div>

              <button
                type="submit"
                :disabled="isSubmitting"
                class="btn btn--primary btn--block btn--lg"
              >
                <span v-if="!isSubmitting">{{ t('landing.cta.send') }}</span>
                <span
                  v-else
                  class="sending"
                >
                  <span
                    class="sending__dot"
                    aria-hidden="true"
                  />
                  {{ t('landing.cta.sending') }}
                </span>
              </button>
            </form>
          </div>
        </div>
      </section>

      <footer class="foot">
        <div class="wrap foot__inner">
          <span class="mark mark--sm">
            <span class="mark__word">{{ t('app.name') }}</span>
          </span>
          <p class="foot__meta">
            &copy; {{ new Date().getFullYear() }} {{ t('app.name') }}
          </p>
        </div>
      </footer>
    </main>
  </div>
</template>

<style scoped>
.clinic {
  --canvas: #F4F6FB;
  --card: #FFFFFF;
  --ink: var(--color-text);
  --muted: var(--color-text-muted);
  --subtle: var(--color-text-subtle);
  --rule: var(--color-border-subtle);
  --primary: var(--color-primary);
  --primary-hover: var(--color-primary-hover);
  --primary-soft: var(--color-primary-soft);
  --radius: var(--radius-xl);

  color: var(--ink);
  font-family: 'Inter Variable', Inter, system-ui, sans-serif;
  -webkit-font-smoothing: antialiased;
  min-height: 100vh;
  overflow-x: clip;
  background:
    radial-gradient(1200px 520px at 50% -10%, color-mix(in srgb, var(--primary) 16%, white), transparent 70%),
    radial-gradient(900px 420px at 100% 8%, color-mix(in srgb, var(--primary) 10%, #fff), transparent 65%),
    radial-gradient(800px 380px at 0% 12%, color-mix(in srgb, var(--primary) 8%, #f8f5ff), transparent 60%),
    var(--canvas);
}

.wrap { max-width: 1120px; margin: 0 auto; padding: 0 24px; }
.mono { font-family: ui-monospace, 'SF Mono', monospace; }
.card {
  background: var(--card);
  border-radius: 24px;
  box-shadow: 0 18px 50px rgba(15, 23, 42, 0.06);
  border: 1px solid color-mix(in srgb, var(--rule) 80%, transparent);
}
.card--flat { box-shadow: none; }

.nav {
  position: sticky; top: 0; z-index: 50;
  padding: 16px 20px 0;
}
.nav__shell {
  max-width: 1080px; margin: 0 auto;
  display: flex; align-items: center; justify-content: space-between; gap: 16px;
  background: color-mix(in srgb, white 88%, transparent);
  backdrop-filter: saturate(180%) blur(16px);
  border: 1px solid color-mix(in srgb, white 70%, var(--rule));
  border-radius: 999px;
  padding: 8px 8px 8px 12px;
  box-shadow: 0 10px 40px rgba(15, 23, 42, 0.06);
}
.mark { display: inline-flex; align-items: center; gap: 10px; text-decoration: none; color: var(--ink); min-width: 0; flex: 1 1 auto; }
.mark__badge {
  width: 36px; height: 36px; border-radius: 999px; flex-shrink: 0;
  display: grid; place-items: center;
  background: var(--primary); color: #fff;
  box-shadow: 0 6px 16px color-mix(in srgb, var(--primary) 35%, transparent);
}
.mark__badge svg { width: 16px; height: 18px; }
.mark__badge--sm { width: 28px; height: 28px; box-shadow: none; }
.mark__badge--sm svg { width: 12px; height: 14px; }
.mark__word {
  font-weight: 700; font-size: 16px; letter-spacing: -0.03em;
  min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.nav__center { display: flex; align-items: center; gap: 4px; }
.nav__link {
  font-size: 14px; font-weight: 550; color: var(--muted); text-decoration: none;
  padding: 8px 14px; border-radius: 999px;
  transition: color .15s ease, background .15s ease;
}
.nav__link:hover { color: var(--ink); background: var(--canvas); }
.nav__actions { display: flex; align-items: center; gap: 6px; flex-shrink: 0; }
.nav__locale {
  font-size: 12px; font-weight: 650; color: var(--subtle);
  background: transparent; border: 0; padding: 6px 8px; cursor: pointer;
  border-radius: 999px;
}
.nav__locale--on { color: var(--primary); background: var(--primary-soft); }
.nav__toggle {
  display: none;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border: 0;
  background: var(--canvas);
  color: var(--ink);
  border-radius: 999px;
  cursor: pointer;
  transition: background .22s ease, color .22s ease, transform .18s ease, box-shadow .22s ease;
}
.nav__toggle:hover { background: color-mix(in srgb, var(--primary) 10%, var(--canvas)); }
.nav__toggle:active { transform: scale(.94); }
.nav__toggle.is-open {
  background: var(--primary);
  color: #fff;
  box-shadow: 0 8px 18px color-mix(in srgb, var(--primary) 28%, transparent);
}
.nav__toggle-bars {
  position: relative;
  display: block;
  width: 16px;
  height: 12px;
}
.nav__toggle-bars span {
  position: absolute;
  left: 0;
  right: 0;
  height: 2px;
  border-radius: 999px;
  background: currentColor;
  transform-origin: center;
  transition: top .28s cubic-bezier(.22, 1, .36, 1), transform .28s cubic-bezier(.22, 1, .36, 1), opacity .18s ease;
}
.nav__toggle-bars span:nth-child(1) { top: 0; }
.nav__toggle-bars span:nth-child(2) { top: 5px; }
.nav__toggle-bars span:nth-child(3) { top: 10px; }
.nav__toggle.is-open .nav__toggle-bars span:nth-child(1) {
  top: 5px;
  transform: rotate(45deg);
}
.nav__toggle.is-open .nav__toggle-bars span:nth-child(2) {
  opacity: 0;
  transform: scaleX(.4);
}
.nav__toggle.is-open .nav__toggle-bars span:nth-child(3) {
  top: 5px;
  transform: rotate(-45deg);
}
.nav__drawer {
  display: none;
}
.nav-drawer-enter-active,
.nav-drawer-leave-active {
  transition:
    opacity .28s ease,
    transform .34s cubic-bezier(.22, 1, .36, 1),
    max-height .34s cubic-bezier(.22, 1, .36, 1);
  overflow: hidden;
}
.nav-drawer-enter-from,
.nav-drawer-leave-to {
  opacity: 0;
  transform: translateY(-12px) scale(.98);
  max-height: 0;
}
.nav-drawer-enter-to,
.nav-drawer-leave-from {
  opacity: 1;
  transform: translateY(0) scale(1);
  max-height: 420px;
}

.btn {
  display: inline-flex; align-items: center; justify-content: center;
  font-size: 14px; font-weight: 650; letter-spacing: -0.01em;
  padding: 10px 18px; border-radius: 999px;
  text-decoration: none; border: 1px solid transparent;
  transition: background .16s ease, color .16s ease, border-color .16s ease, box-shadow .16s ease;
}
.btn--primary {
  background: var(--primary); color: #fff;
  box-shadow: 0 8px 20px color-mix(in srgb, var(--primary) 28%, transparent);
}
.btn--primary:hover { background: var(--primary-hover); }
.btn--primary:disabled { opacity: .55; cursor: not-allowed; box-shadow: none; }
.btn--ghost { border-color: var(--rule); color: var(--ink); background: var(--card); }
.btn--ghost:hover { border-color: color-mix(in srgb, var(--primary) 35%, var(--rule)); }
.btn--sm { padding: 8px 16px; font-size: 13px; }
.btn--lg { padding: 14px 24px; font-size: 15px; }
.btn--block { width: 100%; }
.btn:focus-visible { outline: 2px solid var(--primary); outline-offset: 3px; }

.badge {
  display: inline-flex; align-items: center; gap: 8px;
  margin: 0 0 22px; padding: 8px 14px;
  border-radius: 999px; background: color-mix(in srgb, white 70%, var(--primary-soft));
  color: var(--primary); font-size: 13px; font-weight: 650;
  border: 1px solid color-mix(in srgb, var(--primary) 12%, white);
}
.eyebrow {
  font-size: 12px; letter-spacing: .12em; text-transform: uppercase; font-weight: 650;
  color: var(--primary); margin: 0 0 14px;
}
.sect__title {
  font-weight: 700; letter-spacing: -0.04em; line-height: 1.12;
  font-size: clamp(28px, 3.6vw, 42px); margin: 0 0 14px; color: var(--ink);
}
.lede { font-size: 18px; line-height: 1.65; color: var(--muted); margin: 0 auto; max-width: 42ch; overflow-wrap: break-word; }
.lede--tight { font-size: 16px; margin: 0; }

.hero { padding: clamp(48px, 7vw, 88px) 24px 28px; }
.hero__inner { max-width: 820px; margin: 0 auto; text-align: center; }
.hero__title {
  font-weight: 750; font-size: clamp(28px, 8vw, 68px);
  line-height: 1.04; letter-spacing: -0.045em; margin: 0 auto 18px;
  max-width: 16ch;
  overflow-wrap: anywhere;
}
.hero__title em { font-style: normal; color: var(--primary); }
.hero__actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 28px; justify-content: center; }

.preview-wrap { max-width: 1080px; margin: 0 auto; padding: 0 24px 8px; }
.browser {
  background: #fff;
  border-radius: 28px;
  border: 1px solid color-mix(in srgb, white 50%, var(--rule));
  box-shadow:
    0 40px 80px rgba(15, 23, 42, 0.10),
    0 2px 0 rgba(255,255,255,0.8) inset;
  overflow: hidden;
}
.browser__chrome {
  display: flex; align-items: center; gap: 8px;
  padding: 12px 16px;
  background: color-mix(in srgb, var(--canvas) 80%, white);
  border-bottom: 1px solid var(--rule);
}
.browser__dot { width: 8px; height: 8px; border-radius: 999px; background: #d7dbe3; }
.browser__url {
  margin-left: 10px; font-size: 12px; color: var(--subtle); font-weight: 550;
}

.app-preview__bar {
  display: flex; align-items: center; justify-content: space-between; gap: 16px;
  padding: 12px 18px;
  border-bottom: 1px solid var(--rule);
}
.app-preview__tabs { display: flex; gap: 6px; }
.app-preview__tab {
  font-size: 13px; font-weight: 600; color: var(--muted);
  padding: 6px 12px; border-radius: 999px;
}
.app-preview__tab--on { background: #111; color: #fff; }
.app-preview__body { padding: 22px 20px 24px; background: linear-gradient(180deg, #fff, var(--canvas)); }
.app-preview__welcome {
  display: flex; align-items: flex-end; justify-content: space-between; gap: 16px;
  margin-bottom: 18px;
}
.app-preview__hi { font-size: 22px; font-weight: 700; letter-spacing: -0.03em; margin: 0 0 4px; }
.app-preview__sub { font-size: 13px; color: var(--muted); margin: 0; }
.app-preview__search {
  display: inline-flex; align-items: center; gap: 8px;
  min-width: 220px; padding: 10px 14px;
  border-radius: 999px; background: #fff; color: var(--subtle); font-size: 13px;
  border: 1px solid var(--rule);
}

.kpis { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-bottom: 16px; }
.kpi {
  background: #fff; border: 1px solid var(--rule); border-radius: 18px;
  padding: 14px 14px 16px;
}
.kpi__icon { width: 18px; height: 18px; color: var(--primary); margin-bottom: 10px; }
.kpi__label { margin: 0; font-size: 13px; font-weight: 650; color: var(--ink); }

.arch { padding: 16px 16px 18px; background: #fff; border-radius: 18px; border: 1px solid var(--rule); }
.arch__label {
  display: flex; gap: 14px; align-items: baseline;
  font-size: 11px; letter-spacing: .12em; text-transform: uppercase; margin-bottom: 14px;
}
.arch__label .mono { color: var(--primary); font-weight: 650; }
.arch__labeltext { color: var(--subtle); letter-spacing: .04em; }
.arch__row { display: flex; gap: 6px; justify-content: space-between; }
.arch__row--lower { margin-top: 6px; }
.tooth {
  flex: 1 1 0; min-width: 0;
  font-family: ui-monospace, monospace; font-size: 11px;
  text-align: center; padding: 10px 0;
  color: var(--subtle); background: var(--canvas);
  border-radius: 10px;
}
.tooth--on { color: var(--primary); background: var(--primary-soft); font-weight: 650; }

.remaining { padding: clamp(48px, 7vw, 80px) 0 0; }
.remaining__grid {
  display: grid;
  grid-template-columns: minmax(0, .85fr) minmax(0, 1.15fr);
  gap: 32px;
  align-items: center;
}
.remaining__viz { padding: 24px; }
.remaining .sect { margin-bottom: 0; }

.how { padding: clamp(48px, 7vw, 80px) 0 0; }
.how .sect { text-align: center; }
.step-grid {
  list-style: none; margin: 0; padding: 0;
  display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px;
}
.step-card { padding: 24px 26px 28px; }
.step-card__top {
  display: flex; align-items: flex-start; justify-content: space-between; gap: 12px;
  margin-bottom: 8px;
}
.step-card__n { font-size: 11px; color: var(--primary); letter-spacing: .08em; }

.chart { padding: clamp(56px, 8vw, 96px) 0; }
.sect { margin-bottom: 32px; }
.chart .sect { text-align: center; }
.chart .lede { margin-bottom: 0; }
.feature-grid {
  list-style: none; margin: 0; padding: 0;
  display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px;
}
.feature-card { padding: 28px; position: relative; }
.feature-card__icon {
  width: 44px; height: 44px; border-radius: 14px;
  background: var(--primary-soft); color: var(--primary);
  display: flex; align-items: center; justify-content: center; margin-bottom: 16px;
}
.feature-card__name { font-size: 18px; font-weight: 650; letter-spacing: -0.02em; margin: 8px 0 8px; }
.feature-card__desc { font-size: 14px; line-height: 1.65; color: var(--muted); margin: 0; }

.price { padding: 0 0 clamp(56px, 8vw, 96px); }
.price__grid { display: grid; grid-template-columns: minmax(0, 1.35fr) minmax(0, .85fr); gap: 28px; align-items: start; }
.incl { list-style: none; margin: 28px 0 0; padding: 0; display: grid; gap: 10px; }
.incl__item {
  display: flex; align-items: flex-start; gap: 10px;
  font-size: 15px; color: var(--ink);
  background: var(--card); border-radius: 16px; padding: 12px 14px;
  border: 1px solid var(--rule);
}
.incl__check { width: 18px; height: 18px; color: var(--primary); flex-shrink: 0; margin-top: 1px; }

.quote { padding: 28px 26px; }
.quote__eyebrow { font-size: 12px; letter-spacing: .12em; text-transform: uppercase; color: var(--primary); font-weight: 650; margin: 0 0 16px; }
.quote__figure { font-weight: 650; font-size: 32px; letter-spacing: -0.04em; margin: 0 0 12px; }
.quote__note { font-size: 14px; line-height: 1.65; color: var(--muted); margin: 0 0 22px; }
.quote__fine { font-size: 12px; color: var(--subtle); margin: 14px 0 0; text-align: center; }

.plans { list-style: none; margin: 0 0 22px; padding: 0; max-height: 280px; overflow-y: auto; }
.plans__item { display: flex; align-items: baseline; gap: 8px; padding: 12px 0; border-bottom: 1px solid var(--rule); }
.plans__item:first-child { padding-top: 0; }
.plans__item:last-child { border-bottom: none; }
.plans__name { font-size: 14px; flex: 1; }
.plans__price { font-weight: 650; font-size: 18px; }
.plans__duration { font-size: 12px; color: var(--subtle); }

.req { padding: 0 0 clamp(64px, 8vw, 104px); }
.req__grid { display: grid; grid-template-columns: minmax(0, .8fr) minmax(0, 1.2fr); gap: 28px; align-items: start; }
.req__intro { position: sticky; top: 96px; }
.req__panel { padding: 28px; }

.form__pair { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.field { margin-bottom: 16px; }
.field__label {
  display: flex; align-items: baseline; gap: 8px;
  font-size: 13px; font-weight: 600; margin-bottom: 8px;
}
.field__req { font-size: 11px; color: var(--subtle); font-weight: 500; }
.field__input {
  width: 100%; max-width: 100%; box-sizing: border-box; background: var(--canvas);
  border: 1px solid var(--rule); border-radius: 14px;
  padding: 12px 14px; font-size: 16px; color: var(--ink);
  font-family: inherit;
}
.field__input::placeholder { color: var(--subtle); }
.field__input:focus {
  outline: none; border-color: var(--primary);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--primary) 16%, transparent);
  background: #fff;
}

.sending { display: inline-flex; align-items: center; gap: 9px; }
.sending__dot {
  width: 6px; height: 6px; border-radius: 50%; background: currentColor;
  animation: pulse 1.1s ease-in-out infinite;
}
@keyframes pulse { 0%, 100% { opacity: .25 } 50% { opacity: 1 } }

.done { padding: 8px 0 8px; }
.done__icon {
  width: 40px; height: 40px; border-radius: 12px; margin-bottom: 16px;
  background: var(--primary-soft); color: var(--primary);
  display: flex; align-items: center; justify-content: center;
}
.done__title { font-weight: 650; font-size: 24px; letter-spacing: -0.03em; margin: 0 0 10px; }
.done__body { font-size: 15px; line-height: 1.68; color: var(--muted); margin: 0; }

.foot { padding: 0 0 40px; }
.foot__inner { display: flex; align-items: center; justify-content: space-between; gap: 20px; }
.mark--sm .mark__word { font-size: 15px; }
.foot__meta { font-size: 12px; color: var(--subtle); }

@media (max-width: 1100px) {
  .nav__center,
  .nav__login,
  .nav__cta { display: none; }
  .nav__toggle { display: inline-flex; }
  .nav__drawer {
    display: flex;
    flex-direction: column;
    gap: 6px;
    width: 100%;
    max-width: 1080px;
    margin: 10px auto 0;
    padding: 12px;
    background: #fff;
    border: 1px solid var(--rule);
    border-radius: 20px;
    transform-origin: top center;
    box-shadow: 0 18px 40px rgba(15, 23, 42, 0.08);
  }
  .nav__drawer-link {
    font-size: 15px;
    font-weight: 600;
    color: var(--ink);
    text-decoration: none;
    padding: 12px 14px;
    border-radius: 12px;
  }
  .nav__drawer-link:hover { background: var(--canvas); }
  .nav__drawer .btn { width: 100%; }
  .nav__drawer-locales { display: flex; gap: 4px; padding: 4px 6px 8px; }
  .nav-drawer-enter-active .nav__drawer-link,
  .nav-drawer-enter-active .nav__drawer-locales,
  .nav-drawer-enter-active .btn {
    animation: navItemIn .36s cubic-bezier(.22, 1, .36, 1) both;
  }
  .nav-drawer-enter-active .nav__drawer-link:nth-child(1) { animation-delay: .04s; }
  .nav-drawer-enter-active .nav__drawer-link:nth-child(2) { animation-delay: .08s; }
  .nav-drawer-enter-active .nav__drawer-link:nth-child(3) { animation-delay: .12s; }
  .nav-drawer-enter-active .nav__drawer-link:nth-child(4) { animation-delay: .16s; }
  .nav-drawer-enter-active .nav__drawer-locales { animation-delay: .2s; }
  .nav-drawer-enter-active .btn:nth-last-child(2) { animation-delay: .24s; }
  .nav-drawer-enter-active .btn:last-child { animation-delay: .28s; }
}

@keyframes navItemIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

@media (max-width: 900px) {
  .wrap, .preview-wrap { padding-left: 16px; padding-right: 16px; }
  .price__grid, .req__grid, .remaining__grid { grid-template-columns: 1fr; }
  .feature-grid, .step-grid, .kpis { grid-template-columns: 1fr 1fr; }
  .req__intro { position: static; }
  .app-preview__tabs { display: none; }
  .app-preview__welcome { flex-direction: column; align-items: stretch; }
  .app-preview__search { min-width: 0; width: 100%; }
  .app-preview__bar { flex-wrap: wrap; }
  .browser { border-radius: 20px; }
  .hero__title { max-width: none; }
  .remaining__viz { padding: 16px; overflow-x: auto; }
  .arch { overflow-x: auto; }
  .arch__row { min-width: 420px; }
}

@media (max-width: 640px) {
  .kpis, .form__pair, .feature-grid, .step-grid { grid-template-columns: 1fr; }
  .hero { padding: 28px 16px 16px; }
  .hero__actions { flex-direction: column; }
  .hero__actions .btn { width: 100%; }
  .lede { font-size: 16px; max-width: none; }
  .nav { padding: 10px 12px 0; }
  .nav__shell {
    gap: 8px;
    padding: 6px 6px 6px 10px;
  }
  .nav__actions .nav__locale { display: none; }
  .mark__word { font-size: 14px; }
  .mark__badge { width: 32px; height: 32px; }
  .tooth { font-size: 8px; padding: 6px 0; }
  .arch__row { gap: 3px; }
  .app-preview__body { padding: 14px 12px 16px; }
  .app-preview__hi { font-size: 18px; }
  .preview-wrap { overflow-x: auto; }
  .foot__inner { flex-direction: column; align-items: flex-start; }
  .req__panel, .quote, .feature-card, .step-card { padding: 20px; }
  .badge { font-size: 12px; max-width: 100%; }
  .done__body { overflow-wrap: anywhere; }
}

@media (max-width: 400px) {
  .hero__title { font-size: 26px; }
  .mark--sm .mark__word { font-size: 13px; }
}

@media (prefers-reduced-motion: reduce) {
  .clinic *, .clinic *::before, .clinic *::after {
    animation-duration: .01ms !important;
    transition-duration: .01ms !important;
  }
}
</style>
