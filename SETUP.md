# 🛠 คู่มือติดตั้งและเริ่มใช้งาน (30 นาที)

> ทำตามทีละขั้น แม้ไม่เคยใช้ Flutter ก็ทำตามได้

---

## 📋 Prerequisites

| Tool | Minimum Version | Recommended |
|------|----------------|-------------|
| **Flutter SDK** | 3.27.0 | 3.27.x (latest stable) |
| **Dart SDK** | 3.6.0 | (มากับ Flutter) |
| **Git** | 2.30+ | latest |
| **Android Studio** | Iguana 2023.2 | Koala+ |
| **Xcode** (macOS only) | 15.0 | latest |
| **CocoaPods** (macOS only) | 1.13+ | latest |
| **Node.js** | 18+ | 20+ (สำหรับ tools เสริม) |

### ตรวจสอบเครื่องคุณ

```bash
flutter --version
flutter doctor -v
```

ถ้า `flutter doctor` แจ้งปัญหา **แก้ก่อนทำต่อ** — โดยเฉพาะ Android licenses

```bash
flutter doctor --android-licenses
```

---

## 🚀 Step-by-Step Setup

### 1. ติดตั้ง Flutter (ข้ามถ้ามีแล้ว)

#### macOS
```bash
# ใช้ Homebrew
brew install --cask flutter
# หรือ Manual: https://docs.flutter.dev/get-started/install/macos
```

#### Windows
ดาวน์โหลดจาก https://docs.flutter.dev/get-started/install/windows แล้วเพิ่ม PATH

#### Linux
```bash
sudo snap install flutter --classic
```

### 2. Clone โปรเจ็กต์

```bash
git clone https://github.com/your-username/moneydiary_thai.git
cd moneydiary_thai
```

### 3. ดาวน์โหลดฟอนต์ Sarabun

แอปใช้ฟอนต์ Sarabun ที่ต้องดาวน์โหลดเอง (ไม่ commit เข้า git):

1. เปิด https://fonts.google.com/specimen/Sarabun
2. กด **"Download family"**
3. แตก ZIP แล้วก็อปไฟล์เหล่านี้ไปที่ `assets/fonts/`:
   - `Sarabun-Regular.ttf` → `assets/fonts/Sarabun-Regular.ttf`
   - `Sarabun-Medium.ttf` → `assets/fonts/Sarabun-Medium.ttf`
   - `Sarabun-SemiBold.ttf` → `assets/fonts/Sarabun-SemiBold.ttf`
   - `Sarabun-Bold.ttf` → `assets/fonts/Sarabun-Bold.ttf`

หรือใช้ command line (macOS/Linux):

```bash
cd assets/fonts
curl -L "https://github.com/googlefonts/sarabun/raw/main/fonts/ttf/Sarabun-Regular.ttf" -o Sarabun-Regular.ttf
curl -L "https://github.com/googlefonts/sarabun/raw/main/fonts/ttf/Sarabun-Medium.ttf" -o Sarabun-Medium.ttf
curl -L "https://github.com/googlefonts/sarabun/raw/main/fonts/ttf/Sarabun-SemiBold.ttf" -o Sarabun-SemiBold.ttf
curl -L "https://github.com/googlefonts/sarabun/raw/main/fonts/ttf/Sarabun-Bold.ttf" -o Sarabun-Bold.ttf
cd ../..
```

### 4. ติดตั้ง Dependencies

```bash
flutter pub get
```

ถ้าเจอ error เกี่ยวกับ version ให้รัน:

```bash
flutter pub upgrade
```

### 5. Setup Environment Variables

```bash
# คัดลอก template
cp .env.example .env

# แก้ไขถ้าจำเป็น (สำหรับ MVP ใช้ default ได้เลย)
# nano .env   # หรือเปิดด้วย editor ที่ชอบ
```

### 6. Generate Code (l10n + drift + riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

> 💡 **คำสั่งนี้สำคัญมาก** — generate ไฟล์ `app_localizations.dart` ที่ใช้ทั่วทั้งแอป
> ถ้าเปลี่ยน `.arb` files ต้องรันใหม่
> ใช้ `--watch` เพื่อ auto-regenerate

### 7. รันแอป!

#### Android Emulator

```bash
# เปิด emulator (ถ้ายังไม่มี emulator)
# Android Studio → AVD Manager → Create

# ตรวจสอบ devices
flutter devices

# รัน
flutter run
```

#### iOS Simulator (macOS only)

```bash
# เปิด simulator
open -a Simulator

# รัน
flutter run
```

#### บนเครื่องจริง

**Android:**
1. เปิด Developer Options → USB debugging
2. ต่อสาย USB
3. `flutter run`

**iOS:**
1. เปิด `ios/Runner.xcworkspace` ใน Xcode
2. Signing & Capabilities → เลือก Team
3. ต่อสาย iPhone + Trust computer
4. `flutter run`

---

## ✅ ตรวจสอบว่าติดตั้งสำเร็จ

หลังรัน `flutter run` ควรเห็น:

1. ✅ แอปเปิดมาเห็น **Bottom Navigation 4 tabs** (หน้าแรก, รายงาน, รายการ, ตั้งค่า)
2. ✅ FAB ➕ ตรงกลาง — กดแล้วเปิด bottom sheet placeholder
3. ✅ เปลี่ยน tab ได้
4. ✅ แสดงข้อความเป็นไทย
5. ✅ Hot reload ทำงาน (กด `r` ใน terminal)

ถ้าครบ 5 ข้อ → **Batch 1 สำเร็จ!** 🎉

---

## 🐛 Troubleshooting (10 ปัญหาที่พบบ่อย)

### 1. `flutter pub get` ค้าง

```bash
flutter clean
rm -rf .dart_tool/ pubspec.lock
flutter pub get
```

### 2. `Could not find package "flutter_riverpod"`

ตรวจสอบ `pubspec.yaml` ว่า indent ถูกต้อง (Yaml ละเอียดเรื่อง space)

### 3. ฟอนต์ไม่แสดงเป็น Sarabun

- ตรวจสอบไฟล์ใน `assets/fonts/` ครบ 4 ไฟล์
- ชื่อไฟล์ตรง spelling ใน `pubspec.yaml` (case-sensitive!)
- รัน `flutter clean && flutter pub get` แล้ว run ใหม่

### 4. iOS Build Error: "CocoaPods not found"

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### 5. Android Build Error: "Unable to find Gradle"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

### 6. `dart run build_runner build` Error

```bash
# Force clean + retry
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### 7. Hot Reload ไม่ทำงาน

ลอง Hot Restart แทน (กด `R` ตัวใหญ่)
ถ้ายังไม่ได้ → Full Restart: หยุดแล้วรัน `flutter run` ใหม่

### 8. แอปแสดงเป็นภาษาอังกฤษทั้งหมด

ตรวจสอบ:
- `lib/l10n/app_th.arb` มีอยู่
- รัน `dart run build_runner build` แล้ว
- iOS Simulator: Settings → General → Language → Thai
- Android Emulator: Settings → System → Languages → Thai

### 9. White screen ตอนเปิดแอป

ดู console log มี error อะไร — มักเป็น initialization failure
ลอง:
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -v   # verbose mode
```

### 10. Xcode Signing Error

- เปิด `ios/Runner.xcworkspace` (ไม่ใช่ .xcodeproj)
- Runner target → Signing & Capabilities
- เลือก Team (Apple ID ฟรี ก็ได้สำหรับ dev)
- Bundle Identifier ต้องไม่ซ้ำคนอื่น

---

## 🧹 Clean Build Commands

```bash
# ล้าง cache ของ Flutter
flutter clean

# ล้าง build artifacts
rm -rf build/

# ล้าง generated code
find . -name "*.g.dart" -delete
find . -name "*.freezed.dart" -delete

# ล้าง iOS pods
cd ios && pod deintegrate && pod install && cd ..

# Refresh ทั้งหมด
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
```

---

## 📞 ต้องการความช่วยเหลือ

- **GitHub Issues:** สำหรับ bug + feature request
- **Email:** support@moneydiary.app
- **Flutter Community (TH):** https://flutter.in.th/ *(ตัวอย่าง)*

---

**Next Step:** เมื่อ setup เสร็จ → ไป Batch 2 (Data Layer) ครับ
