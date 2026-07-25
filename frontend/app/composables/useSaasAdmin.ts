/**
 * Superadmin dashboard data layer: leads, clinic directory, subscriptions,
 * and pricing plans. Mirrors the `useUsers.ts` pattern (state + toasts +
 * i18n error copy) so the `/admin` page stays a thin consumer.
 */

export interface SaasLead {
  id: string
  contact_name: string
  clinic_name: string
  phone: string | null
  email: string
  expected_users: number | null
  message: string | null
  status: 'pending' | 'contacted' | 'processed' | 'rejected'
  created_at: string
  updated_at: string
}

export interface SaasPricingPlan {
  id: string
  name: string
  duration_months: number
  price: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface SaasSubscription {
  id: string
  clinic_id: string
  plan_id?: string
  plan?: SaasPricingPlan
  start_date: string
  end_date: string
  status: string
  effective_status: 'upcoming' | 'active' | 'expired'
  created_at: string
  updated_at: string
}

export interface SaasClinicDirectoryEntry {
  id: string
  name: string
  tax_id: string
  created_at: string
  subscription_active: boolean
  subscription_end_date: string | null
  subscription_count: number
}

export interface TenantProvisionPayload {
  clinic_name: string
  tax_id: string
  admin_email: string
  admin_password: string
  admin_first_name: string
  admin_last_name: string
  currency: string
  timezone: string
}

function errorDescription(e: unknown, fallback: string): string {
  const fetchError = e as { data?: { message?: string, detail?: string } }
  return fetchError.data?.message || fetchError.data?.detail || fallback
}

export function useSaasAdmin() {
  const api = useApi()
  const toast = useToast()
  const { t } = useI18n()

  const leads = ref<SaasLead[]>([])
  const clinics = ref<SaasClinicDirectoryEntry[]>([])
  const plans = ref<SaasPricingPlan[]>([])
  const isLoading = ref(false)

  async function fetchAll(): Promise<void> {
    isLoading.value = true
    try {
      const [leadsRes, clinicsRes, plansRes] = await Promise.all([
        api.get<SaasLead[]>('/api/v1/saas/leads'),
        api.get<SaasClinicDirectoryEntry[]>('/api/v1/saas/clinics'),
        api.get<SaasPricingPlan[]>('/api/v1/saas/plans?include_inactive=true')
      ])
      leads.value = leadsRes
      clinics.value = clinicsRes
      plans.value = plansRes
    } catch (e) {
      toast.add({
        title: t('common.error'),
        description: errorDescription(e, t('saasAdmin.errors.loadDashboard')),
        color: 'error'
      })
      console.error('Failed to load SaaS admin dashboard:', e)
    } finally {
      isLoading.value = false
    }
  }

  async function updateLeadStatus(leadId: string, status: SaasLead['status']): Promise<boolean> {
    const previous = leads.value
    leads.value = leads.value.map(l => l.id === leadId ? { ...l, status } : l)
    try {
      await api.patch<SaasLead>(`/api/v1/saas/leads/${leadId}`, { status })
      return true
    } catch (e) {
      leads.value = previous
      toast.add({
        title: t('common.error'),
        description: errorDescription(e, t('saasAdmin.errors.updateLead')),
        color: 'error'
      })
      console.error('Failed to update lead status:', e)
      return false
    }
  }

  async function provisionTenant(payload: TenantProvisionPayload): Promise<boolean> {
    try {
      await api.post('/api/v1/saas/clinics/provision', payload)
      toast.add({
        title: t('common.success'),
        description: t('saasAdmin.messages.tenantProvisioned', { clinic: payload.clinic_name }),
        color: 'success'
      })
      await fetchAll()
      return true
    } catch (e: unknown) {
      const fetchError = e as { statusCode?: number }
      const fallback = fetchError.statusCode === 400
        ? t('saasAdmin.errors.emailExists')
        : fetchError.statusCode === 409
          ? t('saasAdmin.errors.tenantConflict')
          : t('saasAdmin.errors.provisionTenant')
      toast.add({
        title: t('common.error'),
        description: errorDescription(e, fallback),
        color: 'error'
      })
      console.error('Failed to provision tenant:', e)
      return false
    }
  }

  async function fetchClinicSubscriptions(clinicId: string): Promise<SaasSubscription[]> {
    try {
      return await api.get<SaasSubscription[]>(
        `/api/v1/saas/subscriptions?filter_clinic_id=${clinicId}`
      )
    } catch (e) {
      toast.add({
        title: t('common.error'),
        description: errorDescription(e, t('saasAdmin.errors.loadHistory')),
        color: 'error'
      })
      console.error('Failed to load subscription history:', e)
      return []
    }
  }

  async function grantSubscription(clinicId: string, durationMonths: number, planId?: string): Promise<SaasSubscription | null> {
    try {
      const sub = await api.post<SaasSubscription>('/api/v1/saas/subscriptions', {
        clinic_id: clinicId,
        duration_months: durationMonths,
        plan_id: planId && planId !== 'custom' ? planId : undefined
      })
      toast.add({
        title: t('common.success'),
        description: t('saasAdmin.messages.subscriptionGranted'),
        color: 'success'
      })
      await fetchAll()
      return sub
    } catch (e: unknown) {
      const fetchError = e as { statusCode?: number }
      const fallback = fetchError.statusCode === 404
        ? t('saasAdmin.errors.clinicNotFound')
        : t('saasAdmin.errors.grantSubscription')
      toast.add({
        title: t('common.error'),
        description: errorDescription(e, fallback),
        color: 'error'
      })
      console.error('Failed to grant subscription:', e)
      return null
    }
  }

  async function createPlan(data: { name: string, duration_months: number, price: number, is_active: boolean }): Promise<boolean> {
    try {
      await api.post('/api/v1/saas/plans', data)
      toast.add({
        title: t('common.success'),
        description: t('saasAdmin.messages.planCreated'),
        color: 'success'
      })
      await fetchAll()
      return true
    } catch (e) {
      toast.add({
        title: t('common.error'),
        description: errorDescription(e, t('saasAdmin.errors.createPlan')),
        color: 'error'
      })
      console.error('Failed to create pricing plan:', e)
      return false
    }
  }

  async function togglePlanActive(plan: SaasPricingPlan): Promise<boolean> {
    const previous = plans.value
    plans.value = plans.value.map(p => p.id === plan.id ? { ...p, is_active: !p.is_active } : p)
    try {
      await api.patch(`/api/v1/saas/plans/${plan.id}`, { is_active: !plan.is_active })
      return true
    } catch (e) {
      plans.value = previous
      toast.add({
        title: t('common.error'),
        description: errorDescription(e, t('saasAdmin.errors.updatePlan')),
        color: 'error'
      })
      console.error('Failed to toggle pricing plan:', e)
      return false
    }
  }

  return {
    leads: readonly(leads),
    clinics: readonly(clinics),
    plans: readonly(plans),
    isLoading: readonly(isLoading),
    fetchAll,
    updateLeadStatus,
    provisionTenant,
    fetchClinicSubscriptions,
    grantSubscription,
    createPlan,
    togglePlanActive
  }
}
