<script setup lang="ts">
interface Props {
  icon: string
  label: string
  value?: string | null
  copyAriaLabel: string
  href?: string
  placeholder?: string
}

const props = withDefaults(defineProps<Props>(), {
  value: null,
  href: undefined,
  placeholder: '—',
})

const { t } = useI18n()
const toast = useToast()

const hasValue = computed(() => props.value !== null && props.value !== undefined && props.value !== '')

async function copyValue() {
  if (!hasValue.value || !props.value) return
  try {
    await navigator.clipboard.writeText(props.value)
    toast.add({
      title: t('common.copied'),
      color: 'success',
      icon: 'i-lucide-check',
    })
  }
  catch {
    /* clipboard not available; silently ignore */
  }
}
</script>

<template>
  <div class="flex items-center gap-3 py-3">
    <UIcon
      :name="icon"
      class="w-3.5 h-3.5 text-subtle shrink-0"
      aria-hidden="true"
    />
    <dt class="text-[11px] font-semibold uppercase tracking-wide text-muted w-28 shrink-0">
      {{ label }}
    </dt>
    <dd class="text-sm text-muted min-w-0 flex-1 break-words">
      <a
        v-if="hasValue && href"
        :href="href"
        class="inline-flex items-center gap-1.5 text-muted hover:text-[var(--color-primary)] transition-colors"
      >
        {{ value }}
      </a>
      <span v-else-if="hasValue">{{ value }}</span>
      <span
        v-else
        class="text-subtle"
      >{{ placeholder }}</span>
    </dd>
    <UButton
      v-if="hasValue"
      variant="ghost"
      color="neutral"
      size="xs"
      icon="i-lucide-copy"
      :aria-label="copyAriaLabel"
      class="shrink-0 rounded-full"
      @click="copyValue"
    />
  </div>
</template>
