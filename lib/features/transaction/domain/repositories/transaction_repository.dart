import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';

/// ──────────────────────────────────────────────────
/// TransactionRepository — interface
/// ──────────────────────────────────────────────────
abstract interface class TransactionRepository {
  Future<Result<List<Transaction>>> getAll();

  Stream<List<Transaction>> watchAll();

  Future<Result<List<Transaction>>> getByDateRange({
    required DateTime from,
    required DateTime to,
  });

  Stream<List<Transaction>> watchByDateRange({
    required DateTime from,
    required DateTime to,
  });

  Future<Result<Transaction>> getById(String id);

  Future<Result<Transaction>> create(Transaction transaction);

  Future<Result<Transaction>> update(Transaction transaction);

  Future<Result<void>> delete(String id);

  /// Aggregated summary (income + expense) ในช่วงวันที่
  Future<Result<TransactionSummary>> getSummary({
    required DateTime from,
    required DateTime to,
  });

  /// Stream summary
  Stream<TransactionSummary> watchSummary({
    required DateTime from,
    required DateTime to,
  });

  /// Group by category
  Future<Result<Map<String, double>>> sumByCategory({
    required DateTime from,
    required DateTime to,
    TransactionType? type,
  });
}

/// ──────────────────────────────────────────────────
/// TransactionSummary — value object สรุปยอด
/// ──────────────────────────────────────────────────
class TransactionSummary {
  const TransactionSummary({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  double get net => income - expense;

  static const TransactionSummary zero =
      TransactionSummary(income: 0, expense: 0);
}
