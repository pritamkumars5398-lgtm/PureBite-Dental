import { PERMISSIONS } from '~/config/permissions'

export default defineNuxtRouteMiddleware(async (to) => {
  const auth = useAuth()

  // Public routes that don't require authentication.
  // ``/p/budget/<token>`` is the patient-facing budget view (ADR 0006).
  // Server-side authorization happens via the public-link 2FA cookie
  // scoped to the token; the global auth middleware must let the page
  // render so the SPA can run the /meta + /verify dance.
  const publicRoutes = ['/login', '/p/budget', '/landing', '/locked']
  const isPublicRoute = publicRoutes.some(route => to.path === route || to.path.startsWith(route + '/'))

  // Initialize auth state (fetch user if token exists) - works on both server and client
  await auth.init()

  if (!auth.isAuthenticated.value && !isPublicRoute) {
    // If they hit the root URL without auth, send them to the public landing page.
    // Otherwise (e.g. they tried to access a specific protected route), send them to landing.
    if (to.path === '/login') {
      return
    }
    return navigateTo('/landing')
  }

  if (auth.isAuthenticated.value) {
    if (to.path === '/login') {
      return navigateTo('/')
    }

    const isSuperadmin = auth.permissions.value.includes(PERMISSIONS.saas.leadsRead)
    const isAdminRoute = to.path === '/admin' || to.path.startsWith('/admin/')

    // Superadmins can only access /admin, /settings, and public routes
    if (isSuperadmin) {
      if (!isAdminRoute && to.path !== '/settings' && !isPublicRoute) {
        return navigateTo('/admin')
      }
    } else {
      // Normal clinic users cannot access /admin
      if (isAdminRoute) {
        return navigateTo('/')
      }
      
      // Prevent dashboard flicker if subscription is expired/not activated
      const clinic = auth.clinics.value?.[0]
      const subscriptionActive = clinic?.subscription_active ?? true
      if (!subscriptionActive && !isPublicRoute) {
        return navigateTo('/locked')
      }
    }
  }
})
