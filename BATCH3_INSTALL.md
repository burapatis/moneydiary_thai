# 📦 Batch 3 — Transaction UI (วิธีติดตั้ง)

> **เป้าหมาย:** บันทึกเงินจริงผ่านแอปได้ใน 3 วินาที!

---

## 🎯 สิ่งที่จะได้หลัง Batch 3

✨ **Quick-Add Bottom Sheet** — UI หลักของแอป
- เปิดจากกด FAB ➕ ตรงกลาง
- Toggle รายจ่าย/รายรับ (default = รายจ่าย)
- Number input พร้อม auto-focus + keyboard ขึ้นทันที
- Category picker แบบ horizontal scroll (25 หมวดไทย)
- Account selector dropdown
- Note field (optional)
- Date/Time picker
- ปุ่ม "บันทึก" + haptic feedback + toast confirmation

✨ **Transactions Tab** (รายการ)
- List จัดกลุ่มตามวันที่ (วันนี้/เมื่อวาน/2 วันก่อน...)
- แต่ละ item แสดง icon + ชื่อหมวด + เวลา + บัญชี + จำนวน
- กดเข้าไป → เปิด Quick-Add ในโหมด edit
- ยอดรวมแต่ละวัน

✨ **Home Screen ใหม่**
- เพิ่ม "รายการล่าสุด" 5 อันท้าย (วันนี้)
- ทุกอย่าง live update เมื่อมีรายการใหม่

✨ **Smart Features**
- จำหมวด + บัญชีล่าสุด (next time จะ auto-select)
- บัญชี "เงินสด" สร้างให้อัตโนมัติเมื่อเปิดแอปครั้งแรก
- Validation: amount > 0, required fields

---

## 🛠 วิธีติดตั้ง

### Step 1: Commit ของเก่าก่อน (ใช้ Git ที่ตั้งไว้)

ก่อนติดตั้ง Batch ใหม่ ควร commit ของเก่าเป็น checkpoint ไว้:

```bash
cd ~/development/moneydiary_thai_v2

# ดูสถานะ
git status

# Commit ของที่อาจแก้ระหว่าง Batch 2
git add .
git commit -m "Checkpoint before Batch 3"
git push
```

> 💡 ถ้า status ว่างเปล่า (nothing to commit) ก็ไม่เป็นไร — ข้ามไปได้

### Step 2: หยุดแอป (ถ้ารันอยู่)

ใน Terminal: กด `q`

### Step 3: แตก Batch 3 ทับ

```bash
cd ~/development/moneydiary_thai_v2

unzip -o ~/Downloads/batch3.zip
```

จะเห็นไฟล์ที่ overwrite + ไฟล์ใหม่หลายๆ ไฟล์

### Step 4: ติดตั้ง dependencies (ถ้ามีอะไรใหม่)

```bash
flutter pub get
```

### Step 5: 🔥 Regenerate code

Batch 3 มี seeder ใหม่ (Account seeder) ที่อาจต้อง regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 6: รันแอป

```bash
flutter run
```

---

## ⚠️ สิ่งที่อาจต้องทำ — Reset Database

Batch 3 เพิ่ม **Account Seeder** ที่จะสร้างบัญชี "เงินสด" ให้อัตโนมัติ
แต่ถ้า database เก่ายังอยู่ (จากการรัน Batch 2) จะ skip seeder

**ทางเลือกที่ 1: Erase Simulator (แนะนำ — clean slate)**

ใน iOS Simulator:
- Menu bar: **Device → Erase All Content and Settings**
- ยืนยัน → Simulator restart
- รัน `flutter run` ใหม่

**ทางเลือกที่ 2: Uninstall app**

- ใน Simulator: long-press app icon → Remove App → Delete
- รัน `flutter run` ใหม่

**ทางเลือกที่ 3: ไม่ทำอะไร**

ถ้ายัง edit ของเดิมจะใช้ database เก่าที่ไม่มี "เงินสด" — Quick-Add จะแสดง "ไม่พบบัญชี" → ต้องเพิ่มเองใน Batch 4

> 💡 **ผมแนะนำทางเลือก #1** — เพราะอยากเห็น flow แบบ first-time user

---

## ✅ ทดสอบ Batch 3 — สนุก!

หลังแอปเปิดขึ้นมา ลอง:

### Test 1: บันทึกรายจ่ายแรก (3 วินาที)
1. กด FAB ➕ ตรงกลาง
2. (Default = "รายจ่าย" ↑)
3. พิมพ์ "65" (keyboard ขึ้นมาเอง — autofocus!)
4. เลือก ☕ "กาแฟ-ขนม" จาก horizontal scroll
5. (Account "เงินสด" ถูกเลือกอัตโนมัติ)
6. กด "บันทึก"

ผลลัพธ์:
- ✅ Toast "บันทึกแล้ว ✓" เด้งขึ้น
- ✅ Haptic feedback (เครื่องสั่นเบาๆ — บน device จริง)
- ✅ Sheet ปิดเอง
- ✅ **Home screen อัปเดตทันที** → เห็น "-฿65.00"
- ✅ Cards "รายจ่ายวันนี้" แสดง ฿65.00
- ✅ "รายการล่าสุด" แสดง ☕ กาแฟ-ขนม -65

### Test 2: บันทึกรายรับ
1. กด FAB ➕
2. กด toggle "↓ รายรับ"
3. พิมพ์ "1500"
4. เลือก 💼 "เงินเดือน"
5. กด "บันทึก"

ผลลัพธ์:
- ยอดวันนี้กลายเป็น +฿1,435 (1500 - 65)
- รายรับวันนี้: ฿1,500

### Test 3: เปลี่ยน Tab "รายการ"
- กด tab "📋 รายการ"
- เห็น list จัดกลุ่ม "วันนี้ +฿1,435"
- 2 items: กาแฟ-ขนม (-65) และ เงินเดือน (+1500)

### Test 4: แก้ไข Transaction
1. กดที่ "กาแฟ-ขนม" ใน list
2. Quick-Add Sheet เปิดในโหมด edit (ค่าเก่ามาแล้ว)
3. เปลี่ยน 65 → 90
4. เปลี่ยน note เป็น "กาแฟลาเต้ Starbucks"
5. กด "บันทึก"

ผลลัพธ์:
- รายจ่ายวันนี้: ฿90 (อัปเดตทันที)
- ใน list เห็น "กาแฟลาเต้ Starbucks" ใต้หมวด

### Test 5: บันทึกหลายๆ รายการ
ลอง 5-10 รายการ ดูว่า:
- ✅ Hot reload ของ data ทำงาน (ไม่ต้อง refresh)
- ✅ Summary calc ถูกต้อง
- ✅ Group by date ทำงาน

---

## 🧪 รัน Tests

ใน terminal tab ใหม่:
```bash
cd ~/development/moneydiary_thai_v2
flutter test
```

ควรเห็น ~44 tests ผ่าน (เพิ่มจาก Batch 2 อีก 3 test)

---

## 💡 Tips สำหรับ Quick-Add

| Tip | รายละเอียด |
|-----|---------|
| **Keyboard ปิด** | กดที่ว่างใน sheet หรือลาก sheet ลง |
| **ปิดโดยไม่บันทึก** | กด X ที่มุมขวาบน หรือ swipe ลง |
| **เลื่อนวันที่ผ่านมา** | กดที่ "วันนี้ XX:XX" → เลือกวัน + เวลาเก่า |
| **ลบรายการ** | (Batch 4 จะเพิ่ม delete button — ตอนนี้ต้องไป tab "รายการ" → กด → ยังไม่มีปุ่มลบ) |

> ⚠️ **Note Batch 3 ขาด:** ปุ่ม Delete ใน edit mode — จะเพิ่มใน Batch 4 พร้อม Categories/Accounts management

---

## 🐛 ถ้าเจอปัญหา

### ปัญหา: Quick-Add บอก "ไม่พบบัญชี"

**สาเหตุ:** Database เก่าจาก Batch 2 ที่ไม่มี Account seeder

**แก้:** Erase Simulator (ทางเลือก #1 ข้างบน)

### ปัญหา: หมวดไม่ขึ้น

**สาเหตุ:** Categories seeder ไม่ทำงาน

**แก้:**
```bash
# ลบ database ปัจจุบัน
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

ถ้ายังไม่ได้ → Erase Simulator

### ปัญหา: Compile error

ส่ง error message มาให้ผมดู — ผมจะออก hotfix ให้

---

## 🎯 ขั้นตอนสรุป

```bash
cd ~/development/moneydiary_thai_v2
git add . && git commit -m "Checkpoint before Batch 3" && git push
unzip -o ~/Downloads/batch3.zip
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

หลังรันสำเร็จ:
- กด ➕
- พิมพ์ 65
- เลือก ☕
- กด "บันทึก"
- 🎉

---

## ⏭️ หลัง Batch 3 — สิ่งที่ยังไม่มี

- ❌ Delete transaction button (Batch 4)
- ❌ Custom categories (Batch 4)
- ❌ Add/edit accounts UI (Batch 4)
- ❌ Reports/charts (Batch 5)
- ❌ Settings (Batch 7)
- ❌ Cloud sync (Phase 2)

แต่สิ่งที่ **ใช้งานได้แล้ว**:
- ✅ จดเงินจริง
- ✅ ดูสรุปวันนี้/เดือนนี้
- ✅ ดูรายการทั้งหมด
- ✅ แก้ไขรายการ
- ✅ Multi-account (สร้างผ่าน DB เท่านั้น ใน Batch นี้)

---

**สนุกกับการจดเงินครั้งแรกในแอปของคุณเองครับ! 🎊**

ถ้าทุกอย่าง work บอก "ไป Batch 4" — ส่ง Categories + Accounts UI ให้ต่อ
ถ้าเจอ error ส่งมาผมแก้ทันที 🚀
