<script setup lang="ts">
/**
 * SkeletonCard — universal shimmer loading placeholder.
 *
 * Renders a UCard with animated skeleton rows matching common
 * card body patterns (info list, totals, content block).
 *
 * Variants:
 *   'rows'    — label + value pairs (EntityInfoCard, EntityTotalsCard)
 *   'content' — heading + paragraph block (SectionCard, general)
 *   'kpi'     — large number + hint line (dashboard tiles)
 */
interface Props {
  variant?: 'rows' | 'content' | 'kpi'
  /** Number of skeleton rows to render (for 'rows' variant). */
  rows?: number
  title?: string
}

withDefaults(defineProps<Props>(), {
  variant: 'rows',
  rows: 4,
  title: undefined,
})
</script>

<template>
  <UCard>
    <template
      v-if="title"
      #header
    >
      <USkeleton class="h-5 w-40" />
    </template>

    <!-- Rows: label / value pairs -->
    <div
      v-if="variant === 'rows'"
      class="space-y-3"
      aria-busy="true"
      aria-label="Loading…"
    >
      <div
        v-for="i in rows"
        :key="i"
        class="flex items-center justify-between gap-3"
      >
        <USkeleton class="h-4 w-1/3" />
        <USkeleton class="h-4 w-1/4" />
      </div>
    </div>

    <!-- Content: heading + paragraph lines -->
    <div
      v-else-if="variant === 'content'"
      class="space-y-3"
      aria-busy="true"
      aria-label="Loading…"
    >
      <USkeleton class="h-6 w-2/3" />
      <USkeleton class="h-4 w-full" />
      <USkeleton class="h-4 w-5/6" />
      <USkeleton class="h-4 w-4/6" />
    </div>

    <!-- KPI: big number + hint -->
    <div
      v-else-if="variant === 'kpi'"
      class="space-y-2"
      aria-busy="true"
      aria-label="Loading…"
    >
      <USkeleton class="h-8 w-3/4" />
      <USkeleton class="h-3 w-1/2" />
    </div>
  </UCard>
</template>
