<script setup lang="ts">
/**
 * DataListLayout — canonical shell for clinic list pages.
 *
 * Zendenta table chrome: one white 16–20px rounded page card with title,
 * result count, filter toolbar + primary action, muted column headers,
 * rows, then pagination.
 */
interface Props {
  title: string
  subtitle?: string
  /** Lowercase noun interpolated into the count line ("12 total invoices"). */
  noun?: string
  loading: boolean
  /** True when the result set is empty AND not loading. */
  empty: boolean
  /** Optional error message. */
  error?: string | null
  /** Pagination + count info. */
  page: number
  pageSize: number
  total: number
  totalPages: number
  /** When false, the heading is screen-reader only — the app chrome already shows the page name. */
  showTitle?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  subtitle: undefined,
  noun: undefined,
  error: null,
  skeletonRows: 6,
  showTitle: true,
})

const emit = defineEmits<{
  'update:page': [page: number]
}>()

const { t } = useI18n()

const countSuffix = computed(() => {
  if (props.noun) return t('lists.totalSuffix', { noun: props.noun })
  return t('lists.totalSuffixBare')
})

function onPage(value: number) {
  emit('update:page', value)
}
</script>

<template>
  <div
    class="overflow-hidden bg-[var(--color-surface)] rounded-[var(--radius-xl)]"
  >
    <header
      v-if="showTitle || subtitle || $slots.tabs"
      class="px-5 sm:px-6 pt-5 sm:pt-6"
    >
      <h1
        v-if="showTitle"
        class="text-h1 text-default text-pretty"
      >
        {{ title }}
      </h1>
      <h1
        v-else
        class="sr-only"
      >
        {{ title }}
      </h1>
      <p
        v-if="subtitle"
        class="mt-1 text-body text-muted text-pretty"
      >
        {{ subtitle }}
      </p>
      <div
        v-if="$slots.tabs"
        :class="(showTitle || subtitle) ? 'mt-4' : ''"
      >
        <slot name="tabs" />
      </div>
    </header>

    <div class="px-5 sm:px-6 py-4 flex flex-col gap-3 lg:flex-row lg:items-center">
      <p class="shrink-0 text-lg text-default">
        <span class="font-semibold tnum">{{ total }}</span>
        <span class="text-muted"> {{ countSuffix }}</span>
      </p>

      <div class="flex-1 min-w-0 flex items-center gap-2">
        <div
          v-if="$slots.toolbar"
          class="flex-1 min-w-0"
        >
          <slot name="toolbar" />
        </div>
        <div
          v-if="$slots.actions"
          class="shrink-0 ml-auto flex items-center gap-2 min-h-11"
        >
          <slot name="actions" />
        </div>
      </div>
    </div>

    <UAlert
      v-if="error"
      color="error"
      variant="soft"
      :title="t('common.error')"
      :description="error"
      class="mx-5 sm:mx-6 mb-3 rounded-[var(--radius-lg)]"
    />

    <div
      v-if="loading"
      class="px-5 sm:px-6 pb-6 space-y-3"
    >
      <USkeleton
        v-for="i in skeletonRows"
        :key="i"
        class="h-11 w-full rounded-[var(--radius-lg)]"
      />
    </div>

    <slot
      v-else-if="empty"
      name="empty"
    >
      <EmptyState
        icon="i-lucide-inbox"
        :title="t('lists.empty.title')"
        :description="t('lists.empty.description')"
      />
    </slot>

    <template v-else>
      <div
        v-if="$slots.columns"
        class="hidden md:flex items-center gap-3 px-5 sm:px-6 min-h-11 border-t border-b border-[var(--color-border-subtle)] text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]"
      >
        <slot name="columns" />
      </div>
      <div :class="$slots.columns ? '' : 'border-t border-[var(--color-border-subtle)]'">
        <slot name="rows" />
      </div>

      <div class="flex items-center justify-between gap-3 px-5 sm:px-6 py-3 min-h-11 border-t border-[var(--color-border-subtle)] text-caption text-subtle tnum">
        <span>
          {{ t('lists.resultCount', { shown: Math.min(page * pageSize, total), total }) }}
        </span>
        <div class="[&>:first-child]:mt-0 [&>:first-child]:border-0 [&>:first-child]:pt-0">
          <PaginationBar
            :page="page"
            :total-pages="totalPages"
            :total="total"
            :page-size="pageSize"
            @update:page="onPage"
          />
        </div>
      </div>
    </template>
  </div>
</template>
