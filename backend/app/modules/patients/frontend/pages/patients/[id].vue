<script setup lang="ts">
/**
 * Patient detail — dashboard-first IA.
 *
 * The page hosts a persistent sticky header + an airy tab strip. Resumen is
 * a dashboard of smart-cards: each card lives in (and is registered by)
 * its owning module via the ``patient.summary.cards`` slot. The page
 * only fetches data from its own module (``/api/v1/patients/{id}/extended``);
 * cross-module data (appointments, plans, ledger, allergies, etc.) is
 * fetched by the modules that own it inside their slot components.
 *
 * Cross-module data that the page used to fetch (emergency contact,
 * legal guardian, alerts, appointments, plans) now reaches the page
 * only through ``PatientExtended.active_alerts`` / the
 * patients_clinical slots — the page no longer reaches into other
 * modules' APIs directly.
 */
import type { PatientExtended, ApiResponse } from '~~/app/types'
import { PERMISSIONS } from '~~/app/config/permissions'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const api = useApi()
const toast = useToast()
const { can } = usePermissions()
const { resolve } = useModuleSlots()

const patientId = route.params.id as string
const patientIdRef = computed(() => patientId)

// Handle returnTo query param (from invoice edit page)
const returnTo = computed(() => route.query.returnTo as string | undefined)
const openBillingEdit = computed(() => route.query.tab === 'billing')

// Fetch patient identity from the patients module. The Resumen smart-
// cards each fetch their own module's data via slot registration; the
// page no longer mediates that traffic. The Datos tab still consumes
// patients_clinical data through the legacy stitching below (emergency
// contact, legal guardian, alerts) — that surface will move to
// patients_clinical-owned cards in a follow-up; the goal of this PR is
// to land the new IA without regressing Datos.
const { data: patient, status, refresh } = await useAsyncData(
  `patient:${patientId}`,
  async () => {
    try {
      const [identity, emergency, guardian, alertsResp] = await Promise.all([
        api.get<ApiResponse<PatientExtended>>(
          `/api/v1/patients/${patientId}/extended`
        ),
        api.get<ApiResponse<PatientExtended['emergency_contact']>>(
          `/api/v1/patients_clinical/patients/${patientId}/emergency-contact`
        ).catch(() => ({ data: null })),
        api.get<ApiResponse<PatientExtended['legal_guardian']>>(
          `/api/v1/patients_clinical/patients/${patientId}/legal-guardian`
        ).catch(() => ({ data: null })),
        api.get<ApiResponse<{ alerts: PatientExtended['active_alerts'] }>>(
          `/api/v1/patients_clinical/patients/${patientId}/alerts`
        ).catch(() => ({ data: { alerts: [] } }))
      ])

      return {
        ...identity.data,
        emergency_contact: emergency.data ?? undefined,
        legal_guardian: guardian.data ?? undefined,
        active_alerts: alertsResp.data?.alerts ?? []
      } as PatientExtended
    } catch (error: unknown) {
      const fetchError = error as { statusCode?: number }
      if (fetchError.statusCode === 404) {
        throw createError({
          statusCode: 404,
          message: t('patients.notFound')
        })
      }
      throw error
    }
  }
)

// Medical-history composable lives in patients_clinical but is shared
// via auto-import. We only need it here to drive the section-edit modal
// (medical history form). The Resumen surfaces the same data through a
// patients_clinical-owned card.
const { medicalHistory, isSaving: isSavingMedical, saveMedicalHistory } = useMedicalHistory(patientIdRef)

// Tabs — Resumen is the landing.
const activeTab = ref('summary')

watch(
  () => route.query.tab,
  (tab) => {
    if (tab && typeof tab === 'string') {
      activeTab.value = tab
    } else {
      activeTab.value = 'summary'
    }
  },
  { immediate: true }
)

const tabs = computed(() => {
  const items: Array<{ value: string, label: string, icon: string, slot: string }> = [
    {
      value: 'summary',
      label: t('patientDetail.tabs.summary'),
      icon: 'i-lucide-layout-dashboard',
      slot: 'summary'
    },
    {
      value: 'info',
      label: t('patientDetail.tabs.info'),
      icon: 'i-lucide-user',
      slot: 'info'
    }
  ]

  if (can(PERMISSIONS.odontogram.read) || can(PERMISSIONS.treatmentPlans.read)) {
    items.push({
      value: 'clinical',
      label: t('patientDetail.tabs.clinical'),
      icon: 'i-lucide-stethoscope',
      slot: 'clinical'
    })
  }

  if (can(PERMISSIONS.budget.read) || can(PERMISSIONS.billing.read)) {
    items.push({
      value: 'administration',
      label: t('patientDetail.tabs.administration'),
      icon: 'i-lucide-briefcase',
      slot: 'administration'
    })
  }

  if (can(PERMISSIONS.documents.read)) {
    items.push({
      value: 'gallery',
      label: t('patientDetail.tabs.gallery', 'Galería'),
      icon: 'i-lucide-images',
      slot: 'gallery'
    })
  }

  items.push({
    value: 'timeline',
    label: t('patientDetail.tabs.timeline'),
    icon: 'i-lucide-history',
    slot: 'timeline'
  })

  return items
})

// Permissions used by Datos tab + edit modals.
const canEditMedicalHistory = computed(() => can(PERMISSIONS.medicalHistory.write))
const canEditPatient = computed(() => can(PERMISSIONS.patients.write))

// Section edit modals state
type SectionType = 'demographics' | 'emergency' | 'guardian' | 'billing' | 'medical'
const editModalOpen = ref(false)
const editModalSection = ref<SectionType>('demographics')
const isSubmitting = ref(false)

function openSectionModal(section: SectionType) {
  editModalSection.value = section
  editModalOpen.value = true
}

// Auto-open billing modal if coming from invoice edit
watch(
  () => patient.value,
  (newPatient) => {
    if (openBillingEdit.value && newPatient && !editModalOpen.value) {
      openSectionModal('billing')
    }
  },
  { immediate: true }
)

// Deep-link from the medical-history card: ?tab=info&edit=medical.
watch(
  () => route.query.edit,
  (edit) => {
    if (edit === 'medical' && patient.value && !editModalOpen.value) {
      openSectionModal('medical')
    }
  },
  { immediate: true }
)

async function handleSectionSave(_section: SectionType, _data: Record<string, unknown>) {
  await refresh()
}

async function handleMedicalSave() {
  const success = await saveMedicalHistory()
  if (success) {
    editModalOpen.value = false
  }
}

// Resumen smart-cards come from the slot registry. We read the live
// entries so we can show a sensible empty state when no module has
// registered cards yet (e.g. fresh install).
const summaryCards = computed(() =>
  patient.value ? resolve('patient.summary.cards', { patient: patient.value }) : []
)

// Archive patient
const isArchiveModalOpen = ref(false)

async function archivePatient() {
  isSubmitting.value = true

  try {
    await api.del(`/api/v1/patients/${patientId}`)

    toast.add({
      title: t('common.success'),
      description: t('patients.archived'),
      color: 'success'
    })

    await router.push('/patients')
  } catch (error: unknown) {
    const fetchError = error as { statusCode?: number, data?: { message?: string } }

    toast.add({
      title: t('common.error'),
      description: fetchError.data?.message || t('common.serverError'),
      color: 'error'
    })
  } finally {
    isSubmitting.value = false
    isArchiveModalOpen.value = false
  }
}

// Check if patient is a minor (under 18)
const isMinor = computed(() => {
  if (!patient.value?.date_of_birth) return false
  const today = new Date()
  const birth = new Date(patient.value.date_of_birth)
  let years = today.getFullYear() - birth.getFullYear()
  const m = today.getMonth() - birth.getMonth()
  if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) years--
  return years < 18
})

// Header action handlers — delegate to existing flows. New-appointment
// and new-note land on dedicated pages we already have.
function goBack() {
  if (returnTo.value) {
    router.push(returnTo.value)
  } else {
    router.push('/patients')
  }
}

function openEditPatient() {
  openSectionModal('demographics')
}

function newAppointment() {
  // Send the user to the agenda with `patient_id` in the URL. The agenda
  // reads it into `initialPatientId` and forwards it to the create modal
  // when the user picks a slot. No auto-open — the slot decides the
  // date / time / cabinet.
  router.push(`/appointments?patient_id=${patientId}`)
}

function newNote() {
  // Clinical-notes module owns the composer; we deep-link into the
  // Resumen feed where it lives. A future iteration may expose a
  // dedicated slot for "open composer" — keep it as a simple route
  // change for now.
  router.push(`/patients/${patientId}?tab=summary#new-note`)
}

function collect() {
  router.push(`/patients/${patientId}?tab=administration&adminMode=payments`)
}
</script>

<template>
  <div class="patient-detail space-y-4 pb-24 lg:pb-6">
    <!-- Loading state -->
    <div
      v-if="status === 'pending'"
      class="overflow-hidden bg-[var(--color-surface)] p-5 sm:p-6 space-y-4"
      style="border-radius: var(--radius-xl)"
    >
      <USkeleton class="h-16 w-full rounded-[var(--radius-lg)]" />
      <USkeleton class="h-8 w-64 rounded-[var(--radius-md)]" />
      <USkeleton class="h-96 w-full rounded-[var(--radius-lg)]" />
    </div>

    <!-- Patient content -->
    <template v-else-if="patient">
      <!-- Return to invoice banner -->
      <div
        v-if="returnTo"
        class="alert-surface-info rounded-[var(--radius-xl)] px-4 py-3 flex items-center justify-between gap-3"
        role="status"
      >
        <span class="text-body">
          {{ t('patients.editingBillingForInvoice') }}
        </span>
        <UButton
          variant="soft"
          color="primary"
          size="sm"
          icon="i-lucide-arrow-left"
          class="rounded-full"
          :to="returnTo"
        >
          {{ t('patients.returnToInvoice') }}
        </UButton>
      </div>

      <div
        class="overflow-hidden bg-[var(--color-surface)]"
        style="border-radius: var(--radius-xl)"
      >
        <!-- Persistent header — stays visible across all tabs. -->
        <PatientStickyHeader
          :patient="patient"
          @back="goBack"
          @edit="openEditPatient"
          @new-appointment="newAppointment"
          @new-note="newNote"
          @collect="collect"
          @archive="isArchiveModalOpen = true"
        />

        <main class="w-full min-w-0">
          <div
            class="px-5 sm:px-6 flex items-center gap-6 overflow-x-auto border-b border-[var(--color-border-subtle)]"
            role="tablist"
          >
            <button
              v-for="tab in tabs"
              :key="tab.value"
              type="button"
              role="tab"
              class="relative pb-3 text-sm whitespace-nowrap transition-colors shrink-0"
              :class="activeTab === tab.value
                ? 'font-medium text-[var(--color-primary)]'
                : 'text-muted hover:text-default'"
              :aria-selected="activeTab === tab.value"
              @click="activeTab = tab.value"
            >
              {{ tab.label }}
              <span
                v-if="activeTab === tab.value"
                class="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-[var(--color-primary)]"
              />
            </button>
          </div>

          <!-- Resumen — smart-card grid + clinical-notes feed.
               The whole Resumen body is slot-driven; modules register
               their cards via `.client.ts` plugins that only run after
               hydration. Wrapping in <ClientOnly> keeps the SSR tree
               aligned with the client tree (an identically-shaped
               skeleton grid) so Vue doesn't hit hydration mismatches
               that re-layout the page after refresh. -->
          <div
            v-if="activeTab === 'summary'"
            class="px-5 sm:px-6 py-5"
          >
            <ClientOnly>
              <div class="space-y-4 overflow-visible">
                <div
                  v-if="summaryCards.length === 0"
                  class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3 lg:gap-4"
                >
                  <div
                    class="md:col-span-2 xl:col-span-3 rounded-[var(--radius-lg)] border border-dashed border-[var(--color-border)] px-4 py-10 text-center text-muted"
                  >
                    {{ t('patientDetail.noSummaryCards') }}
                  </div>
                </div>
                <div
                  v-else
                  class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3 lg:gap-4"
                >
                  <component
                    :is="entry.component"
                    v-for="entry in summaryCards"
                    :key="entry.id"
                    :ctx="{ patient }"
                  />
                </div>

                <section id="new-note">
                  <ModuleSlot
                    name="patient.summary.feed"
                    :ctx="{ patient }"
                  />
                </section>

                <ModuleSlot
                  name="patient.detail.sidebar"
                  :ctx="{ patient }"
                />
              </div>

              <template #fallback>
                <div class="space-y-4">
                  <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3 lg:gap-4">
                    <USkeleton
                      v-for="i in 6"
                      :key="i"
                      class="h-36 w-full rounded-[var(--radius-lg)]"
                    />
                  </div>
                  <USkeleton class="h-40 w-full rounded-[var(--radius-lg)]" />
                </div>
              </template>
            </ClientOnly>
          </div>

          <!-- Datos tab content -->
          <div
            v-if="activeTab === 'info'"
            class="px-5 sm:px-6 py-5 space-y-4 overflow-visible"
          >
            <MedicalSnapshotCard
              :medical-history="medicalHistory"
              :active-alerts="patient.active_alerts"
              :can-edit="canEditMedicalHistory"
              @edit="openSectionModal('medical')"
              @complete-history="openSectionModal('medical')"
            />

            <PersonalInfoCard
              :patient="patient"
              :can-edit="canEditPatient"
              @edit="openSectionModal('demographics')"
            />

            <ContactInfoCard
              :patient="patient"
              :is-minor="isMinor"
              :can-edit="canEditPatient"
              @edit-contact="openSectionModal('demographics')"
              @edit-emergency="openSectionModal('emergency')"
              @edit-guardian="openSectionModal('guardian')"
            />

            <AdministrativeCard
              :patient="patient"
              :can-edit="canEditPatient"
              @edit="openSectionModal('billing')"
            />

            <!-- Danger zone -->
            <div class="alert-surface-danger rounded-[var(--radius-xl)] px-4 py-3 flex items-center justify-between gap-4">
              <div class="min-w-0">
                <div class="text-ui">
                  {{ t('patients.dangerZone.title') }}
                </div>
                <div class="text-caption">
                  {{ t('patients.dangerZone.archiveHelp') }}
                </div>
              </div>
              <UButton
                variant="outline"
                color="error"
                icon="i-lucide-archive"
                size="sm"
                class="rounded-full"
                @click="isArchiveModalOpen = true"
              >
                {{ t('patients.archive') }}
              </UButton>
            </div>
          </div>

          <!-- Clinical tab content (Odontogram + Treatment Plans) -->
          <div
            v-if="activeTab === 'clinical' && tabs.some((tab) => tab.value === 'clinical')"
            class="px-5 sm:px-6 py-5"
          >
            <ClinicalTab
              :patient-id="patientId"
              :readonly="!can(PERMISSIONS.odontogram.write)"
            />
          </div>

          <!-- Administration tab content (Budgets + Billing + Payments) -->
          <div
            v-if="activeTab === 'administration' && tabs.some((tab) => tab.value === 'administration')"
            class="px-5 sm:px-6 py-5"
          >
            <AdministrationTab
              :patient-id="patientId"
              :patient="patient"
            />
          </div>

          <!-- Gallery tab content -->
          <div
            v-if="activeTab === 'gallery' && tabs.some((tab) => tab.value === 'gallery')"
            class="px-5 sm:px-6 py-5"
          >
            <PhotoGallery :patient-id="patientId" />
          </div>

          <!-- Timeline tab content -->
          <div
            v-if="activeTab === 'timeline'"
            class="px-5 sm:px-6 py-5"
          >
            <PatientTimeline :patient-id="patientId" />
          </div>
        </main>
      </div>

      <!-- Mobile bottom action bar -->
      <PatientBottomActionBar
        :patient="patient"
        @new-appointment="newAppointment"
        @collect="collect"
        @new-note="newNote"
      />
    </template>

    <!-- Section Edit Modal -->
    <PatientSectionEditModal
      v-if="patient"
      v-model:open="editModalOpen"
      :section="editModalSection"
      :patient="patient"
      :medical-history="medicalHistory"
      :is-saving-medical="isSavingMedical"
      @save="handleSectionSave"
      @save-medical="handleMedicalSave"
    />

    <!-- Archive confirmation modal -->
    <UModal v-model:open="isArchiveModalOpen">
      <template #content>
        <UCard>
          <template #header>
            <h2 class="text-h1 text-default">
              {{ t('patients.archiveConfirm', { name: `${patient?.first_name} ${patient?.last_name}` }) }}
            </h2>
          </template>
          <p class="text-body text-muted">
            {{ t('patients.archiveDescription') }}
          </p>
          <template #footer>
            <div class="flex justify-end gap-3">
              <UButton
                variant="outline"
                color="neutral"
                @click="isArchiveModalOpen = false"
              >
                {{ t('patients.cancel') }}
              </UButton>
              <UButton
                color="error"
                :loading="isSubmitting"
                @click="archivePatient"
              >
                {{ t('patients.archive') }}
              </UButton>
            </div>
          </template>
        </UCard>
      </template>
    </UModal>
  </div>
</template>
