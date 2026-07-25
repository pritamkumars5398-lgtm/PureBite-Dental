<script setup lang="ts">
definePageMeta({
  title: 'Platform Administration Dashboard'
})
const { t } = useI18n()
const { leads, clinics, plans, isLoading, fetchAll } = useSaasAdmin()

onMounted(fetchAll)
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          {{ t('nav.dashboard') }}
        </h1>
        <p class="text-sm text-gray-500 dark:text-gray-400">
          {{ t('saasAdmin.subtitle') }}
        </p>
      </div>
      <UButton
        to="/admin/clinics?provision=true"
        color="primary"
        variant="solid"
        size="md"
        class="shadow-sm hidden sm:flex"
        icon="i-lucide-plus"
      >
        {{ t('saasAdmin.clinics.provision') }}
      </UButton>
    </div>

    <div v-if="isLoading" class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <USkeleton class="h-[148px] w-full" />
      <USkeleton class="h-[148px] w-full" />
      <USkeleton class="h-[148px] w-full" />
    </div>
    <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <UCard class="flex flex-col items-center justify-center text-center">
        <UIcon name="i-lucide-users" class="w-8 h-8 text-primary mb-2" />
        <h3 class="text-lg font-semibold">{{ leads.length }}</h3>
        <p class="text-sm text-muted">{{ t('saasAdmin.tabs.leads') }}</p>
        <UButton to="/admin/leads" variant="link" class="mt-2">View</UButton>
      </UCard>
      <UCard class="flex flex-col items-center justify-center text-center">
        <UIcon name="i-lucide-building" class="w-8 h-8 text-primary mb-2" />
        <h3 class="text-lg font-semibold">{{ clinics.length }}</h3>
        <p class="text-sm text-muted">{{ t('saasAdmin.tabs.clinics') }}</p>
        <UButton to="/admin/clinics" variant="link" class="mt-2">View</UButton>
      </UCard>
      <UCard class="flex flex-col items-center justify-center text-center">
        <UIcon name="i-lucide-tags" class="w-8 h-8 text-primary mb-2" />
        <h3 class="text-lg font-semibold">{{ plans.length }}</h3>
        <p class="text-sm text-muted">{{ t('saasAdmin.tabs.plans') }}</p>
        <UButton to="/admin/plans" variant="link" class="mt-2">View</UButton>
      </UCard>
    </div>
  </div>
</template>
