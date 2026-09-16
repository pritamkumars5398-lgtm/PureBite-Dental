<script setup lang="ts">
/**
 * DataListItem — row wrapper with dual layout (Zendenta table chrome).
 *
 *   md+:    renders the ``row`` slot (compact horizontal row).
 *   <md:    renders the ``card`` slot (mobile-first card with prominent
 *           operational metric).
 *
 * Splits on ``NuxtLink`` vs ``div`` via ``v-if`` (same pattern as
 * ``ListRow``). Using ``<component :is="'NuxtLink'">`` proved unreliable
 * — string resolution didn't always pick up the global registration,
 * leaving rows non-clickable.
 */
interface Props {
  /** Optional NuxtLink target — when set, the whole row/card becomes a link. */
  to?: string
}

defineProps<Props>()

const wrapperClass
  = 'group/row block focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-[var(--color-primary)]'
const rowClass
  = 'hidden md:flex items-center gap-3 px-5 sm:px-6 py-3 min-h-11 transition-colors hover:bg-[var(--color-canvas)] border-b border-[var(--color-border-subtle)] group-last/row:border-b-0'
const cardClass
  = 'md:hidden flex flex-col gap-2 px-5 py-4 min-h-11 transition-colors hover:bg-[var(--color-canvas)] active:bg-[var(--color-canvas)] border-b border-[var(--color-border-subtle)] group-last/row:border-b-0'
</script>

<template>
  <NuxtLink
    v-if="to"
    :to="to"
    :class="wrapperClass"
  >
    <div :class="rowClass">
      <slot name="row" />
    </div>
    <div :class="cardClass">
      <slot name="card">
        <slot name="row" />
      </slot>
    </div>
  </NuxtLink>

  <div
    v-else
    :class="wrapperClass"
  >
    <div :class="rowClass">
      <slot name="row" />
    </div>
    <div :class="cardClass">
      <slot name="card">
        <slot name="row" />
      </slot>
    </div>
  </div>
</template>
