<script setup lang="ts">
const {
  platform,
  isNative,
  canUseHaptics,
  count,
  loading,
  saving,
  hapticPending,
  message,
  error,
  increment,
  reset,
  testHaptics,
} = useNativeTools()

const platformLabels: Record<string, string> = { web: 'مرورگر وب', android: 'اندروید', ios: 'iOS' }
const platformLabel = platformLabels[platform] ?? platform
</script>

<template>
  <main class="shell">
    <header class="topbar">
      <a class="brand" href="/" aria-label="صفحهٔ اصلی">
        <svg class="brand-icon" viewBox="0 0 40 40" fill="none" aria-hidden="true">
          <path d="m5 29 11-19 11 19H5Z" stroke="currentColor" stroke-width="3" stroke-linejoin="round" />
          <path d="m22 29 6-11 7 11H22Z" fill="currentColor" />
        </svg>
        <span dir="ltr">Nuxt + Capacitor</span>
      </a>
      <span class="status"><span class="status-dot" />{{ platformLabel }}</span>
    </header>

    <section class="intro" aria-labelledby="page-title">
      <p class="eyebrow" dir="ltr">WEB · ANDROID · iOS</p>
      <h1 id="page-title">یک پروژه،<br><span>چند تجربه.</span></h1>
      <p class="lead">پایهٔ اپلیکیشن شما با Nuxt 3 و Capacitor آماده است. از همین‌جا شروع کنید و قابلیت‌های دستگاه را به برنامه اضافه کنید.</p>
      <div class="tags">
        <span>Nuxt 3</span>
        <span>Capacitor 8</span>
        <span>TypeScript</span>
      </div>
    </section>

    <section class="tools" aria-label="آزمایش قابلیت‌ها">
      <article class="card storage-card">
        <div class="card-heading">
          <span class="card-number" aria-hidden="true">01</span>
          <span class="chip">Preferences</span>
        </div>
        <h2>حافظهٔ دستگاه</h2>
        <p>شمارنده را تغییر دهید و صفحه را دوباره باز کنید؛ مقدار روی دستگاه شما باقی می‌ماند.</p>
        <output class="counter" aria-label="مقدار شمارنده" aria-live="polite">{{ loading ? '…' : count.toLocaleString('fa-IR') }}</output>
        <div class="actions">
          <button class="button primary" :disabled="loading || saving" @click="increment">{{ saving ? 'در حال ذخیره…' : 'یکی اضافه کن' }}<span aria-hidden="true">＋</span></button>
          <button class="button secondary" :disabled="loading || saving || count === 0" @click="reset">شروع دوباره</button>
        </div>
      </article>

      <article class="card haptics-card">
        <div class="card-heading">
          <span class="card-number" aria-hidden="true">02</span>
          <span class="chip">Haptics</span>
        </div>
        <h2>بازخورد لمسی</h2>
        <p>ارتباط با امکانات بومی دستگاه را با یک بازخورد لمسی کوتاه امتحان کنید.</p>
        <div class="device-illustration" aria-hidden="true">
          <span class="wave wave-right">))</span>
          <svg viewBox="0 0 52 76" fill="none"><rect x="7" y="3" width="38" height="70" rx="9" stroke="currentColor" stroke-width="2" /><path d="M20 10h12M22 65h8" stroke="currentColor" stroke-width="2" stroke-linecap="round" /><path d="m29 25-9 15h8l-5 12 12-17h-9l3-10Z" fill="currentColor" /></svg>
          <span class="wave wave-left">((</span>
        </div>
        <button class="button secondary full-width" :disabled="!canUseHaptics || hapticPending" @click="testHaptics">{{ hapticPending ? 'در حال اجرا…' : 'تست بازخورد لمسی' }}</button>
        <small>{{ isNative ? 'روی دستگاه دارای سخت‌افزار پشتیبانی‌شده اجرا می‌شود.' : 'برای این آزمایش، برنامه را روی اندروید یا iOS اجرا کنید.' }}</small>
      </article>
    </section>

    <div class="feedback" aria-live="polite" role="status">
      <p v-if="error" class="error">{{ error }}</p>
      <p v-else-if="message">{{ message }}</p>
    </div>

    <footer class="footer">
      <span>آماده برای قدم بعدی شما</span>
      <span dir="ltr">Built with Nuxt &amp; Capacitor <span class="footer-dot">●</span></span>
    </footer>
  </main>
</template>
