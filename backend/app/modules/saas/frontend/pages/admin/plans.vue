<script setup lang="ts">
import type { SaasPricingPlan } from '~/composables/useSaasAdmin'

definePageMeta({
  title: 'Platform Administration - Pricing Plans'
})

const { t } = useI18n()

function formatRupees(amount: number) {
  return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(amount)
}

const {
  plans,
  isLoading,
  fetchAll,
  createPlan,
  togglePlanActive
} = useSaasAdmin()

onMounted(fetchAll)

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
        {{ t('saasAdmin.plans.heading') }}
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
                {{ t('saasAdmin.plans.durationMonths', { count: plan.duration_months }) }} · {{ formatRupees(plan.price) }}
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
                  step="1"
                  required
                >
                  <template #leading>
                    <span class="text-gray-500 sm:text-sm">₹</span>
                  </template>
                </UInput>
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
  </div>
</template>
