import '../../features/account/domain/entities/account.dart';
import '../../l10n/gen/app_localizations.dart';

/// แปลง AccountType เป็นข้อความตาม locale ปัจจุบัน
String accountTypeLabel(AppLocalizations l10n, AccountType type) {
  return switch (type) {
    AccountType.cash => l10n.accountTypeCash,
    AccountType.bank => l10n.accountTypeBank,
    AccountType.ewallet => l10n.accountTypeEwallet,
    AccountType.credit => l10n.accountTypeCredit,
    AccountType.other => l10n.accountTypeOther,
  };
}
