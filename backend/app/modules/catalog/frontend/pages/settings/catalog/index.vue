<script setup lang="ts">
import type { TreatmentCatalogItem, TreatmentCatalogItemUpdate, TreatmentCatalogItemCreate, VatTypeBrief } from '~~/app/types'

const PAGE_SIZE = 20

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
const catalog = useCatalog()

const showModal = ref(false)
const editingItem = ref<TreatmentCatalogItem | null>(null)
const isSaving = ref(false)

const showDeleteConfirm = ref(false)
const itemToDelete = ref<TreatmentCatalogItem | null>(null)
const isDeleting = ref(false)

const searchQuery = ref('')
const selectedCategoryIds = ref<string[]>([])
const statusTab = ref<'active' | 'inactive'>('active')

onMounted(async () => {
  await catalog.fetchCategories()
  await loadItems(1)
})

watch([selectedCategoryIds, statusTab], () => {
  loadItems(1)
})

const statusTabs = computed(() => [
  { label: t('catalog.listTabs.active'), value: 'active' },
  { label: t('catalog.listTabs.inactive'), value: 'inactive' },
])

const categoryFilterItems = computed(() =>
  catalog.activeCategories.value.map(c => ({
    value: c.id,
    label: catalog.getCategoryName(c),
  })),
)

const activeFilterCount = computed(() => selectedCategoryIds.value.length)

function loadItems(page = 1) {
  return catalog.fetchItems({
    page,
    pageSize: PAGE_SIZE,
    search: searchQuery.value || undefined,
    categoryId: selectedCategoryIds.value[0],
    isActive: statusTab.value === 'active',
  })
}

function handlePageChange(page: number) {
  loadItems(page)
}

function onSearchDebounced() {
  loadItems(1)
}

function resetFilters() {
  selectedCategoryIds.value = []
  searchQuery.value = ''
  loadItems(1)
}

function openCreateModal() {
  editingItem.value = null
  showModal.value = true
}

function openEditModal(item: TreatmentCatalogItem) {
  editingItem.value = item
  showModal.value = true
}

async function handleCreateItem(data: TreatmentCatalogItemCreate) {
  isSaving.value = true
  const result = await catalog.createItem(data)
  isSaving.value = false

  if (result) {
    showModal.value = false
  }
}

async function handleSaveItem(data: TreatmentCatalogItemUpdate) {
  if (!editingItem.value) return

  isSaving.value = true
  const result = await catalog.updateItem(editingItem.value.id, data)
  isSaving.value = false

  if (result) {
    showModal.value = false
    editingItem.value = null
  }
}

function confirmDelete(item: TreatmentCatalogItem) {
  itemToDelete.value = item
  showDeleteConfirm.value = true
}

async function handleDeleteItem() {
  if (!itemToDelete.value) return

  isDeleting.value = true
  const result = await catalog.deleteItem(itemToDelete.value.id)
  isDeleting.value = false

  if (result) {
    showDeleteConfirm.value = false
    itemToDelete.value = null
  }
}

function getItemName(item: TreatmentCatalogItem): string {
  return catalog.getItemName(item)
}

function getCategoryName(categoryId: string): string {
  const category = catalog.categories.value.find(c => c.id === categoryId)
  return category ? catalog.getCategoryName(category) : '-'
}

function getVatTypeLabel(vatType: VatTypeBrief | undefined): string {
  if (!vatType) return '-'
  return vatType.names[locale.value] || vatType.names.es || vatType.names.en || '-'
}

function getVatTypeBadgeColor(vatType: VatTypeBrief | undefined): string {
  if (!vatType) return 'neutral'
  if (vatType.rate === 0) return 'success'
  if (vatType.rate < 10) return 'warning'
  return 'error'
}

function itemInitials(item: TreatmentCatalogItem): string {
  const name = getItemName(item).trim()
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

function durationLabel(minutes: number | null | undefined): string {
  if (!minutes) return '—'
  return t('time.minutes', { n: minutes })
}
</script>

<template>
  <DataListLayout
    :title="t('catalog.title')"
    :subtitle="t('catalog.description')"
    :noun="t('lists.noun.treatments')"
    :loading="catalog.loading.value"
    :empty="!catalog.items.value.length"
    :error="catalog.error.value"
    :page="catalog.currentPage.value"
    :page-size="catalog.pageSize.value"
    :total="catalog.totalItems.value"
    :total-pages="catalog.totalPages.value"
    @update:page="handlePageChange"
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
      <FilterBar
        :active-count="activeFilterCount"
        always-collapsed
        @reset="resetFilters"
      >
        <template #search>
          <SearchBar
            :model-value="searchQuery"
            :placeholder="t('catalog.searchPlaceholder')"
            max-width="max-w-sm"
            @update:model-value="(v) => (searchQuery = v)"
            @update:debounced="onSearchDebounced"
          />
        </template>

        <FilterChipMulti
          :model-value="selectedCategoryIds"
          :items="categoryFilterItems"
          :label="t('catalog.category')"
          icon="i-lucide-layers"
          :multiple="false"
          @update:model-value="(v) => (selectedCategoryIds = v)"
        />
      </FilterBar>
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
        {{ t('catalog.newItem') }}
      </UButton>
    </template>

    <template #empty>
      <EmptyState
        icon="i-lucide-package"
        :title="t('catalog.noItems')"
      >
        <template
          v-if="isAdmin && !activeFilterCount && !searchQuery"
          #actions
        >
          <UButton
            color="primary"
            variant="solid"
            icon="i-lucide-plus"
            class="rounded-full"
            @click="openCreateModal"
          >
            {{ t('catalog.newItem') }}
          </UButton>
        </template>
      </EmptyState>
    </template>

    <template #columns>
      <span class="w-9 shrink-0" />
      <span class="flex-1">{{ t('catalog.name') }}</span>
      <span class="hidden sm:inline w-28">{{ t('catalog.code') }}</span>
      <span class="hidden md:inline w-40">{{ t('catalog.category') }}</span>
      <span class="w-28 text-right">{{ t('catalog.price') }}</span>
      <span class="hidden lg:inline w-32 text-center">{{ t('catalog.vatType') }}</span>
      <span class="hidden xl:inline w-24 text-center">{{ t('catalog.duration') }}</span>
      <span class="w-16" />
    </template>

    <template #rows>
      <DataListItem
        v-for="item in catalog.items.value"
        :key="item.id"
      >
        <template #row>
          <div
            class="w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-semibold shrink-0"
            :class="avatarTone(item.id)"
          >
            {{ itemInitials(item) }}
          </div>
          <div class="flex-1 min-w-0">
            <div class="text-ui text-default truncate flex items-center gap-1.5 flex-wrap">
              <span class="truncate">{{ getItemName(item) }}</span>
              <UBadge
                v-if="item.is_system"
                variant="subtle"
                color="info"
                size="xs"
              >
                {{ t('catalog.system') }}
              </UBadge>
              <UBadge
                v-if="!item.is_active"
                variant="subtle"
                color="error"
                size="xs"
              >
                {{ t('common.inactive') }}
              </UBadge>
            </div>
            <div class="text-caption text-subtle font-mono truncate sm:hidden">
              {{ item.internal_code }}
            </div>
          </div>
          <div class="hidden sm:block w-28 shrink-0 font-mono text-caption text-muted truncate">
            {{ item.internal_code }}
          </div>
          <div class="hidden md:block w-40 shrink-0 text-caption text-muted truncate">
            {{ getCategoryName(item.category_id) }}
          </div>
          <div class="w-28 shrink-0 text-right text-ui text-default tnum">
            {{ catalog.formatPrice(item.default_price) }}
          </div>
          <div class="hidden lg:flex w-32 shrink-0 justify-center">
            <UBadge
              :color="getVatTypeBadgeColor(item.vat_type)"
              variant="subtle"
              size="xs"
            >
              {{ getVatTypeLabel(item.vat_type) }}
            </UBadge>
          </div>
          <div class="hidden xl:block w-24 shrink-0 text-center text-caption text-muted tnum">
            {{ durationLabel(item.default_duration_minutes) }}
          </div>
          <div
            v-if="isAdmin"
            class="w-16 shrink-0 flex items-center justify-end gap-0.5"
          >
            <UButton
              icon="i-lucide-pencil"
              size="xs"
              variant="ghost"
              color="neutral"
              :aria-label="t('common.edit')"
              @click="openEditModal(item)"
            />
            <UButton
              v-if="!item.is_system"
              icon="i-lucide-trash-2"
              size="xs"
              variant="ghost"
              color="error"
              :aria-label="t('common.delete')"
              @click="confirmDelete(item)"
            />
          </div>
        </template>

        <template #card>
          <div class="flex items-start justify-between gap-3">
            <div class="flex items-center gap-3 min-w-0 flex-1">
              <div
                class="w-10 h-10 rounded-full flex items-center justify-center text-xs font-semibold shrink-0"
                :class="avatarTone(item.id)"
              >
                {{ itemInitials(item) }}
              </div>
              <div class="min-w-0 flex-1">
                <div class="font-medium text-default truncate flex items-center gap-1.5">
                  {{ getItemName(item) }}
                  <UBadge
                    v-if="item.is_system"
                    variant="subtle"
                    color="info"
                    size="xs"
                  >
                    {{ t('catalog.system') }}
                  </UBadge>
                  <UBadge
                    v-if="!item.is_active"
                    variant="subtle"
                    color="error"
                    size="xs"
                  >
                    {{ t('common.inactive') }}
                  </UBadge>
                </div>
                <div class="text-caption text-subtle truncate">
                  {{ item.internal_code }} · {{ getCategoryName(item.category_id) }}
                </div>
              </div>
            </div>
            <div class="text-right shrink-0">
              <div class="font-medium text-default tnum">
                {{ catalog.formatPrice(item.default_price) }}
              </div>
              <div class="text-caption text-subtle">
                {{ getVatTypeLabel(item.vat_type) }}
              </div>
            </div>
          </div>
          <div
            v-if="isAdmin"
            class="flex justify-end gap-1"
          >
            <UButton
              icon="i-lucide-pencil"
              size="xs"
              variant="ghost"
              color="neutral"
              @click="openEditModal(item)"
            >
              {{ t('common.edit') }}
            </UButton>
            <UButton
              v-if="!item.is_system"
              icon="i-lucide-trash-2"
              size="xs"
              variant="ghost"
              color="error"
              @click="confirmDelete(item)"
            >
              {{ t('common.delete') }}
            </UButton>
          </div>
        </template>
      </DataListItem>
    </template>
  </DataListLayout>

  <CatalogItemModal
    v-model:open="showModal"
    :item="editingItem"
    :categories="catalog.categories.value"
    :loading="isSaving"
    @create="handleCreateItem"
    @save="handleSaveItem"
  />

  <UModal v-model:open="showDeleteConfirm">
    <template #content>
      <div class="bg-surface rounded-lg shadow-xl p-6 max-w-md">
        <div class="flex items-start gap-4">
          <div class="flex-shrink-0 w-10 h-10 rounded-full bg-[var(--color-danger-soft)] flex items-center justify-center">
            <UIcon
              name="i-lucide-trash-2"
              class="w-5 h-5 text-danger-accent"
            />
          </div>
          <div class="flex-1">
            <h3 class="text-h1 text-default">
              {{ t('catalog.deleteItem') }}
            </h3>
            <p class="mt-2 text-caption text-subtle">
              {{ t('catalog.deleteItemConfirm', { name: itemToDelete ? getItemName(itemToDelete) : '' }) }}
            </p>
            <p class="mt-1 text-sm text-subtle">
              {{ t('catalog.deleteItemNote') }}
            </p>
          </div>
        </div>
        <div class="flex justify-end gap-2 mt-6">
          <UButton
            variant="ghost"
            @click="showDeleteConfirm = false"
          >
            {{ t('common.cancel') }}
          </UButton>
          <UButton
            color="error"
            :loading="isDeleting"
            @click="handleDeleteItem"
          >
            {{ t('common.delete') }}
          </UButton>
        </div>
      </div>
    </template>
  </UModal>
</template>
