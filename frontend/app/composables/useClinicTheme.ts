export interface ThemePreset {
  id: string
  nameKey: string
  primaryColor: string
  descriptionKey: string
  previewBadge: string
}

export const THEME_PRESETS: ThemePreset[] = [
  {
    id: 'ocean_blue',
    nameKey: 'settings.branding.presets.oceanBlue',
    primaryColor: '#0284C7',
    descriptionKey: 'settings.branding.presets.oceanBlueDesc',
    previewBadge: 'bg-sky-500'
  },
  {
    id: 'emerald',
    nameKey: 'settings.branding.presets.emerald',
    primaryColor: '#059669',
    descriptionKey: 'settings.branding.presets.emeraldDesc',
    previewBadge: 'bg-emerald-600'
  },
  {
    id: 'gold',
    nameKey: 'settings.branding.presets.gold',
    primaryColor: '#B39D82',
    descriptionKey: 'settings.branding.presets.goldDesc',
    previewBadge: 'bg-[#B39D82]'
  },
  {
    id: 'indigo',
    nameKey: 'settings.branding.presets.indigo',
    primaryColor: '#4F46E5',
    descriptionKey: 'settings.branding.presets.indigoDesc',
    previewBadge: 'bg-indigo-600'
  },
  {
    id: 'violet',
    nameKey: 'settings.branding.presets.violet',
    primaryColor: '#7C3AED',
    descriptionKey: 'settings.branding.presets.violetDesc',
    previewBadge: 'bg-violet-600'
  },
  {
    id: 'amber',
    nameKey: 'settings.branding.presets.amber',
    primaryColor: '#D97706',
    descriptionKey: 'settings.branding.presets.amberDesc',
    previewBadge: 'bg-amber-600'
  },
  {
    id: 'rose',
    nameKey: 'settings.branding.presets.rose',
    primaryColor: '#E11D48',
    descriptionKey: 'settings.branding.presets.roseDesc',
    previewBadge: 'bg-rose-600'
  },
  {
    id: 'teal',
    nameKey: 'settings.branding.presets.teal',
    primaryColor: '#0D9488',
    descriptionKey: 'settings.branding.presets.tealDesc',
    previewBadge: 'bg-teal-600'
  }
]

// --- Color math utilities ---

function hexToRgb(hex: string): [number, number, number] {
  let c = hex.replace('#', '').trim()
  if (c.length === 3) {
    c = c.split('').map(x => x + x).join('')
  }
  const num = parseInt(c, 16)
  if (isNaN(num) || c.length !== 6) {
    return [2, 132, 199] // fallback #0284c7
  }
  return [(num >> 16) & 255, (num >> 8) & 255, num & 255]
}

function rgbToHex(r: number, g: number, b: number): string {
  const toHex = (n: number) => Math.max(0, Math.min(255, Math.round(n))).toString(16).padStart(2, '0')
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase()
}

function rgbToHsl(r: number, g: number, b: number): [number, number, number] {
  r /= 255
  g /= 255
  b /= 255
  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  let h = 0
  let s = 0
  const l = (max + min) / 2

  if (max !== min) {
    const d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
    switch (max) {
      case r:
        h = (g - b) / d + (g < b ? 6 : 0)
        break
      case g:
        h = (b - r) / d + 2
        break
      case b:
        h = (r - g) / d + 4
        break
    }
    h /= 6
  }

  return [h * 360, s, l]
}

function hslToRgb(h: number, s: number, l: number): [number, number, number] {
  h = ((h % 360) + 360) % 360 / 360
  let r: number, g: number, b: number

  if (s === 0) {
    r = g = b = l
  } else {
    const hue2rgb = (p: number, q: number, t: number) => {
      if (t < 0) t += 1
      if (t > 1) t -= 1
      if (t < 1 / 6) return p + (q - p) * 6 * t
      if (t < 1 / 2) return q
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6
      return p
    }
    const q = l < 0.5 ? l * (1 + s) : l + s - l * s
    const p = 2 * l - q
    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  }

  return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)]
}

export function generatePalette(baseHex: string): Record<string, string> {
  const [r, g, b] = hexToRgb(baseHex)
  const [h, s] = rgbToHsl(r, g, b)

  // Target lightness steps for 50-950
  const lightnessMap: Record<string, number> = {
    50: 0.96,
    100: 0.91,
    200: 0.82,
    300: 0.70,
    400: 0.58,
    500: 0.48,
    600: 0.40,
    700: 0.32,
    800: 0.24,
    900: 0.17,
    950: 0.10
  }

  const palette: Record<string, string> = {}

  for (const [step, targetL] of Object.entries(lightnessMap)) {
    let stepS = s
    if (step === '50' || step === '100') {
      stepS = Math.min(s, 0.75)
    } else if (step === '900' || step === '950') {
      stepS = Math.min(s, 0.85)
    }
    const [pr, pg, pb] = hslToRgb(h, stepS, targetL)
    palette[step] = rgbToHex(pr, pg, pb)
  }

  palette['500'] = baseHex.toUpperCase()

  return palette
}

export function useClinicTheme() {
  const clinic = useClinic()
  const api = useApi()
  const toast = useToast()
  const { t } = useI18n()

  // Extract from current clinic state
  const clinicSettings = computed(() => clinic.currentClinic.value?.settings || {})
  const clinicBranding = computed(() => {
    const raw = clinicSettings.value
    const sub = (typeof raw.branding === 'object' && raw.branding !== null) ? raw.branding as Record<string, unknown> : {}
    return {
      logo_url: (sub.logo_url as string) || (raw.logo_url as string) || null,
      primary_color: (sub.primary_color as string) || (raw.primary_color as string) || '#0284C7',
      theme_preset: (sub.theme_preset as string) || (raw.theme_preset as string) || 'ocean_blue',
      dark_mode_preference: (sub.dark_mode_preference as string) || (raw.dark_mode_preference as string) || 'system'
    }
  })

  const clinicLogo = computed(() => clinicBranding.value.logo_url)
  const currentPrimaryColor = computed(() => clinicBranding.value.primary_color || '#0284C7')
  const currentPreset = computed(() => clinicBranding.value.theme_preset || 'ocean_blue')

  // Preview state (ephemeral, used during live editing in settings)
  const previewColor = ref<string | null>(null)
  const activeColor = computed(() => previewColor.value || currentPrimaryColor.value)

  /**
   * Inject CSS variables directly into document head/root
   */
  function applyThemeVariables(colorHex: string) {
    if (!import.meta.client) return

    const palette = generatePalette(colorHex)
    const root = document.documentElement

    // Set Nuxt UI / Tailwind Primary CSS variables
    for (const [step, val] of Object.entries(palette)) {
      root.style.setProperty(`--color-primary-${step}`, val)
      root.style.setProperty(`--ui-color-primary-${step}`, val)
      root.style.setProperty(`--ui-primary-${step}`, val)
    }

    // Set Design System Primary Tokens
    root.style.setProperty('--color-primary', palette['500'] || colorHex)
    root.style.setProperty('--color-primary-hover', palette['600'] || colorHex)
    root.style.setProperty('--color-primary-soft', palette['50'] || '#F0F9FF')
    root.style.setProperty('--color-primary-soft-text', palette['800'] || '#075985')
    root.style.setProperty('--ui-primary', palette['500'] || colorHex)

    // Add a custom style tag to guarantee full CSS property cascade
    let customStyleTag = document.getElementById('clinic-custom-theme-style')
    if (!customStyleTag) {
      customStyleTag = document.createElement('style')
      customStyleTag.id = 'clinic-custom-theme-style'
      document.head.appendChild(customStyleTag)
    }

    const rgb500 = hexToRgb(palette['500'] || colorHex).join(', ')

    customStyleTag.innerHTML = `
      :root {
        --color-primary: ${palette['500']};
        --color-primary-hover: ${palette['600']};
        --color-primary-soft: ${palette['50']};
        --color-primary-soft-text: ${palette['800']};
        --color-primary-50: ${palette['50']};
        --color-primary-100: ${palette['100']};
        --color-primary-200: ${palette['200']};
        --color-primary-300: ${palette['300']};
        --color-primary-400: ${palette['400']};
        --color-primary-500: ${palette['500']};
        --color-primary-600: ${palette['600']};
        --color-primary-700: ${palette['700']};
        --color-primary-800: ${palette['800']};
        --color-primary-900: ${palette['900']};
        --color-primary-950: ${palette['950']};

        --ui-primary: ${palette['500']};
        --ui-primary-50: ${palette['50']};
        --ui-primary-100: ${palette['100']};
        --ui-primary-200: ${palette['200']};
        --ui-primary-300: ${palette['300']};
        --ui-primary-400: ${palette['400']};
        --ui-primary-500: ${palette['500']};
        --ui-primary-600: ${palette['600']};
        --ui-primary-700: ${palette['700']};
        --ui-primary-800: ${palette['800']};
        --ui-primary-900: ${palette['900']};
        --ui-primary-950: ${palette['950']};

        --ui-color-primary-50: ${palette['50']};
        --ui-color-primary-100: ${palette['100']};
        --ui-color-primary-200: ${palette['200']};
        --ui-color-primary-300: ${palette['300']};
        --ui-color-primary-400: ${palette['400']};
        --ui-color-primary-500: ${palette['500']};
        --ui-color-primary-600: ${palette['600']};
        --ui-color-primary-700: ${palette['700']};
        --ui-color-primary-800: ${palette['800']};
        --ui-color-primary-900: ${palette['900']};
        --ui-color-primary-950: ${palette['950']};
      }
      .dark {
        --color-primary: ${palette['400']};
        --color-primary-hover: ${palette['300']};
        --color-primary-soft: rgba(${rgb500}, 0.18);
        --color-primary-soft-text: ${palette['100']};
        --ui-primary: ${palette['400']};
      }
    `
  }

  function previewTheme(hex: string) {
    previewColor.value = hex
    applyThemeVariables(hex)
  }

  function resetPreview() {
    previewColor.value = null
    applyThemeVariables(currentPrimaryColor.value)
  }

  /**
   * Save branding settings to backend
   */
  async function saveBranding(payload: {
    logo_url?: string | null
    primary_color?: string
    theme_preset?: string
    dark_mode_preference?: string
  }): Promise<boolean> {
    try {
      await api.patch<{ data: Record<string, unknown> }>(
        '/api/v1/auth/clinic/settings/branding',
        payload
      )

      // Update local clinic store
      const currentClinicState = useState<Record<string, unknown> | null>('clinic:current')
      if (currentClinicState.value) {
        const settings = { ...((currentClinicState.value.settings as Record<string, unknown>) || {}) }
        const branding = { ...((settings.branding as Record<string, unknown>) || {}), ...payload }
        settings.branding = branding
        if (payload.logo_url !== undefined) settings.logo_url = payload.logo_url
        if (payload.primary_color !== undefined) settings.primary_color = payload.primary_color
        if (payload.theme_preset !== undefined) settings.theme_preset = payload.theme_preset

        currentClinicState.value = {
          ...currentClinicState.value,
          settings
        }
      }

      previewColor.value = null
      if (payload.primary_color) {
        applyThemeVariables(payload.primary_color)
      }

      toast.add({
        title: t('common.success'),
        description: t('settings.branding.toast.saved'),
        color: 'success'
      })
      return true
    } catch (e) {
      console.error('Failed to save branding:', e)
      toast.add({
        title: t('common.error'),
        description: t('settings.branding.toast.saveError'),
        color: 'error'
      })
      return false
    }
  }

  // Watch for clinic branding changes to apply theme automatically
  if (import.meta.client) {
    watch(
      () => currentPrimaryColor.value,
      (newColor) => {
        if (!previewColor.value) {
          applyThemeVariables(newColor || '#0284C7')
        }
      },
      { immediate: true }
    )
  }

  return {
    THEME_PRESETS,
    clinicLogo,
    currentPrimaryColor,
    currentPreset,
    activeColor,
    previewColor,
    generatePalette,
    applyThemeVariables,
    previewTheme,
    resetPreview,
    saveBranding
  }
}
