# Nuxt 3 + Capacitor

پروژهٔ پایهٔ TypeScript برای اجرای یک برنامه روی وب و اندروید، با امکان اضافه‌کردن iOS روی مک.

## اجرای وب

پیش‌نیاز: Node.js نسخهٔ 22.12 یا بالاتر.

```bash
npm ci
npm run dev
```

برنامه در `http://localhost:3000` در دسترس است.

```bash
npm run typecheck
npm run build
npm run preview
```

`build` دستور `nuxt generate` را اجرا می‌کند و فایل‌های قابل انتشار را در `.output/public` می‌سازد. `ssr: false` تنظیم شده، چون WebView فایل‌های محلی را اجرا می‌کند و سرور Node داخل اپ وجود ندارد. برای API باید از یک سرویس جداگانه با آدرس قابل دسترس از دستگاه استفاده کنید؛ مسیرهای `server/api` داخل اپ بسته‌بندی‌شده اجرا نمی‌شوند.

## اندروید

پروژهٔ بومی در `android/` قرار دارد. برای ساخت APK با خط فرمان، JDK 21، Android SDK Platform 36 و Build Tools 35.0.0 لازم است. متغیرهای `JAVA_HOME` و `ANDROID_HOME` باید به مسیر نصب ابزارها اشاره کنند. برای استفاده از محیط گرافیکی، Android Studio نسخهٔ 2025.2.1 یا جدیدتر را نصب کنید.

پس از تغییر کد وب یا نصب افزونه:

```bash
npm run android:sync
npm run android:open
```

برای اجرای مستقیم روی دستگاه یا شبیه‌ساز آماده:

```bash
npm run android:run
```

ساخت APK دیباگ روی ویندوز، همراه با ساخت وب، همگام‌سازی و بررسی امضا:

```bash
npm run android:apk
```

خروجی آمادهٔ نصب در `artifacts/android/nuxt-capacitor-debug.apk` قرار می‌گیرد. این نسخه با کلید دیباگ امضا می‌شود و برای تست روی دستگاه است. اسکریپت متغیرهای محیطی ذخیره‌شدهٔ کاربر یا تنظیم محلی `.cache/android-toolchain.json` را می‌خواند؛ برای اجرا پس از نصب نیازی به بازکردن ترمینال جدید ندارد.

برای ساخت مستقیم در PowerShell:

```powershell
npm run android:sync
Push-Location android
.\gradlew.bat assembleDebug
Pop-Location
```

فایل در `android/app/build/outputs/apk/debug/app-debug.apk` ساخته می‌شود.

در این سیستم، Microsoft OpenJDK 21.0.13، SDK Platform 36، Build Tools 35.0.0 و Platform Tools 37.0.1 در `D:/AndroidToolchain` نصب شده‌اند و کش Gradle نیز روی همین درایو است. مسیر ابزارها در متغیرهای محیطی کاربر ذخیره شده است. برای دسترسی به مخزن Google از شبکهٔ فعلی، فایل محلی `.cache/google-cdn.init.gradle` آدرس Maven گوگل را به CDN رسمی آن تغییر می‌دهد؛ اسکریپت ساخت در صورت وجود این فایل آن را به Gradle می‌دهد. Gradle Wrapper همان نسخهٔ 8.14.3 را با بستهٔ باینری و SHA-256 رسمی دریافت می‌کند.

دستور `npm run android:add` فقط برای ایجاد اولیهٔ پوشهٔ اندروید در نسخه‌ای از پروژه است که هنوز آن پوشه را ندارد؛ روی پروژهٔ موجود دوباره آن را اجرا نکنید.

## iOS روی مک

وابستگی iOS نصب شده، اما پروژهٔ Xcode باید روی macOS با Xcode 26 یا جدیدتر ایجاد و بررسی شود:

```bash
npm ci
npm run ios:add
npm run ios:open
```

در دفعات بعد:

```bash
npm run ios:sync
npm run ios:run
```

Capacitor 8 به‌صورت پیش‌فرض از Swift Package Manager استفاده می‌کند. برای افزونهٔ Preferences، فایل `PrivacyInfo.xcprivacy` را به target برنامه در Xcode اضافه کنید و دلیل استفاده از `UserDefaults` را ثبت کنید:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
      <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array><string>CA92.1</string></array>
      </dict>
    </array>
  </dict>
</plist>
```

اگر این فایل از قبل وجود دارد، ورودی بالا را با محتوای موجود ادغام کنید. [راهنمای رسمی Preferences](https://capacitorjs.com/docs/apis/preferences#apple-privacy-manifest-requirements)

## ساختار و قابلیت‌های نمونه

- `pages/index.vue`: صفحهٔ شروع فارسی، راست‌به‌چپ و واکنش‌گرا.
- `composables/useNativeTools.ts`: تشخیص پلتفرم، شمارندهٔ ذخیره‌شونده و تست بازخورد لمسی با مدیریت خطا.
- `nuxt.config.ts`: خروجی کلاینت و تنظیمات وب.
- `capacitor.config.ts`: شناسه، نام و مسیر خروجی اپ.
- `android/`: سورس بومی اندروید؛ تغییرات این پوشه را همراه پروژه نگه دارید.

Preferences در مرورگر از `localStorage` و روی موبایل از حافظهٔ بومی استفاده می‌کند. شمارنده با بستن و بازکردن برنامه حفظ می‌شود. داده با حذف برنامه یا پاک‌کردن داده‌های مرورگر از بین می‌رود. بازخورد لمسی فقط در اپ بومی فعال است و به پشتیبانی سخت‌افزار نیاز دارد.

شناسهٔ اولیه `com.example.nuxtcapacitor` و نام برنامه `Nuxt Capacitor` است. پیش از انتشار، این موارد را در تنظیمات Capacitor و پروژه‌های بومی تغییر دهید. فایل تنظیمات هیچ `server.url` خارجی ندارد؛ نسخهٔ نصب‌شده فایل‌های وب بسته‌بندی‌شده را بارگذاری می‌کند.

`npm run cap:sync` ابتدا خروجی وب را می‌سازد و سپس همهٔ پلتفرم‌های اضافه‌شده را همگام می‌کند. برای کار فقط روی اندروید، `android:sync` را استفاده کنید.

## منابع

- [استقرار استاتیک Nuxt 3](https://nuxt.com/docs/3.x/getting-started/deployment)
- [نصب Capacitor](https://capacitorjs.com/docs/getting-started)
- [پیش‌نیازهای ابزارهای بومی](https://capacitorjs.com/docs/getting-started/environment-setup)
