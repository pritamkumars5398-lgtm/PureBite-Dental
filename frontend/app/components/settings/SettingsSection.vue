<script setup lang="ts">
/**
 * SettingsSection — landing-page card for one settings page or inline
 * editor. Hosts the icon header, title, optional subtitle, attention
 * dot, and a body slot (or behaves as a card-link when ``to`` is set).
 */
interface Props {
  icon: string
  title: string
  subtitle?: string
  /** Renders an amber left border + dot when true. */
  attention?: boolean
  /** When set, the entire card becomes a NuxtLink. */
  to?: string
  /** Hide the chevron at the right when ``to`` is set. */
  noChevron?: boolean
}

withDefaults(defineProps<Props>(), {
  attention: false,
  noChevron: false
})
</script>

<template>
  <NuxtLink
    v-if="to"
    :to="to"
    class="block rounded-[var(--radius-xl)] bg-(--color-surface) transition cursor-pointer"
    :class="attention ? 'border-l-4 border-(--color-warning-accent)' : ''"
  >
    <div class="p-5 sm:p-6">
      <div class="flex items-start gap-3.5">
        <div class="shrink-0 w-10 h-10 rounded-[12px] bg-(--color-primary-soft) flex items-center justify-center">
          <UIcon
            :name="icon"
            class="w-5 h-5"
            :style="{ color: 'var(--color-primary)' }"
          />
        </div>
        <div class="min-w-0 flex-1">
          <div class="flex items-center gap-2">
            <h3 class="text-h3 text-default truncate">
              {{ title }}
            </h3>
            <span
              v-if="attention"
              class="w-2 h-2 rounded-full bg-(--color-warning-accent) shrink-0"
              aria-hidden="true"
            />
          </div>
          <p
            v-if="subtitle"
            class="mt-1 text-caption text-muted text-pretty"
          >
            {{ subtitle }}
          </p>
          <div
            v-if="$slots.default"
            class="mt-3"
          >
            <slot />
          </div>
        </div>
        <div
          v-if="$slots.actions"
          class="shrink-0 flex items-center gap-2"
        >
          <slot name="actions" />
        </div>
        <UIcon
          v-else-if="!noChevron"
          name="i-lucide-chevron-right"
          class="shrink-0 w-5 h-5 text-subtle self-center"
        />
      </div>
    </div>
  </NuxtLink>

  <div
    v-else
    class="block rounded-[var(--radius-xl)] bg-(--color-surface) transition"
    :class="attention ? 'border-l-4 border-(--color-warning-accent)' : ''"
  >
    <div class="p-5 sm:p-6">
      <div class="flex items-start gap-3.5">
        <div class="shrink-0 w-10 h-10 rounded-[12px] bg-(--color-primary-soft) flex items-center justify-center">
          <UIcon
            :name="icon"
            class="w-5 h-5"
            :style="{ color: 'var(--color-primary)' }"
          />
        </div>
        <div class="min-w-0 flex-1">
          <div class="flex items-center gap-2">
            <h3 class="text-h3 text-default truncate">
              {{ title }}
            </h3>
            <span
              v-if="attention"
              class="w-2 h-2 rounded-full bg-(--color-warning-accent) shrink-0"
              aria-hidden="true"
            />
          </div>
          <p
            v-if="subtitle"
            class="mt-1 text-caption text-muted text-pretty"
          >
            {{ subtitle }}
          </p>
          <div
            v-if="$slots.default"
            class="mt-3"
          >
            <slot />
          </div>
        </div>
        <div
          v-if="$slots.actions"
          class="shrink-0 flex items-center gap-2"
        >
          <slot name="actions" />
        </div>
      </div>
    </div>
  </div>
</template>
