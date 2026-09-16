<script setup lang="ts">
/**
 * Host-only chrome for clinic home tiles: white surface, large radius,
 * no shadow or border. Optional caption for the tile meta line.
 */
defineProps<{
  title?: string
  caption?: string
  to?: string
}>()
</script>

<template>
  <NuxtLink
    v-if="to"
    :to="to"
    class="dashboard-card flex flex-col h-full min-w-0 rounded-[20px] bg-surface p-5 focus:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-primary)]"
  >
    <div
      v-if="title || caption || $slots.actions || $slots.title"
      class="flex items-start justify-between gap-3 mb-4"
    >
      <div class="min-w-0">
        <h2
          v-if="title"
          class="text-h3 text-default truncate"
        >
          {{ title }}
        </h2>
        <slot name="title" />
      </div>
      <div class="flex items-center gap-2 shrink-0">
        <span
          v-if="caption"
          class="text-caption text-subtle whitespace-nowrap"
        >
          {{ caption }}
        </span>
        <slot name="actions" />
      </div>
    </div>
    <div class="flex-1 min-h-0">
      <slot />
    </div>
  </NuxtLink>
  <div
    v-else
    class="dashboard-card flex flex-col h-full min-w-0 rounded-[20px] bg-surface p-5"
  >
    <div
      v-if="title || caption || $slots.actions || $slots.title"
      class="flex items-start justify-between gap-3 mb-4"
    >
      <div class="min-w-0">
        <h2
          v-if="title"
          class="text-h3 text-default truncate"
        >
          {{ title }}
        </h2>
        <slot name="title" />
      </div>
      <div class="flex items-center gap-2 shrink-0">
        <span
          v-if="caption"
          class="text-caption text-subtle whitespace-nowrap"
        >
          {{ caption }}
        </span>
        <slot name="actions" />
      </div>
    </div>
    <div class="flex-1 min-h-0">
      <slot />
    </div>
  </div>
</template>
