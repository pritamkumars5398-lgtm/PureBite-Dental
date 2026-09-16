<script setup lang="ts">
interface Props {
  icon?: string
  title: string
  description?: string
  /** Tighter padding for dense dashboard cards. */
  compact?: boolean
}

withDefaults(defineProps<Props>(), {
  icon: 'i-lucide-inbox',
  compact: false
})
</script>

<template>
  <div
    class="flex flex-col items-center justify-center text-center px-6"
    :class="compact ? 'py-8' : 'py-16'"
  >
    <div
      class="mb-4 flex items-center justify-center rounded-full bg-[var(--color-canvas)] ring-1 ring-[var(--color-border-subtle)]"
      :class="compact ? 'h-11 w-11' : 'h-14 w-14'"
    >
      <UIcon
        :name="icon"
        class="text-subtle"
        :class="compact ? 'w-5 h-5' : 'w-6 h-6'"
      />
    </div>
    <h3 class="text-h2 text-default mb-1">
      {{ title }}
    </h3>
    <p
      v-if="description"
      class="text-body text-muted max-w-sm"
    >
      {{ description }}
    </p>
    <div
      v-if="$slots.actions"
      class="mt-6 flex items-center gap-2 min-h-11"
    >
      <slot name="actions" />
    </div>
  </div>
</template>
