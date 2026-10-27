import { Capacitor } from '@capacitor/core'
import { Haptics, ImpactStyle } from '@capacitor/haptics'
import { Preferences } from '@capacitor/preferences'

const counterKey = 'nuxt-capacitor.counter'

export function useNativeTools() {
  const platform = Capacitor.getPlatform()
  const isNative = Capacitor.isNativePlatform()
  const canUseHaptics = isNative && Capacitor.isPluginAvailable('Haptics')
  const count = ref(0)
  const loading = ref(true)
  const saving = ref(false)
  const hapticPending = ref(false)
  const message = ref('')
  const error = ref('')

  onMounted(async () => {
    try {
      const { value } = await Preferences.get({ key: counterKey })
      const saved = value === null ? 0 : Number(value)
      count.value = Number.isSafeInteger(saved) && saved >= 0 ? saved : 0
    }
    catch {
      error.value = 'خواندن مقدار ذخیره‌شده ممکن نشد. دسترسی به حافظه را بررسی کنید.'
    }
    finally {
      loading.value = false
    }
  })

  async function saveCount(value: number) {
    if (loading.value || saving.value) return

    saving.value = true
    message.value = ''
    error.value = ''

    try {
      await Preferences.set({ key: counterKey, value: String(value) })
      count.value = value
      message.value = 'مقدار روی همین دستگاه ذخیره شد.'
    }
    catch {
      error.value = 'ذخیره انجام نشد. دوباره تلاش کنید.'
    }
    finally {
      saving.value = false
    }
  }

  async function testHaptics() {
    if (!canUseHaptics || hapticPending.value) return

    hapticPending.value = true
    message.value = ''
    error.value = ''

    try {
      await Haptics.impact({ style: ImpactStyle.Medium })
      message.value = 'درخواست بازخورد لمسی ارسال شد؛ اجرا به سخت‌افزار دستگاه بستگی دارد.'
    }
    catch {
      error.value = 'بازخورد لمسی در این دستگاه در دسترس نیست.'
    }
    finally {
      hapticPending.value = false
    }
  }

  return {
    platform,
    isNative,
    canUseHaptics,
    count,
    loading,
    saving,
    hapticPending,
    message,
    error,
    increment: () => saveCount(count.value + 1),
    reset: () => saveCount(0),
    testHaptics,
  }
}
