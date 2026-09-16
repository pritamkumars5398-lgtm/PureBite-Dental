<script setup lang="ts">
import type { VatType, VatTypeCreate, VatTypeUpdate } from '~~/app/types'

const AVATAR_TONES = [
  'bg-violet-100 text-violet-700',
  'bg-sky-100 text-sky-700',
  'bg-blue-100 text-blue-700',
  'bg-pink-100 text-pink-700',
  'bg-emerald-100 text-emerald-800',
  'bg-amber-100 text-amber-800',
  'bg-rose-100 text-rose-700',
] as const

const { t, locale } = useI18n()
const { isAdmin } = usePermissions()
const {
  vatTypes,
  isLoading,
  activeVatTypes,
  fetchVatTypes,
  createVatType,
  updateVatType,
  deleteVatType,
  getVatTypeName,
  getVatTypeLabel
} = useVatTypes()

const showCreateModal = ref(false)
const isCreating = ref(false)
const newVatType = ref({
  name: '',
  rate: 0,
  is_default: false
})

const showEditModal = ref(false)
const isEditing = ref(false)
const editingVatType = ref<VatType | null>(null)
const editData = ref({
  name: '',
  rate: 0,
  is_default: false,
  is_active: true
})

const showDeleteModal = ref(false)
const isDeleting = ref(false)
const vatTypeToDelete = ref<VatType | null>(null)

const searchQuery = ref('')
const statusTab = ref<'active' | 'inactive'>('active')

onMounted(() => {
  fetchVatTypes(false)
})

watch(statusTab, (tab) => {
  fetchVatTypes(tab === 'inactive')
})

const statusTabs = computed(() => [
  { label: t('vatTypes.listTabs.active'), value: 'active' },
  { label: t('vatTypes.listTabs.inactive'), value: 'inactive' },
])

const displayVatTypes = computed(() => {
  const source = statusTab.value === 'inactive'
    ? vatTypes.value.filter(vt => !vt.is_active)
    : activeVatTypes.value
  const q = searchQuery.value.trim().toLowerCase()
  if (!q) return source
  return source.filter((vt) => {
    const name = getVatTypeName(vt).toLowerCase()
    return name.includes(q) || String(vt.rate).includes(q)
  })
})

function openCreateModal() {
  newVatType.value = {
    name: '',
    rate: 0,
    is_default: false
  }
  showCreateModal.value = true
}

async function handleCreate() {
  isCreating.value = true
  const data: VatTypeCreate = {
    names: { [locale.value]: newVatType.value.name },
    rate: newVatType.value.rate,
    is_default: newVatType.value.is_default
  }
  const result = await createVatType(data)
  isCreating.value = false
  if (result) {
    showCreateModal.value = false
  }
}

function openEditModal(vatType: VatType) {
  editingVatType.value = vatType
  editData.value = {
    name: getVatTypeName(vatType),
    rate: vatType.rate,
    is_default: vatType.is_default,
    is_active: vatType.is_active
  }
  showEditModal.value = true
}

async function handleUpdate() {
  if (!editingVatType.value) return

  isEditing.value = true
  const data: VatTypeUpdate = {
    names: { [locale.value]: editData.value.name },
    rate: editData.value.rate,
    is_default: editData.value.is_default,
    is_active: editData.value.is_active
  }

  if (editingVatType.value.is_system) {
    delete data.names
    delete data.rate
    delete data.is_active
  }

  const result = await updateVatType(editingVatType.value.id, data)
  isEditing.value = false
  if (result) {
    showEditModal.value = false
    editingVatType.value = null
  }
}

function openDeleteModal(vatType: VatType) {
  vatTypeToDelete.value = vatType
  showDeleteModal.value = true
}

async function handleDelete() {
  if (!vatTypeToDelete.value) return

  isDeleting.value = true
  const result = await deleteVatType(vatTypeToDelete.value.id)
  isDeleting.value = false
  if (result) {
    showDeleteModal.value = false
    vatTypeToDelete.value = null
  }
}

function canDelete(vatType: VatType): boolean {
  return !vatType.is_system && !vatType.is_default
}

function canEdit(_vatType: VatType): boolean {
  return true
}

function vatInitials(vatType: VatType): string {
  const name = getVatTypeName(vatType).trim()
  const parts = name.split(/\s+/).filter(Boolean)
  if (parts.length >= 2) {
    return `${parts[0]!.charAt(0)}${parts[1]!.charAt(0)}`.toUpperCase()
  }
  return name.slice(0, 2).toUpperCase() || '?'
}

function avatarTone(id: string): string {
  let h = 0
  for (let i = 0; i < id.length; i++) h = (h + id.charCodeAt(i) * (i + 1)) % AVATAR_TONES.length
  return AVATAR_TONES[h] ?? AVATAR_TONES[0]
}

function rateColor(rate: number): string {
  if (rate === 0) return 'success'
  if (rate < 10) return 'warning'
  return 'error'
}
</script>

<template>
  <DataListLayout
    :title="t('vatTypes.title')"
    :subtitle="t('vatTypes.description')"
    :noun="t('lists.noun.vatTypes')"
    :loading="isLoading"
    :empty="!displayVatTypes.length"
    :page="1"
    :page-size="Math.max(displayVatTypes.length, 1)"
    :total="displayVatTypes.length"
    :total-pages="1"
  >
    <template #tabs>
      <div
        class="flex items-center gap-6"
        role="tablist"
      >
        <button
          v-for="tab in statusTabs"
          :key="tab.value"
          type="button"
          role="tab"
          class="relative pb-3 text-sm transition-colors"
          :class="statusTab === tab.value
            ? 'font-medium text-primary'
            : 'text-muted hover:text-default'"
          :aria-selected="statusTab === tab.value"
          @click="statusTab = tab.value"
        >
          {{ tab.label }}
          <span
            v-if="statusTab === tab.value"
            class="absolute inset-x-0 -bottom-px h-0.5 rounded-full bg-primary"
          />
        </button>
      </div>
    </template>

    <template #toolbar>
      <SearchBar
        :model-value="searchQuery"
        :placeholder="t('vatTypes.searchPlaceholder')"
        max-width="max-w-sm"
        @update:model-value="(v) => (searchQuery = v)"
      />
    </template>

    <template #actions>
      <UButton
        v-if="isAdmin"
        color="primary"
        variant="solid"
        icon="i-lucide-plus"
        class="rounded-full"
        @click="openCreateModal"
      >
        {{ t('vatTypes.new') }}
      </UButton>
    </template>

    <template #empty>
      <EmptyState
        icon="i-lucide-percent"
        :title="t('vatTypes.noItems')"
      >
        <template
          v-if="isAdmin && !searchQuery"
          #actions
        >
          <UButton
            color="primary"
            variant="solid"
            icon="i-lucide-plus"
            class="rounded-full"
            @click="openCreateModal"
          >
            {{ t('vatTypes.new') }}
          </UButton>
        </template>
      </EmptyState>
    </template>

    <template #columns>
      <span class="w-9 shrink-0" />
      <span class="flex-1">{{ t('vatTypes.name') }}</span>
      <span class="w-24 text-right">{{ t('vatTypes.rate') }}</span>
      <span class="hidden sm:inline w-48">{{ t('lists.columns.status') }}</span>
      <span class="w-16" />
    </template>

    <template #rows>
      <DataListItem
        v-for="vatType in displayVatTypes"
        :key="vatType.id"
      >
        <template #row>
          <div
            class="w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-semibold shrink-0"
            :class="avatarTone(vatType.id)"
          >
            {{ vatInitials(vatType) }}
          </div>
          <div class="flex-1 min-w-0">
            <div class="text-ui text-default truncate">
              {{ getVatTypeName(vatType) }}
            </div>
            <div class="text-caption text-subtle sm:hidden tnum">
              {{ vatType.rate }}%
            </div>
          </div>
          <div class="w-24 shrink-0 text-right">
            <UBadge
              :color="rateColor(vatType.rate)"
              variant="subtle"
              size="xs"
            >
              {{ vatType.rate }}%
            </UBadge>
          </div>
          <div class="hidden sm:flex w-48 shrink-0 items-center gap-1.5 flex-wrap">
            <UBadge
              v-if="vatType.is_default"
              color="info"
              variant="subtle"
              size="xs"
            >
              {{ t('vatTypes.default') }}
            </UBadge>
            <UBadge
              v-if="vatType.is_system"
              color="neutral"
              variant="subtle"
              size="xs"
            >
              {{ t('vatTypes.system') }}
            </UBadge>
            <UBadge
              v-if="!vatType.is_active"
              color="error"
              variant="subtle"
              size="xs"
            >
              {{ t('common.inactive') }}
            </UBadge>
          </div>
          <div class="w-16 shrink-0 flex items-center justify-end gap-0.5">
            <UButton
              v-if="isAdmin && canEdit(vatType)"
              icon="i-lucide-pencil"
              size="xs"
              variant="ghost"
              color="neutral"
              :aria-label="t('common.edit')"
              @click="openEditModal(vatType)"
            />
            <UButton
              v-if="isAdmin && canDelete(vatType)"
              icon="i-lucide-trash-2"
              size="xs"
              variant="ghost"
              color="error"
              :aria-label="t('common.delete')"
              @click="openDeleteModal(vatType)"
            />
          </div>
        </template>

        <template #card>
          <div class="flex items-start justify-between gap-3">
            <div class="flex items-center gap-3 min-w-0 flex-1">
              <div
                class="w-10 h-10 rounded-full flex items-center justify-center text-xs font-semibold shrink-0"
                :class="avatarTone(vatType.id)"
              >
                {{ vatInitials(vatType) }}
              </div>
              <div class="min-w-0 flex-1">
                <div class="font-medium text-default truncate">
                  {{ getVatTypeName(vatType) }}
                </div>
                <div class="flex flex-wrap gap-1 mt-1">
                  <UBadge
                    v-if="vatType.is_default"
                    color="info"
                    variant="subtle"
                    size="xs"
                  >
                    {{ t('vatTypes.default') }}
                  </UBadge>
                  <UBadge
                    v-if="vatType.is_system"
                    color="neutral"
                    variant="subtle"
                    size="xs"
                  >
                    {{ t('vatTypes.system') }}
                  </UBadge>
                  <UBadge
                    v-if="!vatType.is_active"
                    color="error"
                    variant="subtle"
                    size="xs"
                  >
                    {{ t('common.inactive') }}
                  </UBadge>
                </div>
              </div>
            </div>
            <UBadge
              :color="rateColor(vatType.rate)"
              variant="subtle"
            >
              {{ vatType.rate }}%
            </UBadge>
          </div>
          <div
            v-if="isAdmin"
            class="flex justify-end gap-1"
          >
            <UButton
              v-if="canEdit(vatType)"
              icon="i-lucide-pencil"
              size="xs"
              variant="ghost"
              color="neutral"
              @click="openEditModal(vatType)"
            >
              {{ t('common.edit') }}
            </UButton>
            <UButton
              v-if="canDelete(vatType)"
              icon="i-lucide-trash-2"
              size="xs"
              variant="ghost"
              color="error"
              @click="openDeleteModal(vatType)"
            >
              {{ t('common.delete') }}
            </UButton>
          </div>
        </template>
      </DataListItem>
    </template>
  </DataListLayout>

  <UModal v-model:open="showCreateModal">
    <template #content>
      <UCard>
        <template #header>
          <div class="flex items-center gap-2">
            <UIcon
              name="i-lucide-plus"
              class="w-5 h-5 text-primary-accent"
            />
            <h3 class="font-semibold text-default">
              {{ t('vatTypes.new') }}
            </h3>
          </div>
        </template>

        <form
          class="space-y-4"
          @submit.prevent="handleCreate"
        >
          <UFormField :label="t('vatTypes.name')">
            <UInput
              v-model="newVatType.name"
              required
              :placeholder="t('vatTypes.namePlaceholder')"
            />
          </UFormField>

          <UFormField :label="t('vatTypes.rate')">
            <UInput
              v-model.number="newVatType.rate"
              type="number"
              step="0.1"
              min="0"
              max="100"
              required
            >
              <template #trailing>
                %
              </template>
            </UInput>
          </UFormField>

          <div class="flex items-center gap-3">
            <USwitch v-model="newVatType.is_default" />
            <span class="text-sm text-muted">
              {{ t('vatTypes.setAsDefault') }}
            </span>
          </div>

          <div class="flex justify-end gap-2 pt-4">
            <UButton
              variant="ghost"
              @click="showCreateModal = false"
            >
              {{ t('common.cancel') }}
            </UButton>
            <UButton
              type="submit"
              :loading="isCreating"
            >
              {{ t('common.save') }}
            </UButton>
          </div>
        </form>
      </UCard>
    </template>
  </UModal>

  <UModal v-model:open="showEditModal">
    <template #content>
      <UCard>
        <template #header>
          <div class="flex items-center gap-2">
            <UIcon
              name="i-lucide-pencil"
              class="w-5 h-5 text-primary-accent"
            />
            <h3 class="font-semibold text-default">
              {{ t('vatTypes.edit') }}
            </h3>
          </div>
        </template>

        <form
          class="space-y-4"
          @submit.prevent="handleUpdate"
        >
          <UFormField :label="t('vatTypes.name')">
            <UInput
              v-model="editData.name"
              required
              :disabled="editingVatType?.is_system"
              :placeholder="t('vatTypes.namePlaceholder')"
            />
          </UFormField>

          <UFormField :label="t('vatTypes.rate')">
            <UInput
              v-model.number="editData.rate"
              type="number"
              step="0.1"
              min="0"
              max="100"
              required
              :disabled="editingVatType?.is_system"
            >
              <template #trailing>
                %
              </template>
            </UInput>
          </UFormField>

          <div class="flex items-center gap-3">
            <USwitch v-model="editData.is_default" />
            <span class="text-sm text-muted">
              {{ t('vatTypes.setAsDefault') }}
            </span>
          </div>

          <div
            v-if="!editingVatType?.is_system"
            class="flex items-center gap-3"
          >
            <USwitch v-model="editData.is_active" />
            <span class="text-sm text-muted">
              {{ t('vatTypes.active') }}
            </span>
          </div>

          <p
            v-if="editingVatType?.is_system"
            class="text-caption text-subtle"
          >
            {{ t('vatTypes.systemNote') }}
          </p>

          <div class="flex justify-end gap-2 pt-4">
            <UButton
              variant="ghost"
              @click="showEditModal = false"
            >
              {{ t('common.cancel') }}
            </UButton>
            <UButton
              type="submit"
              :loading="isEditing"
            >
              {{ t('common.save') }}
            </UButton>
          </div>
        </form>
      </UCard>
    </template>
  </UModal>

  <UModal v-model:open="showDeleteModal">
    <template #content>
      <UCard>
        <template #header>
          <div class="flex items-center gap-2">
            <UIcon
              name="i-lucide-alert-triangle"
              class="w-5 h-5 text-danger-accent"
            />
            <h3 class="font-semibold text-default">
              {{ t('vatTypes.delete') }}
            </h3>
          </div>
        </template>

        <p class="text-muted dark:text-subtle">
          {{ t('vatTypes.deleteConfirm') }}
          <strong class="text-default">
            {{ vatTypeToDelete ? getVatTypeLabel(vatTypeToDelete) : '' }}
          </strong>?
        </p>
        <p class="mt-2 text-caption text-subtle">
          {{ t('vatTypes.deleteNote') }}
        </p>

        <div class="flex justify-end gap-2 pt-6">
          <UButton
            variant="ghost"
            @click="showDeleteModal = false"
          >
            {{ t('common.cancel') }}
          </UButton>
          <UButton
            color="error"
            :loading="isDeleting"
            @click="handleDelete"
          >
            {{ t('common.delete') }}
          </UButton>
        </div>
      </UCard>
    </template>
  </UModal>
</template>
