<script setup lang="ts">
definePageMeta({
  layout: 'guest'
})

const { t } = useI18n()
const auth = useAuth()
const toast = useToast()

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

const isLoading = ref(false)
const showPassword = ref(false)
const formState = reactive({
  email: '',
  password: ''
})
const errorMessage = ref('')
const emailError = ref('')
const passwordError = ref('')

function validate(): boolean {
  emailError.value = ''
  passwordError.value = ''

  const email = formState.email.trim()
  if (!email) {
    emailError.value = t('auth.emailRequired')
  } else if (!EMAIL_RE.test(email)) {
    emailError.value = t('auth.emailInvalid')
  }

  if (!formState.password) {
    passwordError.value = t('auth.passwordRequired')
  }

  return !emailError.value && !passwordError.value
}

function mapError(err: unknown): string {
  const e = err as {
    statusCode?: number
    status?: number
    message?: string
    data?: { message?: string }
  }
  const status = e.statusCode ?? e.status

  switch (status) {
    case 400:
    case 401:
      return t('auth.invalidCredentials')
    case 403:
      return t('auth.accountInactive')
    case 422:
      return t('auth.invalidCredentials')
    case 429:
      return t('auth.tooManyAttempts')
  }

  if (!status || status === 0 || (e.message && /network|fetch|failed/i.test(e.message))) {
    return t('auth.networkError')
  }
  if (status >= 500) {
    return t('auth.serverError')
  }
  return t('auth.unknownError')
}

async function onSubmit() {
  errorMessage.value = ''
  if (!validate()) return

  isLoading.value = true
  try {
    await auth.login({
      email: formState.email.trim(),
      password: formState.password
    })

    toast.add({
      title: t('auth.loginSuccess'),
      color: 'success'
    })

    const clinic = auth.clinics.value?.[0]
    if (clinic?.name === 'Platform Administration') {
      await navigateTo('/admin')
    } else {
      await navigateTo('/')
    }
  } catch (error: unknown) {
    console.error('Login error:', error)
    errorMessage.value = mapError(error)
  } finally {
    isLoading.value = false
  }
}

watch(() => formState.email, () => {
  if (emailError.value) emailError.value = ''
  if (errorMessage.value) errorMessage.value = ''
})
watch(() => formState.password, () => {
  if (passwordError.value) passwordError.value = ''
  if (errorMessage.value) errorMessage.value = ''
})
</script>

<template>
  <div class="w-full max-w-5xl">
    <div class="grid lg:grid-cols-2 gap-10 lg:gap-16 items-center">
      <div class="text-center lg:text-left">
        <NuxtLink
          to="/landing"
          class="inline-block text-2xl sm:text-3xl font-semibold tracking-tight text-default hover:text-primary-accent transition-colors"
        >
          {{ t('app.name') }}
        </NuxtLink>
        <p class="text-body text-muted mt-2">
          {{ t('app.tagline') }}
        </p>
        <DentalArchArt class="mt-6 lg:mt-10 max-w-[220px] sm:max-w-xs lg:max-w-md mx-auto lg:mx-0" />
      </div>

      <div class="w-full max-w-[440px] mx-auto lg:max-w-none">
        <div class="mb-8 flex flex-col items-center lg:items-start">
          <ToothMark
            size="lg"
            class="mb-4"
          />
          <h1 class="text-2xl font-semibold tracking-tight text-default">
            {{ t('auth.welcomeBack') }}
          </h1>
        </div>

        <div class="bg-surface rounded-[var(--radius-xl)] p-6 sm:p-8">
          <form
            class="space-y-5"
            @submit.prevent="onSubmit"
          >
            <div
              v-if="errorMessage"
              class="alert-surface-danger rounded-[var(--radius-lg)] px-3 py-2.5 flex items-start gap-2"
              role="alert"
            >
              <UIcon
                name="i-lucide-alert-circle"
                class="w-4 h-4 mt-0.5 shrink-0"
                :style="{ color: 'var(--color-danger-accent)' }"
              />
              <span class="text-body">
                {{ errorMessage }}
              </span>
            </div>

            <UFormField
              :label="t('auth.email')"
              name="email"
              :error="emailError || undefined"
            >
              <UInput
                v-model="formState.email"
                type="email"
                class="w-full"
                :placeholder="t('auth.email')"
                icon="i-lucide-mail"
                autocomplete="email"
                :disabled="isLoading"
              />
            </UFormField>

            <UFormField
              :label="t('auth.password')"
              name="password"
              :error="passwordError || undefined"
            >
              <div class="relative w-full">
                <UInput
                  v-model="formState.password"
                  :type="showPassword ? 'text' : 'password'"
                  class="w-full"
                  :placeholder="t('auth.password')"
                  icon="i-lucide-lock"
                  autocomplete="current-password"
                  :disabled="isLoading"
                />
                <button
                  type="button"
                  class="absolute inset-y-0 right-0 px-3 flex items-center text-muted hover:text-default z-10"
                  tabindex="-1"
                  :aria-label="showPassword ? t('auth.hidePassword') : t('auth.showPassword')"
                  @click="showPassword = !showPassword"
                >
                  <UIcon
                    :name="showPassword ? 'i-lucide-eye-off' : 'i-lucide-eye'"
                    class="w-4 h-4"
                  />
                </button>
              </div>
            </UFormField>

            <UButton
              type="submit"
              color="primary"
              variant="solid"
              size="lg"
              block
              class="rounded-token-pill"
              :loading="isLoading"
              :disabled="isLoading"
            >
              {{ t('auth.loginButton') }}
            </UButton>
          </form>
        </div>

        <DemoCredentialsHint />

        <p class="text-center lg:text-left text-caption text-subtle mt-8">
          &copy; {{ new Date().getFullYear() }} {{ t('app.name') }}
        </p>
      </div>
    </div>
  </div>
</template>
