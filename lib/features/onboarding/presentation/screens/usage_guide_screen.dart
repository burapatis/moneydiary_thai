import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../services/preferences_service.dart';

/// โหมดแสดงผล — ครั้งแรก (ต้องรับทราบ) หรือ ทบทวน (จาก Settings)
enum UsageGuideMode { firstLaunch, review }

/// ──────────────────────────────────────────────────
/// UsageGuideScreen — คู่มือใช้งานง่าย สำหรับผู้สูงวัย / มือใหม่
/// ──────────────────────────────────────────────────
class UsageGuideScreen extends ConsumerStatefulWidget {
  const UsageGuideScreen({
    super.key,
    this.mode = UsageGuideMode.firstLaunch,
  });

  final UsageGuideMode mode;

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => const UsageGuideScreen(
          mode: UsageGuideMode.review,
        ),
      ),
    );
  }

  @override
  ConsumerState<UsageGuideScreen> createState() => _UsageGuideScreenState();
}

class _UsageGuideScreenState extends ConsumerState<UsageGuideScreen> {
  bool _isSubmitting = false;

  bool get _isReview => widget.mode == UsageGuideMode.review;

  Future<void> _acknowledge() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    await ref.read(usageGuideDoneProvider.notifier).markDone();
  }

  Future<void> _openOnlineHelp() async {
    final Uri uri = Uri.parse(EnvConfig.supportHelpUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).settingsOpenUrlFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final List<({IconData icon, String title, String body})> steps =
        <({IconData icon, String title, String body})>[
      (
        icon: Icons.add_circle_outline,
        title: l10n.guideStep1Title,
        body: l10n.guideStep1Body,
      ),
      (
        icon: Icons.category_outlined,
        title: l10n.guideStep2Title,
        body: l10n.guideStep2Body,
      ),
      (
        icon: Icons.payments_outlined,
        title: l10n.guideStep3Title,
        body: l10n.guideStep3Body,
      ),
      (
        icon: Icons.list_alt_outlined,
        title: l10n.guideStep4Title,
        body: l10n.guideStep4Body,
      ),
      (
        icon: Icons.settings_outlined,
        title: l10n.guideStep5Title,
        body: l10n.guideStep5Body,
      ),
    ];

    return Scaffold(
      appBar: _isReview
          ? AppBar(title: Text(l10n.guideTitle))
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!_isReview) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: Icon(
                          Icons.menu_book_outlined,
                          size: 72,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Text(
                      l10n.guideTitle,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.favorite_border,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.guideReassurance,
                              style: context.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ...List<Widget>.generate(steps.length, (int index) {
                      final step = steps[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _GuideStepCard(
                          stepNumber: index + 1,
                          icon: step.icon,
                          title: step.title,
                          body: step.body,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _openOnlineHelp,
                    icon: const Icon(Icons.open_in_new),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    label: Text(l10n.guideOpenOnlineHelp),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _isReview
                      ? OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            textStyle: context.textTheme.titleMedium,
                          ),
                          child: Text(l10n.guideCloseButton),
                        )
                      : FilledButton(
                          onPressed: _isSubmitting ? null : _acknowledge,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            textStyle: context.textTheme.titleMedium,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.guideAcknowledgeButton),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStepCard extends StatelessWidget {
  const _GuideStepCard({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int stepNumber;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$stepNumber',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(icon, size: 22, color: context.colors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          title,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: context.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
