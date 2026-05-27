import 'package:equatable/equatable.dart';

/// ──────────────────────────────────────────────────
/// Failure — Base class สำหรับ business logic errors
/// ──────────────────────────────────────────────────
sealed class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => <Object?>[message, code];
}

/// ปัญหาจาก database
final class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

/// ปัญหาจาก validation (input ไม่ถูก)
final class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    this.field,
  });

  final String? field;

  @override
  List<Object?> get props => <Object?>[...super.props, field];
}

/// ไม่พบข้อมูล
final class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    required this.entity,
  });

  final String entity;

  @override
  List<Object?> get props => <Object?>[...super.props, entity];
}

/// permission / authorization
final class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}

/// ไม่คาดคิด - catch-all
final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}

/// ──────────────────────────────────────────────────
/// Result<T> — แทน throw exception ใน domain layer
/// ──────────────────────────────────────────────────
/// ใช้ผ่าน pattern matching:
///   final result = await useCase();
///   switch (result) {
///     case Success(:final data): // ...
///     case ResultFailure(:final failure): // ...
///   }
///
/// 🔧 FIX: เปลี่ยนจาก static method เป็น factory constructor
/// เพื่อให้ใช้ Result<Transaction>.success(...) ได้
/// ──────────────────────────────────────────────────
sealed class Result<T> {
  const Result();

  /// Factory constructor — สร้าง success
  /// เรียกแบบ: Result<Transaction>.success(myTransaction)
  factory Result.success(T data) = Success<T>;

  /// Factory constructor — สร้าง failure
  /// เรียกแบบ: Result<Transaction>.failure(myFailure)
  factory Result.failure(Failure failure) = ResultFailure<T>;

  /// ดึงค่าได้ถ้า success, otherwise null
  T? get dataOrNull => switch (this) {
        Success<T>(:final T data) => data,
        ResultFailure<T>() => null,
      };

  /// ดึง failure ถ้าเป็น failure, otherwise null
  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        ResultFailure<T>(:final Failure failure) => failure,
      };

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.data) : super();
  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure) : super();
  final Failure failure;
}
