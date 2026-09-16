<script setup lang="ts">
/**
 * Sample FDI remaining-teeth illustration for the marketing page.
 * Not a live patient chart — states are a static demo of the odontogram.
 */
type ToothState = 'remaining' | 'missing' | 'restored' | 'planned'

const UPPER = ['18', '17', '16', '15', '14', '13', '12', '11', '21', '22', '23', '24', '25', '26', '27', '28']
const LOWER = ['48', '47', '46', '45', '44', '43', '42', '41', '31', '32', '33', '34', '35', '36', '37', '38']

const SAMPLE: Record<string, ToothState> = {
  18: 'missing',
  16: 'restored',
  14: 'planned',
  28: 'missing',
  26: 'restored',
  24: 'planned',
  38: 'missing',
  36: 'planned',
  46: 'restored',
  48: 'missing'
}

const { t } = useI18n()
const hovered = ref<string | null>(null)

function stateOf(id: string): ToothState {
  return SAMPLE[id] ?? 'remaining'
}

const remainingCount = computed(() =>
  [...UPPER, ...LOWER].filter(id => stateOf(id) !== 'missing').length
)

const legend = [
  { id: 'remaining' as const, key: 'landing.remaining.remaining' },
  { id: 'missing' as const, key: 'landing.remaining.missing' },
  { id: 'restored' as const, key: 'landing.remaining.restored' },
  { id: 'planned' as const, key: 'landing.remaining.planned' }
]
</script>

<template>
  <div class="viz">
    <div class="viz__meta">
      <p class="viz__count">
        {{ t('landing.remaining.count', { n: remainingCount }) }}
      </p>
      <p class="viz__note">
        {{ t('landing.remaining.sample') }}
      </p>
    </div>

    <div
      class="viz__arch"
      role="img"
      :aria-label="t('landing.remaining.aria')"
    >
      <div class="viz__row">
        <button
          v-for="id in UPPER"
          :key="id"
          type="button"
          class="viz__tooth"
          :class="[`is-${stateOf(id)}`, { 'is-hover': hovered === id }]"
          :aria-label="`${id} — ${t('landing.remaining.' + stateOf(id))}`"
          @mouseenter="hovered = id"
          @mouseleave="hovered = null"
          @focus="hovered = id"
          @blur="hovered = null"
        >
          <svg
            viewBox="0 0 24 32"
            aria-hidden="true"
          >
            <path d="M12 2.2c3.4 0 6.4 2.6 6.6 6.2.2 2.8-.4 6.6-1.1 10.4-.5 2.6-1 5.7-2.4 6.6-1.1.7-3.1.8-3.1.8s-2 0-3.1-.8c-1.4-.9-1.9-4-2.4-6.6C5.8 15 5.2 11.2 5.4 8.4 5.6 4.8 8.6 2.2 12 2.2Z" />
          </svg>
          <span class="viz__fdi">{{ id }}</span>
        </button>
      </div>
      <div class="viz__row viz__row--lower">
        <button
          v-for="id in LOWER"
          :key="id"
          type="button"
          class="viz__tooth viz__tooth--lower"
          :class="[`is-${stateOf(id)}`, { 'is-hover': hovered === id }]"
          :aria-label="`${id} — ${t('landing.remaining.' + stateOf(id))}`"
          @mouseenter="hovered = id"
          @mouseleave="hovered = null"
          @focus="hovered = id"
          @blur="hovered = null"
        >
          <svg
            viewBox="0 0 24 32"
            aria-hidden="true"
          >
            <path d="M12 29.8c3.4 0 6.4-2.6 6.6-6.2.2-2.8-.4-6.6-1.1-10.4-.5-2.6-1-5.7-2.4-6.6-1.1-.7-3.1-.8-3.1-.8s-2 0-3.1.8c-1.4.9-1.9 4-2.4 6.6C5.8 17 5.2 20.8 5.4 23.6c.2 3.6 3.2 6.2 6.6 6.2Z" />
          </svg>
          <span class="viz__fdi">{{ id }}</span>
        </button>
      </div>
    </div>

    <ul class="viz__legend">
      <li
        v-for="item in legend"
        :key="item.id"
        class="viz__legend-item"
      >
        <span
          class="viz__swatch"
          :class="`is-${item.id}`"
        />
        {{ t(item.key) }}
      </li>
    </ul>
  </div>
</template>

<style scoped>
.viz {
  display: grid;
  gap: 18px;
}
.viz__meta { display: flex; align-items: baseline; justify-content: space-between; gap: 12px; flex-wrap: wrap; }
.viz__count { margin: 0; font-size: 22px; font-weight: 700; letter-spacing: -0.03em; }
.viz__note { margin: 0; font-size: 12px; color: var(--color-text-subtle); }
.viz__arch {
  background: #fff;
  border: 1px solid var(--color-border-subtle);
  border-radius: 24px;
  padding: 20px 16px 16px;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}
.viz__row { display: flex; gap: 4px; justify-content: space-between; }
.viz__row--lower { margin-top: 10px; }
.viz__tooth {
  flex: 1 1 0;
  min-width: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 4px 0 2px;
  border: 0;
  background: transparent;
  cursor: pointer;
  border-radius: 10px;
}
.viz__tooth svg { width: 100%; max-width: 28px; height: 38px; display: block; }
.viz__tooth path {
  stroke-width: 1.2;
  transition: fill .16s ease, stroke .16s ease, opacity .16s ease;
}
.viz__tooth--lower { flex-direction: column-reverse; }
.viz__fdi {
  font-family: ui-monospace, monospace;
  font-size: 9px;
  color: var(--color-text-subtle);
}
.is-remaining path { fill: #fff; stroke: #94a3b8; }
.is-missing path { fill: transparent; stroke: #94a3b8; stroke-dasharray: 3 2; opacity: .45; }
.is-restored path { fill: var(--color-primary-soft); stroke: var(--color-primary); }
.is-planned path { fill: var(--color-warning-soft); stroke: var(--color-warning-accent); }
.is-hover { background: var(--color-canvas); }
.viz__legend {
  list-style: none; margin: 0; padding: 0;
  display: flex; flex-wrap: wrap; gap: 14px 18px;
}
.viz__legend-item {
  display: inline-flex; align-items: center; gap: 8px;
  font-size: 13px; color: var(--color-text-muted);
}
.viz__swatch {
  width: 14px; height: 18px; border-radius: 6px 6px 8px 8px;
  border: 1.5px solid #94a3b8; background: #fff;
}
.viz__swatch.is-missing { background: transparent; border-style: dashed; opacity: .7; }
.viz__swatch.is-restored { background: var(--color-primary-soft); border-color: var(--color-primary); }
.viz__swatch.is-planned { background: var(--color-warning-soft); border-color: var(--color-warning-accent); }

@media (max-width: 640px) {
  .viz__tooth svg { height: 28px; }
  .viz__fdi { font-size: 8px; }
}

@media (max-width: 480px) {
  .viz__row { min-width: 440px; }
  .viz__count { font-size: 18px; }
}
</style>
