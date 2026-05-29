# 📦 Batch 8 Part 1 — i18n (แปลภาษาให้ครบ)

> **เป้าหมาย:** แก้ปัญหา language switcher เปลี่ยนภาษาไม่ครบ — ตอนนี้หัวข้อหลักทุกหน้าจะแปลตาม locale

---

## ✨ สิ่งที่แก้

แทน **hardcoded ไทย → l10n keys** ใน 6 ไฟล์ + เพิ่ม ~45 keys ใหม่ใน ARB:

| ไฟล์ | จุดที่แก้ |
|-----|----------|
| `reports_screen` | "รายจ่ายตามหมวด", รายรับ/รายจ่าย/คงเหลือ, "ข้อมูลน่าสนใจ", empty state |
| `category_list_screen` | "จัดการหมวด", tabs, "เพิ่มหมวด", "เริ่มต้น", empty |
| `category_edit_screen` | "สร้าง/แก้ไขหมวด", labels (ชื่อไทย/อังกฤษ), hints, save |
| `account_list_screen` | "จัดการบัญชี", "เพิ่มบัญชี", empty |
| `account_edit_screen` | "สร้าง/แก้ไขบัญชี", labels, save, archive |
| `settings_screen` | Sections ทั้งหมด, Theme/Language tiles, Export/Import, Biometric |

**ที่เก็บไว้เป็นไทย (ตั้งใจ):**
- Insight messages ใน reports (ประโยคยาวที่อ่านดีในไทย)
- Type chips (เงินสด/ธนาคาร/E-Wallet/เครดิต/อื่นๆ)
- Confirmation dialogs (ลบหมวดนี้?, เก็บถาวรบัญชีนี้?)
- → จะแปลต่อใน hotfix ถ้าจำเป็น

---

## 🛠 วิธีติดตั้ง

### Step 1: หยุดแอป (กด `q`)

### Step 2: แตก patch

```bash
cd ~/development/moneydiary_thai_v2
unzip -o ~/Downloads/batch8_i18n.zip
```

### Step 3: 🔥 สำคัญ! — Regenerate l10n

เนื่องจาก ARB เปลี่ยน → ต้อง regenerate `app_localizations.dart`:

```bash
flutter gen-l10n
```

หรือถ้า command ไม่มี:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Step 4: รันแอป

```bash
flutter run
```

---

## 🎉 ทดสอบ

### Test 1: เปลี่ยนภาษา → ดูทั้งแอป
1. ⚙️ ตั้งค่า → ภาษา → English
2. กลับมาดู:
   - tab labels (Home, Reports, Transactions, Settings) ← เคยทำงาน
   - **Settings sections** (Display, Accounts & Categories, ...) ← **เพิ่งแก้!**
   - **Theme tile** (Theme / Light/Dark/System) ← **เพิ่งแก้!**
   - **Reports** (Expenses by Category, Total Expense, Insights) ← **เพิ่งแก้!**
   - **Category management** title + add button ← **เพิ่งแก้!**
   - **Account management** title + add button ← **เพิ่งแก้!**

### Test 2: เปลี่ยนกลับไทย
- ทุกอย่างกลับมาเป็นไทย

### Test 3: Tests ยังผ่าน
```bash
flutter test
```
ควรเห็น ~54 tests passed (ของเดิม ไม่กระทบ)

---

## 🐛 ถ้าเจอปัญหา

### "AppLocalizations doesn't have getter X"
หมายถึง l10n ยังไม่ regenerate
```bash
flutter gen-l10n
```

### Compile error อื่น
ส่ง error log มา ผมแก้ทันที

---

## 📋 สรุป

```bash
cd ~/development/moneydiary_thai_v2
# กด q หยุดแอป
unzip -o ~/Downloads/batch8_i18n.zip
flutter gen-l10n   # หรือ build_runner
flutter run
```

---

## ⏭️ ถัดไป

หลัง i18n ทำงาน → ผมจะส่ง **Batch 8 Part 2** ที่จะมี:
- App icon + launcher
- Splash screen
- Store metadata (description, keywords, categories)
- `flutter packages upgrade` แก้ analyzer warning

หรือถ้ามีปัญหา i18n บอกผม จะ hotfix ก่อน 🚀
