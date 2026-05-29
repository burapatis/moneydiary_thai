# 🎨 Batch 8 Part 2.1 — App Icon

> **เป้าหมาย:** เปลี่ยน app icon จาก Flutter default → ดอกบัว + ฿ สีเขียว

---

## 📋 ขั้นตอน (3 step + 1 รันคำสั่ง)

### Step 1: หยุดแอป (กด `q`)

### Step 2: แตก zip ทับ

```bash
cd ~/development/moneydiary_thai_v2
unzip -o ~/Downloads/batch8_icon.zip
```

ไฟล์ที่เปลี่ยน:
- `pubspec.yaml` — เพิ่ม `flutter_launcher_icons` + config
- `assets/app_icon/icon_1024.png` — icon master (1024×1024)

### Step 3: ติดตั้ง dependencies

```bash
flutter pub get
```

### Step 4: 🎨 Generate iOS icons ทุก size

```bash
dart run flutter_launcher_icons
```

จะเห็น output ประมาณนี้:
```
✓ Successfully generated launcher icons
```

Tool จะ generate iOS icons **ทุกขนาด** อัตโนมัติ:
- iPhone notification 20×20 @1x, 2x, 3x
- iPhone settings 29×29 @2x, 3x
- iPhone spotlight 40×40 @2x, 3x
- iPhone app 60×60 @2x, 3x
- iPad notification 20×20 @1x, 2x
- iPad settings 29×29 @1x, 2x
- iPad spotlight 40×40 @1x, 2x
- iPad app 76×76 @1x, 2x
- iPad pro app 83.5×83.5 @2x
- App Store 1024×1024 @1x

**ทั้งหมด ~15 ไฟล์** ใส่ใน `ios/Runner/Assets.xcassets/AppIcon.appiconset/` อัตโนมัติ

### Step 5: ⚠️ ลบแอปเก่าจาก Simulator ก่อนรันใหม่

iOS cache app icon ค่อนข้างเหนียว — ต้องลบเก่าก่อน:

**วิธี A:** Long-press app icon ใน Simulator → กา ✕ ลบ
**วิธี B:** ใน Simulator menu: **Device → Erase All Content and Settings** (จะลบทั้งหมด — รวมข้อมูลเดิม!)

### Step 6: รันแอปใหม่

```bash
flutter run
```

---

## ✅ ตรวจสอบผลลัพธ์

หลังแอปเปิดมา:

1. **กด Home button** (⌘+Shift+H ใน Simulator)
2. ไปที่ home screen ของ Simulator
3. หา app "Moneydiary Thai"
4. **เห็น icon ใหม่!** 🎨
   - ดอกบัวเต็มดอก
   - ตัว ฿ ตรงกลาง
   - สีเขียวสวย
   - iOS round corners อัตโนมัติ

### ทดสอบที่อื่น
- **App Switcher** (⌘+Tab) — icon โผล่ในนั้น
- **Spotlight Search** (⌘+Space) → พิมพ์ "Moneydiary" — icon เล็กๆ ขึ้นข้างชื่อ
- **Settings → General → iPhone Storage → Moneydiary Thai** — icon ใหญ่

---

## 🐛 Troubleshooting

### ปัญหา: icon ยังเป็นของเก่า

**สาเหตุ:** iOS cache
**แก้:** Erase Simulator (Step 5 วิธี B)

### ปัญหา: `dart run flutter_launcher_icons` error

ลอง:
```bash
flutter clean
flutter pub get
dart run flutter_launcher_icons
```

### ปัญหา: "image_path not found"

ตรวจสอบว่าไฟล์อยู่:
```bash
ls -la assets/app_icon/icon_1024.png
```

ถ้าไม่มี → แตก zip ซ้ำ

### ปัญหา: error เรื่อง alpha channel

ใน pubspec มี `remove_alpha_ios: true` แล้ว — ถ้ายังขึ้น error ลอง:
```bash
dart run flutter_launcher_icons:main --help
```

---

## 📋 สรุป Commands

```bash
cd ~/development/moneydiary_thai_v2
# กด q หยุดแอป
unzip -o ~/Downloads/batch8_icon.zip
flutter pub get
dart run flutter_launcher_icons
# ลบแอปเก่าจาก Simulator (long-press → ✕)
flutter run
```

หลังเสร็จ — ไปที่ home screen ของ Simulator (⌘+Shift+H) ดู icon ใหม่! 🎨

---

## 📊 ความก้าวหน้า Batch 8 Part 2

```
✅ App icon                  ← เพิ่งจบ!
🔜 Splash screen
⏳ App Store listing prep
⏳ Bundle ID + signing
⏳ flutter packages upgrade
⏳ Version bump 0.1.0 → 1.0.0
```

---

## ⏭️ ขั้นถัดไป

หลัง icon ทำงานแล้ว ผมจะส่ง:

**Batch 8 Part 2.2 — Splash Screen**
- หน้าจอเปิดแอปสวยๆ (ก่อน home screen โหลด)
- ใช้ flutter_native_splash
- background สีเขียว + icon เดียวกัน

แล้วค่อย **Part 2.3 — Store Prep + Bundle ID**

ลองติดตั้งแล้วบอกผลครับ! 🚀

ส่ง screenshot home screen ของ Simulator มาให้ดูได้ — อยากเห็น icon ใหม่บนเครื่องจริง 😊
