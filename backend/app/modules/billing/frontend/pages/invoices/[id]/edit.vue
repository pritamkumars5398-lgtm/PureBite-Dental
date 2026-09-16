<script setup lang="ts">
import type { InvoiceItem, Patient } from '~~/app/types'

const route = useRoute()
const router = useRouter()
const { t, locale } = useI18n()
const toast = useToast()

const {
  currentInvoice,
  isLoading,
  fetchInvoice,
  updateInvoice,
  removeItem,
  canEdit,
  formatCurrency
} = useInvoices()

const invoiceId = computed(() => route.params.id as string)

// State
const isSaving = ref(false)
const selectedPatient = ref<Patient | null>(null)
const isChangingPatient = ref(false)

// Form data (no billing fields - billing comes from patient)
const form = ref({
  payment_term_days: 30,
  due_date: '',
  internal_notes: '',
  public_notes: ''
})

// Track deleted items
const deletedItemIds = ref<Set<string>>(new Set())

// Item modal state
const isItemModalOpen = ref(false)
const editingItem = ref<InvoiceItem | undefined>(undefined)

function openAddItemModal() {
  editingItem.value = undefined
  isItemModalOpen.value = true
}

function openEditItemModal(item: InvoiceItem) {
  editingItem.value = item
  isItemModalOpen.value = true
}

// Can change patient? Only for drafts without budget link
const canChangePatient = computed(() => {
  return currentInvoice.value?.status === 'draft' && !currentInvoice.value?.budget
})

// Get effective billing data (from patient for drafts)
// Use selectedPatient if changed, otherwise use invoice patient
const effectiveBillingData = computed(() => {
  const patient = selectedPatient.value || currentInvoice.value?.patient
  if (!patient) return null

  return {
    name: patient.billing_name || `${patient.first_name} ${patient.last_name}`,
    tax_id: patient.billing_tax_id || '',
    email: patient.billing_email || patient.email || '',
    address: patient.billing_address || null
  }
})

// When patient is selected via PatientSearch component
function handlePatientChange(patient: Patient | null) {
  selectedPatient.value = patient
  isChangingPatient.value = false
}

// Load invoice
onMounted(async () => {
  const invoice = await fetchInvoice(invoiceId.value)

  if (!invoice) {
    toast.add({
      title: t('common.error'),
      description: t('invoice.notFound'),
      color: 'error'
    })
    router.push('/invoices')
    return
  }

  if (!canEdit(invoice)) {
    toast.add({
      title: t('common.error'),
      description: t('invoice.errors.cannotEdit'),
      color: 'error'
    })
    router.push(`/invoices/${invoiceId.value}`)
    return
  }

  // Populate form with invoice data (no billing fields)
  form.value = {
    payment_term_days: invoice.payment_term_days || 30,
    due_date: invoice.due_date?.split('T')[0] || '',
    internal_notes: invoice.internal_notes || '',
    public_notes: invoice.public_notes || ''
  }

  // Set selectedPatient for PatientSearch component
  if (invoice.patient) {
    selectedPatient.value = invoice.patient as Patient
  }
})

// Get current items (excluding deleted)
const currentItems = computed(() => {
  if (!currentInvoice.value?.items) return []
  return currentInvoice.value.items.filter(item => !deletedItemIds.value.has(item.id))
})

// Mark item for deletion
function markItemForDeletion(itemId: string) {
  deletedItemIds.value.add(itemId)
}

// Get item display name (from catalog if available)
function getItemName(item: InvoiceItem): string {
  if (item.catalog_item) {
    return item.catalog_item.names[locale.value] || item.catalog_item.names.es || item.catalog_item.internal_code
  }
  return item.description
}

// Handle item saved from modal (add or edit)
function handleItemSaved() {
  isItemModalOpen.value = false
  editingItem.value = undefined
  fetchInvoice(invoiceId.value) // Refresh invoice data
}

// Calculate totals (using server-side values, excluding deleted items)
const totals = computed(() => {
  let subtotal = 0
  let totalTax = 0

  currentItems.value.forEach((item) => {
    subtotal += Number(item.line_subtotal) - Number(item.line_discount)
    totalTax += Number(item.line_tax)
  })

  return {
    subtotal,
    totalTax,
    total: subtotal + totalTax
  }
})

// Save changes
async function handleSave() {
  if (currentItems.value.length === 0) {
    toast.add({
      title: t('common.error'),
      description: t('invoice.errors.itemsRequired'),
      color: 'error'
    })
    return
  }

  isSaving.value = true

  try {
    // 1. Update invoice details (no billing fields - comes from patient)
    const patientChanged = canChangePatient.value
      && selectedPatient.value?.id !== currentInvoice.value?.patient?.id

    await updateInvoice(invoiceId.value, {
      patient_id: patientChanged ? selectedPatient.value?.id : undefined,
      payment_term_days: form.value.payment_term_days,
      due_date: form.value.due_date || undefined,
      internal_notes: form.value.internal_notes || undefined,
      public_notes: form.value.public_notes || undefined
    })

    // 2. Delete removed items
    for (const itemId of deletedItemIds.value) {
      await removeItem(invoiceId.value, itemId)
    }

    toast.add({
      title: t('common.success'),
      description: t('invoice.messages.updated'),
      color: 'success'
    })

    router.push(`/invoices/${invoiceId.value}`)
  } catch {
    toast.add({
      title: t('common.error'),
      description: t('invoice.errors.update'),
      color: 'error'
    })
  } finally {
    isSaving.value = false
  }
}

function goBack() {
  router.push(`/invoices/${invoiceId.value}`)
}
</script>

<template>
  <div class="space-y-5">
    <!-- Loading state -->
    <div
      v-if="isLoading && !currentInvoice"
      class="space-y-4"
    >
      <div
        class="overflow-hidden bg-[var(--color-surface)] px-5 sm:px-6 py-6"
        style="border-radius: var(--radius-xl)"
      >
        <USkeleton class="h-8 w-48" />
      </div>
      <USkeleton
        class="h-64 w-full"
        style="border-radius: var(--radius-xl)"
      />
    </div>

    <!-- Content -->
    <template v-else-if="currentInvoice">
      <!-- Header card -->
      <div
        class="overflow-hidden bg-[var(--color-surface)]"
        style="border-radius: var(--radius-xl)"
      >
        <div class="px-5 sm:px-6 py-5 flex items-center gap-3">
          <UButton
            variant="ghost"
            color="neutral"
            icon="i-lucide-arrow-left"
            class="-ml-2"
            @click="goBack"
          />
          <div class="min-w-0">
            <h1 class="text-display text-default truncate">
              {{ t('invoice.edit') }}
            </h1>
            <p class="text-caption text-muted tnum">
              {{ currentInvoice.invoice_number || t('invoice.draftNoNumber') }}
            </p>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
        <!-- Left column - Form -->
        <div class="lg:col-span-2 space-y-5">
          <!-- Patient info -->
          <div
            class="overflow-hidden bg-[var(--color-surface)]"
            style="border-radius: var(--radius-xl)"
          >
            <header class="px-5 sm:px-6 pt-5 pb-3 flex items-center justify-between gap-3">
              <h2 class="text-h3 text-default">
                {{ t('invoice.patient') }}
              </h2>
              <UBadge
                v-if="!canChangePatient && currentInvoice.budget"
                color="neutral"
                variant="subtle"
              >
                {{ t('invoice.linkedToBudget') }}
              </UBadge>
            </header>
            <div class="px-5 sm:px-6 pb-5">

            <!-- Patient selector (for drafts without budget) -->
            <div v-if="canChangePatient">
              <!-- Show current patient with change button -->
              <div
                v-if="selectedPatient && !isChangingPatient"
                class="flex items-center justify-between"
              >
                <div>
                  <p class="font-medium text-default">
                    {{ selectedPatient.last_name }}, {{ selectedPatient.first_name }}
                  </p>
                  <p class="text-caption text-subtle">
                    {{ selectedPatient.email || '-' }}
                  </p>
                </div>
                <UButton
                  variant="outline"
                  color="neutral"
                  size="sm"
                  icon="i-lucide-repeat"
                  @click="isChangingPatient = true"
                >
                  {{ t('common.change') }}
                </UButton>
              </div>

              <!-- Patient search (shown when no patient or changing) -->
              <div v-else>
                <UFormField :label="t('invoice.selectPatient')">
                  <PatientVisualSelector
                    :model-value="selectedPatient"
                    @update:model-value="handlePatientChange"
                  />
                </UFormField>
                <UButton
                  v-if="isChangingPatient && selectedPatient"
                  variant="ghost"
                  color="neutral"
                  size="sm"
                  class="mt-2"
                  @click="isChangingPatient = false"
                >
                  {{ t('common.cancel') }}
                </UButton>
              </div>
            </div>

            <!-- Current patient display (read-only when linked to budget) -->
            <div
              v-else-if="currentInvoice.patient"
              class="flex items-center justify-between"
            >
              <div>
                <p class="font-medium text-default">
                  {{ currentInvoice.patient.last_name }}, {{ currentInvoice.patient.first_name }}
                </p>
                <p class="text-caption text-subtle">
                  {{ currentInvoice.patient.email || '-' }}
                </p>
              </div>
            </div>
            </div>
          </div>

          <!-- Billing data (from patient - read-only) -->
          <div
            class="overflow-hidden bg-[var(--color-surface)]"
            style="border-radius: var(--radius-xl)"
          >
            <header class="px-5 sm:px-6 pt-5 pb-3 flex items-center justify-between gap-3">
              <h2 class="text-h3 text-default">
                {{ t('invoice.billingData') }}
              </h2>
              <div class="flex items-center gap-2">
                <UBadge
                  color="info"
                  variant="subtle"
                >
                  {{ t('invoice.fromPatient') }}
                </UBadge>
                <UButton
                  v-if="currentInvoice?.patient?.id"
                  variant="ghost"
                  color="neutral"
                  size="xs"
                  icon="i-lucide-external-link"
                  :to="`/patients/${currentInvoice.patient.id}?tab=billing&returnTo=${encodeURIComponent(route.fullPath)}`"
                >
                  {{ t('invoice.editInPatient') }}
                </UButton>
              </div>
            </header>

            <div
              v-if="effectiveBillingData"
              class="px-5 sm:px-6 pb-5 space-y-3"
            >
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <p class="text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]">
                    {{ t('invoice.billingName') }}
                  </p>
                  <p class="mt-1 text-body text-default">
                    {{ effectiveBillingData.name || '-' }}
                  </p>
                </div>
                <div>
                  <p class="text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]">
                    {{ t('invoice.taxId') }}
                  </p>
                  <p class="mt-1 text-body text-default tnum">
                    {{ effectiveBillingData.tax_id || '-' }}
                  </p>
                </div>
                <div>
                  <p class="text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]">
                    {{ t('invoice.billingEmail') }}
                  </p>
                  <p class="mt-1 text-body text-default">
                    {{ effectiveBillingData.email || '-' }}
                  </p>
                </div>
                <div v-if="effectiveBillingData.address">
                  <p class="text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]">
                    {{ t('invoice.billingAddress') }}
                  </p>
                  <p class="mt-1 text-body text-default">
                    {{ effectiveBillingData.address.street }},
                    {{ effectiveBillingData.address.postal_code }} {{ effectiveBillingData.address.city }}
                  </p>
                </div>
              </div>

              <p class="text-caption text-subtle italic">
                {{ t('invoice.billingFromPatientHint') }}
              </p>
            </div>
            <div
              v-else
              class="px-5 sm:px-6 pb-5"
            >
              <p class="text-caption text-subtle">
                {{ t('invoice.noBillingData') }}
              </p>
            </div>
          </div>

          <!-- Payment terms -->
          <div
            class="overflow-hidden bg-[var(--color-surface)]"
            style="border-radius: var(--radius-xl)"
          >
            <header class="px-5 sm:px-6 pt-5 pb-3">
              <h2 class="text-h3 text-default">
                {{ t('invoice.paymentTerms') }}
              </h2>
            </header>
            <div class="px-5 sm:px-6 pb-5 grid grid-cols-1 md:grid-cols-2 gap-4">
              <UFormField :label="t('invoice.paymentTermDays')">
                <UInput
                  v-model.number="form.payment_term_days"
                  type="number"
                  :min="0"
                  class="focus-visible:ring-[var(--color-primary)]"
                />
              </UFormField>

              <UFormField :label="t('invoice.dueDate')">
                <UInput
                  v-model="form.due_date"
                  type="date"
                  class="focus-visible:ring-[var(--color-primary)]"
                />
              </UFormField>
            </div>
          </div>

          <!-- Items table -->
          <div
            class="overflow-hidden bg-[var(--color-surface)]"
            style="border-radius: var(--radius-xl)"
          >
            <header class="px-5 sm:px-6 pt-5 pb-3 flex items-center justify-between gap-3">
              <h2 class="text-h3 text-default">
                {{ t('invoice.items') }}
              </h2>
              <UButton
                color="primary"
                icon="i-lucide-plus"
                size="sm"
                class="rounded-full"
                @click="openAddItemModal"
              >
                {{ t('invoice.addItem') }}
              </UButton>
            </header>

            <div
              v-if="currentItems.length === 0"
              class="px-5 sm:px-6 pb-6 text-center text-subtle"
            >
              {{ t('budget.items.empty') }}
            </div>

            <template v-else>
              <div
                class="hidden md:flex items-center gap-3 px-5 sm:px-6 py-2.5 border-t border-b border-[var(--color-border-subtle)] text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-text-subtle)]"
              >
                <span class="flex-1 min-w-0">{{ t('invoice.itemDescription') }}</span>
                <span class="w-14 text-right">{{ t('invoice.itemQuantity') }}</span>
                <span class="w-24 text-right">{{ t('invoice.itemPrice') }}</span>
                <span class="w-24 text-right">{{ t('invoice.total') }}</span>
                <span class="w-16" />
              </div>
              <div>
                <div
                  v-for="item in currentItems"
                  :key="item.id"
                  class="px-5 sm:px-6 py-3.5 border-b border-[var(--color-border-subtle)] last:border-b-0 cursor-pointer hover:bg-[var(--color-surface-muted)] transition-colors"
                  @click="openEditItemModal(item)"
                >
                  <div class="hidden md:flex items-center gap-3">
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2 flex-wrap">
                        <span class="text-ui text-default">{{ getItemName(item) }}</span>
                        <span
                          v-if="item.tooth_number"
                          class="text-caption text-subtle"
                        >
                          #{{ item.tooth_number }}
                          <span v-if="item.surfaces?.length">({{ item.surfaces.join(', ') }})</span>
                        </span>
                      </div>
                      <p
                        v-if="item.catalog_item?.internal_code"
                        class="text-caption text-subtle mt-0.5"
                      >
                        {{ item.catalog_item.internal_code }}
                      </p>
                    </div>
                    <span class="w-14 text-right text-caption text-subtle tnum">{{ item.quantity }}</span>
                    <span class="w-24 text-right text-caption text-subtle tnum">{{ formatCurrency(item.unit_price) }}</span>
                    <span class="w-24 text-right text-ui font-medium text-default tnum">{{ formatCurrency(item.line_total) }}</span>
                    <div class="w-16 flex items-center justify-end gap-0.5">
                      <UButton
                        variant="ghost"
                        color="neutral"
                        icon="i-lucide-pencil"
                        size="xs"
                        :aria-label="t('invoice.editItem')"
                        @click.stop="openEditItemModal(item)"
                      />
                      <UButton
                        variant="ghost"
                        color="error"
                        icon="i-lucide-trash-2"
                        size="xs"
                        :aria-label="t('common.delete')"
                        @click.stop="markItemForDeletion(item.id)"
                      />
                    </div>
                  </div>
                  <div class="md:hidden flex items-start gap-3">
                    <div class="flex-1 min-w-0">
                      <p class="text-ui text-default">{{ getItemName(item) }}</p>
                      <p class="text-caption text-subtle tnum">
                        {{ item.quantity }} × {{ formatCurrency(item.unit_price) }}
                        <span
                          v-if="item.line_discount > 0"
                          class="text-success-accent"
                        >
                          -{{ formatCurrency(item.line_discount) }}
                        </span>
                      </p>
                    </div>
                    <p class="text-ui font-medium tnum">{{ formatCurrency(item.line_total) }}</p>
                    <UButton
                      variant="ghost"
                      color="error"
                      icon="i-lucide-trash-2"
                      size="xs"
                      @click.stop="markItemForDeletion(item.id)"
                    />
                  </div>
                </div>
              </div>
            </template>
          </div>

          <!-- Notes -->
          <div
            class="overflow-hidden bg-[var(--color-surface)]"
            style="border-radius: var(--radius-xl)"
          >
            <header class="px-5 sm:px-6 pt-5 pb-3">
              <h2 class="text-h3 text-default">
                {{ t('invoice.notes') }}
              </h2>
            </header>
            <div class="px-5 sm:px-6 pb-5 space-y-4">
              <UFormField :label="t('invoice.publicNotes')">
                <UTextarea
                  v-model="form.public_notes"
                  :rows="2"
                  :placeholder="t('invoice.publicNotesPlaceholder')"
                />
              </UFormField>

              <UFormField :label="t('invoice.internalNotes')">
                <UTextarea
                  v-model="form.internal_notes"
                  :rows="2"
                  :placeholder="t('invoice.internalNotesPlaceholder')"
                />
              </UFormField>
            </div>
          </div>
        </div>

        <!-- Right column - Summary -->
        <div class="space-y-5">
          <div
            class="overflow-hidden bg-[var(--color-surface)]"
            style="border-radius: var(--radius-xl)"
          >
            <header class="px-5 sm:px-6 pt-5 pb-3">
              <h2 class="text-h3 text-default">
                {{ t('invoice.summary') }}
              </h2>
            </header>
            <div class="px-5 sm:px-6 pb-5 space-y-3">
              <div class="flex justify-between">
                <span class="text-subtle">{{ t('invoice.subtotal') }}</span>
                <span class="font-medium tnum">{{ formatCurrency(totals.subtotal) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-subtle">{{ t('invoice.tax') }}</span>
                <span class="font-medium tnum">{{ formatCurrency(totals.totalTax) }}</span>
              </div>
              <div class="flex justify-between pt-3 border-t border-[var(--color-border-subtle)]">
                <span class="font-semibold text-default">{{ t('invoice.total') }}</span>
                <span class="font-bold text-lg text-default tnum">
                  {{ formatCurrency(totals.total) }}
                </span>
              </div>
              <div class="pt-3 space-y-2">
                <UButton
                  block
                  color="primary"
                  class="rounded-full"
                  :loading="isSaving"
                  @click="handleSave"
                >
                  {{ t('common.save') }}
                </UButton>
                <UButton
                  block
                  variant="outline"
                  color="neutral"
                  class="rounded-full"
                  @click="goBack"
                >
                  {{ t('common.cancel') }}
                </UButton>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- Item Modal (Add/Edit) -->
    <InvoiceItemModal
      v-model:open="isItemModalOpen"
      :invoice-id="invoiceId"
      :edit-item="editingItem"
      @saved="handleItemSaved"
    />
  </div>
</template>
