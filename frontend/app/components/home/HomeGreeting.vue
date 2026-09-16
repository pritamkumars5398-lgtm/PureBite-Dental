<script setup lang="ts">
const { t, locale } = useI18n()
const { user } = useAuth()

const now = ref(new Date())

function refreshNow() {
  now.value = new Date()
}

let intervalId: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  refreshNow()
  intervalId = setInterval(refreshNow, 60_000)
})

onBeforeUnmount(() => {
  if (intervalId) clearInterval(intervalId)
})

const greetingKey = computed(() => {
  const h = now.value.getHours()
  if (h < 6 || h >= 21) return 'dashboard.greetings.evening'
  if (h < 13) return 'dashboard.greetings.morning'
  return 'dashboard.greetings.afternoon'
})

const firstName = computed(() => user.value?.first_name?.trim() ?? '')

const title = computed(() => {
  const greeting = t(greetingKey.value)
  if (firstName.value) {
    return t('dashboard.greetings.named', { greeting, name: firstName.value })
  }
  return t('dashboard.greetings.unnamed', { greeting })
})

const formattedDate = computed(() => {
  const raw = now.value.toLocaleDateString(locale.value, {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  })
  return raw.charAt(0).toUpperCase() + raw.slice(1)
})
</script>

<template>
  <div class="min-w-0">
    <h1 class="text-display text-default text-pretty">
      {{ title }}
    </h1>
    <p class="mt-1 text-body text-muted text-pretty">
      {{ formattedDate }}
    </p>
  </div>
</template>
