
import 'package:money/feature/model/DebtReceviable/cover_image.dart';

class DebtFormData {
  final String? payId; // فقط ویرایش
  final String contactId;
  final String recordType; // Debt | Receivable
  final String wholePrice; // فقط رقم
  final DateTime registerdDate;
  final DateTime endedDate;
  final String? description;
  final bool payStatus;
  final bool isStarred;
  final List<CoverImage> newCovers; // فقط تصاویر جدید

  const DebtFormData({
    this.payId,
    required this.contactId,
    required this.recordType,
    required this.wholePrice,
    required this.registerdDate,
    required this.endedDate,
    this.description,
    this.payStatus = false,
    this.isStarred = false,
    this.newCovers = const [],
  });
}

class DebtApiException implements Exception {
  final String message;
  DebtApiException(this.message);
  @override
  String toString() => message;
}