# 📦 Batch 4 — Categories + Accounts Management UI

> **เป้าหมาย:** จัดการหมวดและบัญชีเองได้ผ่าน UI สวยๆ + Delete transactions

---

## 🎯 สิ่งที่จะได้หลัง Batch 4

✨ **Delete Transaction**
- ปุ่ม 🗑️ สีแดงใน Quick-Add edit mode (มุมขวาบน)
- Confirmation dialog ก่อนลบ (ป้องกันพลาด)

✨ **Category Management** (Settings → จัดการหมวด)
- แท็บแยก "รายจ่าย" / "รายรับ"
- **สร้างหมวดเอง** เช่น "ค่าฟิตเนส", "ค่า Netflix"
- **แก้ไข** หมวดที่สร้างเอง
- **ลบ** หมวดที่สร้างเอง (default ลบไม่ได้ — ใช้ซ่อนแทน)
- **ซ่อน/แสดง** หมวด default ที่ไม่ใช้
- **Icon Picker** — เลือกจาก ~30 icons
- **Color Picker** — 12 สี

✨ **Account Management** (Settings → จัดการบัญชี)
- **สร้างบัญชี** เพิ่ม K PLUS, SCB Easy, ทรู มันนี่, บัตรเครดิต
- ประเภทบัญชี: เงินสด / ธนาคาร / E-Wallet / เครดิต / อื่นๆ
- **ยอดเริ่มต้น** ใส่ได้ (เช่น เริ่ม K PLUS ที่ 5,000)
- **แสดงยอดปัจจุบัน** = initial + transactions
- **Archive** (เก็บถาวร) แทน delete ถ้ามี transactions

✨ **Settings Tab ใหม่**
- มี Section "บัญชี" → link ไป 2 หน้าใหม่
- แสดง version
- (Batch 7 จะเพิ่ม Theme, Language, Backup ฯลฯ)

---

## 🛠 วิธีติดตั้ง (5 ขั้นง่ายๆ)

### Step 0: Commit ของเก่าก่อน (Best Practice)

```bash
cd ~/development/moneydiary_thai_v2
git add .
git commit -m 'Checkpoint before Batch 4'
git push
```

### Step 1: หยุดแอป

ใน Terminal: กด `q`

### Step 2: แตก Batch 4 ทับ

```bash
unzip -o ~/Downloads/batch4.zip
```

### Step 3: ติดตั้ง dependencies + Generate

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

> 💡 Batch 4 **ไม่มี table ใหม่** — build_runner จะเร็วกว่า Batch ก่อน

### Step 4: รันแอป

```bash
flutter run
```

---

## 🎉 ทดสอบ Batch 4

### Test 1: Delete Transaction
1. กด tab **"📋 รายการ"** (ของคุณมี โจ๊ก, Disk, ฟรีแลนซ์ จาก Batch 3)
2. กดที่ "Disk -฿520"
3. Quick-Add Sheet เปิดในโหมด edit
4. **เห็นปุ่ม 🗑️ สีแดง** มุมขวาบน
5. กด → Dialog "ลบรายการนี้?"
6. กด "ลบ"
7. → Toast "ลบแล้ว" + Sheet ปิด
8. → Home screen อัปเดต: คงเหลือเดือนนี้ ฿809 → ฿1,329

### Test 2: สร้างหมวด Custom
1. กด tab **"⚙️ ตั้งค่า"**
2. กด **"จัดการหมวด"**
3. (อยู่แท็บ "รายจ่าย")
4. กด FAB **"+ เพิ่มหมวด"**
5. กรอก:
   - ชื่อไทย: `ค่าฟิตเนส`
   - ชื่ออังกฤษ: `Gym`
   - เลือก icon 💆 (spa)
   - เลือกสีชมพู
6. กด "บันทึก"
7. → กลับมาที่ list — เห็น "ค่าฟิตเนส" อยู่ท้ายสุด
8. กด ➕ FAB กลาง → ลองบันทึกหมวดใหม่ดู

### Test 3: ซ่อนหมวด Default
1. ใน "จัดการหมวด" → แท็บ "รายจ่าย"
2. หา "นวด-สปา" (หรืออื่นๆ ที่ไม่ใช้)
3. กด icon 👁️ สีเทอเควอยซ์ ขวามือ
4. → กลายเป็นเส้นขีดทับ + icon 👁️‍🗨️ (closed eye)
5. กด ➕ FAB กลาง → "นวด-สปา" จะไม่ขึ้นใน picker แล้ว
6. กลับไปกด 👁️‍🗨️ อีกครั้ง → ปลดซ่อน

### Test 4: เพิ่มบัญชี K PLUS
1. ตั้งค่า → **"จัดการบัญชี"**
2. เห็น "เงินสด ฿0.00" (จาก Batch 3 seeder)
3. กด FAB **"+ เพิ่มบัญชี"**
4. กรอก:
   - ชื่อ: `K PLUS`
   - ประเภท: ธนาคาร
   - ยอดเริ่มต้น: `5000`
   - Icon: 🏛️ (account_balance)
   - สี: ฟ้า
5. กด "บันทึก"
6. → กลับมาที่ list — เห็น "K PLUS ฿5,000.00"
7. กด ➕ FAB → ลองเลือก "K PLUS" ใน account picker

### Test 5: Archive Account
1. กดที่ "K PLUS" ใน list
2. มุมขวาบน กด icon "เก็บถาวร" (archive)
3. ยืนยัน → "เก็บถาวรแล้ว"
4. → K PLUS หายจาก list (และ FAB picker)

> 💡 **Archive ≠ Delete** — ข้อมูลยังอยู่ + transactions เดิมยังนับ แต่ไม่ขึ้นใน list

---

## 🧪 รัน Tests

```bash
flutter test
```

ควรเห็น **~45 tests passed** (เพิ่มจาก Batch 3 อีก 4 tests สำหรับ custom category)

---

## 💡 Tips

### หมวดเริ่มต้น (Default) ลบไม่ได้

เพื่อกัน UX พัง — ถ้าผู้ใช้ลบ "อาหาร" แล้ว transaction เก่าจะหายไปอ้างหมวด

**วิธีจัดการ:** ใช้ **ซ่อน** แทน — รายการเก่ายังเห็นหมวดเดิม แต่ไม่ขึ้นใน picker ตอนเพิ่มใหม่

### Account ที่มี transactions ลบไม่ได้

ใช้ **archive** แทน — บัญชีจะถูกซ่อนแต่ transactions ทั้งหมดยังคงอยู่

### สีและ icon ที่ใช้ใน Picker

12 สี + 30 icons รวมหลัก:
- 🍴 อาหาร, ☕ กาแฟ, 🛒 ตลาด
- 🚗 รถ, ⛽ น้ำมัน
- 🏠 บ้าน, ⚡ ไฟ, 📱 โทร
- 👜 ช้อป, 👕 เสื้อผ้า, 💆 สปา
- 🎬 หนัง, 🎓 เรียน, 💊 ยา
- ❤️ ทำบุญ, 🐾 สัตว์เลี้ยง, 🎁 ของขวัญ
- 💼 งาน, ✏️ ฟรีแลนซ์, 🏪 ขายของ
- 💳 เครดิต, 💰 wallet, 📈 ดอกเบี้ย

---

## 🐛 ถ้าเจอปัญหา

### ปัญหา: "เพิ่มหมวดใหม่" แล้วไม่ขึ้นใน Quick-Add picker
- ตรวจสอบว่าเลือก type ตรงกัน (รายจ่าย/รายรับ)
- อาจต้อง Hot Restart (`R` ตัวใหญ่)

### ปัญหา: ลบบัญชีไม่ได้ ขึ้น error
ปกติครับ! บัญชีที่มี transactions ลบไม่ได้ — ใช้ปุ่ม archive (icon กล่อง) ที่มุมขวาบนแทน

### ปัญหา: Compile error อื่นๆ
ส่ง error message มาให้ผมดู — ผมจะออก hotfix ให้

---

## 📋 สรุป Commands

```bash
cd ~/development/moneydiary_thai_v2
git add . && git commit -m 'Checkpoint before Batch 4' && git push
unzip -o ~/Downloads/batch4.zip
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

หลังรันสำเร็จ:
1. ลอง Delete transaction "Disk"
2. สร้างหมวด "ค่าฟิตเนส" สีชมพู
3. เพิ่มบัญชี "K PLUS" ยอด 5,000
4. 🎉

---

## ⏭️ Batch ถัดไป

**Batch 5 — Reports + Charts** จะส่ง:
- 📊 **Pie chart** รายจ่ายตามหมวด
- 📈 **Bar chart** เปรียบเทียบเดือน
- 📅 **Period selector** วัน/สัปดาห์/เดือน/ปี
- 💡 **Insights** เช่น "ค่ากาแฟลด 12% จากเดือนก่อน"
- ⬅️➡️ **Month navigation** เปลี่ยนเดือน

หลัง Batch 5 → tab "📊 รายงาน" จะเปิดมาเห็นกราฟสวยๆ 🎯

---

ลองทำดูแล้วบอก "ทำได้แล้ว" หรือส่ง error มาครับ! 🚀
