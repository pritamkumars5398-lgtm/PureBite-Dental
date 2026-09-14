<script setup lang="ts">
const { t, locale } = useI18n()

useHead(() => ({
  meta: [
    { name: 'viewport', content: 'width=device-width, initial-scale=1' }
  ],
  link: [
    { rel: 'icon', href: '/favicon.ico' }
  ],
  htmlAttrs: {
    lang: locale.value
  }
}))

useSeoMeta({
  title: 'Nº 1 Dental Studio',
  description: t('app.tagline')
})

// Dynamically apply superadmin-configured clinic theme color
useClinicTheme()
</script>

<template>
  <UApp>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </UApp>
</template>
