# 🤝 Contributing Guide

> มาตรฐานการเขียนโค้ดและ workflow สำหรับ MoneyDiary Thai

---

## 🎯 หลักการเขียนโค้ด

### SOLID + Clean Architecture
- **S**ingle Responsibility — class/function ทำเรื่องเดียวให้ดี
- **O**pen/Closed — ขยาย ไม่แก้
- **L**iskov Substitution — subclass แทน parent ได้เสมอ
- **I**nterface Segregation — interface เล็กดีกว่าใหญ่
- **D**ependency Inversion — depend on abstraction ไม่ใช่ concrete

### DRY, KISS, YAGNI
- อย่าเขียนซ้ำ
- ทำให้ง่ายที่สุด
- อย่าทำในสิ่งที่ยังไม่ต้องการ

### Layering Rules
```
presentation → domain → data
     ↑
ไม่อนุญาตให้ presentation รู้จัก data layer โดยตรง
ต้องผ่าน domain (use cases / repositories interfaces)
```

---

## 📝 Naming Conventions

### Files
- snake_case: `transaction_repository.dart`
- หลีกเลี่ยง abbreviation: `transaction` ไม่ใช่ `tx`

### Classes
- PascalCase: `TransactionRepository`
- Suffix ตาม role:
  - Screen: `HomeScreen`
  - Widget: `CategoryChip`
  - Provider: `TransactionsProvider` หรือ `transactionsProvider`
  - Repository: `TransactionRepository` (interface) / `TransactionRepositoryImpl` (impl)
  - UseCase: `AddTransactionUseCase`
  - Model/DTO: `TransactionModel`
  - Entity: `Transaction`

### Variables
- camelCase: `totalAmount`
- Private prefix `_`: `_calculateTotal()`
- Constants: `kPrimaryColor` หรือใน abstract final class

### Boolean
- ใช้ `is`, `has`, `should`, `can`: `isLoading`, `hasError`

---

## 🌐 Localization Rules

### ❌ ห้าม hardcode strings

```dart
// ❌ BAD
Text('บันทึก')

// ✅ GOOD
Text(AppLocalizations.of(context).commonSave)
// หรือใช้ context.l10n.commonSave (extension ใน batch ถัดไป)
```

### Key naming ใน .arb

- snake_case + namespace prefix: `transaction_add_title`
- เพิ่มทั้ง `app_th.arb` + `app_en.arb` พร้อมกัน

---

## 💬 Comments

ตามที่ master prompt ระบุ — **คอมเมนต์ภาษาไทยในจุดสำคัญ**

### เมื่อใดควรคอมเมนต์
- ✅ Business logic ซับซ้อน
- ✅ เหตุผลการตัดสินใจที่ไม่ obvious
- ✅ Workaround / hack ที่มี issue link
- ✅ Performance optimization
- ✅ Security consideration

### ไม่ต้องคอมเมนต์
- ❌ Code ที่อ่านเข้าใจอยู่แล้ว
- ❌ ระบุชื่อ function (ใช้ชื่อให้ดีแทน)

### ตัวอย่าง
```dart
// ✅ GOOD — อธิบาย "ทำไม"
// ใช้ #0A0A0A แทน #000000 เพื่อลด OLED burn-in
// ใน OLED screens สีดำสนิทเปิด pixel ไม่ทำงาน = burn pattern ติด
static const Color darkBg = Color(0xFF0A0A0A);

// ❌ BAD — อธิบาย "ทำอะไร" ซ้ำกับโค้ด
// set color to teal
static const Color primary = Color(0xFF0F766E);
```

---

## ✅ Linting Rules

```bash
# Run lint
flutter analyze

# Auto fix
dart fix --apply
```

ก่อน commit ต้อง **ไม่มี warning** ใดๆ

---

## 🧪 Testing Standards

### Coverage Target
- Domain (use cases): ≥ 90%
- Data (repositories): ≥ 80%
- Presentation: ≥ 60%
- **โดยรวม ≥ 70%**

### Test Naming
```dart
group('TransactionRepository', () {
  group('add', () {
    test('should save transaction successfully', () { ... });
    test('should throw DatabaseException when DB unavailable', () { ... });
    test('should validate amount > 0', () { ... });
  });
});
```

### File Naming
- `test/unit/features/transaction/domain/add_transaction_usecase_test.dart`
- ตรงโครงสร้างกับ source

### Mock with mocktail
```dart
class MockTransactionRepository extends Mock 
    implements TransactionRepository {}
```

---

## 📦 Git Workflow

### Branch Naming
```
feature/transaction-quick-add
fix/category-icon-not-loading
refactor/extract-amount-formatter
docs/update-readme
```

### Commit Messages (Conventional Commits)

```
<type>(<scope>): <subject>

<body (optional)>

<footer (optional)>
```

**Types:**
- `feat` — feature ใหม่
- `fix` — แก้ bug
- `refactor` — เปลี่ยนโค้ดโดยไม่เปลี่ยน behavior
- `style` — formatting only
- `docs` — เอกสาร
- `test` — เพิ่ม/แก้ test
- `chore` — config, deps, build
- `perf` — performance improvement
- `ci` — CI/CD changes

**Examples:**
```bash
feat(transaction): add quick-add bottom sheet
fix(category): icon not loading on Android
refactor(theme): extract design tokens to separate files
docs: update SETUP.md with font installation
test(formatters): cover Thai date formatting edge cases
chore(deps): upgrade flutter to 3.27
```

### PR Standards (สำหรับ solo dev — review ตัวเอง)
- Description มี screenshot/screen recording (ถ้าเปลี่ยน UI)
- Test ผ่านครบ
- Lint ผ่าน
- ไม่มี `print()` หรือ `TODO` ค้าง

---

## 🚦 Pre-Commit Checklist

ก่อน `git commit`:

- [ ] `flutter analyze` — ไม่มี warning
- [ ] `flutter test` — ผ่านครบ
- [ ] `dart format .` — format แล้ว
- [ ] ไม่มี `print()` debug
- [ ] ไม่มี `// TODO` (ถ้ามีก็ใส่ issue link `// TODO(#42): ...`)
- [ ] ไม่ commit `.env`, secrets, keys

---

## 🗂 Folder Conventions

### Feature folder structure
```
features/<feature_name>/
├── data/
│   ├── datasources/        # local + (Phase 2) remote
│   ├── models/             # DTO/JSON models
│   └── repositories/       # repository implementation
├── domain/
│   ├── entities/           # business entities (no Flutter import)
│   ├── repositories/       # repository interfaces
│   └── usecases/           # business logic
└── presentation/
    ├── screens/            # full screens
    ├── widgets/            # feature-specific widgets
    └── providers/          # Riverpod providers
```

### shared widgets
- ถ้าใช้แค่ feature เดียว → ใน `features/<x>/presentation/widgets/`
- ถ้าใช้ทั้ง app → `core/widgets/`

---

## 🔒 Security Guidelines

1. **ห้าม commit secrets** — ใช้ `.env` (อยู่ใน `.gitignore`)
2. **ห้าม log sensitive data** — ห้าม `print(transaction.amount)` ใน production
3. **ใช้ HTTPS เท่านั้น** — Phase 2 เมื่อมี API
4. **Validate input ทุก field**
5. **ใช้ secure storage** สำหรับ encryption keys + tokens

---

## 🎨 UI/UX Guidelines

- **ทุก touch target ≥ 44pt × 44pt**
- **ทุก color combo ต้อง pass WCAG AA**
- **ทุก icon ต้องมี semanticsLabel** ถ้ามีความหมาย
- **animation duration ≤ 300ms** (UX research)
- **ใช้ design tokens เสมอ** — `AppColors.primary` ไม่ใช่ `Color(0xFF0F766E)`
- **ใช้ AppSpacing** — `AppSpacing.md` ไม่ใช่ `16.0`

---

## 📚 Recommended Resources

- Flutter docs: https://docs.flutter.dev
- Riverpod: https://riverpod.dev
- Drift: https://drift.simonbinder.eu
- Effective Dart: https://dart.dev/effective-dart
- Clean Architecture: Robert C. Martin

---

**Thank you for contributing! 🙏**
