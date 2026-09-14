<script setup lang="ts">
import { PERMISSIONS } from '~/config/permissions'

const { t, locale } = useI18n()
const { user } = useAuth()
const { can } = usePermissions()

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
  const g = t(greetingKey.value)
  return firstName.value ? `${g}, ${firstName.value}` : g
})

const formattedDate = computed(() =>
  now.value.toLocaleDateString(locale.value, {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  })
)

const canWriteAppointments = computed(() => can(PERMISSIONS.appointments.write))
const canWritePatients = computed(() => can(PERMISSIONS.patients.write))
</script>

<template>
  <div class="relative mb-6">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <!-- Greeting & Date -->
      <div>
        <h1 class="text-2xl sm:text-3xl font-bold tracking-tight text-neutral-900 dark:text-white text-pretty">
          {{ title }}
        </h1>
        <p class="mt-1 text-sm sm:text-base text-neutral-500 dark:text-neutral-400 capitalize">
          {{ formattedDate }}
        </p>
      </div>

      <!-- Quick Actions -->
      <div class="flex flex-wrap items-center gap-3">
        <UButton
          v-if="canWritePatients"
          to="/patients?new=1"
          variant="soft"
          color="neutral"
          size="md"
          icon="i-lucide-user-plus"
        >
          {{ t('dashboard.quickActions.newPatient') }}
        </UButton>
        <UButton
          v-if="canWriteAppointments"
          to="/appointments?new=1"
          variant="solid"
          color="primary"
          size="md"
          icon="i-lucide-calendar-plus"
        >
          {{ t('dashboard.quickActions.newAppointment') }}
        </UButton>
      </div>
    </div>
  </div>
</template>
