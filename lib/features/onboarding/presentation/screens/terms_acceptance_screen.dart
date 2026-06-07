import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../services/preferences_service.dart';

/// โหมดแสดงผล — ครั้งแรก (ต้องยอมรับ) หรือ ทบทวน (จาก Settings)
enum TermsScreenMode { firstLaunch, review }

/// ──────────────────────────────────────────────────
/// TermsAcceptanceScreen — ยอมรับข้อตกลงก่อนใช้งาน
/// ──────────────────────────────────────────────────
class TermsAcceptanceScreen extends ConsumerStatefulWidget {
  const TermsAcceptanceScreen({
    super.key,
    this.mode = TermsScreenMode.firstLaunch,
  });

  final TermsScreenMode mode;

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => const TermsAcceptanceScreen(
          mode: TermsScreenMode.review,
        ),
      ),
    );
  }

  @override
  ConsumerState<TermsAcceptanceScreen> createState() =>
      _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends ConsumerState<TermsAcceptanceScreen> {
  bool _agreed = false;
  bool _isSubmitting = false;

  bool get _isReview => widget.mode == TermsScreenMode.review;

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).settingsOpenUrlFailed)),
      );
    }
  }

  Future<void> _accept() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    await ref.read(termsAcceptedProvider.notifier).accept();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: _isReview
          ? AppBar(title: Text(l10n.termsTitle))
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
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: Icon(
                          Icons.description_outlined,
                          size: 72,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Text(
                      l10n.termsTitle,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.termsIntro,
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _TermsBullet(text: l10n.termsBullet1),
                    _TermsBullet(text: l10n.termsBullet2),
                    _TermsBullet(text: l10n.termsBullet3),
                    _TermsBullet(text: l10n.termsBullet4),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.termsReadFull,
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () =>
                              _openUrl(EnvConfig.termsOfServiceUrl),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: Text(l10n.settingsTermsOfService),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _openUrl(EnvConfig.privacyPolicyUrl),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: Text(l10n.settingsPrivacyPolicy),
                        ),
                      ],
                    ),
                    if (!_isReview) ...<Widget>[
                      const SizedBox(height: AppSpacing.xl),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _agreed,
                        onChanged: (bool? value) =>
                            setState(() => _agreed = value ?? false),
                        title: Text(
                          l10n.termsAgreeCheckbox,
                          style: context.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _isReview
                  ? OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.guideCloseButton),
                    )
                  : FilledButton(
                      onPressed:
                          (_agreed && !_isSubmitting) ? _accept : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        textStyle: context.textTheme.titleMedium,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.termsAgreeButton),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsBullet extends StatelessWidget {
  const _TermsBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 8),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: context.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
