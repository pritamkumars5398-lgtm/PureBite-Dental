<script setup lang="ts">
import type { Recall } from '../composables/useRecalls'

interface Props {
  items: Recall[]
  isLoading: boolean
}
defineProps<Props>()

const emit = defineEmits<{ changed: [recall: Recall] }>()
const { t } = useI18n()
</script>

<template>
  <div>
    <div
      v-if="isLoading"
      class="px-5 sm:px-6 pb-6 space-y-3"
    >
      <USkeleton
        v-for="i in 5"
        :key="i"
        class="h-16 w-full rounded-[var(--radius-lg)]"
      />
    </div>
    <EmptyState
      v-else-if="items.length === 0"
      icon="i-lucide-phone"
      :title="t('recalls.noRecallsThisMonth')"
    />
    <template v-else>
      <div class="hidden md:flex items-center gap-3 px-5 sm:px-6 py-2.5 border-t border-b border-[var(--color-border-subtle)] text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]">
        <span class="w-9 shrink-0" />
        <span class="flex-1">{{ t('lists.columns.patient') }}</span>
        <span class="w-28">{{ t('lists.columns.reason') }}</span>
        <span class="w-24">{{ t('lists.columns.status') }}</span>
        <span class="w-24">{{ t('lists.columns.priority') }}</span>
        <span class="w-28">{{ t('lists.columns.phone') }}</span>
        <span class="w-40" />
      </div>
      <ul>
        <li
          v-for="recall in items"
          :key="recall.id"
        >
          <RecallRow
            :recall="recall"
            @changed="emit('changed', $event)"
          />
        </li>
      </ul>
    </template>
  </div>
</template>
