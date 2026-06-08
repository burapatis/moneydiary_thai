import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../services/backup/csv_backup_service.dart';
import '../../../../services/database/app_database.dart';
import '../../../../services/database/database_providers.dart';
import '../../../../services/preferences_service.dart';
import '../../../account/domain/entities/account.dart';
import '../../../category/domain/entities/category.dart';
import '../../../transaction/domain/entities/transaction.dart';

/// ──────────────────────────────────────────────────
/// Backup Provider — orchestrate export/import
/// ──────────────────────────────────────────────────

final Provider<CsvBackupService> csvBackupServiceProvider =
    Provider<CsvBackupService>((Ref ref) => CsvBackupService());

/// Controller สำหรับ backup operations
class BackupController {
  BackupController(this._ref);

  final Ref _ref;

  /// Export ทั้งหมดเป็น CSV → คืน file path
  Future<Result<String>> exportAll() async {
    final txRepo = _ref.read(transactionRepositoryProvider);
    final categoryRepo = _ref.read(categoryRepositoryProvider);
    final accountRepo = _ref.read(accountRepositoryProvider);
    final csvService = _ref.read(csvBackupServiceProvider);

    // ดึงข้อมูลทั้งหมด
    final txResult = await txRepo.getAll();
    if (txResult.isFailure) {
      return Result<String>.failure(
        txResult.failureOrNull ?? const UnknownFailure(message: 'export ล้มเหลว'),
      );
    }
    final List<Transaction> transactions = txResult.dataOrNull!;

    if (transactions.isEmpty) {
      return Result<String>.failure(
        const ValidationFailure(message: 'EXPORT_EMPTY'),
      );
    }

    final catResult = await categoryRepo.getAll(includeHidden: true);
    final List<Category> categories = catResult.dataOrNull ?? <Category>[];
    final Map<String, Category> categoryMap = <String, Category>{
      for (final Category c in categories) c.id: c,
    };

    final accResult = await accountRepo.getAll(includeArchived: true);
    final List<Account> accounts = accResult.dataOrNull ?? <Account>[];
    final Map<String, Account> accountMap = <String, Account>{
      for (final Account a in accounts) a.id: a,
    };

    return csvService.exportToCsv(
      transactions: transactions,
      categoryMap: categoryMap,
      accountMap: accountMap,
    );
  }

  /// Import จาก CSV file path
  /// คืนจำนวน transactions ที่ import สำเร็จ
  Future<Result<int>> importFromCsv(String filePath) async {
    final csvService = _ref.read(csvBackupServiceProvider);
    final txRepo = _ref.read(transactionRepositoryProvider);
    final categoryRepo = _ref.read(categoryRepositoryProvider);
    final accountRepo = _ref.read(accountRepositoryProvider);

    // 1. Parse CSV
    final parseResult = await csvService.parseCsv(filePath);
    if (parseResult.isFailure) {
      return Result<int>.failure(
        parseResult.failureOrNull ??
            const UnknownFailure(message: 'parse ล้มเหลว'),
      );
    }
    final List<ImportedRow> rows = parseResult.dataOrNull!;

    // 2. โหลด category + account ปัจจุบันเพื่อ match ตามชื่อ
    final categories =
        (await categoryRepo.getAll(includeHidden: true)).dataOrNull ??
            <Category>[];
    final accounts =
        (await accountRepo.getAll(includeArchived: true)).dataOrNull ??
            <Account>[];

    // map ชื่อ → id (lookup)
    final Map<String, String> categoryByName = <String, String>{
      for (final Category c in categories) c.nameTh: c.id,
    };
    final Map<String, String> accountByName = <String, String>{
      for (final Account a in accounts) a.name: a.id,
    };

    // default fallback ids (ถ้าหาไม่เจอ)
    final String? fallbackAccountId =
        accounts.isNotEmpty ? accounts.first.id : null;

    if (fallbackAccountId == null) {
      return Result<int>.failure(
        const ValidationFailure(message: 'ไม่พบบัญชีสำหรับ import'),
      );
    }

    // 3. Insert ทีละ row
    int successCount = 0;
    for (final ImportedRow row in rows) {
      // match category (ถ้าไม่เจอ → ข้าม row)
      final String? categoryId = categoryByName[row.categoryName];
      if (categoryId == null) continue;

      // match account (ถ้าไม่เจอ → ใช้ default)
      final String accountId =
          accountByName[row.accountName] ?? fallbackAccountId;

      final TransactionType type = TransactionType.fromString(row.type);
      final DateTime now = DateTime.now();

      final result = await txRepo.create(Transaction(
        id: '',
        accountId: accountId,
        categoryId: categoryId,
        amount: row.amount,
        type: type,
        date: row.date,
        note: row.note,
        createdAt: now,
        updatedAt: now,
      ));

      if (result.isSuccess) successCount++;
    }

    return Result<int>.success(successCount);
  }

  /// ลบข้อมูลทั้งหมด — transactions + accounts + categories แล้ว seed ใหม่
  Future<Result<void>> deleteAllData() async {
    try {
      final AppDatabase db = _ref.read(appDatabaseProvider);
      await db.resetAllUserData();

      final SharedPreferences prefs = _ref.read(sharedPreferencesProvider);
      await prefs.remove(AppConstants.prefKeyLastUsedCategoryId);
      await prefs.remove(AppConstants.prefKeyLastUsedAccountId);

      return Result<void>.success(null);
    } catch (e) {
      return Result<void>.failure(
        DatabaseFailure(message: 'ลบข้อมูลทั้งหมดล้มเหลว: $e'),
      );
    }
  }
}

final Provider<BackupController> backupControllerProvider =
    Provider<BackupController>((Ref ref) => BackupController(ref));
