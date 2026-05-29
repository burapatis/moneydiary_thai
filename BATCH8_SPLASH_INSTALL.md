# 🚀 Batch 8 Part 2.2 — Splash Screen

> **เป้าหมาย:** เพิ่มหน้า splash สวยๆ ตอนเปิดแอป (พื้นเขียว + ดอกบัวตรงกลาง)

---

## 📋 ขั้นตอน (5 steps + 1 รันคำสั่ง)

### Step 1: หยุดแอป (กด `q`)

### Step 2: แตก zip ทับ

```bash
cd ~/development/moneydiary_thai_v2
unzip -o ~/Downloads/batch8_splash.zip
```

ไฟล์ที่เปลี่ยน:
- `pubspec.yaml` — เพิ่ม `flutter_native_splash` + config
- `assets/app_icon/splash_icon.png` — splash icon (512×512)
- `assets/app_icon/splash_icon_dark.png` — dark mode version

### Step 3: ติดตั้ง dependencies

```bash
flutter pub get
```

### Step 4: 🎨 Generate splash screens

```bash
dart run flutter_native_splash:create
```

จะเห็น output:
```
[iOS] Creating splash images
[iOS] Updating Info.plist
[iOS] Creating LaunchScreen.storyboard
...
✓ Native splash complete
```

Tool จะ generate และ update **automatically**:
- iOS splash images ทุก device (iPhone, iPad)
- iOS dark mode versions
- `ios/Runner/Info.plist`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/`

ทั้งหมด ~20 ไฟล์ — **ไม่ต้องทำมือเลยแม้แต่ไฟล์เดียว!**

### Step 5: ⚠️ ลบแอปเก่าจาก Simulator

iOS cache splash + icon ค่อนข้างเหนียว — ลบก่อน:

- Long-press "Moneydiary Thai" บน home screen
- กด ✕ ลบ

### Step 6: รันใหม่

```bash
flutter run
```

---

## ✅ ตรวจสอบผลลัพธ์

หลัง `flutter run` เสร็จ:

1. **กด Home button** (⌘+Shift+H)
2. กลับมาเปิดแอป "Moneydiary Thai" จาก home screen
3. **ดูทันที!** จะเห็น:
   - 🟢 **พื้นเขียว teal** (สีหลักของแอป)
   - 🌸 **ดอกบัว + ฿ ตรงกลาง**
   - ⏱️ แสดง ~1 วินาที
   - 🏠 เข้า home screen ของแอป

### ทดสอบ Dark Mode
1. Simulator menu: **Features → Toggle Appearance** (⌘+Shift+A)
2. เปิดแอปอีกครั้ง
3. → พื้นจะเป็น teal เข้มกว่า (#065F58)

---

## 🎨 ทำไม Splash Screen สำคัญ

| ก่อนมี Splash | หลังมี Splash |
|---------------|---------------|
| 😐 หน้าขาวเปล่าๆ | 🌸 หน้าเขียวสวย มี logo |
| ดูเหมือนแอปไม่ทำงาน | รู้สึก premium ตั้งแต่วินาทีแรก |
| First impression แย่ | First impression ดี |

ผู้ใช้จะตัดสินใจเปิดแอปอีกครั้งจาก **first impression** — splash ดี = หวนกลับมาใช้ซ้ำ

---

## 🐛 Troubleshooting

### ปัญหา: ยังเห็นหน้าขาวเปล่า
**สาเหตุ:** iOS cache splash
**แก้:** ลบแอปจาก Simulator + run อีกครั้ง

### ปัญหา: `flutter_native_splash:create` error
ลอง:
```bash
flutter clean
flutter pub get
dart run flutter_native_splash:create
```

### ปัญหา: Splash แสดงไม่ตรง dark mode
ปกติ — Simulator ต้อง toggle appearance ก่อน (⌘+Shift+A)

### ปัญหา: icon ใน splash ใหญ่/เล็กไป
แก้ใน pubspec:
```yaml
flutter_native_splash:
  fill: false  # default
  # หรือ
  fullscreen: true
```

ผมตั้ง `ios_content_mode: center` ไว้ — ถ้าอยากปรับบอกได้

---

## 📋 สรุป Commands

```bash
cd ~/development/moneydiary_thai_v2
# กด q
unzip -o ~/Downloads/batch8_splash.zip
flutter pub get
dart run flutter_native_splash:create
# ลบแอปจาก Simulator
flutter run
```

---

## 📊 ความก้าวหน้า Batch 8 Part 2

```
✅ App icon                  
✅ Splash screen             ← เพิ่งจบ!
🔜 flutter packages upgrade  (แก้ analyzer warning)
🔜 Bundle ID + signing
🔜 App Store listing prep
🔜 Version bump 1.0.0
```

หลัง splash → **~85% ของโปรเจ็กต์**! ใกล้ launch แล้ว 🚀

---

## ⏭️ ขั้นถัดไป (Part 2.3)

หลัง splash ทำงาน ผมจะส่ง:

**Batch 8 Part 2.3 — Cleanup + Version**
- `flutter packages upgrade` แก้ analyzer warning
- ลบ `flutter_secure_storage` / `flutter_local_notifications` ที่ไม่ได้ใช้
- Version: `0.1.0+1` → `1.0.0+1`
- Bundle ID configuration

**Part 2.4 — App Store Listing**
- เขียน description (ไทย + อังกฤษ)
- Keywords
- Screenshots prep guide

ลองติดตั้งแล้วบอกผล! 🎯

ส่ง screenshot ตอน splash โผล่ขึ้นมาได้ (อาจต้องอัดวิดีโอ Simulator เพราะ splash หายเร็ว) 😊
