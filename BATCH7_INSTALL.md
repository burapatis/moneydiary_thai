# 📦 Batch 7 — Settings + Backup

> **เป้าหมาย:** Settings ครบเครื่อง — Theme, ภาษา, Export/Import CSV, Face ID lock

---

## 🎯 สิ่งที่จะได้หลัง Batch 7

✨ **Theme Switcher** 🌗
- สว่าง / มืด / ตามระบบ
- เปลี่ยนทันที (ทั้งแอป)

✨ **Language Switcher** 🌐
- ไทย / English
- เปลี่ยนทันที

✨ **Export CSV** 📤
- ส่งออก transactions ทั้งหมดเป็น CSV
- เปิด share sheet → บันทึก Files / iCloud / ส่ง email / LINE
- รองรับภาษาไทย (UTF-8 BOM — เปิดใน Excel ได้)

✨ **Import CSV** 📥
- เลือกไฟล์ CSV → นำเข้า transactions
- Match หมวด/บัญชีตามชื่ออัตโนมัติ

✨ **Biometric Lock** 🔒
- ล็อกแอปด้วย Face ID / Touch ID
- ต้องยืนยันตัวตนเพื่อเปิดใช้

✨ **Settings Sections ใหม่**
- การแสดงผล / บัญชีและหมวด / ข้อมูล / ความปลอดภัย / เกี่ยวกับ

---

## ⚠️ สำคัญ — Batch 7 มี 2 ขั้นตอนพิเศษ

### พิเศษ #1: เพิ่ม package `local_auth`
pubspec.yaml ของ Batch 7 เพิ่ม `local_auth` แล้ว — `flutter pub get` จะดาวน์โหลดให้

### พิเศษ #2: เพิ่ม Face ID permission ใน Info.plist
iOS ต้องการคำอธิบายว่าทำไมแอปใช้ Face ID (ไม่งั้น crash ตอนเรียก)

---

## 🛠 วิธีติดตั้ง (มีขั้นตอนพิเศษ)

### Step 0: Commit ของเก่า

```bash
cd ~/development/moneydiary_thai_v2
git add . && git commit -m 'Add Batch 5 - Reports and Charts' && git push
```

### Step 1: หยุดแอป (กด `q`)

### Step 2: แตก Batch 7

```bash
unzip -o ~/Downloads/batch7.zip
```

### Step 3: 🔑 เพิ่ม Face ID permission ใน Info.plist

เปิดไฟล์ `ios/Runner/Info.plist` ใน VS Code:

```bash
code ios/Runner/Info.plist
```

หา `<dict>` แรก (บรรทัดบนๆ) แล้วเพิ่ม 2 บรรทัดนี้ต่อจาก `<dict>`:

```xml
	<key>NSFaceIDUsageDescription</key>
	<string>ใช้ Face ID เพื่อล็อกแอปให้ปลอดภัย</string>
```

**ตัวอย่าง** — ควรอยู่ประมาณนี้:
```xml
<plist version="1.0">
<dict>
	<key>NSFaceIDUsageDescription</key>
	<string>ใช้ Face ID เพื่อล็อกแอปให้ปลอดภัย</string>
	<key>CFBundleDevelopmentRegion</key>
	...
```

> 💡 ถ้าลืมขั้นตอนนี้ → biometric toggle จะทำงานไม่ได้ (แต่แอปไม่ crash ตอนเปิด เพราะผมใส่ try-catch ไว้)

### Step 4: ติดตั้ง dependencies

```bash
flutter pub get
```

ครั้งนี้จะดาวน์โหลด `local_auth` + dependencies

### Step 5: Generate code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 6: ⚠️ ต้อง pod install (เพราะมี native plugin ใหม่)

```bash
cd ios
pod install
cd ..
```

### Step 7: รันแอป

```bash
flutter run
```

> ⚠️ ครั้งนี้ใช้เวลานานหน่อย (~ 2-3 นาที) เพราะ build native plugin ใหม่ (local_auth)

---

## 🎉 ทดสอบ Batch 7

### Test 1: เปลี่ยน Theme
1. กด tab ⚙️ ตั้งค่า
2. "การแสดงผล" → "ธีม"
3. เลือก "มืด"
4. → ทั้งแอปเปลี่ยนเป็น dark mode ทันที!
5. ลอง "ตามระบบ" → ตามการตั้งค่า iOS

### Test 2: เปลี่ยนภาษา
1. ตั้งค่า → "ภาษา"
2. เลือก "English"
3. → UI เปลี่ยนเป็นอังกฤษ (tab labels, หัวข้อ ฯลฯ)
4. กลับเป็น "ไทย"

### Test 3: Export CSV
1. ตั้งค่า → "ส่งออกข้อมูล (CSV)"
2. → Share sheet เปิดขึ้น
3. เลือก "Save to Files" หรือ "Mail" หรือ copy
4. → ได้ไฟล์ `moneydiary_export_XXXX.csv`
5. เปิดดูใน Files → เห็นข้อมูลทั้งหมด

### Test 4: Import CSV
1. ตั้งค่า → "นำเข้าข้อมูล (CSV)"
2. เลือกไฟล์ CSV (ที่เพิ่ง export)
3. → "นำเข้า X รายการสำเร็จ"
4. ดู tab รายการ — มีรายการเพิ่ม (ซ้ำกับเดิม — เพราะ import เพิ่ม ไม่ replace)

### Test 5: Biometric Lock (ถ้าทำ Step 3 แล้ว)
1. ตั้งค่า → "ความปลอดภัย"
2. เปิด toggle "ล็อกแอปด้วย Face ID"
3. → Simulator จะถาม authenticate
4. ใน Simulator: menu **Features → Face ID → Enrolled** (เปิด) ก่อน
5. แล้ว **Features → Face ID → Matching Face** เพื่อจำลองสแกนสำเร็จ

> 💡 บน Simulator ต้อง enroll Face ID ก่อน (Features menu) — บนเครื่องจริงใช้ได้เลย

---

## 🧪 รัน Tests

```bash
flutter test
```

ควรเห็น **~54 tests passed** (เพิ่ม CSV service tests 3 ตัว)

---

## 🐛 Troubleshooting

### ปัญหา: pod install error
```bash
cd ios
pod repo update
pod install
cd ..
```

### ปัญหา: local_auth crash ตอนเปิด biometric
- ตรวจสอบว่าเพิ่ม `NSFaceIDUsageDescription` ใน Info.plist แล้ว (Step 3)
- ตรวจสอบว่า Simulator enroll Face ID แล้ว (Features → Face ID → Enrolled)

### ปัญหา: Export ไม่เปิด share sheet
- ปกติบน Simulator share sheet อาจมี options น้อย — ลองบนเครื่องจริง

### ปัญหา: Compile error
ส่ง error log มาให้ผมดู — ผมออก hotfix ให้

---

## 📋 สรุป Commands

```bash
cd ~/development/moneydiary_thai_v2
git add . && git commit -m 'Add Batch 5' && git push   # commit ของเก่า
# กด q หยุดแอป
unzip -o ~/Downloads/batch7.zip
code ios/Runner/Info.plist   # เพิ่ม NSFaceIDUsageDescription (Step 3)
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd ios && pod install && cd ..
flutter run
```

---

## ⏭️ Batch ถัดไป

**Batch 6 — Home Widget** (กลับมาทำตามที่วางแผน)
- iOS WidgetKit
- จดเงินจาก home screen

**Batch 8 — Polish + Tests + Compliance** (ตัวสุดท้าย!)
- SQLCipher encryption
- Performance + accessibility
- App Store submission prep
- `flutter packages upgrade` แก้ analyzer warning

---

## 💪 ความก้าวหน้าหลัง Batch 7

```
██████████████████████░░  ~65% (ใกล้เสร็จ!)

✅ Batch 1-5
✅ Batch 7 — Settings + Backup ← นี่
🔜 Batch 6 — Home Widget
⏳ Batch 8 — Polish + Launch
```

หลัง Batch 7 แอปจะมี feature ครบสำหรับ MVP — Theme, ภาษา, Backup, ความปลอดภัย!

---

ลองติดตั้งแล้วบอกผลครับ — มี Step พิเศษ (Info.plist + pod install) อย่าลืม! 🚀
