# 📦 Batch 5 — Reports + Charts

> **เป้าหมาย:** Tab "📊 รายงาน" กลายเป็น dashboard มีกราฟสวยๆ + insights

---

## 🎯 สิ่งที่จะได้หลัง Batch 5

✨ **Period Selector** — เลือกช่วงเวลา
- วัน / สัปดาห์ / เดือน / ปี

✨ **Date Navigator** — เลื่อนดูช่วงอื่น
- ◀ ▶ เลื่อนซ้าย-ขวา
- แตะตรงกลางเพื่อกลับมา "วันนี้"

✨ **Summary Cards**
- รายรับ / รายจ่าย / คงเหลือ ของช่วงที่เลือก

✨ **Pie Chart** 🥧
- รายจ่ายแยกตามหมวด (สีตรงกับหมวด)
- แตะ section → แสดง %
- Center hole แสดงยอดรวม
- Legend ด้านล่าง: icon + ชื่อ + จำนวนรายการ + %

✨ **Insight Cards** 💡
- "รายจ่ายลดลง X% จากช่วงก่อน 🎉" (เปรียบเทียบเดือนก่อน)
- "อัตราการออม X% ของรายรับ"
- "หมวดที่ใช้มากสุด: อาหาร (45%)"

---

## 🛠 วิธีติดตั้ง

### Step 0: Commit ของเก่า

```bash
cd ~/development/moneydiary_thai_v2
git add . && git commit -m 'Before Batch 5' && git push
```

### Step 1: หยุดแอป (กด `q`)

### Step 2: แตก Batch 5

```bash
unzip -o ~/Downloads/batch5.zip
```

### Step 3: Dependencies + Generate

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

> 💡 fl_chart มีอยู่ใน pubspec แล้วตั้งแต่ Batch 1 — ไม่ต้องเพิ่ม

### Step 4: รันแอป

```bash
flutter run
```

---

## 🎉 ทดสอบ Batch 5

### Test 1: ดูรายงานเดือนนี้
1. กด tab **"📊 รายงาน"**
2. (default = เดือน)
3. เห็น:
   - Summary cards (รายรับ/รายจ่าย/คงเหลือ)
   - Insight card 💡
   - **Pie chart** รายจ่ายตามหมวด!
   - Legend ด้านล่าง

### Test 2: แตะ Pie Chart
- แตะที่ section ใดก็ได้
- → section ขยาย + แสดง %

### Test 3: เปลี่ยน Period
- กด "วัน" / "สัปดาห์" / "ปี"
- → กราฟอัปเดตตามช่วง

### Test 4: เลื่อนเดือน
- กด ◀ → ดูเดือนก่อน
- กด ▶ → เดือนถัดไป
- แตะตรงกลาง (ชื่อเดือน) → กลับมาปัจจุบัน

### Test 5: ดู Insights
- ถ้ามีข้อมูล 2 เดือน → เห็น "รายจ่ายเพิ่ม/ลด X%"
- เห็น "อัตราการออม X%"
- เห็น "หมวดที่ใช้มากสุด"

> 💡 **เพื่อเห็น insights เปรียบเทียบ** — ลองบันทึก transactions ในเดือนก่อน (พ.ค. หรือ เม.ย.) ด้วย (กด ➕ → เปลี่ยนวันที่)

---

## 🧪 รัน Tests

```bash
flutter test
```

ควรเห็น **~51 tests passed** (เพิ่มจาก Batch 4 อีก 3 tests)

---

## 🐛 ถ้าเจอปัญหา

### ปัญหา: Pie chart ไม่ขึ้น / ว่างเปล่า
- ตรวจสอบว่ามี transactions ประเภท "รายจ่าย" ในช่วงที่เลือก
- ลองเปลี่ยนเป็นเดือนที่มีข้อมูล

### ปัญหา: Compile error เกี่ยวกับ fl_chart
fl_chart version 0.69.2 — ถ้า error ส่ง log มาให้ผมดู

### ปัญหา: insights ไม่ขึ้น
ปกติ — insight เปรียบเทียบจะขึ้นเมื่อมีข้อมูลช่วงก่อนหน้า

---

## 📋 สรุป Commands

```bash
cd ~/development/moneydiary_thai_v2
git add . && git commit -m 'Before Batch 5' && git push
unzip -o ~/Downloads/batch5.zip
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## ⏭️ Batch ถัดไป

**Batch 6 — Home Screen Widget**
- iOS WidgetKit — จดเงินจาก home screen
- Quick stats ใน widget
- (ยากที่สุด — มี Swift native code)

**Batch 7 — Settings + Backup**
- Theme switcher (light/dark/system)
- Language (TH/EN)
- CSV export/import
- Biometric lock

**Batch 8 — Polish + Tests + Compliance**
- SQLCipher encryption
- Performance tuning
- App Store submission prep

---

ลองดูแล้วส่ง screenshot กราฟมาอวดได้ครับ! 🎨📊
