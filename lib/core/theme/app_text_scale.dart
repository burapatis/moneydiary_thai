/// ขนาดตัวอักษรที่ผู้ใช้เลือกได้ (เหมาะกับผู้สูงวัย)
enum AppTextScale {
  normal,
  large,
  extraLarge,
}

extension AppTextScaleX on AppTextScale {
  double get scaleFactor {
    switch (this) {
      case AppTextScale.normal:
        return 1.0;
      case AppTextScale.large:
        return 1.25;
      case AppTextScale.extraLarge:
        return 1.45;
    }
  }
}

AppTextScale parseAppTextScale(String? value) {
  switch (value) {
    case 'large':
      return AppTextScale.large;
    case 'extraLarge':
      return AppTextScale.extraLarge;
    default:
      return AppTextScale.normal;
  }
}
