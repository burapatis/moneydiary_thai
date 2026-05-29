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
          _SectionHeader(title: l10n.settingsSectionDisplay),
          const _ThemeTile(),
          const _LanguageTile(),

          const Divider(),

          // ═══ บัญชีและหมวด ═══
          _SectionHeader(title: l10n.settingsSectionAccountCategory),
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.settingsAccountManage,
            subtitle: l10n.settingsAccountManageSub,
            onTap: () => AccountListScreen.show(context),
          ),
          _SettingsTile(
            icon: Icons.category_outlined,
            title: l10n.settingsCategoryManage,
            subtitle: l10n.settingsCategoryManageSub,
            onTap: () => CategoryListScreen.show(context),
          ),

          const Divider(),

          // ═══ ข้อมูล ═══
          _SectionHeader(title: l10n.settingsSectionDataBackup),
          const _ExportTile(),
          const _ImportTile(),

          const Divider(),

          // ═══ ความปลอดภัย ═══
          _SectionHeader(title: l10n.settingsSectionSecurity),
          const _BiometricTile(),

          const Divider(),

          // ═══ เกี่ยวกับ ═══
          _SectionHeader(title: l10n.settingsAbout),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n.settingsVersion,
            subtitle: l10n.settingsVersionValue,
            trailing: const SizedBox.shrink(),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.settingsPrivacy,
            subtitle: l10n.settingsPrivacySub,
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeMode mode = ref.watch(themeModeProvider);

    String label;
    IconData icon;
    switch (mode) {
      case ThemeMode.light:
        label = l10n.settingsThemeLight;
        icon = Icons.light_mode_outlined;
      case ThemeMode.dark:
        label = l10n.settingsThemeDark;
        icon = Icons.dark_mode_outlined;
      case ThemeMode.system:
        label = l10n.settingsThemeSystem;
        icon = Icons.brightness_auto_outlined;
    }

    return ListTile(
      leading: Icon(icon, color: context.colors.primary),
      title: Text(l10n.settingsTheme),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(l10n.settingsChooseTheme, style: ctx.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _themeOption(ctx, ref, ThemeMode.light, l10n.settingsThemeLight,
                  Icons.light_mode_outlined, current),
              _themeOption(ctx, ref, ThemeMode.dark, l10n.settingsThemeDark,
                  Icons.dark_mode_outlined, current),
              _themeOption(ctx, ref, ThemeMode.system, l10n.settingsThemeSystem,
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale locale = ref.watch(localeProvider);
    final String label = locale.languageCode == 'en'
        ? l10n.settingsLanguageEnglish
        : l10n.settingsLanguageThai;

    return ListTile(
      leading: Icon(Icons.language_outlined, color: context.colors.primary),
      title: Text(l10n.settingsLanguage),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(l10n.settingsChooseLanguage, style: ctx.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _langOption(ctx, ref, 'th', l10n.settingsLanguageThai, current),
              _langOption(ctx, ref, 'en', l10n.settingsLanguageEnglish, current),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(Icons.upload_file_outlined, color: context.colors.primary),
      title: Text(l10n.settingsExportCsv),
      subtitle: Text(l10n.settingsExportSub),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(Icons.download_outlined, color: context.colors.primary),
      title: Text(l10n.settingsImportCsv),
      subtitle: Text(l10n.settingsImportSub),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isEnabled = ref.watch(biometricLockProvider);
    final AsyncValue<bool> availableAsync =
        ref.watch(biometricAvailableProvider);

    return availableAsync.when(
      data: (bool available) {
        if (!available) {
          return ListTile(
            leading: Icon(Icons.lock_outline,
                color: context.colors.onSurface.withValues(alpha: 0.4)),
            title: Text(l10n.settingsBiometricLock),
            subtitle: Text(l10n.settingsBiometricUnavailable),
            enabled: false,
          );
        }

        return SwitchListTile(
          secondary: Icon(Icons.lock_outline, color: context.colors.primary),
          title: Text(l10n.settingsBiometricLock),
          subtitle: Text(l10n.settingsBiometricSub),
          value: isEnabled,
          onChanged: (bool value) async {
            final messenger = ScaffoldMessenger.of(context);
            final bool ok = await ref
                .read(biometricLockProvider.notifier)
                .setEnabled(value);
            if (!ok && value) {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.settingsBiometricFailed)),
              );
            }
          },
        );
      },
      loading: () => ListTile(
        leading: const Icon(Icons.lock_outline),
        title: Text(l10n.settingsBiometricLock),
        trailing: const SizedBox(
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
