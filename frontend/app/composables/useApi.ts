import type { ApiResponse, PaginatedResponse } from '~/types'

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'

interface UseApiOptions {
  method?: HttpMethod
  body?: object | null
  headers?: Record<string, string>
  skipAuth?: boolean
  signal?: AbortSignal
  timeout?: number
}

export function useApi() {
  const config = useRuntimeConfig()
  const auth = useAuth()
  const { t } = useI18n()
  const toast = useToast()


  const apiBaseUrl = computed(() =>
    import.meta.server ? config.apiBaseUrlServer : config.public.apiBaseUrl
  )

  async function $api<T>(
    path: string,
    options: UseApiOptions = {}
  ): Promise<T> {
    const { skipAuth, method, body, headers: optionHeaders, signal } = options

    const headers: Record<string, string> = {
      ...(optionHeaders || {})
    }

    // Add auth header if authenticated and not skipping auth
    if (!skipAuth && auth.accessToken.value) {
      headers.Authorization = `Bearer ${auth.accessToken.value}`
    }

    try {
      return await $fetch<T>(path, {
        baseURL: apiBaseUrl.value,
        timeout: options.timeout ?? 60000,
        method,
        body,
        headers,
        signal
      })
    } catch (error: unknown) {
      const fetchError = error as { name?: string, statusCode?: number, data?: { message?: string } }

      if (fetchError.name === 'AbortError' || signal?.aborted) {
        throw error
      }

      if (fetchError.statusCode === 401) {
        const refreshed = await auth.refresh()
        if (refreshed) {
          headers.Authorization = `Bearer ${auth.accessToken.value}`
          return await $fetch<T>(path, {
            baseURL: apiBaseUrl.value,
            timeout: options.timeout ?? 60000,
            method,
            body,
            headers,
            signal
          })
        }
        await auth.logout()
        throw error
      }

      if (fetchError.statusCode === 403) {
        toast.add({
          title: t('common.error'),
          description: t('common.forbidden', 'Acceso denegado'),
          color: 'error'
        })
        throw error
      }

      if (fetchError.statusCode === 404) {
        throw error
      }

      if (fetchError.statusCode === 409) {
        throw error
      }

      if (fetchError.statusCode === 422) {
        throw error
      }

      if (fetchError.statusCode && fetchError.statusCode >= 500) {
        toast.add({
          title: t('common.error'),
          description: t('common.serverError'),
          color: 'error'
        })
        throw error
      }

      if (!fetchError.statusCode) {
        toast.add({
          title: t('common.error'),
          description: t('common.networkError'),
          color: 'error'
        })
      }

      throw error
    }
  }

  async function get<T>(path: string, options: Omit<UseApiOptions, 'method' | 'body'> = {}): Promise<T> {
    return $api<T>(path, { ...options, method: 'GET' })
  }

  async function post<T>(path: string, body?: object | null, options: Omit<UseApiOptions, 'method' | 'body'> = {}): Promise<T> {
    return $api<T>(path, { ...options, method: 'POST', body })
  }

  async function put<T>(path: string, body?: object | null, options: Omit<UseApiOptions, 'method' | 'body'> = {}): Promise<T> {
    return $api<T>(path, { ...options, method: 'PUT', body })
  }

  async function patch<T>(path: string, body?: object | null, options: Omit<UseApiOptions, 'method' | 'body'> = {}): Promise<T> {
    return $api<T>(path, { ...options, method: 'PATCH', body })
  }

  async function del<T>(path: string, options: Omit<UseApiOptions, 'method' | 'body'> = {}): Promise<T> {
    return $api<T>(path, { ...options, method: 'DELETE' })
  }

  return {
    $api,
    get,
    post,
    put,
    patch,
    del
  }
}
export type { ApiResponse, PaginatedResponse }
