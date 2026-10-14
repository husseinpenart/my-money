import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';

enum ContactFilter { all, demander, debtor }

enum ContactSort { newest, oldest, name, mostDebts }

class ContactModel {
  final String contactId;
  final String name;
  final String phoneNumber;
  final DateTime? createdAt;
  final List<SearchDebt> debts;
  bool get hasPhone => phoneNumber.trim().isNotEmpty;

  const ContactModel({
    required this.contactId,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
    required this.debts,
  });

  factory ContactModel.fromJson(Map<String, dynamic> j) => ContactModel(
    contactId: (j['contactId'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    phoneNumber: (j['phoneNumber'] ?? '').toString(),
    createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()),
    debts: ((j['debtReceivable'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SearchDebt.fromJson)
        .toList(),
  );

  int get unpaidCount => debts.where((d) => !d.payStatus).length;
  bool get hasUnpaidReceivable => debts.any((d) => !d.payStatus && !d.isDebt);
  bool get hasUnpaidDebt => debts.any((d) => !d.payStatus && d.isDebt);

  /// طلب پرداخت‌نشده منهای بدهی پرداخت‌نشده
  double get balance {
    var total = 0.0;
    for (final d in debts) {
      if (d.payStatus) continue;
      final v = parseAmount(d.wholePrice) ?? 0;
      total += d.isDebt ? -v : v;
    }
    return total;
  }
}

/// یک ردیف از مخاطبین گوشی

class ContactApiException implements Exception {
  final String message;
  ContactApiException(this.message);
  @override
  String toString() => message;
}

extension ContactSortX on ContactSort {
  String get label => switch (this) {
    ContactSort.newest => 'جدیدترین',
    ContactSort.oldest => 'قدیمی‌ترین',
    ContactSort.name => 'نام (الفبایی)',
    ContactSort.mostDebts => 'بیشترین تعداد رکورد',
  };

  String get apiKey => switch (this) {
    ContactSort.newest || ContactSort.oldest => 'createdAt',
    ContactSort.name => 'name',
    ContactSort.mostDebts => 'debtCount',
  };

  bool get desc => switch (this) {
    ContactSort.newest || ContactSort.mostDebts => true,
    ContactSort.oldest || ContactSort.name => false,
  };
}

class ContactStats {
  final int total, demanders, debtors;
  const ContactStats({
    required this.total,
    required this.demanders,
    required this.debtors,
  });
}
