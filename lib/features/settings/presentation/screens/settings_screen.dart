import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../services/preferences_service.dart';
import '../../../account/presentation/screens/account_list_screen.dart';
import '../../../category/presentation/screens/category_list_screen.dart';
import '../providers/backup_provider.dart';
import '../providers/biometric_provider.dart';

/// ──────────────────────────────────────────────────
/// Settings Screen — Batch 7 (full version)
/// ──────────────────────────────────────────────────
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: <Widget>[
          // ═══ การแสดงผล ═══
          const _SectionHeader(title: 'การแสดงผล'),
          const _ThemeTile(),
          const _LanguageTile(),

          const Divider(),

          // ═══ บัญชีและหมวด ═══
          const _SectionHeader(title: 'บัญชีและหมวด'),
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'จัดการบัญชี',
            subtitle: 'เพิ่ม / แก้ไข / เก็บถาวร',
            onTap: () => AccountListScreen.show(context),
          ),
          _SettingsTile(
            icon: Icons.category_outlined,
            title: 'จัดการหมวด',
            subtitle: 'หมวดเริ่มต้น + สร้างเอง',
            onTap: () => CategoryListScreen.show(context),
          ),

          const Divider(),

          // ═══ ข้อมูล ═══
          const _SectionHeader(title: 'ข้อมูลและสำรอง'),
          const _ExportTile(),
          const _ImportTile(),

          const Divider(),

          // ═══ ความปลอดภัย ═══
          const _SectionHeader(title: 'ความปลอดภัย'),
          const _BiometricTile(),

          const Divider(),

          // ═══ เกี่ยวกับ ═══
          const _SectionHeader(title: 'เกี่ยวกับ'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'เวอร์ชั่น',
            subtitle: '0.1.0 (MVP)',
            trailing: const SizedBox.shrink(),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'ความเป็นส่วนตัว',
            subtitle: 'ข้อมูลเก็บในเครื่องเท่านั้น',
            trailing: const SizedBox.shrink(),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
// Theme Tile
// ════════════════════════════════════════════════
class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);

    String label;
    IconData icon;
    switch (mode) {
      case ThemeMode.light:
        label = 'สว่าง';
        icon = Icons.light_mode_outlined;
      case ThemeMode.dark:
        label = 'มืด';
        icon = Icons.dark_mode_outlined;
      case ThemeMode.system:
        label = 'ตามระบบ';
        icon = Icons.brightness_auto_outlined;
    }

    return ListTile(
      leading: Icon(icon, color: context.colors.primary),
      title: const Text('ธีม'),
      subtitle: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemePicker(context, ref, mode),
    );
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              Text('เลือกธีม', style: ctx.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _themeOption(ctx, ref, ThemeMode.light, 'สว่าง',
                  Icons.light_mode_outlined, current),
              _themeOption(ctx, ref, ThemeMode.dark, 'มืด',
                  Icons.dark_mode_outlined, current),
              _themeOption(ctx, ref, ThemeMode.system, 'ตามระบบ',
                  Icons.brightness_auto_outlined, current),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    String label,
    IconData icon,
    ThemeMode current,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: mode == current
          ? Icon(Icons.check_circle, color: context.colors.primary)
          : null,
      onTap: () {
        ref.read(themeModeProvider.notifier).setMode(mode);
        Navigator.of(context).pop();
      },
    );
  }
}

// ════════════════════════════════════════════════
// Language Tile
// ════════════════════════════════════════════════
class _LanguageTile extends ConsumerWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = ref.watch(localeProvider);
    final String label = locale.languageCode == 'en' ? 'English' : 'ไทย';

    return ListTile(
      leading: Icon(Icons.language_outlined, color: context.colors.primary),
      title: const Text('ภาษา'),
      subtitle: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguagePicker(context, ref, locale),
    );
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    Locale current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              Text('เลือกภาษา', style: ctx.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _langOption(ctx, ref, 'th', 'ไทย', current),
              _langOption(ctx, ref, 'en', 'English', current),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _langOption(
    BuildContext context,
    WidgetRef ref,
    String code,
    String label,
    Locale current,
  ) {
    return ListTile(
      title: Text(label),
      trailing: code == current.languageCode
          ? Icon(Icons.check_circle, color: context.colors.primary)
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(code);
        Navigator.of(context).pop();
      },
    );
  }
}

// ════════════════════════════════════════════════
// Export Tile
// ════════════════════════════════════════════════
class _ExportTile extends ConsumerStatefulWidget {
  const _ExportTile();

  @override
  ConsumerState<_ExportTile> createState() => _ExportTileState();
}

class _ExportTileState extends ConsumerState<_ExportTile> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.upload_file_outlined, color: context.colors.primary),
      title: const Text('ส่งออกข้อมูล (CSV)'),
      subtitle: const Text('บันทึกไฟล์ / แชร์ / สำรอง'),
      trailing: _isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: _isExporting ? null : _export,
    );
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final Result<String> result =
        await ref.read(backupControllerProvider).exportAll();

    if (!mounted) return;
    setState(() => _isExporting = false);

    if (result.isSuccess) {
      final String path = result.dataOrNull!;
      await Share.shareXFiles(
        <XFile>[XFile(path)],
        subject: 'MoneyDiary Export',
        text: 'ข้อมูลรายรับ-รายจ่ายจาก MoneyDiary Thai',
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'ส่งออกล้มเหลว'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

// ════════════════════════════════════════════════
// Import Tile
// ════════════════════════════════════════════════
class _ImportTile extends ConsumerStatefulWidget {
  const _ImportTile();

  @override
  ConsumerState<_ImportTile> createState() => _ImportTileState();
}

class _ImportTileState extends ConsumerState<_ImportTile> {
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.download_outlined, color: context.colors.primary),
      title: const Text('นำเข้าข้อมูล (CSV)'),
      subtitle: const Text('กู้คืนจากไฟล์สำรอง'),
      trailing: _isImporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: _isImporting ? null : _import,
    );
  }

  Future<void> _import() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['csv'],
    );

    if (picked == null || picked.files.single.path == null) return;
    if (!mounted) return;

    setState(() => _isImporting = true);

    final String path = picked.files.single.path!;
    final Result<int> result =
        await ref.read(backupControllerProvider).importFromCsv(path);

    if (!mounted) return;
    setState(() => _isImporting = false);

    if (result.isSuccess) {
      final int count = result.dataOrNull!;
      messenger.showSnackBar(
        SnackBar(
          content: Text('นำเข้า $count รายการสำเร็จ'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'นำเข้าล้มเหลว'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

// ════════════════════════════════════════════════
// Biometric Tile
// ════════════════════════════════════════════════
class _BiometricTile extends ConsumerWidget {
  const _BiometricTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEnabled = ref.watch(biometricLockProvider);
    final AsyncValue<bool> availableAsync =
        ref.watch(biometricAvailableProvider);

    return availableAsync.when(
      data: (bool available) {
        if (!available) {
          return ListTile(
            leading: Icon(Icons.lock_outline,
                color: context.colors.onSurface.withValues(alpha: 0.4)),
            title: const Text('ล็อกแอปด้วย Face ID / Touch ID'),
            subtitle: const Text('อุปกรณ์นี้ไม่รองรับ'),
            enabled: false,
          );
        }

        return SwitchListTile(
          secondary: Icon(Icons.lock_outline, color: context.colors.primary),
          title: const Text('ล็อกแอปด้วย Face ID / Touch ID'),
          subtitle: const Text('ยืนยันตัวตนทุกครั้งที่เปิดแอป'),
          value: isEnabled,
          onChanged: (bool value) async {
            final messenger = ScaffoldMessenger.of(context);
            final bool ok = await ref
                .read(biometricLockProvider.notifier)
                .setEnabled(value);
            if (!ok && value) {
              messenger.showSnackBar(
                const SnackBar(content: Text('ยืนยันตัวตนไม่สำเร็จ')),
              );
            }
          },
        );
      },
      loading: () => const ListTile(
        leading: Icon(Icons.lock_outline),
        title: Text('ล็อกแอปด้วย Face ID / Touch ID'),
        trailing: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ════════════════════════════════════════════════
// Shared widgets
// ════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colors.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
