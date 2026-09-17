<script setup lang="ts">
/** Decorative FDI-style remaining-teeth vector. Not a live patient chart. */
const upper = ['18', '17', '16', '15', '14', '13', '12', '11', '21', '22', '23', '24', '25', '26', '27', '28']
const lower = ['48', '47', '46', '45', '44', '43', '42', '41', '31', '32', '33', '34', '35', '36', '37', '38']
const missing = new Set(['18', '28', '38', '48'])
const restored = new Set(['16', '26', '46'])
const planned = new Set(['14', '24'])

function kind(id: string) {
  if (missing.has(id)) return 'missing'
  if (restored.has(id)) return 'restored'
  if (planned.has(id)) return 'planned'
  return 'remaining'
}
</script>

<template>
  <div
    class="arch-art"
    aria-hidden="true"
  >
    <div class="arch-art__row">
      <span
        v-for="id in upper"
        :key="id"
        class="arch-art__tooth"
        :class="`is-${kind(id)}`"
      >
        <svg viewBox="0 0 24 32">
          <path d="M12 2.2c3.4 0 6.4 2.6 6.6 6.2.2 2.8-.4 6.6-1.1 10.4-.5 2.6-1 5.7-2.4 6.6-1.1.7-3.1.8-3.1.8s-2 0-3.1-.8c-1.4-.9-1.9-4-2.4-6.6C5.8 15 5.2 11.2 5.4 8.4 5.6 4.8 8.6 2.2 12 2.2Z" />
        </svg>
      </span>
    </div>
    <div class="arch-art__row arch-art__row--lower">
      <span
        v-for="id in lower"
        :key="id"
        class="arch-art__tooth is-lower"
        :class="`is-${kind(id)}`"
      >
        <svg viewBox="0 0 24 32">
          <path d="M12 29.8c3.4 0 6.4-2.6 6.6-6.2.2-2.8-.4-6.6-1.1-10.4-.5-2.6-1-5.7-2.4-6.6-1.1-.7-3.1-.8-3.1-.8s-2 0-3.1.8c-1.4.9-1.9 4-2.4 6.6C5.8 17 5.2 20.8 5.4 23.6c.2 3.6 3.2 6.2 6.6 6.2Z" />
        </svg>
      </span>
    </div>
  </div>
</template>

<style scoped>
.arch-art { display: grid; gap: 10px; width: 100%; }
.arch-art__row { display: flex; gap: 3px; justify-content: space-between; }
.arch-art__tooth {
  flex: 1 1 0;
  min-width: 0;
  display: flex;
  justify-content: center;
}
.arch-art__tooth svg { width: 100%; max-width: 28px; height: 40px; display: block; }
.arch-art__tooth path { stroke-width: 1.15; }
.is-remaining path { fill: var(--color-surface); stroke: var(--color-text-subtle); }
.dark .is-remaining path { fill: rgba(250, 250, 250, 0.92); }
.is-missing path { fill: transparent; stroke: var(--color-text-subtle); stroke-dasharray: 3 2; opacity: .4; }
.is-restored path { fill: var(--color-primary-soft); stroke: var(--color-primary); }
.is-planned path { fill: var(--color-warning-soft); stroke: var(--color-warning-accent); }
</style>
