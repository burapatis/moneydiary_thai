# 📦 Batch 2 — Data Layer (วิธีติดตั้ง)

> **เป้าหมาย Batch 2:** มี database พร้อมใช้ + 25 หมวดไทย default + บันทึก/อ่าน/แก้/ลบ data ได้

---

## ⚠️ สำคัญ — Batch 2 ต้องรัน Code Generation

แตกต่างจาก Batch 1 — Batch 2 ใช้ **drift** ซึ่งสร้างไฟล์ `.g.dart` อัตโนมัติ
**ต้องรัน build_runner** ไม่งั้น compile ไม่ผ่าน

---

## 🛠 วิธีติดตั้ง Batch 2 (Step-by-Step)

### Step 1: หยุดแอปก่อน (ถ้ายังรันอยู่)

ใน terminal กด `q` เพื่อหยุดแอป

### Step 2: คัดลอกไฟล์ Batch 2 ทับ Batch 1

```bash
cd ~/development/moneydiary_thai

# Backup ของเดิม (เผื่อต้องย้อน)
cd ..
cp -R moneydiary_thai moneydiary_thai.batch1.backup

# กลับไป
cd moneydiary_thai

# วางไฟล์ Batch 2 ทับ
# (ลากโฟลเดอร์ moneydiary_thai_batch2 ที่ผมส่ง วางในโฟลเดอร์ ~/development)
# แล้วคัดลอกทับ
cp -R ~/Downloads/moneydiary_thai_batch2/* .
cp -R ~/Downloads/moneydiary_thai_batch2/.* . 2>/dev/null || true
```

หรือถ้าใช้ zip:
```bash
cd ~/development/moneydiary_thai
unzip -o ~/Downloads/moneydiary_thai_batch2.zip
# -o = overwrite without prompt
```

### Step 3: ติดตั้ง dependencies ใหม่ (เพิ่มแล้วใน pubspec.yaml ของ Batch 1)

```bash
flutter pub get
```

ครั้งนี้จะดาวน์โหลด:
- `drift`, `drift_flutter`, `sqlite3_flutter_libs`
- `uuid`
- ของอื่นๆ ที่เพิ่ม

### Step 4: 🔥 รัน Code Generation (สำคัญ!)

นี่คือ step ที่ขาดไม่ได้ — drift จะสร้างไฟล์ `.g.dart` (auto-generated)

```bash
dart run build_runner build --delete-conflicting-outputs
```

**ครั้งแรกใช้เวลา 2-3 นาที** เพราะต้อง compile drift code generator

จะเห็น output แบบ:
```
[INFO] Generating build script completed, took 234ms
[INFO] Reading cached asset graph completed, took 56ms
[INFO] Setting up file watchers completed, took 11ms
[INFO] Updating asset graph completed, took 89ms
[INFO] Running build...
[INFO] Generating SDK summary completed, took 1.2s
[INFO] 1.5s elapsed, 8/10 actions completed.
[INFO] 4.2s elapsed, 12/12 actions completed.
[INFO] Running build completed, took 4.5s
[INFO] Caching finalized dependency graph completed, took 89ms
[INFO] Succeeded after 4.6s with 6 outputs (12 actions)
```

ตรวจสอบว่าสร้างไฟล์แล้ว:
```bash
find lib -name "*.g.dart" | head
```

ควรเห็น:
- `lib/services/database/app_database.g.dart`
- `lib/services/database/daos/account_dao.g.dart`
- `lib/services/database/daos/category_dao.g.dart`
- `lib/services/database/daos/transaction_dao.g.dart`

### Step 5: รันแอป

```bash
flutter run
```

ครั้งแรกหลัง Batch 2 ใช้เวลา ~ 2-3 นาที (build SQLite native libs)

---

## ✅ Verification — ตรวจสอบว่า Batch 2 ทำงานถูก

หลังแอปเปิดขึ้นมา ให้สังเกต **หน้า Home** (tab แรก):

### สิ่งที่ควรเห็น

```
┌─────────────────────────────┐
│ MoneyDiary Thai             │
├─────────────────────────────┤
│                             │
│   วันนี้                     │
│                             │
│   ฿0.00                     │   ← Hero number
│                             │
│   ┌─────────┐ ┌─────────┐   │
│   │ ↓ รายรับ │ │ ↑ รายจ่าย│   │
│   │  ฿0.00  │ │  ฿0.00  │   │
│   └─────────┘ └─────────┘   │
│                             │
│   เดือนนี้                   │
│                             │
│   ┌───────────────────┐    │
│   │ รายรับ      ฿0.00  │    │
│   │ ──────────────    │    │
│   │ รายจ่าย     ฿0.00  │    │
│   │ ──────────────    │    │
│   │ คงเหลือ     ฿0.00  │    │
│   └───────────────────┘    │
│                             │
│       📭                    │
│   ยังไม่มีรายการ              │
│      ในวันนี้                │
│                             │
└─────────────────────────────┘
```

✅ ถ้าเห็นหน้านี้ = Batch 2 สำเร็จ!

---

## 🧪 ทดสอบว่า Database ทำงานจริง

ใน Terminal (ไม่ปิดแอป) เปิด **tab ใหม่** แล้วรัน unit tests:

```bash
flutter test test/unit/features/category/category_repository_test.dart
```

ควรเห็น:
```
00:02 +0: loading test/unit/features/category/category_repository_test.dart
00:05 +9: All tests passed!
```

ถ้าผ่านทั้ง 9 tests แสดงว่า:
- ✅ Database สร้างได้
- ✅ Migration ทำงาน
- ✅ Seed default categories 25 หมวด
- ✅ CRUD ทำงาน

ลองรันทั้งหมด:
```bash
flutter test
```

ควรผ่านทุก test (~ 30 tests)

---

## 🎯 ลองเพิ่ม transaction ผ่าน Dart REPL (ทดลอง data layer)

> **หมายเหตุ:** Batch 3 จะมี UI สำหรับเพิ่ม transaction
> ตอนนี้เราเทสได้ผ่าน test เท่านั้น

ลองรัน specific test:
```bash
flutter test test/unit/features/transaction/transaction_repository_test.dart
```

ดู output — จะเห็นการสร้าง transaction, validate amount, calculate summary

---

## 🔥 Hot Reload กับ Database

**สำคัญ:** Hot Reload (`r`) **ไม่** reset database — data ที่เพิ่มไว้จะอยู่ต่อ

ถ้าต้องการ reset:
- **Hot Restart** (`R` ใหญ่) — รัน main() ใหม่ แต่ DB ยังอยู่ในเครื่อง
- **Uninstall + reinstall**:
  - ใน Simulator: long-press app icon → Remove App
  - หรือ: `Device → Erase All Content and Settings`

---

## 🐛 Troubleshooting — Batch 2

### ปัญหา #1: `Error: Type 'AppDatabase' not found`

**สาเหตุ:** ยังไม่ได้รัน build_runner

**แก้:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### ปัญหา #2: `Conflicting outputs` error

**สาเหตุ:** มี `.g.dart` เก่าจาก build ก่อน

**แก้:**
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### ปัญหา #3: `sqlite3 library not found` (iOS)

**สาเหตุ:** Pods ต้อง update

**แก้:**
```bash
cd ios
pod install
cd ..
flutter run
```

### ปัญหา #4: แอปเปิดมา crash ทันที

ดู Terminal มี error อะไร — มักเป็น database initialization failure

ลอง:
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd ios && pod install && cd ..
flutter run
```

### ปัญหา #5: ลบแอปออกเริ่มใหม่

ใน Simulator: Settings app → General → Transfer or Reset → Reset → Erase All Content and Settings

หรือคลิกขวาที่ app icon ใน Simulator → Delete App

---

## 📂 ไฟล์ใหม่ใน Batch 2 (สำหรับเปิดดู)

### Database Core
```
lib/services/database/
├── app_database.dart              ← Main database class
├── app_database.g.dart            ← Auto-generated (ห้ามแก้)
├── database_providers.dart        ← Riverpod registrations
├── tables/
│   ├── accounts_table.dart
│   ├── categories_table.dart
│   └── transactions_table.dart
├── daos/
│   ├── account_dao.dart           ← + .g.dart
│   ├── category_dao.dart          ← + .g.dart
│   └── transaction_dao.dart       ← + .g.dart
└── seeders/
    └── category_seeder.dart       ← 25 หมวดไทย
```

### Domain Layer (Pure Business Logic)
```
lib/features/
├── account/domain/
│   ├── entities/account.dart
│   └── repositories/account_repository.dart
├── category/domain/
│   ├── entities/category.dart
│   └── repositories/category_repository.dart
└── transaction/domain/
    ├── entities/transaction.dart
    └── repositories/transaction_repository.dart
```

### Data Layer (Implementation)
```
lib/features/*/data/repositories/
├── account_repository_impl.dart
├── category_repository_impl.dart
└── transaction_repository_impl.dart
```

### Tests
```
test/
├── helpers/test_database.dart
├── widget/smoke_test.dart
└── unit/features/
    ├── account/account_repository_test.dart
    ├── category/category_repository_test.dart
    └── transaction/transaction_repository_test.dart
```

---

## 💡 สิ่งที่ทำได้แล้วหลัง Batch 2

- ✅ Database + 3 tables พร้อม
- ✅ 25 default categories ภาษาไทย/อังกฤษ
- ✅ Repository pattern ครบ (Clean Architecture)
- ✅ Reactive streams ผ่าน Riverpod (UI auto-update)
- ✅ Validation (amount > 0, required fields)
- ✅ Aggregations (sum by category, by date range)
- ✅ Unit tests 30+ ตัว ครอบคลุม edge cases
- ✅ Home screen แสดง summary จริงจาก DB

---

## ⏭️ Batch 3 จะส่งอะไร

**Transaction UI** — UI ที่ผู้ใช้จดเงินได้จริง

- Quick-Add Bottom Sheet (เปิดจาก FAB)
- Number keypad UI
- Category picker (horizontal scroll)
- Account picker dropdown
- Transaction List screen (ใน tab "รายการ")
- Edit / Delete transactions
- Empty state ที่สวย

หลัง Batch 3 → คุณจะ **บันทึกรายจ่ายจริงได้แล้ว** ผ่าน UI

---

ติดอะไรบอกผมครับ — ส่ง error เต็มๆ มาเลย 🚀
