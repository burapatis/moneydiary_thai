# 📒 MoneyDiary Thai

> **สมุดบันทึกเงินวิถีไทย** — แอปบันทึกรายรับ-รายจ่ายส่วนบุคคล แบบ Offline-first ที่เข้าใจวิถีคนไทย

---

## ✨ Key Features (MVP)

- 🚀 **Quick-Add 3 วินาที** — กด ➕ → เลือกหมวด → ใส่จำนวน → เสร็จ
- 🇹🇭 **หมวดไทย 25 หมวด** — ทำบุญ, นวด, ตลาดสด, วินมอเตอร์ไซค์ ฯลฯ
- 🔒 **Privacy-First** — เก็บใน device ของคุณเท่านั้น ไม่ต้องสมัครสมาชิก ไม่เชื่อมต่อธนาคาร
- 🔐 **Encrypted Database** — SQLCipher AES-256
- 📊 **รายงานสวยอ่านง่าย** — Pie chart, Bar chart, เปรียบเทียบเดือนก่อน
- 🏠 **Home Screen Widget** — จดได้โดยไม่ต้องเปิดแอป
- 🌗 **Dark Mode** — Auto/Light/Dark
- 🌐 **ไทย + English** — i18n ตั้งแต่วันแรก
- ♿ **Accessibility** — WCAG 2.1 AA compliant

---

## 🛠 Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.27+ |
| Language | Dart 3.6+ |
| State Management | Riverpod 2.6+ |
| Local DB | drift 2.21+ (SQLite) |
| DB Encryption | SQLCipher (Batch 2) |
| Routing | go_router 14+ |
| Charts | fl_chart 0.69+ |
| Localization | flutter_localizations + intl |
| Font | Sarabun (Google Fonts) |

ดูรายละเอียดเพิ่มเติมใน [docs/02_ARCHITECTURE.md](docs/02_ARCHITECTURE.md)

---

## 🚀 เริ่มต้นใช้งานเร็ว (30 นาที)

ดูคู่มือฉบับเต็มใน [SETUP.md](SETUP.md)

**สรุปเร็ว:**

```bash
# 1. ติดตั้ง Flutter (ถ้ายังไม่ได้ติดตั้ง)
# https://docs.flutter.dev/get-started/install

# 2. Clone โปรเจ็กต์
git clone https://github.com/your-username/moneydiary_thai.git
cd moneydiary_thai

# 3. ติดตั้ง dependencies
flutter pub get

# 4. ดาวน์โหลดฟอนต์ Sarabun (ดูใน SETUP.md)

# 5. Copy .env template
cp .env.example .env

# 6. Generate l10n + drift code
dart run build_runner build --delete-conflicting-outputs

# 7. รัน!
flutter run
```

---

## 📂 โครงสร้างโปรเจ็กต์

```
moneydiary_thai/
├── README.md                  # ไฟล์นี้
├── SETUP.md                   # คู่มือติดตั้งทีละขั้น
├── ARCHITECTURE.md            # อธิบายสถาปัตยกรรม
├── DEPLOYMENT.md              # คู่มือ build + publish
├── CONTRIBUTING.md            # มาตรฐานการเขียนโค้ด
├── .env.example
├── .gitignore
├── pubspec.yaml
├── l10n.yaml
├── analysis_options.yaml
│
├── lib/
│   ├── main.dart              # Entry point
│   ├── app.dart               # MaterialApp.router setup
│   │
│   ├── core/                  # ส่วนกลาง (theme, utils, errors)
│   │   ├── theme/             # Design tokens
│   │   ├── constants/
│   │   ├── utils/             # formatters, date helpers
│   │   ├── errors/            # Failure + Result pattern
│   │   ├── extensions/        # BuildContext extensions
│   │   ├── router/            # go_router config
│   │   └── widgets/           # shared widgets
│   │
│   ├── features/              # แบ่งตาม feature
│   │   ├── home/
│   │   ├── transaction/
│   │   ├── report/
│   │   └── settings/
│   │       └── presentation/
│   │           ├── screens/
│   │           ├── widgets/
│   │           └── providers/
│   │
│   ├── services/              # cross-feature services
│   └── l10n/                  # th.arb, en.arb
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
└── assets/
    ├── fonts/                 # Sarabun
    ├── images/
    └── icons/
```

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| Primary | `#0F766E` (Teal) |
| Success (รายรับ) | `#10B981` |
| Danger (รายจ่าย) | `#EF4444` |
| Warning (FAB) | `#F59E0B` |
| Font | Sarabun (Regular/Medium/SemiBold/Bold) |
| Grid | 8pt |
| Default radius | 12pt |

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/unit/core/utils/formatters_test.dart
```

**เป้าหมาย coverage:** ≥ 70%

---

## 📋 Roadmap

ดูรายละเอียด Sprint plan ใน [docs/04_ROADMAP.md](../phase2/04_ROADMAP.md)

| Sprint | Feature | Status |
|--------|---------|--------|
| 0 (Batch 1) | Foundation: setup + core + theme + l10n | ✅ Done |
| 1 (Batch 2) | Data Layer: drift schema + repositories | 🔄 Next |
| 2 (Batch 3) | Transactions UI | ⏳ |
| 3 (Batch 4) | Categories + Accounts | ⏳ |
| 4 (Batch 5) | Reports + Charts | ⏳ |
| 5 (Batch 6) | Home Widget | ⏳ |
| 6 (Batch 7) | Settings + Backup | ⏳ |
| 7 (Batch 8) | Tests + Polish | ⏳ |

---

## 🤝 Contributing

ดู [CONTRIBUTING.md](CONTRIBUTING.md) สำหรับ coding standards + commit convention

---

## 📄 License

License จะกำหนดตอน open source (Phase 2). ตอนนี้เป็น **Proprietary** — All rights reserved

---

## 📧 ติดต่อ

- Support: support@moneydiary.app
- Privacy: privacy@moneydiary.app
- Website: https://moneydiary.app *(ใน Phase 4)*

---

**Made with ❤️ in Thailand**
