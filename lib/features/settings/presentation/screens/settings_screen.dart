import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../account/presentation/screens/account_list_screen.dart';
import '../../../category/presentation/screens/category_list_screen.dart';

/// ──────────────────────────────────────────────────
/// Settings Screen — Batch 4 version
/// ──────────────────────────────────────────────────
/// Phase 4 (Batch 4): ลิงก์ไปจัดการ Categories + Accounts
/// Phase 7 (Batch 7): เพิ่ม Theme, Language, Privacy, Backup
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
          // ─── ส่วน "บัญชี" ───
          _SectionHeader(title: 'บัญชี'),
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'จัดการบัญชี',
            subtitle: 'เพิ่ม / แก้ไข / เก็บถาวร',
            onTap: () => AccountListScreen.show(context),
          ),
          _SettingsTile(
            icon: Icons.category_outlined,
            title: 'จัดการหมวด',
            subtitle: 'หมวดเริ่มต้น 25 หมวด + สร้างเองได้',
            onTap: () => CategoryListScreen.show(context),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),

          // ─── ส่วน "เกี่ยวกับ" (placeholder ใน Batch ถัดไป) ───
          _SectionHeader(title: 'เกี่ยวกับ'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'เวอร์ชั่น',
            subtitle: '0.1.0',
            trailing: const SizedBox.shrink(),
          ),

          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'การตั้งค่าอื่นๆ จะเพิ่มใน Batch 7\n(Theme, Language, Backup, Privacy)',
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
