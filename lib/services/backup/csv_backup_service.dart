import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/errors/failures.dart';
import '../../features/account/domain/entities/account.dart';
import '../../features/category/domain/entities/category.dart';
import '../../features/transaction/domain/entities/transaction.dart';

/// ──────────────────────────────────────────────────
/// CsvBackupService — Export / Import transactions เป็น CSV
/// ──────────────────────────────────────────────────
/// Format:
///   Date, Type, Amount, Category, Account, Note
///   2026-05-28 14:30, expense, 65, กาแฟ-ขนม, เงินสด, ลาเต้
///
/// ใช้สำหรับ:
///   - Backup ข้อมูลไว้ใน Files / iCloud / email
///   - ย้ายเครื่อง
///   - เปิดดูใน Excel / Google Sheets
/// ──────────────────────────────────────────────────
class CsvBackupService {
  /// CSV header columns
  static const List<String> _headers = <String>[
    'Date',
    'Type',
    'Amount',
    'Category',
    'Account',
    'Note',
  ];

  /// ────────────────
  /// EXPORT
  /// ────────────────
  /// สร้างไฟล์ CSV จาก transactions แล้วคืน path
  ///
  /// คืน Result พร้อม path ของไฟล์ที่สร้าง (ใน temp directory)
  /// caller จะนำไป share ผ่าน share_plus
  Future<Result<String>> exportToCsv({
    required List<Transaction> transactions,
    required Map<String, Category> categoryMap,
    required Map<String, Account> accountMap,
  }) async {
    try {
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

      // สร้าง rows
      final List<List<dynamic>> rows = <List<dynamic>>[
        _headers,
        ...transactions.map((Transaction tx) {
          final Category? cat = categoryMap[tx.categoryId];
          final Account? acc = accountMap[tx.accountId];
          return <dynamic>[
            dateFormat.format(tx.date),
            tx.type.name,
            tx.amount.toStringAsFixed(2),
            cat?.nameTh ?? 'unknown',
            acc?.name ?? 'unknown',
            tx.note ?? '',
          ];
        }),
      ];

      // แปลงเป็น CSV string
      final String csvData = const ListToCsvConverter().convert(rows);

      // เขียนไฟล์ใน temp directory
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filePath =
          '${tempDir.path}/moneydiary_export_$timestamp.csv';
      final File file = File(filePath);

      // เพิ่ม BOM เพื่อให้ Excel เปิดภาษาไทยถูก (UTF-8 BOM)
      await file.writeAsString('\uFEFF$csvData');

      return Result<String>.success(filePath);
    } catch (e) {
      return Result<String>.failure(
        FileFailure(message: 'ส่งออก CSV ล้มเหลว: $e'),
      );
    }
  }

  /// ────────────────
  /// IMPORT
  /// ────────────────
  /// อ่านไฟล์ CSV แล้ว parse เป็น list ของ ImportedTransaction
  ///
  /// หมายเหตุ: คืนข้อมูลดิบ — caller ต้อง match category/account
  /// แล้ว insert เอง (เพราะต้องสร้าง category/account ที่ขาดก่อน)
  Future<Result<List<ImportedRow>>> parseCsv(String filePath) async {
    try {
      final File file = File(filePath);
      if (!file.existsSync()) {
        return Result<List<ImportedRow>>.failure(
          FileFailure(message: 'ไม่พบไฟล์'),
        );
      }

      String content = await file.readAsString();
      // ตัด BOM ออกถ้ามี
      if (content.startsWith('\uFEFF')) {
        content = content.substring(1);
      }

      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(content);

      if (rows.isEmpty) {
        return Result<List<ImportedRow>>.success(<ImportedRow>[]);
      }

      // ข้าม header (row แรก)
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      final List<ImportedRow> result = <ImportedRow>[];

      for (int i = 1; i < rows.length; i++) {
        final List<dynamic> row = rows[i];
        if (row.length < 5) continue; // skip malformed

        try {
          result.add(ImportedRow(
            date: dateFormat.parse(row[0].toString()),
            type: row[1].toString(),
            amount: double.parse(row[2].toString()),
            categoryName: row[3].toString(),
            accountName: row[4].toString(),
            note: row.length > 5 ? row[5].toString() : null,
          ));
        } catch (_) {
          // skip row ที่ parse ไม่ได้
          continue;
        }
      }

      return Result<List<ImportedRow>>.success(result);
    } catch (e) {
      return Result<List<ImportedRow>>.failure(
        FileFailure(message: 'นำเข้า CSV ล้มเหลว: $e'),
      );
    }
  }
}

/// ข้อมูล 1 แถวจาก CSV import (ยังไม่ match กับ DB ids)
class ImportedRow {
  ImportedRow({
    required this.date,
    required this.type,
    required this.amount,
    required this.categoryName,
    required this.accountName,
    this.note,
  });

  final DateTime date;
  final String type;
  final double amount;
  final String categoryName;
  final String accountName;
  final String? note;
}
