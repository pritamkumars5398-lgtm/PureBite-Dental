<script setup lang="ts">
import { PERMISSIONS } from '~/config/permissions'

const { t } = useI18n()
const { can } = usePermissions()
const { messages, busy, reset } = useCopilot()

if (!can(PERMISSIONS.copilot.chat)) {
  throw createError({ statusCode: 403, statusMessage: 'Forbidden' })
}
</script>

<template>
  <div
    class="mx-auto flex h-[calc(100vh-8rem)] max-w-3xl flex-col overflow-hidden bg-[var(--color-surface)]"
    style="border-radius: var(--radius-xl)"
  >
    <div class="flex items-start justify-between gap-3 px-5 sm:px-6 pt-5 pb-3">
      <div>
        <h1 class="sr-only">
          {{ t('copilot.page.title') }}
        </h1>
        <p class="text-body text-muted">
          {{ t('copilot.page.subtitle') }}
        </p>
      </div>
      <UButton
        v-if="messages.length"
        icon="i-lucide-plus"
        color="primary"
        variant="solid"
        size="sm"
        class="rounded-full"
        :disabled="busy"
        @click="reset"
      >
        {{ t('copilot.new') }}
      </UButton>
    </div>

    <div class="flex-1 overflow-hidden px-3 sm:px-4 pb-4">
      <CopilotDrawer />
    </div>
  </div>
</template>
