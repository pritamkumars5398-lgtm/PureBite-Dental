<script setup lang="ts">
const api = useApi()
const auth = useAuth()
const clinic = computed(() => auth.clinics.value?.[0])

const { data: subscriptions, pending } = await useAsyncData('clinic-subscriptions', () => {
  return api.get<any[]>('/api/v1/saas/subscriptions')
})

const subStatusColor: Record<string, string> = {
  active: 'success',
  upcoming: 'neutral',
  expired: 'error'
}

const daysRemaining = computed(() => {
  if (!clinic.value?.subscription_active || !clinic.value?.subscription_end_date) return null
  const end = new Date(clinic.value.subscription_end_date)
  const now = new Date()
  const diffTime = end.getTime() - now.getTime()
  return Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)))
})

function fmtDate(iso?: string) {
  if (!iso) return ''
  return new Intl.DateTimeFormat('en-US', {
    dateStyle: 'medium'
  }).format(new Date(iso))
}
</script>

<template>
  <div class="space-y-6 max-w-3xl">
    <div>
      <UButton
        variant="ghost"
        color="gray"
        icon="i-lucide-arrow-left"
        to="/settings"
        class="mb-4 -ml-2"
      >
        Back to Settings
      </UButton>
      <h2 class="text-h2 text-default mb-1">Clinic Subscription</h2>
      <p class="text-caption text-subtle">View your current subscription status and billing history.</p>
    </div>

    <!-- Current Status -->
    <section>
      <h3 class="text-base font-semibold text-default mb-3">Current Status</h3>
      <UCard class="shadow-sm border-t-4 border-t-primary-500">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-sm font-medium text-default mb-1">
              {{ clinic?.name }}
            </h4>
            <div class="text-sm text-subtle" v-if="clinic?.subscription_active && clinic?.subscription_end_date">
              <p>Your subscription is active and will expire on <strong class="text-default font-medium">{{ fmtDate(clinic.subscription_end_date) }}</strong>.</p>
              <p class="mt-1 font-medium text-primary-600 dark:text-primary-400" v-if="daysRemaining !== null">
                {{ daysRemaining }} day(s) remaining
              </p>
            </div>
            <p class="text-sm text-error" v-else-if="clinic?.subscription_end_date">
              Your subscription expired on <strong class="font-medium">{{ fmtDate(clinic.subscription_end_date) }}</strong>.
            </p>
            <p class="text-sm text-subtle" v-else>
              No active subscription found.
            </p>
          </div>
          <UBadge
            :color="clinic?.subscription_active ? 'success' : 'error'"
            variant="subtle"
            size="lg"
          >
            {{ clinic?.subscription_active ? 'Active' : 'Expired / None' }}
          </UBadge>
        </div>
      </UCard>
    </section>

    <!-- History -->
    <section>
      <h3 class="text-base font-semibold text-default mb-3">Subscription History</h3>
      
      <div v-if="pending" class="space-y-3">
        <USkeleton class="h-20 w-full" />
        <USkeleton class="h-20 w-full" />
      </div>
      
      <div v-else-if="!subscriptions?.length" class="p-6 text-center text-subtle border border-[var(--color-border-subtle)] rounded-md bg-gray-50 dark:bg-gray-800/50">
        No subscription history available.
      </div>
      
      <div v-else class="space-y-3">
        <div
          v-for="sub in subscriptions"
          :key="sub.id"
          class="flex flex-col gap-2 p-4 bg-gray-50 dark:bg-gray-800/50 rounded-md border border-[var(--color-border-subtle)]"
        >
          <div class="flex items-center justify-between">
            <span class="text-sm font-medium text-default">
              {{ fmtDate(sub.start_date) }} – {{ fmtDate(sub.end_date) }}
            </span>
            <UBadge
              :color="subStatusColor[sub.effective_status] || 'neutral'"
              variant="subtle"
              size="sm"
              class="capitalize"
            >
              {{ sub.effective_status }}
            </UBadge>
          </div>
          <div class="flex items-center gap-2 text-xs text-subtle mt-1" v-if="sub.plan">
            <UIcon name="i-lucide-tag" class="w-4 h-4 text-primary-500" />
            <span class="font-medium text-default">{{ sub.plan.name }}</span>
            <span>·</span>
            <span>₹{{ sub.plan.price }} for {{ sub.plan.duration_months }} mo</span>
          </div>
          <div class="flex items-center gap-2 text-xs text-subtle mt-1" v-else>
             <UIcon name="i-lucide-calendar" class="w-4 h-4 text-primary-500" />
             <span class="font-medium text-default">Custom Duration</span>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
