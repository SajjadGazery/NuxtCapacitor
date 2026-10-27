export default defineNuxtConfig({
  compatibilityDate: '2026-10-27',
  // Capacitor loads bundled files in a WebView without a Node server.
  ssr: false,
  devtools: { enabled: true },
  css: ['~/assets/css/main.css'],
  app: {
    head: {
      title: 'Nuxt + Capacitor',
      htmlAttrs: { lang: 'fa', dir: 'rtl' },
      meta: [
        {
          name: 'viewport',
          content: 'width=device-width, initial-scale=1, viewport-fit=cover',
        },
        { name: 'theme-color', content: '#071b21' },
        { name: 'description', content: 'پروژهٔ پایهٔ Nuxt 3 با Capacitor برای وب، اندروید و iOS' },
      ],
      link: [{ rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' }],
    },
  },
  typescript: { strict: true },
})
