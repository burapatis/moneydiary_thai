import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/account/data/repositories/account_repository_impl.dart';
import '../../features/account/domain/repositories/account_repository.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/transaction/data/repositories/transaction_repository_impl.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import 'app_database.dart';

/// ──────────────────────────────────────────────────
/// Database Providers — Riverpod registrations
/// ──────────────────────────────────────────────────
/// AppDatabase + 3 Repositories
///
/// ใช้ Provider (sync, ไม่ async) เพราะ AppDatabase initialize ใน main.dart
/// ก่อน runApp
/// ──────────────────────────────────────────────────

/// AppDatabase — singleton ทั้งแอป
/// Override ใน main.dart เพื่อให้ ProviderScope ใช้ instance ที่ initialize แล้ว
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in main()');
});

/// Account Repository
final Provider<AccountRepository> accountRepositoryProvider =
    Provider<AccountRepository>((Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return AccountRepositoryImpl(db);
});

/// Category Repository
final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>((Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return CategoryRepositoryImpl(db);
});

/// Transaction Repository
final Provider<TransactionRepository> transactionRepositoryProvider =
    Provider<TransactionRepository>((Ref ref) {
  final AppDatabase db = ref.watch(appDatabaseProvider);
  return TransactionRepositoryImpl(db);
});
