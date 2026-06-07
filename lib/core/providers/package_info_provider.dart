import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Package metadata จาก pubspec.yaml / platform bundle
final FutureProvider<PackageInfo> packageInfoProvider =
    FutureProvider<PackageInfo>((Ref ref) async {
  return PackageInfo.fromPlatform();
});
