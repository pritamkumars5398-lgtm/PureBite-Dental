<script setup lang="ts">
withDefaults(defineProps<{
  size?: 'sm' | 'md' | 'lg'
}>(), {
  size: 'md'
})
</script>

<template>
  <span
    class="tooth-mark"
    :class="`tooth-mark--${size}`"
    aria-hidden="true"
  >
    <svg
      viewBox="0 0 24 28"
      fill="none"
      stroke="currentColor"
      stroke-width="1.6"
    >
      <path
        d="M12 5.5C9.5 2.5 4 2.8 2.8 7c-1.1 3.9 1 7.2 2 11.4.7 3 1.3 6.4 3.2 6.4 1.7 0 1.8-3.2 2.3-5.6.3-1.4.6-2.4 1.7-2.4s1.4 1 1.7 2.4c.5 2.4.6 5.6 2.3 5.6 1.9 0 2.5-3.4 3.2-6.4 1-4.2 3.1-7.5 2-11.4C20 2.8 14.5 2.5 12 5.5Z"
        stroke-linejoin="round"
      />
    </svg>
  </span>
</template>

<style scoped>
.tooth-mark {
  display: grid;
  place-items: center;
  flex-shrink: 0;
  border-radius: 999px;
  background: var(--color-primary);
  color: #fff;
  box-shadow: 0 8px 20px color-mix(in srgb, var(--color-primary) 32%, transparent);
}
.tooth-mark--sm { width: 28px; height: 28px; }
.tooth-mark--sm svg { width: 12px; height: 14px; }
.tooth-mark--md { width: 48px; height: 48px; }
.tooth-mark--md svg { width: 20px; height: 24px; }
.tooth-mark--lg { width: 64px; height: 64px; }
.tooth-mark--lg svg { width: 28px; height: 32px; }
</style>
