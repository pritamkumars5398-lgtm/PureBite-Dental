<script setup lang="ts">
interface Props {
  title: string
  subtitle?: string
  /** When false, the heading is screen-reader only — the app chrome already shows the page name. */
  showTitle?: boolean
}

withDefaults(defineProps<Props>(), {
  subtitle: undefined,
  showTitle: true
})
</script>

<template>
  <header class="mb-5">
    <div
      v-if="showTitle || subtitle || $slots.actions"
      class="flex items-start justify-between gap-4"
    >
      <div class="min-w-0">
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
          class="mt-1 text-caption text-muted text-pretty"
        >
          {{ subtitle }}
        </p>
      </div>
      <div
        v-if="$slots.actions"
        class="flex items-center gap-2 shrink-0"
      >
        <slot name="actions" />
      </div>
    </div>
    <div
      v-if="$slots.tabs"
      :class="(showTitle || subtitle || $slots.actions) ? 'mt-4 -mb-px border-b border-subtle' : '-mb-px border-b border-subtle'"
    >
      <slot name="tabs" />
    </div>
  </header>
</template>
