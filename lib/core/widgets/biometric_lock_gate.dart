import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/providers/biometric_provider.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_spacing.dart';

/// ──────────────────────────────────────────────────
/// BiometricLockGate — บังคับ authenticate เมื่อเปิดแอป / กลับจาก background
/// ──────────────────────────────────────────────────
class BiometricLockGate extends ConsumerStatefulWidget {
  const BiometricLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends ConsumerState<BiometricLockGate>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_maybeLock(showOverlayFirst: true));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_maybeLock(showOverlayFirst: true));
    }
  }

  Future<void> _maybeLock({required bool showOverlayFirst}) async {
    final bool enabled = ref.read(biometricLockProvider);
    if (!enabled) {
      if (_isLocked && mounted) {
        setState(() => _isLocked = false);
      }
      return;
    }

    final bool available =
        await ref.read(biometricAvailableProvider.future);
    if (!available || !mounted) return;

    if (showOverlayFirst && mounted) {
      setState(() => _isLocked = true);
    }

    await _authenticate();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating || !mounted) return;
    _isAuthenticating = true;

    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool ok = await ref.read(biometricLockProvider.notifier).authenticate(
          reason: l10n.biometricAuthReasonUnlock,
        );

    _isAuthenticating = false;
    if (!mounted) return;

    if (ok) {
      setState(() => _isLocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(biometricLockProvider, (bool? previous, bool next) {
      if (next) {
        unawaited(_maybeLock(showOverlayFirst: true));
      } else if (_isLocked) {
        setState(() => _isLocked = false);
      }
    });

    final AppLocalizations l10n = AppLocalizations.of(context);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (_isLocked)
          ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.lock_outline,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.biometricLockTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.settingsBiometricSub,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton.icon(
                        onPressed: _authenticate,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(l10n.biometricUnlock),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
