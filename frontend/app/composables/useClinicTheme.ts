/**
 * Dynamic Clinic Theme Engine.
 *
 * Reads the clinic's superadmin-configured `theme_color` (from auth/clinic state)
 * and dynamically injects full 50-950 color tokens + primary CSS custom variables
 * to `:root` so the entire client UI/dashboard/buttons/badges adapt automatically.
 */

// Helper to convert hex to HSL
function hexToHsl(hex: string): { h: number, s: number, l: number } {
  let cleanHex = hex.replace('#', '')
  if (cleanHex.length === 3) {
    cleanHex = cleanHex.split('').map(c => c + c).join('')
  }
  const r = parseInt(cleanHex.substring(0, 2), 16) / 255
  const g = parseInt(cleanHex.substring(2, 4), 16) / 255
  const b = parseInt(cleanHex.substring(4, 6), 16) / 255

  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  let h = 0
  let s = 0
  const l = (max + min) / 2

  if (max !== min) {
    const d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
    switch (max) {
      case r: h = (g - b) / d + (g < b ? 6 : 0); break
      case g: h = (b - r) / d + 2; break
      case b: h = (r - g) / d + 4; break
    }
    h /= 6
  }

  return {
    h: Math.round(h * 360),
    s: Math.round(s * 100),
    l: Math.round(l * 100)
  }
}

function hslToHex(h: number, s: number, l: number): string {
  const sDec = s / 100
  const lDec = l / 100

  const c = (1 - Math.abs(2 * lDec - 1)) * sDec
  const x = c * (1 - Math.abs((h / 60) % 2 - 1))
  const m = lDec - c / 2
  let r = 0, g = 0, b = 0

  if (h >= 0 && h < 60) { r = c; g = x; b = 0 }
  else if (h >= 60 && h < 120) { r = x; g = c; b = 0 }
  else if (h >= 120 && h < 180) { r = 0; g = c; b = x }
  else if (h >= 180 && h < 240) { r = 0; g = x; b = c }
  else if (h >= 240 && h < 300) { r = x; g = 0; b = c }
  else if (h >= 300 && h < 360) { r = c; g = 0; b = x }

  const toHex = (n: number) => {
    const val = Math.round((n + m) * 255).toString(16)
    return val.length === 1 ? '0' + val : val
  }

  return `#${toHex(r)}${toHex(g)}${toHex(b)}`
}

export function useClinicTheme() {
  const auth = useAuth()
  const clinicState = useClinic()

  const activeClinicColor = computed(() => {
    const currentFromClinic = clinicState.currentClinic.value?.settings?.theme_color || clinicState.currentClinic.value?.theme_color
    if (currentFromClinic) return currentFromClinic

    const activeAuthClinic = auth.clinics.value?.[0]
    return activeAuthClinic?.theme_color || null
  })

  function applyTheme(hexColor: string | null | undefined) {
    if (!import.meta.client) return

    const root = document.documentElement
    if (!hexColor || !/^#([0-9A-F]{3}){1,2}$/i.test(hexColor)) {
      // Clear overrides to use default tokens
      const properties = [
        '--color-primary',
        '--color-primary-hover',
        '--color-primary-soft',
        '--color-primary-soft-text',
        '--color-primary-50',
        '--color-primary-100',
        '--color-primary-200',
        '--color-primary-300',
        '--color-primary-400',
        '--color-primary-500',
        '--color-primary-600',
        '--color-primary-700',
        '--color-primary-800',
        '--color-primary-900',
        '--color-primary-950'
      ]
      properties.forEach(prop => root.style.removeProperty(prop))
      return
    }

    const { h, s, l } = hexToHsl(hexColor)

    // Generate palette levels
    const c50 = hslToHex(h, Math.min(s, 60), 96)
    const c100 = hslToHex(h, Math.min(s, 70), 92)
    const c200 = hslToHex(h, Math.min(s, 75), 84)
    const c300 = hslToHex(h, Math.min(s, 80), 72)
    const c400 = hslToHex(h, Math.min(s, 85), 60)
    const c500 = hexColor
    const c600 = hslToHex(h, s, Math.max(l - 8, 25))
    const c700 = hslToHex(h, Math.min(s, 90), Math.max(l - 16, 20))
    const c800 = hslToHex(h, Math.min(s, 90), Math.max(l - 24, 15))
    const c900 = hslToHex(h, Math.min(s, 95), Math.max(l - 30, 10))
    const c950 = hslToHex(h, Math.min(s, 95), 6)

    root.style.setProperty('--color-primary', hexColor)
    root.style.setProperty('--color-primary-hover', c600)
    root.style.setProperty('--color-primary-soft', c50)
    root.style.setProperty('--color-primary-soft-text', c800)

    root.style.setProperty('--color-primary-50', c50)
    root.style.setProperty('--color-primary-100', c100)
    root.style.setProperty('--color-primary-200', c200)
    root.style.setProperty('--color-primary-300', c300)
    root.style.setProperty('--color-primary-400', c400)
    root.style.setProperty('--color-primary-500', c500)
    root.style.setProperty('--color-primary-600', c600)
    root.style.setProperty('--color-primary-700', c700)
    root.style.setProperty('--color-primary-800', c800)
    root.style.setProperty('--color-primary-900', c900)
    root.style.setProperty('--color-primary-950', c950)
  }

  // Watch for changes in active clinic color and apply
  if (import.meta.client) {
    watch(activeClinicColor, (newColor) => {
      applyTheme(newColor)
    }, { immediate: true })
  }

  return {
    activeClinicColor,
    applyTheme
  }
}
