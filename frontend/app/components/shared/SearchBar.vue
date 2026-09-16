<script setup lang="ts">
interface Props {
  modelValue: string
  placeholder?: string
  /** Debounce interval in ms. Emits `update:debounced` after user stops typing. */
  debounce?: number
  icon?: string
  /** Tailwind max-width class — e.g. 'max-w-sm', 'max-w-md' */
  maxWidth?: string
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  placeholder: '',
  debounce: 300,
  icon: 'i-lucide-search',
  maxWidth: 'max-w-sm',
  disabled: false
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
  'update:debounced': [value: string]
}>()

const { t } = useI18n()
const local = ref(props.modelValue)
let timer: ReturnType<typeof setTimeout> | null = null

watch(() => props.modelValue, (val) => {
  local.value = val
})

watch(local, (val) => {
  emit('update:modelValue', val)
  if (timer) clearTimeout(timer)
  timer = setTimeout(() => {
    emit('update:debounced', val)
  }, props.debounce)
})

onBeforeUnmount(() => {
  if (timer) clearTimeout(timer)
})

function clear() {
  local.value = ''
}
</script>

<template>
  <div :class="['w-full', maxWidth]">
    <UInput
      v-model="local"
      :placeholder="placeholder || t('common.search')"
      :icon="icon"
      :disabled="disabled"
      size="md"
      class="w-full min-h-11"
      :ui="{
        base: 'rounded-full min-h-11 bg-[var(--color-canvas)] ring-1 ring-inset ring-[var(--color-border-subtle)]',
        trailing: 'pe-1'
      }"
    >
      <template
        v-if="local"
        #trailing
      >
        <UButton
          variant="ghost"
          color="neutral"
          size="xs"
          icon="i-lucide-x"
          class="rounded-full"
          :aria-label="t('lists.search.clear')"
          @click="clear"
        />
      </template>
    </UInput>
  </div>
</template>
