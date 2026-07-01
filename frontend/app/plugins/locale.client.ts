import { STORAGE_KEYS } from '~/constants/storage'

export default defineNuxtPlugin(async (nuxtApp) => {
  const i18n = nuxtApp.$i18n
  const forcedLocale = 'en'

  const savedLocale = localStorage.getItem(STORAGE_KEYS.LOCALE)

  if (savedLocale !== forcedLocale) {
    localStorage.setItem(STORAGE_KEYS.LOCALE, forcedLocale)
  }

  if (i18n.locale.value !== forcedLocale) {
    await i18n.setLocale(forcedLocale)
  }
})
