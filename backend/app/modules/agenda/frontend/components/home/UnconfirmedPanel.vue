<script setup lang="ts">
import type { Appointment } from '~~/app/types'
import { PERMISSIONS } from '~~/app/config/permissions'

defineProps<{ ctx?: unknown }>()

const { t, locale } = useI18n()
const { can } = usePermissions()
const {
  tomorrowUnconfirmed,
  tomorrowLoaded,
  fetchTomorrowUnconfirmed,
  removeTomorrowUnconfirmed
} = useHomeAgenda()
const { transition } = useAppointments()
const toast = useToast()

const pending = computed(() => !tomorrowLoaded.value)
const canWrite = computed(() => can(PERMISSIONS.appointments.write))
const busyIds = ref<Set<string>>(new Set())
const total = computed(() => tomorrowUnconfirmed.value.length)

onMounted(() => {
  if (!tomorrowLoaded.value) fetchTomorrowUnconfirmed()
})
onActivated(() => {
  fetchTomorrowUnconfirmed()
})

async function confirm(a: Appointment) {
  if (!canWrite.value || busyIds.value.has(a.id)) return
  const next = new Set(busyIds.value)
  next.add(a.id)
  busyIds.value = next
  try {
    await transition(a.id, 'confirmed')
    removeTomorrowUnconfirmed(a.id)
  } catch {
    toast.add({
      title: t('dashboard.unconfirmed.confirmError'),
      color: 'error'
    })
  } finally {
    const post = new Set(busyIds.value)
    post.delete(a.id)
    busyIds.value = post
  }
}

function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit' })
}

function isoDay(iso: string): string {
  const d = new Date(iso)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function appointmentHref(a: Appointment): string {
  return `/appointments?highlight=${a.id}&date=${isoDay(a.start_time)}`
}
</script>

<template>
  <DashboardCard
    :title="t('dashboard.unconfirmed.title')"
    :caption="t('dashboard.caption.tomorrow')"
    class="h-full"
  >
    <div
      v-if="pending"
      class="space-y-3"
    >
      <USkeleton class="h-9 w-16" />
      <USkeleton class="h-4 w-28" />
      <USkeleton class="h-14 w-full" />
      <USkeleton class="h-14 w-full" />
    </div>

    <div
      v-else
      class="space-y-4"
    >
      <div>
        <p class="text-display text-default tnum tracking-tight">
          {{ total }}
        </p>
        <p class="text-caption text-muted mt-1">
          {{ total > 0 ? t('dashboard.caption.tomorrow') : t('dashboard.unconfirmed.empty') }}
        </p>
      </div>

      <ul
        v-if="total > 0"
        class="space-y-2"
      >
        <li
          v-for="a in tomorrowUnconfirmed"
          :key="a.id"
          class="rounded-2xl bg-[var(--color-canvas)] px-2 shadow-[0_6px_16px_rgba(15,23,42,0.05)]"
        >
          <ListRow :to="appointmentHref(a)">
            <template #leading>
              <span class="text-ui tnum text-default w-12">
                {{ formatTime(a.start_time) }}
              </span>
            </template>
            <template #title>
              {{ a.patient?.first_name }} {{ a.patient?.last_name }}
            </template>
            <template #subtitle>
              <span v-if="a.professional">
                {{ a.professional.first_name }} {{ a.professional.last_name }}
              </span>
              <span
                v-if="a.cabinet"
                class="ml-1 text-subtle"
              >
                · {{ a.cabinet }}
              </span>
            </template>
            <template
              v-if="canWrite"
              #actions
            >
              <UButton
                size="xs"
                variant="soft"
                color="primary"
                :loading="busyIds.has(a.id)"
                icon="i-lucide-check"
                @click.stop.prevent="confirm(a)"
              >
                {{ t('dashboard.unconfirmed.confirm') }}
              </UButton>
            </template>
          </ListRow>
        </li>
      </ul>
    </div>
  </DashboardCard>
</template>
