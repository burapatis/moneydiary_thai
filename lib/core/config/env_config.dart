import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../constants/app_constants.dart';

/// ──────────────────────────────────────────────────
/// EnvConfig — อ่านค่าจาก .env พร้อม fallback จาก AppConstants
/// ──────────────────────────────────────────────────
abstract final class EnvConfig {
  EnvConfig._();

  static String get privacyPolicyUrl =>
      dotenv.maybeGet('PRIVACY_POLICY_URL') ?? AppConstants.urlPrivacyPolicy;

  static String get termsOfServiceUrl =>
      dotenv.maybeGet('TERMS_OF_SERVICE_URL') ?? AppConstants.urlTermsOfService;

  static String get supportHelpUrl =>
      dotenv.maybeGet('SUPPORT_HELP_URL') ?? AppConstants.urlSupportHelp;

  static String get supportEmail =>
      dotenv.maybeGet('SUPPORT_EMAIL') ?? AppConstants.urlSupport;
}
