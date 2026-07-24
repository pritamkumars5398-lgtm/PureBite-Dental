<script setup lang="ts">
useHead({
  link: [
    { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
    { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
    {
      rel: 'stylesheet',
      href: 'https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght,SOFT,WONK@0,9..144,300..700,0..100,0..1;1,9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap'
    }
  ]
})

definePageMeta({
  layout: false
})

const toast = useToast()

const formState = reactive({
  contact_name: '',
  clinic_name: '',
  phone: '',
  email: '',
  expected_users: null as number | null
})

const isSubmitting = ref(false)
const isSuccess = ref(false)

// Pricing plans are Superadmin-managed (see /admin → Pricing Plans) and
// public by design so this page can show real numbers. If none are
// configured yet, or the fetch fails, the "Get a quote" panel below is
// shown instead — a public marketing page must never dead-end on an
// empty state.
interface PublicPricingPlan {
  id: string
  name: string
  duration_months: number
  price: number
}
const pricingPlans = ref<PublicPricingPlan[]>([])

function formatPlanPrice(price: number): string {
  try {
    return new Intl.NumberFormat(undefined, { style: 'currency', currency: 'USD' }).format(price)
  } catch {
    return `$${price}`
  }
}

onMounted(async () => {
  try {
    // Raw $fetch (not useApi()) — this page is public/unauthenticated,
    // and useApi() toasts network/5xx errors, which would surface an
    // alarming error to an anonymous visitor over a background fetch
    // they never triggered. Silent fallback to "Get a quote" instead.
    const config = useRuntimeConfig()
    pricingPlans.value = await $fetch<PublicPricingPlan[]>('/api/v1/saas/plans', {
      baseURL: config.public.apiBaseUrl
    })
  } catch {
    pricingPlans.value = []
  }
})

async function submitLead() {
  if (!formState.contact_name || !formState.clinic_name || !formState.email) {
    toast.add({
      title: 'Three fields still empty',
      description: 'Add your name, your clinic name, and an email we can reply to.',
      color: 'error'
    })
    return
  }

  isSubmitting.value = true
  try {
    const api = useApi()
    await api.post('/api/v1/saas/leads', formState)
    isSuccess.value = true
    toast.add({
      title: 'Request sent',
      description: 'We reply within one business day.',
      color: 'success'
    })
  } catch (err: unknown) {
    const fetchError = err as { data?: { message?: string, detail?: string } }
    toast.add({
      title: 'Request not sent',
      description: fetchError.data?.message || fetchError.data?.detail || 'The server did not respond. Try again in a moment.',
      color: 'error'
    })
  } finally {
    isSubmitting.value = false
  }
}

// FDI quadrant codes used as the structural key — real dental notation,
// not decorative numbering.
const features = [
  {
    code: '11',
    name: 'Patient records',
    description: 'Medical history, allergies, medications and treatment plans in one chart. Everything is versioned, so you can see who changed what and when.'
  },
  {
    code: '21',
    name: 'The day\'s schedule',
    description: 'Book by chair and by clinician. The calendar refuses double-bookings rather than warning you after the fact, and reminders go out on your schedule.'
  },
  {
    code: '31',
    name: 'Billing',
    description: 'Build an invoice from the treatment plan itself. Track what is paid, what is pending, and what insurance still owes you.'
  },
  {
    code: '41',
    name: 'Who sees what',
    description: 'Receptionists see the schedule. Hygienists see charts. Only you see the finances. Set it once per role.'
  }
]

const included = [
  'Every patient, no per-record fee',
  'Every staff account included',
  'Full-mouth odontogram with treatment history',
  'Data export whenever you ask for it',
  'Support from people who know the software',
  'Onboarding and record migration'
]
</script>

<template>
  <div class="purebite">
    <!-- ─────────────────────── NAV ─────────────────────── -->
    <header class="nav">
      <div class="nav__inner">
        <a href="#top" class="mark">
          <span class="mark__glyph" aria-hidden="true">
            <svg viewBox="0 0 24 28" fill="none" stroke="currentColor" stroke-width="1.4">
              <path d="M12 5.5C9.5 2.5 4 2.8 2.8 7c-1.1 3.9 1 7.2 2 11.4.7 3 1.3 6.4 3.2 6.4 1.7 0 1.8-3.2 2.3-5.6.3-1.4.6-2.4 1.7-2.4s1.4 1 1.7 2.4c.5 2.4.6 5.6 2.3 5.6 1.9 0 2.5-3.4 3.2-6.4 1-4.2 3.1-7.5 2-11.4C20 2.8 14.5 2.5 12 5.5Z" stroke-linejoin="round"/>
            </svg>
          </span>
          <span class="mark__word">PureBite</span>
        </a>

        <nav class="nav__links">
          <a href="#chart" class="nav__link">What it does</a>
          <a href="#price" class="nav__link">Pricing</a>
          <NuxtLink to="/login" class="nav__link flex items-center gap-1.5">
            <UIcon name="i-lucide-log-in" class="w-4 h-4" />
            Log in
          </NuxtLink>
          <a href="#request" class="btn btn--ink">Request access</a>
        </nav>
      </div>
    </header>

    <main id="top">
      <!-- ─────────────────────── HERO ─────────────────────── -->
      <section class="hero">
        <div class="hero__inner">
          <p class="eyebrow">Practice management &middot; est. for dentists</p>

          <h1 class="hero__title">
            The chart,
            <em>the chair,</em>
            and the books.
          </h1>

          <div class="hero__body">
            <p class="lede">
              One record per patient. Every clinician in your practice writing
              to the same chart, in the same place, at the same time.
            </p>
            <div class="hero__actions">
              <a href="#request" class="btn btn--ink btn--lg">Request access</a>
              <a href="#chart" class="btn btn--ghost btn--lg">See what it does</a>
            </div>
          </div>
        </div>

        <!-- SIGNATURE: full dental arch, drawn in FDI notation. -->
        <div class="arch" role="img" aria-label="Upper and lower dental arch labelled in FDI notation">
          <div class="arch__label">
            <span class="mono">FDI</span>
            <span class="arch__labeltext">Two-digit notation &mdash; quadrant, then tooth</span>
          </div>
          <div class="arch__row">
            <span
              v-for="n in ['18','17','16','15','14','13','12','11','21','22','23','24','25','26','27','28']"
              :key="n"
              class="tooth"
              :class="{ 'tooth--on': ['16','11','21','26'].includes(n) }"
            >{{ n }}</span>
          </div>
          <div class="arch__row arch__row--lower">
            <span
              v-for="n in ['48','47','46','45','44','43','42','41','31','32','33','34','35','36','37','38']"
              :key="n"
              class="tooth"
              :class="{ 'tooth--on': ['46','41','31','36'].includes(n) }"
            >{{ n }}</span>
          </div>
        </div>
      </section>

      <!-- ─────────────────────── CHART / FEATURES ─────────────────────── -->
      <section id="chart" class="chart">
        <div class="wrap">
          <header class="sect">
            <p class="eyebrow">The chart</p>
            <h2 class="sect__title">Four things, done properly.</h2>
          </header>

          <ol class="rows">
            <li v-for="f in features" :key="f.code" class="row">
              <span class="row__code mono">{{ f.code }}</span>
              <h3 class="row__name">{{ f.name }}</h3>
              <p class="row__desc">{{ f.description }}</p>
            </li>
          </ol>
        </div>
      </section>

      <!-- ─────────────────────── PRICING ─────────────────────── -->
      <section id="price" class="price">
        <div class="wrap price__grid">
          <div class="price__left">
            <p class="eyebrow">Pricing</p>
            <h2 class="sect__title">One subscription. The whole practice.</h2>
            <p class="lede lede--tight">
              You pay for time, not for patients or seats. A two-chair practice
              and a twelve-chair practice pay differently, so tell us which you are
              and we will quote you.
            </p>

            <ul class="incl">
              <li v-for="i in included" :key="i" class="incl__item">
                <span class="incl__rule" aria-hidden="true"></span>
                {{ i }}
              </li>
            </ul>
          </div>

          <aside v-if="pricingPlans.length > 0" class="quote quote--plans">
            <p class="quote__eyebrow mono">Plans</p>
            <ul class="plans">
              <li v-for="plan in pricingPlans" :key="plan.id" class="plans__item">
                <span class="plans__name">{{ plan.name }}</span>
                <span class="plans__price">{{ formatPlanPrice(plan.price) }}</span>
                <span class="plans__duration">/ {{ plan.duration_months }} mo</span>
              </li>
            </ul>
            <a href="#request" class="btn btn--ink btn--block">Request access</a>
            <p class="quote__fine">No card required to talk to us.</p>
          </aside>

          <aside v-else class="quote">
            <p class="quote__eyebrow mono">Quote</p>
            <p class="quote__figure">Per&nbsp;clinic</p>
            <p class="quote__note">
              Scaled to your chair count and how many clinicians work them.
              No per-patient charge, ever.
            </p>
            <a href="#request" class="btn btn--ink btn--block">Get a quote</a>
            <p class="quote__fine">No card required to talk to us.</p>
          </aside>
        </div>
      </section>

      <!-- ─────────────────────── FORM ─────────────────────── -->
      <section id="request" class="req">
        <div class="wrap req__grid">
          <div class="req__intro">
            <p class="eyebrow">Request access</p>
            <h2 class="sect__title">Tell us about your practice.</h2>
            <p class="lede lede--tight">
              We read every one of these ourselves and reply within one business day.
            </p>
          </div>

          <div class="req__panel">
            <div v-if="isSuccess" class="done">
              <span class="done__rule" aria-hidden="true"></span>
              <h3 class="done__title">Request sent.</h3>
              <p class="done__body">
                It is with our team now. Expect a reply at
                <strong>{{ formState.email }}</strong> within one business day.
              </p>
            </div>

            <form v-else class="form" @submit.prevent="submitLead">
              <div class="form__pair">
                <div class="field">
                  <label for="pb-name" class="field__label">
                    Your name <span class="field__req" aria-hidden="true">required</span>
                  </label>
                  <input
                    id="pb-name"
                    v-model="formState.contact_name"
                    required
                    type="text"
                    class="field__input"
                    placeholder="Enter your name"
                  />
                </div>

                <div class="field">
                  <label for="pb-clinic" class="field__label">
                    Clinic name <span class="field__req" aria-hidden="true">required</span>
                  </label>
                  <input
                    id="pb-clinic"
                    v-model="formState.clinic_name"
                    required
                    type="text"
                    class="field__input"
                    placeholder="Enter your clinic name"
                  />
                </div>
              </div>

              <div class="field">
                <label for="pb-email" class="field__label">
                  Email <span class="field__req" aria-hidden="true">required</span>
                </label>
                <input
                  id="pb-email"
                  v-model="formState.email"
                  required
                  type="email"
                  class="field__input"
                  placeholder="Enter your email address"
                />
              </div>

              <div class="form__pair">
                <div class="field">
                  <label for="pb-phone" class="field__label">Phone</label>
                  <input
                    id="pb-phone"
                    v-model="formState.phone"
                    type="tel"
                    class="field__input"
                    placeholder="Enter your phone number"
                  />
                </div>

                <div class="field">
                  <label for="pb-users" class="field__label">People who will use it</label>
                  <input
                    id="pb-users"
                    v-model="formState.expected_users"
                    type="number"
                    min="1"
                    class="field__input"
                    placeholder="e.g. 5"
                  />
                </div>
              </div>

              <button type="submit" :disabled="isSubmitting" class="btn btn--ink btn--block btn--lg">
                <span v-if="!isSubmitting">Send request</span>
                <span v-else class="sending">
                  <span class="sending__dot" aria-hidden="true"></span>
                  Sending
                </span>
              </button>
            </form>
          </div>
        </div>
      </section>

      <!-- ─────────────────────── FOOTER ─────────────────────── -->
      <footer class="foot">
        <div class="wrap foot__inner">
          <span class="mark mark--sm">
            <span class="mark__word">PureBite</span>
          </span>
          <p class="foot__meta mono">&copy; {{ new Date().getFullYear() }} PureBite Dental</p>
        </div>
      </footer>
    </main>
  </div>
</template>

<style scoped>
/* ───────── tokens ───────── */
.purebite {
  --paper:   #F7F6F2;  /* warm porcelain */
  --paper-2: #EFEDE6;  /* recessed band  */
  --ink:     #16191A;  /* near-black     */
  --ink-60:  #5A6062;
  --ink-30:  #9BA1A1;
  --rule:    #DCD9D0;
  --mint:    #0F766E;  /* single accent  */
  --mint-bg: #E3EEEB;

  background: var(--paper);
  color: var(--ink);
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  font-feature-settings: 'ss01', 'cv05';
  -webkit-font-smoothing: antialiased;
  min-height: 100vh;
}

.wrap { max-width: 1120px; margin: 0 auto; padding: 0 24px; }
.mono { font-family: 'JetBrains Mono', ui-monospace, 'SF Mono', monospace; }

/* ───────── nav ───────── */
.nav {
  position: sticky; top: 0; z-index: 50;
  background: color-mix(in srgb, var(--paper) 88%, transparent);
  backdrop-filter: saturate(180%) blur(8px);
  border-bottom: 1px solid var(--rule);
}
.nav__inner {
  max-width: 1120px; margin: 0 auto; padding: 0 24px;
  height: 68px; display: flex; align-items: center; justify-content: space-between;
}
.mark { display: inline-flex; align-items: center; gap: 9px; text-decoration: none; color: var(--ink); }
.mark__glyph { width: 20px; height: 24px; color: var(--mint); display: block; }
.mark__glyph svg { width: 100%; height: 100%; }
.mark__word {
  font-family: 'Fraunces', Georgia, serif;
  font-weight: 600; font-size: 20px; letter-spacing: -0.02em;
  font-variation-settings: 'SOFT' 0, 'WONK' 1, 'opsz' 24;
}
.nav__links { display: flex; align-items: center; gap: 28px; }
.nav__link {
  font-size: 14px; color: var(--ink-60); text-decoration: none;
  transition: color .15s ease;
}
.nav__link:hover { color: var(--ink); }
.nav__link--btn { padding: 0; }

/* ───────── buttons ───────── */
.btn {
  display: inline-flex; align-items: center; justify-content: center;
  font-size: 14px; font-weight: 500; letter-spacing: -0.005em;
  padding: 10px 18px; border-radius: 3px;
  text-decoration: none; border: 1px solid transparent;
  transition: background .16s ease, color .16s ease, border-color .16s ease;
}
.btn--ink { background: var(--ink); color: var(--paper); }
.btn--ink:hover { background: var(--mint); }
.btn--ink:disabled { background: var(--ink-30); cursor: not-allowed; }
.btn--ghost { border-color: var(--rule); color: var(--ink); background: transparent; }
.btn--ghost:hover { border-color: var(--ink); }
.btn--lg { padding: 15px 28px; font-size: 15px; }
.btn--block { width: 100%; }
.btn:focus-visible { outline: 2px solid var(--mint); outline-offset: 3px; }

/* ───────── shared type ───────── */
.eyebrow {
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px; letter-spacing: .16em; text-transform: uppercase;
  color: var(--mint); margin: 0 0 20px;
}
.sect__title {
  font-family: 'Fraunces', Georgia, serif;
  font-weight: 500; letter-spacing: -0.03em; line-height: 1.06;
  font-size: clamp(30px, 4vw, 46px);
  font-variation-settings: 'SOFT' 0, 'WONK' 1, 'opsz' 48;
  margin: 0 0 20px;
}
.lede { font-size: 17px; line-height: 1.65; color: var(--ink-60); margin: 0; max-width: 46ch; }
.lede--tight { font-size: 16px; }

/* ───────── hero ───────── */
.hero { padding: clamp(64px, 10vw, 116px) 0 0; }
.hero__inner { max-width: 1120px; margin: 0 auto; padding: 0 24px; }
.hero__title {
  font-family: 'Fraunces', Georgia, serif;
  font-weight: 400; font-size: clamp(46px, 9.2vw, 108px);
  line-height: .96; letter-spacing: -0.045em; margin: 0 0 40px;
  font-variation-settings: 'SOFT' 0, 'WONK' 1, 'opsz' 144;
  max-width: 13ch;
}
.hero__title em {
  display: block; font-style: italic; color: var(--mint);
  font-variation-settings: 'SOFT' 40, 'WONK' 1, 'opsz' 144;
}
.hero__body {
  display: grid; grid-template-columns: 1fr auto; gap: 40px;
  align-items: end; padding-bottom: clamp(48px, 7vw, 84px);
}
.hero__actions { display: flex; gap: 10px; flex-shrink: 0; }

/* ───────── signature: the arch ───────── */
.arch {
  border-top: 1px solid var(--rule); border-bottom: 1px solid var(--rule);
  background: var(--paper-2);
  padding: 26px 24px 30px;
  overflow: hidden;
}
.arch__label {
  max-width: 1120px; margin: 0 auto 18px; display: flex; gap: 14px; align-items: baseline;
  font-size: 11px; letter-spacing: .14em; text-transform: uppercase;
}
.arch__label .mono { color: var(--mint); }
.arch__labeltext { color: var(--ink-30); letter-spacing: .06em; }
.arch__row {
  max-width: 1120px; margin: 0 auto; display: flex; gap: 4px;
  justify-content: space-between;
}
.arch__row--lower { margin-top: 6px; }
.tooth {
  flex: 1 1 0; min-width: 0;
  font-family: 'JetBrains Mono', monospace; font-size: 11px;
  text-align: center; padding: 9px 0;
  color: var(--ink-30); background: transparent;
  border: 1px solid var(--rule); border-radius: 2px;
  transition: color .3s ease, background .3s ease, border-color .3s ease;
}
/* the arch curves: outer teeth sit lower, like a real arch */
.arch__row .tooth:nth-child(1),  .arch__row .tooth:nth-child(16) { transform: translateY(9px); }
.arch__row .tooth:nth-child(2),  .arch__row .tooth:nth-child(15) { transform: translateY(6px); }
.arch__row .tooth:nth-child(3),  .arch__row .tooth:nth-child(14) { transform: translateY(3px); }
.arch__row--lower .tooth:nth-child(1),  .arch__row--lower .tooth:nth-child(16) { transform: translateY(-9px); }
.arch__row--lower .tooth:nth-child(2),  .arch__row--lower .tooth:nth-child(15) { transform: translateY(-6px); }
.arch__row--lower .tooth:nth-child(3),  .arch__row--lower .tooth:nth-child(14) { transform: translateY(-3px); }

.tooth--on { color: var(--mint); background: var(--mint-bg); border-color: color-mix(in srgb, var(--mint) 30%, transparent); }

/* ───────── chart / features ───────── */
.chart { padding: clamp(72px, 10vw, 120px) 0; }
.sect { margin-bottom: 56px; }
.rows { list-style: none; margin: 0; padding: 0; border-top: 1px solid var(--rule); }
.row {
  display: grid; grid-template-columns: 72px minmax(0, 260px) minmax(0, 1fr);
  gap: 32px; align-items: start;
  padding: 30px 0; border-bottom: 1px solid var(--rule);
  transition: background .18s ease;
}
.row:hover { background: color-mix(in srgb, var(--mint-bg) 55%, transparent); }
.row__code { font-size: 12px; color: var(--mint); padding-top: 5px; letter-spacing: .06em; }
.row__name {
  font-family: 'Fraunces', Georgia, serif; font-weight: 500;
  font-size: 22px; letter-spacing: -0.02em; margin: 0; line-height: 1.25;
  font-variation-settings: 'SOFT' 0, 'WONK' 1, 'opsz' 24;
}
.row__desc { font-size: 15px; line-height: 1.68; color: var(--ink-60); margin: 0; max-width: 58ch; }

/* ───────── pricing ───────── */
.price { background: var(--paper-2); border-top: 1px solid var(--rule); border-bottom: 1px solid var(--rule); padding: clamp(72px, 10vw, 116px) 0; }
.price__grid { display: grid; grid-template-columns: minmax(0, 1.35fr) minmax(0, .85fr); gap: 64px; align-items: start; }
.incl { list-style: none; margin: 40px 0 0; padding: 0; }
.incl__item {
  display: flex; align-items: center; gap: 14px;
  font-size: 15px; color: var(--ink); padding: 13px 0;
  border-bottom: 1px solid var(--rule);
}
.incl__item:first-child { border-top: 1px solid var(--rule); }
.incl__rule { width: 18px; height: 1px; background: var(--mint); flex-shrink: 0; }

.quote { background: var(--paper); border: 1px solid var(--rule); border-radius: 4px; padding: 34px 30px; }
.quote__eyebrow { font-size: 11px; letter-spacing: .16em; text-transform: uppercase; color: var(--mint); margin: 0 0 18px; }
.quote__figure {
  font-family: 'Fraunces', Georgia, serif; font-weight: 400;
  font-size: 42px; letter-spacing: -0.04em; margin: 0 0 16px; line-height: 1;
  font-variation-settings: 'SOFT' 0, 'WONK' 1, 'opsz' 48;
}
.quote__note { font-size: 14px; line-height: 1.65; color: var(--ink-60); margin: 0 0 26px; }
.quote__fine { font-size: 12px; color: var(--ink-30); margin: 14px 0 0; text-align: center; }

/* ───────── real pricing plans (superadmin-managed) ───────── */
.plans { list-style: none; margin: 0 0 22px; padding: 0; }
.plans__item {
  display: flex; align-items: baseline; gap: 6px;
  padding: 12px 0; border-bottom: 1px solid var(--rule);
}
.plans__item:first-child { padding-top: 0; }
.plans__name { font-size: 14px; color: var(--ink); flex: 1; }
.plans__price {
  font-family: 'Fraunces', Georgia, serif; font-weight: 500;
  font-size: 20px; letter-spacing: -0.02em; color: var(--ink);
}
.plans__duration { font-size: 12px; color: var(--ink-30); }

/* ───────── request form ───────── */
.req { padding: clamp(72px, 10vw, 120px) 0; }
.req__grid { display: grid; grid-template-columns: minmax(0, .8fr) minmax(0, 1.2fr); gap: 64px; align-items: start; }
.req__intro { position: sticky; top: 108px; }
.req__panel { background: var(--paper-2); border: 1px solid var(--rule); border-radius: 4px; padding: 34px; }

.form__pair { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.field { margin-bottom: 20px; }
.field__label {
  display: flex; align-items: baseline; gap: 10px;
  font-size: 13px; font-weight: 500; color: var(--ink); margin-bottom: 8px;
}
.field__req {
  font-family: 'JetBrains Mono', monospace; font-size: 9px;
  letter-spacing: .12em; text-transform: uppercase; color: var(--ink-30);
}
.field__input {
  width: 100%; background: var(--paper);
  border: 1px solid var(--rule); border-radius: 3px;
  padding: 12px 14px; font-size: 15px; color: var(--ink);
  font-family: inherit;
  transition: border-color .16s ease, box-shadow .16s ease;
}
.field__input::placeholder { color: var(--ink-30); }
.field__input:focus {
  outline: none; border-color: var(--mint);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--mint) 14%, transparent);
}

.sending { display: inline-flex; align-items: center; gap: 9px; }
.sending__dot {
  width: 6px; height: 6px; border-radius: 50%; background: currentColor;
  animation: pulse 1.1s ease-in-out infinite;
}
@keyframes pulse { 0%, 100% { opacity: .25 } 50% { opacity: 1 } }

.done { padding: 12px 0 20px; }
.done__rule { display: block; width: 40px; height: 2px; background: var(--mint); margin-bottom: 26px; }
.done__title {
  font-family: 'Fraunces', Georgia, serif; font-weight: 500;
  font-size: 30px; letter-spacing: -0.03em; margin: 0 0 14px;
  font-variation-settings: 'SOFT' 0, 'WONK' 1, 'opsz' 36;
}
.done__body { font-size: 15px; line-height: 1.68; color: var(--ink-60); margin: 0; }
.done__body strong { color: var(--ink); font-weight: 500; }

/* ───────── footer ───────── */
.foot { border-top: 1px solid var(--rule); padding: 32px 0 44px; }
.foot__inner { display: flex; align-items: center; justify-content: space-between; gap: 20px; }
.mark--sm .mark__word { font-size: 16px; }
.foot__meta { font-size: 11px; color: var(--ink-30); letter-spacing: .04em; }

/* ───────── responsive ───────── */
@media (max-width: 900px) {
  .price__grid, .req__grid { grid-template-columns: 1fr; gap: 44px; }
  .req__intro { position: static; }
  .row { grid-template-columns: 48px 1fr; gap: 8px 20px; }
  .row__desc { grid-column: 2; }
  .hero__body { grid-template-columns: 1fr; align-items: start; gap: 30px; }
}
@media (max-width: 640px) {
  .nav__links { gap: 16px; }
  .nav__link:not(.nav__link--btn) { display: none; }
  .form__pair { grid-template-columns: 1fr; gap: 0; }
  .hero__actions { flex-direction: column; width: 100%; }
  .hero__actions .btn { width: 100%; }
  .arch__row { gap: 2px; }
  .tooth { font-size: 8px; padding: 6px 0; }
  .foot__inner { flex-direction: column; align-items: flex-start; }
}

@media (prefers-reduced-motion: reduce) {
  .purebite *, .purebite *::before, .purebite *::after {
    animation-duration: .01ms !important;
    transition-duration: .01ms !important;
  }
}
</style>
