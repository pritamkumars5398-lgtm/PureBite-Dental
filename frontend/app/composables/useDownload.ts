/**
 * Composable to handle authenticated file downloads with real-time percentage / progress tracking and toast notifications.
 */
export function useDownload() {
  const config = useRuntimeConfig()
  const auth = useAuth()
  const toast = useToast()
  const { t } = useI18n()

  const isDownloading = ref(false)
  const downloadProgress = ref(0)

  async function downloadFile(
    urlPath: string,
    fallbackFilename: string = 'document.pdf',
    options?: {
      title?: string
      showToast?: boolean
      onProgress?: (progress: number) => void
    }
  ): Promise<boolean> {
    const showToast = options?.showToast ?? true
    const title = options?.title || t('common.downloading') || 'Downloading document'

    isDownloading.value = true
    downloadProgress.value = 10
    options?.onProgress?.(10)

    const toastId = `download-${Date.now()}`

    if (showToast) {
      toast.add({
        id: toastId,
        title,
        description: `Generating document... 10%`,
        color: 'primary',
        icon: 'i-lucide-loader-2'
      })
    }

    let progressTimer: ReturnType<typeof setInterval> | null = null

    try {
      const fullUrl = urlPath.startsWith('http') ? urlPath : `${config.public.apiBaseUrl}${urlPath}`
      const token = auth.accessToken.value

      const xhr = new XMLHttpRequest()
      xhr.open('GET', fullUrl, true)
      xhr.responseType = 'blob'
      if (token) {
        xhr.setRequestHeader('Authorization', `Bearer ${token}`)
      }

      // Smooth progression increment while waiting for server generation
      progressTimer = setInterval(() => {
        if (downloadProgress.value < 85) {
          const next = Math.min(85, downloadProgress.value + Math.floor(Math.random() * 15) + 5)
          downloadProgress.value = next
          options?.onProgress?.(next)
          if (showToast) {
            toast.add({
              id: toastId,
              title,
              description: `Downloading... ${next}%`,
              color: 'primary',
              icon: 'i-lucide-loader-2'
            })
          }
        }
      }, 300)

      const result = await new Promise<Blob>((resolve, reject) => {
        xhr.onprogress = (event) => {
          if (event.lengthComputable && event.total > 0) {
            const percent = Math.round((event.loaded / event.total) * 100)
            const clamped = Math.max(downloadProgress.value, Math.min(99, percent))
            downloadProgress.value = clamped
            options?.onProgress?.(clamped)
            if (showToast) {
              toast.add({
                id: toastId,
                title,
                description: `Downloading... ${clamped}%`,
                color: 'primary',
                icon: 'i-lucide-loader-2'
              })
            }
          }
        }

        xhr.onload = () => {
          if (progressTimer) clearInterval(progressTimer)
          if (xhr.status >= 200 && xhr.status < 300) {
            downloadProgress.value = 100
            options?.onProgress?.(100)
            resolve(xhr.response as Blob)
          } else {
            reject(new Error(`Download failed with status ${xhr.status}`))
          }
        }

        xhr.onerror = () => {
          if (progressTimer) clearInterval(progressTimer)
          reject(new Error('Network error during download'))
        }

        xhr.ontimeout = () => {
          if (progressTimer) clearInterval(progressTimer)
          reject(new Error('Download timed out'))
        }

        xhr.send()
      })

      // Extract filename from response header
      let filename = fallbackFilename
      const disposition = xhr.getResponseHeader('Content-Disposition')
      if (disposition) {
        const match = disposition.match(/filename="?([^";]+)"?/)
        if (match && match[1]) {
          filename = match[1].trim()
        }
      }

      // Trigger browser download
      const blobUrl = window.URL.createObjectURL(result)
      const a = document.createElement('a')
      a.href = blobUrl
      a.download = filename
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      window.URL.revokeObjectURL(blobUrl)

      if (showToast) {
        toast.add({
          id: toastId,
          title: t('common.downloadComplete') || 'Download complete',
          description: `${filename} (100%)`,
          color: 'success',
          icon: 'i-lucide-check-circle'
        })
      }

      return true
    } catch (err) {
      if (progressTimer) clearInterval(progressTimer)
      console.error('Download error:', err)
      if (showToast) {
        toast.add({
          id: toastId,
          title: t('common.error') || 'Error',
          description: t('invoice.pdf.downloadError') || 'Error downloading file',
          color: 'error',
          icon: 'i-lucide-alert-circle'
        })
      }
      throw err
    } finally {
      isDownloading.value = false
      setTimeout(() => {
        downloadProgress.value = 0
      }, 1500)
    }
  }

  return {
    isDownloading,
    downloadProgress,
    downloadFile
  }
}
