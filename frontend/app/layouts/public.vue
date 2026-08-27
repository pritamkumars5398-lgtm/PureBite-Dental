<script setup lang="ts">
/**
 * Patient-facing layout — no app sidebar, no sticky chrome.
 * Used by ``/p/budget/<token>`` (ADR 0006). Mobile-first.
 */
const clinic = useClinic()
const theme = useClinicTheme()
</script>

<template>
  <div class="min-h-screen bg-[var(--ui-bg)] flex flex-col">
    <header class="border-b border-[var(--ui-border)] bg-[var(--ui-bg-elevated)]">
      <div class="max-w-3xl mx-auto px-4 py-3 flex items-center gap-2">
        <img
          :src="theme.clinicLogo.value || '/logo-icon.svg'"
          alt=""
          width="24"
          height="24"
          class="shrink-0 w-6 h-6 object-contain rounded-sm"
        >
        <span class="font-semibold tracking-tight font-serif">{{ clinic.clinicName || 'PureBite Dental Studio' }}</span>
      </div>
    </header>
    <main class="flex-1">
      <slot />
    </main>
    <footer class="border-t border-[var(--ui-border)] py-4 text-center text-xs text-[var(--ui-text-muted)]">
      <span>{{ clinic.clinicName || 'PureBite Dental Studio' }} · {{ new Date().getFullYear() }}</span>
    </footer>
  </div>
</template>
