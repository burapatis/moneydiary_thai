# 📒 MoneyDiary Thai

> **สมุดบันทึกเงินวิถีไทย** — แอปบันทึกรายรับ-รายจ่ายส่วนบุคคล แบบ Offline-first ที่เข้าใจวิถีคนไทย

**เวอร์ชันปัจจุบัน:** 1.1.0 (App Store)

---

## ✨ Key Features

- 🚀 **Quick-Add 3 วินาที** — กด ➕ → เลือกหมวด → ใส่จำนวน → เสร็จ
- 🇹🇭 **หมวดไทย 25 หมวด** — ทำบุญ, นวด, ตลาดสด, วินมอเตอร์ไซค์ ฯลฯ
- 🔒 **Privacy-First** — เก็บใน device ของคุณเท่านั้น ไม่ต้องสมัครสมาชิก ไม่เชื่อมต่อธนาคาร
- 🔐 **App Lock** — Face ID / Touch ID / Fingerprint (optional)
- 📊 **รายงาน** — Pie chart รายจ่ายตามหมวด, เปรียบเทียบช่วงเวลา
- 💾 **CSV Backup** — ส่งออก/นำเข้าข้อมูล
- 🌗 **Dark Mode** — Auto/Light/Dark
- 🌐 **ไทย + English** — i18n ครบทุกหน้าหลัก

---

## 🛠 Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.27+ |
| Language | Dart 3.6+ |
| State Management | Riverpod 2.6+ |
| Local DB | drift 2.21+ (SQLite) |
| Routing | go_router 14+ |
| Charts | fl_chart 0.69+ |
| Localization | flutter_localizations + intl |
| Font | Sarabun (Google Fonts) |

---

## 🚀 Quick Start

ดูคู่มือฉบับเต็มใน [SETUP.md](SETUP.md)

```bash
flutter pub get
cp .env.example .env
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

---

## 🧪 Testing

```bash
flutter test
flutter analyze
```

**54 tests** — repositories, CSV backup, widget smoke

---

## 📋 Release Notes (1.1.0)

- ✅ Biometric lock ทำงานจริงเมื่อเปิดแอป / กลับจาก background
- ✅ Onboarding ครั้งแรก + analytics consent
- ✅ Version จาก `package_info_plus` (ไม่ hardcode)
- ✅ Privacy Policy / Terms of Service เปิดลิงก์ได้
- ✅ i18n ครบ account/category/settings (EN + TH)
- ✅ แก้ข้อความ encryption ให้ตรงความจริง (device lock)
- ✅ iOS portrait-only สอดคล้องกับแอป

---

## 📄 License

Proprietary — All rights reserved

---

**Made with ❤️ in Thailand**
