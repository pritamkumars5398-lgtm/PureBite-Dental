<script setup lang="ts">
definePageMeta({
  layout: 'guest'
})

const auth = useAuth()
const router = useRouter()

const isSigningOut = ref(false)

const clinicInfo = computed(() => {
  return auth.clinics.value?.[0]
})

const neverHadSubscription = computed(() => {
  return clinicInfo.value && !clinicInfo.value.subscription_end_date && !clinicInfo.value.subscription_active
})

const lastSubscriptionDate = computed(() => {
  if (clinicInfo.value?.subscription_end_date) {
    try {
      return new Intl.DateTimeFormat('en-US', { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
      }).format(new Date(clinicInfo.value.subscription_end_date))
    } catch {
      return null
    }
  }
  return null
})

const pageTitle = computed(() => {
  if (neverHadSubscription.value) return 'Subscription not activated'
  return 'Subscription expired'
})

const pageBody = computed(() => {
  if (neverHadSubscription.value) {
    return 'Your clinic has not activated a subscription yet. Please contact your platform administrator to activate your workspace.'
  }
  if (lastSubscriptionDate.value) {
    return `Your subscription ended on ${lastSubscriptionDate.value}. Contact your administrator to renew.`
  }
  return 'Your workspace is paused. Contact your administrator to renew.'
})

async function handleLogout() {
  isSigningOut.value = true
  try {
    await auth.logout()
    router.push('/login')
  } finally {
    isSigningOut.value = false
  }
}
</script>

<template>
  <div class="expired-wrapper">
    <div class="expired">
      <div class="expired__mark" aria-hidden="true">
        <span class="expired__dot"></span>
        <span class="expired__ring"></span>
      </div>

      <h1 class="expired__title">{{ pageTitle }}</h1>

      <p class="expired__body">
        {{ pageBody }}
      </p>

      <button
        type="button"
        class="expired__out"
        :disabled="isSigningOut"
        @click="handleLogout"
      >
        {{ isSigningOut ? 'Signing out…' : 'Sign out' }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.expired-wrapper {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  width: 100%;
  overflow: hidden;
  background: radial-gradient(circle at 50% 0%, rgba(161, 98, 7, 0.04) 0%, transparent 60%);
}

.expired {
  --paper:  #F7F6F2;
  --ink:    #16191A;
  --ink-60: #5A6062;
  --ink-30: #9BA1A1;
  --rule:   #DCD9D0;
  --amber:  #A16207;

  width: 100%;
  max-width: 440px;
  padding: 48px 32px;
  text-align: center;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  -webkit-font-smoothing: antialiased;
  color: var(--ink);
  
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(220, 217, 208, 0.5);
  border-radius: 16px;
  box-shadow: 0 20px 40px -20px rgba(0, 0, 0, 0.05);
  
  animation: fadeUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
  opacity: 0;
  transform: translateY(10px);
}

.expired__mark {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  margin: 0 auto 32px;
  background: #fff;
  border: 1px solid var(--rule);
  border-radius: 50%;
  box-shadow: 0 4px 12px rgba(161, 98, 7, 0.05);
  animation: scaleIn 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) forwards 0.2s;
  opacity: 0;
  transform: scale(0.8);
}

.expired__dot {
  position: relative;
  z-index: 2;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--amber);
}

.expired__ring {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 100%;
  height: 100%;
  border: 1px solid var(--amber);
  border-radius: 50%;
  transform: translate(-50%, -50%);
  animation: pulseRing 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  opacity: 0;
}

.expired__title {
  font-family: 'Fraunces', Georgia, serif;
  font-weight: 400;
  font-size: 34px;
  letter-spacing: -0.03em;
  line-height: 1.15;
  font-variation-settings: 'SOFT' 0, 'WONK' 1, 'opsz' 36;
  margin: 0 0 16px;
  animation: fadeUp 0.6s ease forwards 0.3s;
  opacity: 0;
  transform: translateY(10px);
}

.expired__body {
  font-size: 16px;
  line-height: 1.6;
  color: var(--ink-60);
  margin: 0 0 36px;
  animation: fadeUp 0.6s ease forwards 0.4s;
  opacity: 0;
  transform: translateY(10px);
}

.expired__out {
  background: none;
  border: 0;
  padding: 8px 16px;
  cursor: pointer;
  font-family: inherit;
  font-size: 14px;
  font-weight: 500;
  color: var(--ink-60);
  border-radius: 20px;
  transition: all 0.2s ease;
  animation: fadeUp 0.6s ease forwards 0.5s;
  opacity: 0;
  transform: translateY(10px);
}

.expired__out:hover:not(:disabled) {
  color: var(--ink);
  background: rgba(0, 0, 0, 0.04);
}

.expired__out:disabled { cursor: default; opacity: 0.5; }
.expired__out:focus-visible { outline: 2px solid var(--ink); outline-offset: 2px; }

/* Animations */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes scaleIn {
  from { opacity: 0; transform: scale(0.8); }
  to { opacity: 1; transform: scale(1); }
}

@keyframes pulseRing {
  0% { transform: translate(-50%, -50%) scale(0.8); opacity: 0.8; }
  100% { transform: translate(-50%, -50%) scale(2); opacity: 0; }
}

@media (prefers-reduced-motion: reduce) {
  .expired *, .expired-wrapper * { 
    transition-duration: .01ms !important;
    animation-duration: .01ms !important;
  }
}
</style>
