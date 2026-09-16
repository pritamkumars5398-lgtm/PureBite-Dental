<script setup lang="ts">
const { t } = useI18n()
const { currentLocale, availableLocales, changeLocale } = useLocale()
</script>

<template>
  <SectionCard
    icon="i-lucide-languages"
    :title="t('settings.language')"
    class="!rounded-[var(--radius-xl)]"
  >
    <p class="text-caption text-subtle mb-4">
      {{ t('settings.languageDescription') }}
    </p>

    <div class="flex gap-2">
      <UButton
        v-for="loc in availableLocales"
        :key="loc.code"
        :variant="currentLocale === loc.code ? 'solid' : 'outline'"
        :color="currentLocale === loc.code ? 'primary' : 'neutral'"
        @click="changeLocale(loc.code)"
      >
        {{ loc.name }}
      </UButton>
    </div>
  </SectionCard>
</template>
