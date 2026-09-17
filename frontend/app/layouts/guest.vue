<script setup lang="ts">
const { t } = useI18n()
</script>

<template>
  <div class="guest-shell min-h-screen flex flex-col relative overflow-hidden">
    <svg
      class="guest-shell__tooth pointer-events-none"
      viewBox="0 0 24 28"
      fill="none"
      stroke="currentColor"
      stroke-width="1.2"
      aria-hidden="true"
    >
      <path
        d="M12 5.5C9.5 2.5 4 2.8 2.8 7c-1.1 3.9 1 7.2 2 11.4.7 3 1.3 6.4 3.2 6.4 1.7 0 1.8-3.2 2.3-5.6.3-1.4.6-2.4 1.7-2.4s1.4 1 1.7 2.4c.5 2.4.6 5.6 2.3 5.6 1.9 0 2.5-3.4 3.2-6.4 1-4.2 3.1-7.5 2-11.4C20 2.8 14.5 2.5 12 5.5Z"
        stroke-linejoin="round"
      />
    </svg>

    <DemoBanner />
    <div class="relative z-10 px-4 pt-5 sm:px-8 flex items-center justify-between gap-3">
      <NuxtLink
        to="/landing"
        class="inline-flex items-center text-ui font-semibold tracking-tight text-default hover:text-primary-accent transition-colors"
      >
        {{ t('app.name') }}
      </NuxtLink>
      <UColorModeButton class="rounded-full" />
    </div>
    <div class="relative z-10 flex-1 flex items-center justify-center px-4 py-10">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.guest-shell {
  background:
    radial-gradient(1200px 520px at 50% -10%, color-mix(in srgb, var(--color-primary) 16%, white), transparent 70%),
    radial-gradient(900px 420px at 100% 8%, color-mix(in srgb, var(--color-primary) 10%, #fff), transparent 65%),
    radial-gradient(800px 380px at 0% 12%, color-mix(in srgb, var(--color-primary) 8%, #f8f5ff), transparent 60%),
    #F4F6FB;
}

.dark .guest-shell {
  background:
    radial-gradient(1200px 520px at 50% -10%, color-mix(in srgb, var(--color-primary) 18%, transparent), transparent 70%),
    radial-gradient(900px 420px at 100% 8%, color-mix(in srgb, var(--color-primary) 12%, transparent), transparent 65%),
    radial-gradient(800px 380px at 0% 12%, color-mix(in srgb, var(--color-primary) 10%, transparent), transparent 60%),
    var(--color-canvas);
}

.guest-shell__tooth {
  position: absolute;
  width: min(42vw, 420px);
  height: auto;
  top: -4%;
  right: -4%;
  color: var(--color-primary);
  opacity: 0.07;
  z-index: 0;
}

.dark .guest-shell__tooth {
  opacity: 0.12;
}
</style>
