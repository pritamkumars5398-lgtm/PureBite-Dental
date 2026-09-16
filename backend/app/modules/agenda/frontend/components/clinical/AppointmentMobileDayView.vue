<script setup lang="ts">
/**
 * Mobile agenda — single-track day view with explicit free slots.
 * Issue #61.
 *
 * Composes the week-strip date nav, the day summary (resource selector
 * + metrics + min-duration filter), and the timeline (busy/free/blocked
 * chronological list). Free slots are tappable and emit `free-slot-tap`
 * with a payload the parent can hand straight to the appointment
 * composer.
 */
import type { Appointment, Cabinet, Professional } from '~~/app/types'
import type {
  FreeSlotEntry,
  ResourceKind,
  ResourceRef,
  DayBounds,
  TimelineEntry,
  BusyEntry,
  BlockedEntry
} from '../../composables/useFreeSlots'
import { useFreeSlots, formatDuration } from '../../composables/useFreeSlots'
import type { AvailabilityPayload } from '../../composables/useScheduleAvailability'
import { useScheduleAvailability } from '../../composables/useScheduleAvailability'

interface ProfessionalWithColor extends Professional {
  color: string
}

const props = defineProps<{
  appointments: readonly Appointment[]
  professionals: ProfessionalWithColor[]
  cabinets: Cabinet[]
  currentDate: Date
  isLoading?: boolean
  highlightedAppointmentId?: string | null
}>()

const emit = defineEmits<{
  'appointment-click': [appointment: Appointment]
  'date-change': [date: Date]
  'create-at': [date: Date]
  'free-slot-tap': [payload: { slot: FreeSlotEntry, resource: ResourceRef }]
  'highlight-cleared': []
}>()

const { t, locale } = useI18n()
const auth = useAuth()
const { fetch: fetchAvailability } = useScheduleAvailability()
const notesIndicator = useAppointmentNotesIndicator()
const { statusLabel, statusIcon } = useAppointmentStatus()

const STORAGE_PREFIX = 'agenda:mobile:'

watch(() => props.highlightedAppointmentId, (newId) => {
  if (newId) setTimeout(() => emit('highlight-cleared'), 5000)
}, { immediate: true })

// ---- Resource selection (persisted) -------------------------------

const resourceKind = ref<ResourceKind>(loadKind())
const resourceId = ref<string | null>(null)

function loadKind(): ResourceKind {
  if (import.meta.server) return 'professional'
  const v = window.localStorage.getItem(STORAGE_PREFIX + 'resourceKind')
  return v === 'cabinet' ? 'cabinet' : 'professional'
}

function loadResourceId(kind: ResourceKind): string | null {
  if (import.meta.server) return null
  return window.localStorage.getItem(STORAGE_PREFIX + 'resourceId:' + kind)
}

function persistResource() {
  if (import.meta.server) return
  window.localStorage.setItem(STORAGE_PREFIX + 'resourceKind', resourceKind.value)
  if (resourceId.value) {
    window.localStorage.setItem(
      STORAGE_PREFIX + 'resourceId:' + resourceKind.value,
      resourceId.value
    )
  }
}

function defaultProfessionalId(): string | null {
  if (props.professionals.length === 0) return null
  const stored = loadResourceId('professional')
  if (stored && props.professionals.some(p => p.id === stored)) return stored
  // Prefer current user when they are a professional.
  const me = auth.user.value?.id
  if (me && props.professionals.some(p => p.id === me)) return me
  // Otherwise alphabetically first.
  const sorted = [...props.professionals].sort((a, b) => {
    const an = `${a.first_name ?? ''} ${a.last_name ?? ''}`
    const bn = `${b.first_name ?? ''} ${b.last_name ?? ''}`
    return an.localeCompare(bn)
  })
  return sorted[0]?.id ?? null
}

function defaultCabinetId(): string | null {
  if (props.cabinets.length === 0) return null
  const stored = loadResourceId('cabinet')
  if (stored && props.cabinets.some(c => c.name === stored)) return stored
  const sorted = [...props.cabinets].sort((a, b) => (a.display_order ?? 0) - (b.display_order ?? 0))
  return sorted[0]?.name ?? null
}

watch(
  [resourceKind, () => props.professionals, () => props.cabinets],
  () => {
    if (resourceKind.value === 'professional') {
      const next = defaultProfessionalId()
      // Only override resourceId when current is invalid for new kind/list.
      if (!resourceId.value || !props.professionals.some(p => p.id === resourceId.value)) {
        resourceId.value = next
      }
    } else {
      const next = defaultCabinetId()
      if (!resourceId.value || !props.cabinets.some(c => c.name === resourceId.value)) {
        resourceId.value = next
      }
    }
    persistResource()
  },
  { immediate: true }
)

const resource = computed<ResourceRef | null>(() => {
  if (!resourceId.value) return null
  return { kind: resourceKind.value, id: resourceId.value }
})

function onUpdateResourceKind(kind: ResourceKind) {
  resourceKind.value = kind
  // Reset resourceId so the watcher above picks the default for the new kind.
  resourceId.value = kind === 'professional' ? defaultProfessionalId() : defaultCabinetId()
  persistResource()
}

function onUpdateResourceId(id: string) {
  resourceId.value = id
  persistResource()
}

// ---- Min-duration filter (persisted) ------------------------------

const minDurationMin = ref<number>(loadMinDuration())

function loadMinDuration(): number {
  if (import.meta.server) return 20
  const raw = window.localStorage.getItem(STORAGE_PREFIX + 'minDurationMin')
  const n = raw ? Number.parseInt(raw, 10) : NaN
  return Number.isFinite(n) && n > 0 ? n : 20
}

function onUpdateMinDuration(value: number) {
  minDurationMin.value = value
  if (!import.meta.server) {
    window.localStorage.setItem(STORAGE_PREFIX + 'minDurationMin', String(value))
  }
}

// ---- Availability fetch ------------------------------------------

const availability = ref<AvailabilityPayload | null>(null)

function isoLocalDate(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

async function refreshAvailability() {
  const iso = isoLocalDate(props.currentDate)
  const params: { start: string, end: string, professional_id?: string } = {
    start: iso,
    end: iso
  }
  if (resourceKind.value === 'professional' && resourceId.value) {
    params.professional_id = resourceId.value
  }
  availability.value = await fetchAvailability(params)
}

watch(
  [() => props.currentDate, resourceKind, resourceId],
  () => { refreshAvailability() },
  { immediate: true }
)

// ---- Bounds (derive from availability open ranges; default 8–21) --

const DEFAULT_BOUNDS: DayBounds = { startHour: 8, endHour: 21 }

const bounds = computed<DayBounds>(() => {
  const payload = availability.value
  if (!payload) return DEFAULT_BOUNDS
  const open = payload.ranges.filter(r => r.state === 'open')
  if (open.length === 0) return DEFAULT_BOUNDS
  let minHour = 24
  let maxHour = 0
  for (const r of open) {
    const s = new Date(r.start)
    const e = new Date(r.end)
    minHour = Math.min(minHour, s.getHours())
    const eh = e.getMinutes() > 0 || e.getSeconds() > 0 ? e.getHours() + 1 : e.getHours()
    maxHour = Math.max(maxHour, eh)
  }
  minHour = Math.max(0, Math.min(minHour, 23))
  maxHour = Math.max(minHour + 1, Math.min(maxHour, 24))
  return { startHour: minHour, endHour: maxHour }
})

// ---- Free-slot engine -------------------------------------------

const appointmentsRef = computed(() => props.appointments)

const { entries, summary } = useFreeSlots({
  appointments: appointmentsRef,
  availability,
  resource,
  date: toRef(() => props.currentDate),
  minDurationMin,
  bounds
})

function onFreeSlotTap(slot: FreeSlotEntry) {
  if (!resource.value) return
  emit('free-slot-tap', { slot, resource: resource.value })
}

// ---- Header / week strip ----------------------------------------

function isSameDay(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear()
    && a.getMonth() === b.getMonth()
    && a.getDate() === b.getDate()
}

function getMonday(date: Date): Date {
  const d = new Date(date)
  const day = d.getDay()
  const diff = day === 0 ? -6 : 1 - day
  d.setDate(d.getDate() + diff)
  d.setHours(0, 0, 0, 0)
  return d
}

const weekDays = computed<Date[]>(() => {
  const start = getMonday(props.currentDate)
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(start)
    d.setDate(start.getDate() + i)
    return d
  })
})

function formatWeekdayShort(date: Date): string {
  return new Intl.DateTimeFormat(locale.value, { weekday: 'narrow' }).format(date)
}

function formatHeaderDate(date: Date): string {
  return new Intl.DateTimeFormat(locale.value, {
    weekday: 'long',
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  }).format(date)
}

function countForDay(day: Date): number {
  return props.appointments.filter((apt) => {
    const d = new Date(apt.start_time)
    return isSameDay(d, day) && apt.status !== 'cancelled'
  }).length
}

function shiftDay(days: number) {
  const next = new Date(props.currentDate)
  next.setDate(next.getDate() + days)
  emit('date-change', next)
}

function selectDay(d: Date) {
  if (!isSameDay(d, props.currentDate)) emit('date-change', new Date(d))
}

function isToday(d: Date): boolean {
  return isSameDay(d, new Date())
}

function createNow() {
  emit('create-at', new Date(props.currentDate))
}

const hasAnyEntry = computed(() => entries.value.length > 0)

const selectedProfessional = computed(() => {
  if (resourceKind.value !== 'professional' || !resourceId.value) return null
  return props.professionals.find(p => p.id === resourceId.value) ?? null
})

const selectedCabinet = computed(() => {
  if (resourceKind.value !== 'cabinet' || !resourceId.value) return null
  return props.cabinets.find(c => c.name === resourceId.value) ?? null
})

const resourceTitle = computed(() => {
  if (selectedProfessional.value) {
    return `${selectedProfessional.value.first_name} ${selectedProfessional.value.last_name}`.trim()
  }
  return selectedCabinet.value?.name ?? ''
})

const resourceCount = computed(() => {
  return entries.value.filter(e => e.type === 'busy').length
})

function initials(prof: ProfessionalWithColor): string {
  return `${prof.first_name.charAt(0)}${prof.last_name.charAt(0)}`.toUpperCase()
}

function isFree(e: TimelineEntry): e is FreeSlotEntry { return e.type === 'free' }
function isBusy(e: TimelineEntry): e is BusyEntry { return e.type === 'busy' }
function isBlocked(e: TimelineEntry): e is BlockedEntry { return e.type === 'blocked' }

function formatTime(d: Date): string {
  return d.toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit' })
}

function formatHourLabel(d: Date): string {
  return d.toLocaleTimeString(locale.value, { hour: 'numeric' }).toLowerCase()
}

function patientName(apt: Appointment): string {
  if (!apt.patient) return t('appointments.noPatient')
  return `${apt.patient.first_name} ${apt.patient.last_name}`.trim()
}

function treatmentLabel(apt: Appointment): string {
  if (apt.treatment_type) return apt.treatment_type
  const first = apt.treatments?.[0]
  if (!first) return ''
  const names = first.names
  return names[locale.value] || names.es || names.en || first.internal_code
}

function professionalFor(apt: Appointment): ProfessionalWithColor | undefined {
  return props.professionals.find(p => p.id === apt.professional_id)
}

function getCardPastel(apt: Appointment): Record<string, string> {
  const byStatus: Partial<Record<Appointment['status'], [string, string]>> = {
    scheduled: ['rgba(251, 207, 232, 0.72)', 'rgba(244, 114, 182, 0.22)'],
    confirmed: ['rgba(191, 219, 254, 0.72)', 'rgba(96, 165, 250, 0.28)'],
    checked_in: ['rgba(254, 215, 170, 0.78)', 'rgba(251, 146, 60, 0.28)'],
    in_treatment: ['rgba(253, 230, 138, 0.82)', 'rgba(245, 158, 11, 0.32)'],
    completed: ['rgba(187, 247, 208, 0.72)', 'rgba(74, 222, 128, 0.28)'],
    cancelled: ['rgba(226, 232, 240, 0.78)', 'rgba(148, 163, 184, 0.28)'],
    no_show: ['rgba(254, 202, 202, 0.72)', 'rgba(248, 113, 113, 0.28)']
  }
  const pair = byStatus[apt.status]
  if (pair) return { backgroundColor: pair[0], borderColor: pair[1] }
  return { backgroundColor: 'rgba(241, 245, 249, 0.9)', borderColor: 'rgba(203, 213, 225, 0.5)' }
}

function getStatusChipClass(status: Appointment['status']): string {
  switch (status) {
    case 'completed':
      return 'bg-white/80 text-emerald-600'
    case 'in_treatment':
      return 'bg-white/80 text-amber-700'
    case 'checked_in':
      return 'bg-white/80 text-orange-600'
    case 'cancelled':
    case 'no_show':
      return 'bg-white/80 text-rose-600'
    default:
      return 'bg-white/75 text-slate-500'
  }
}

function professionalAccent(apt: Appointment): string {
  return professionalFor(apt)?.color || '#0284C7'
}

function blockedLabel(e: BlockedEntry): string {
  if (e.reason === 'clinic_closed') return t('appointments.freeSlots.clinicClosed', 'Clínica cerrada')
  if (e.reason === 'on_break') return t('appointments.freeSlots.onBreak', 'Pausa')
  return t('appointments.notAvailable')
}

function freeAriaLabel(e: FreeSlotEntry): string {
  return t(
    'appointments.freeSlots.tapToBookAria',
    'Hueco libre de {duration} a las {time}',
    { duration: formatDuration(e.durationMin), time: formatTime(e.start) }
  )
}

function entryKey(e: TimelineEntry, i: number): string {
  if (isBusy(e)) return `b-${e.appointment.id}`
  if (isFree(e)) return `f-${e.start.toISOString()}-${e.end.toISOString()}`
  return `x-${i}-${e.start.toISOString()}`
}
</script>

<template>
  <div class="flex flex-col h-full w-full min-w-0">
    <div class="sticky top-0 z-20 bg-surface shadow-xs">
      <div class="flex items-center justify-between px-3 py-2">
        <UButton
          variant="ghost"
          color="neutral"
          size="sm"
          icon="i-lucide-chevron-left"
          :aria-label="t('common.previous', 'Anterior')"
          @click="shiftDay(-1)"
        />
        <button
          type="button"
          class="text-sm font-semibold text-default capitalize px-3 py-1 rounded-token-md hover:bg-canvas min-h-[36px]"
          @click="emit('date-change', new Date())"
        >
          {{ formatHeaderDate(currentDate) }}
        </button>
        <UButton
          variant="ghost"
          color="neutral"
          size="sm"
          icon="i-lucide-chevron-right"
          :aria-label="t('common.next', 'Siguiente')"
          @click="shiftDay(1)"
        />
      </div>

      <div class="grid grid-cols-7 gap-1 px-2 pb-2">
        <button
          v-for="d in weekDays"
          :key="d.toISOString()"
          type="button"
          class="flex flex-col items-center gap-1 py-2 rounded-xl transition-colors min-h-[44px]"
          :class="[
            isSameDay(d, currentDate)
              ? 'bg-[var(--color-primary-soft)] text-[var(--color-primary-soft-text)]'
              : 'text-muted hover:bg-canvas',
            isToday(d) && !isSameDay(d, currentDate) ? 'ring-1 ring-[var(--color-primary)]' : ''
          ]"
          @click="selectDay(d)"
        >
          <span class="text-[10px] uppercase tracking-wide">{{ formatWeekdayShort(d) }}</span>
          <span class="text-ui tnum font-semibold">{{ d.getDate() }}</span>
          <span
            v-if="countForDay(d) > 0"
            class="text-[10px] leading-none px-1.5 py-0.5 rounded-full bg-[var(--color-primary)] text-white tnum"
          >
            {{ countForDay(d) }}
          </span>
          <span v-else class="h-[14px]" />
        </button>
      </div>

      <AppointmentMobileDaySummary
        :resource-kind="resourceKind"
        :resource-id="resourceId"
        :professionals="professionals"
        :cabinets="cabinets"
        :summary="summary"
        :min-duration-min="minDurationMin"
        :is-loading="isLoading"
        @update:resource-kind="onUpdateResourceKind"
        @update:resource-id="onUpdateResourceId"
        @update:min-duration-min="onUpdateMinDuration"
      />
    </div>

    <div class="flex-1 overflow-y-auto pb-24">
      <div v-if="isLoading" class="p-6 flex justify-center">
        <UIcon
          name="i-lucide-loader-2"
          class="w-8 h-8 animate-spin"
          :style="{ color: 'var(--color-primary)' }"
        />
      </div>

      <div
        v-else-if="!resource"
        class="p-6 flex flex-col items-center gap-3 text-center"
      >
        <UIcon name="i-lucide-user-round-search" class="w-10 h-10 text-subtle" />
        <p class="text-ui text-muted">
          {{ resourceKind === 'professional'
            ? t('appointments.noProfessionals')
            : t('appointments.cabinetAssignment.unassigned') }}
        </p>
      </div>

      <div
        v-else-if="!hasAnyEntry"
        class="p-6 flex flex-col items-center gap-3 text-center"
      >
        <UIcon name="i-lucide-calendar-x" class="w-10 h-10 text-subtle" />
        <p class="text-ui text-muted">
          {{ t('appointments.emptyDay', 'No hay citas este día') }}
        </p>
        <UButton
          color="primary"
          variant="soft"
          icon="i-lucide-plus"
          @click="createNow"
        >
          {{ t('appointments.create') }}
        </UButton>
      </div>

      <div
        v-else
        class="mx-2 mt-2 mb-4 rounded-2xl bg-surface shadow-sm overflow-hidden"
      >
        <div
          v-if="resourceTitle"
          class="flex items-center gap-2.5 px-3 py-3 border-b border-subtle"
        >
          <span
            v-if="selectedProfessional"
            class="w-10 h-10 rounded-full flex items-center justify-center text-white text-xs font-semibold shrink-0"
            :style="{ backgroundColor: selectedProfessional.color }"
          >
            {{ initials(selectedProfessional) }}
          </span>
          <span
            v-else
            class="w-10 h-10 rounded-full flex items-center justify-center bg-slate-200 text-slate-600 shrink-0"
          >
            <UIcon name="i-lucide-door-open" class="w-4 h-4" />
          </span>
          <div class="min-w-0">
            <div class="text-sm font-semibold text-default truncate">{{ resourceTitle }}</div>
            <div class="text-[11px] text-muted truncate">
              {{ t('appointments.todaysAppointmentCount', { count: resourceCount }) }}
            </div>
          </div>
        </div>

        <ul>
          <li
            v-for="(entry, i) in entries"
            :key="entryKey(entry, i)"
            class="grid grid-cols-[56px_1fr] border-t border-dashed border-slate-100 dark:border-white/5 first:border-t-0"
          >
            <div class="px-2 py-3 text-right">
              <span class="text-[11px] text-subtle tnum">{{ formatHourLabel(entry.start) }}</span>
            </div>

            <div class="pr-2 py-2 min-w-0">
              <button
                v-if="isBusy(entry)"
                type="button"
                class="w-full text-left rounded-2xl border p-2.5 min-h-[60px] transition-shadow"
                :class="entry.appointment.id === highlightedAppointmentId ? 'ring-2 ring-warning-500' : ''"
                :style="getCardPastel(entry.appointment)"
                @click="emit('appointment-click', entry.appointment)"
              >
                <div class="flex items-start justify-between gap-1 min-w-0">
                  <div class="flex items-center gap-1.5 min-w-0">
                    <span
                      class="w-5 h-5 rounded-md flex items-center justify-center text-white shrink-0"
                      :style="{ backgroundColor: professionalAccent(entry.appointment) }"
                    >
                      <UIcon :name="statusIcon(entry.appointment.status)" class="w-3 h-3" />
                    </span>
                    <span class="text-[13px] font-semibold truncate">{{ patientName(entry.appointment) }}</span>
                    <UIcon
                      v-if="notesIndicator.has(entry.appointment.id)"
                      name="i-lucide-sticky-note"
                      class="w-3 h-3 text-primary shrink-0"
                      :title="t('appointments.hasNotes', 'Tiene notas')"
                    />
                  </div>
                  <span
                    class="text-[10px] font-medium px-1.5 py-0.5 rounded-md shrink-0"
                    :class="getStatusChipClass(entry.appointment.status)"
                  >
                    {{ statusLabel(entry.appointment.status) }}
                  </span>
                </div>
                <div class="text-[11px] text-muted tnum mt-0.5 pl-6">
                  {{ formatTime(entry.start) }} > {{ formatTime(entry.end) }}
                </div>
                <div v-if="treatmentLabel(entry.appointment)" class="mt-1.5 pl-6">
                  <span class="inline-flex text-[10px] text-muted px-2 py-0.5 rounded-md bg-white/70 truncate max-w-full">
                    {{ treatmentLabel(entry.appointment) }}
                  </span>
                </div>
              </button>

              <button
                v-else-if="isFree(entry) && entry.qualifies"
                type="button"
                class="group w-full min-h-[56px] rounded-2xl border border-dashed border-slate-200 dark:border-white/10 bg-slate-50/80 dark:bg-white/5 px-3 py-2 flex items-center justify-between gap-2 text-left"
                :aria-label="freeAriaLabel(entry)"
                @click="onFreeSlotTap(entry)"
              >
                <div class="min-w-0">
                  <div class="text-[13px] font-semibold text-[var(--color-primary)]">
                    {{ formatDuration(entry.durationMin) }}
                    <span class="text-default font-normal">
                      {{ t('appointments.freeSlots.freeSuffix', 'libre') }}
                    </span>
                  </div>
                  <div class="text-[11px] text-muted tnum">
                    {{ formatTime(entry.start) }} > {{ formatTime(entry.end) }}
                  </div>
                </div>
                <UIcon name="i-lucide-plus" class="w-5 h-5 text-slate-400 group-hover:text-[var(--color-primary)]" />
              </button>

              <button
                v-else-if="isFree(entry)"
                type="button"
                class="w-full min-h-[44px] rounded-xl px-2 py-1.5 flex items-center justify-between text-caption text-muted"
                :aria-label="freeAriaLabel(entry)"
                @click="onFreeSlotTap(entry)"
              >
                <span class="tnum">{{ formatTime(entry.start) }} > {{ formatTime(entry.end) }}</span>
                <span>
                  {{ formatDuration(entry.durationMin) }}
                  {{ t('appointments.freeSlots.freeSuffix', 'libre') }}
                </span>
              </button>

              <div
                v-else-if="isBlocked(entry)"
                class="schedules-blocked min-h-[48px] rounded-2xl flex items-center justify-center px-2"
              >
                <span class="text-[10px] font-semibold tracking-[0.14em] uppercase text-slate-400">
                  {{ blockedLabel(entry) }}
                </span>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>

    <UButton
      class="fixed right-4 z-30 shadow-lg"
      :style="{ bottom: 'calc(1rem + env(safe-area-inset-bottom))' }"
      color="primary"
      size="lg"
      icon="i-lucide-plus"
      :aria-label="t('appointments.create')"
      @click="createNow"
    />
  </div>
</template>

<style scoped>
.schedules-blocked {
  background-image: repeating-linear-gradient(
    -45deg,
    rgba(226, 232, 240, 0.55),
    rgba(226, 232, 240, 0.55) 8px,
    rgba(203, 213, 225, 0.7) 8px,
    rgba(203, 213, 225, 0.7) 16px
  );
}
</style>
