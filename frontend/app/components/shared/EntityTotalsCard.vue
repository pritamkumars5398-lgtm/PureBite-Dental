<script setup lang="ts">
import type { SemanticRole } from '~/config/severity'
import { roleToUiColor } from '~/config/severity'

export interface TotalLine {
  key: string
  label: string
  value: number | string | null | undefined
  emphasis?: 'normal' | 'subtle' | 'strong'
  sign?: '+' | '-' | null
  role?: SemanticRole
  divider?: 'above' | 'below' | null
}

interface Props {
  lines: TotalLine[]
  title?: string
  /** Show shimmer skeleton while totals are loading. */
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  title: undefined,
  loading: false,
})

const { t } = useI18n()
const { format } = useCurrency()

const heading = computed(() => props.title ?? t('shared.totals'))

function colorClass(role?: SemanticRole) {
  if (!role || role === 'neutral') return ''
  const ui = roleToUiColor(role)
  const map: Record<string, string> = {
    primary: 'text-primary-accent',
    success: 'text-success-accent',
    info: 'text-info-accent',
    warning: 'text-warning-accent',
    error: 'text-danger-accent'
  }
  return map[ui] ?? ''
}

function signedValue(line: TotalLine): string {
  const formatted = format(line.value)
  if (formatted === '—' || !line.sign) return formatted
  // useCurrency already renders negative with a leading minus; sign is purely visual cue
  return line.sign === '-' && !formatted.startsWith('-') ? `- ${formatted}` : formatted
}
</script>

<template>
  <UCard>
    <template #header>
      <USkeleton
        v-if="loading"
        class="h-5 w-32"
      />
      <h2
        v-else
        class="text-h2 text-default"
      >
        {{ heading }}
      </h2>
    </template>

    <!-- Shimmer rows while loading -->
    <div
      v-if="loading"
      class="space-y-3"
      aria-busy="true"
      aria-label="Loading…"
    >
      <div
        v-for="i in Math.max(lines.length, 4)"
        :key="i"
        class="flex items-center justify-between gap-3"
      >
        <USkeleton class="h-4 w-1/3" />
        <USkeleton class="h-4 w-1/4" />
      </div>
    </div>

    <dl
      v-else
      class="space-y-2"
    >
      <template
        v-for="line in lines"
        :key="line.key"
      >
        <hr
          v-if="line.divider === 'above'"
          class="my-2 border-default"
        >
        <div
          class="flex items-baseline justify-between gap-4"
          :class="[
            line.emphasis === 'strong' ? 'pt-1' : '',
            line.emphasis === 'subtle' ? 'text-muted' : ''
          ]"
        >
          <dt
            :class="line.emphasis === 'strong' ? 'text-h2 text-default font-semibold' : 'text-body'"
          >
            {{ line.label }}
          </dt>
          <dd
            class="tabular-nums"
            :class="[
              line.emphasis === 'strong' ? 'text-h1 text-default font-bold' : 'text-body',
              colorClass(line.role)
            ]"
          >
            {{ signedValue(line) }}
          </dd>
        </div>
        <hr
          v-if="line.divider === 'below'"
          class="my-2 border-default"
        >
      </template>
    </dl>
  </UCard>
</template>
