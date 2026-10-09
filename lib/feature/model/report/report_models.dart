import 'package:persian_datetime_picker/persian_datetime_picker.dart';

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
Map<String, dynamic> _m(dynamic v) =>
    v is Map<String, dynamic> ? v : <String, dynamic>{};
List<Map<String, dynamic>> _l(dynamic v) =>
    ((v as List?) ?? []).whereType<Map<String, dynamic>>().toList();

class ReportApiException implements Exception {
  final String message;
  ReportApiException(this.message);
  @override
  String toString() => message;
}

// ───────────────────── بازه‌ی زمانی ─────────────────────
enum ReportPeriod { all, thisMonth, last30, last90, thisYear }

extension ReportPeriodX on ReportPeriod {
  String get label => switch (this) {
    ReportPeriod.all => 'همه',
    ReportPeriod.thisMonth => 'این ماه',
    ReportPeriod.last30 => '۳۰ روز اخیر',
    ReportPeriod.last90 => '۹۰ روز اخیر',
    ReportPeriod.thisYear => 'امسال',
  };

  static DateTime _utc(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  DateTime? get from {
    final j = Jalali.now();
    return switch (this) {
      ReportPeriod.all => null,
      ReportPeriod.thisMonth => _utc(Jalali(j.year, j.month, 1).toDateTime()),
      ReportPeriod.last30 => _utc(
        DateTime.now().subtract(const Duration(days: 30)),
      ),
      ReportPeriod.last90 => _utc(
        DateTime.now().subtract(const Duration(days: 90)),
      ),
      ReportPeriod.thisYear => _utc(Jalali(j.year, 1, 1).toDateTime()),
    };
  }

  DateTime? get to {
    final j = Jalali.now();
    return switch (this) {
      ReportPeriod.thisMonth => _utc(
        Jalali(j.year, j.month, j.monthLength).toDateTime(),
      ),
      ReportPeriod.thisYear => _utc(
        Jalali(j.year, 12, Jalali(j.year, 12, 1).monthLength).toDateTime(),
      ),
      _ => null,
    };
  }
}

// ───────────────────── مدل‌های پاسخ ─────────────────────
class ReportSummary {
  final double totalDebt,
      totalReceivable,
      paidDebt,
      paidReceivable,
      unpaidDebt,
      unpaidReceivable,
      overdueDebt,
      overdueReceivable;
  final int recordCount,
      debtCount,
      receivableCount,
      paidCount,
      unpaidCount,
      overdueCount,
      starredCount,
      contactCount,
      invalidAmountCount;

  const ReportSummary({
    required this.totalDebt,
    required this.totalReceivable,
    required this.paidDebt,
    required this.paidReceivable,
    required this.unpaidDebt,
    required this.unpaidReceivable,
    required this.overdueDebt,
    required this.overdueReceivable,
    required this.recordCount,
    required this.debtCount,
    required this.receivableCount,
    required this.paidCount,
    required this.unpaidCount,
    required this.overdueCount,
    required this.starredCount,
    required this.contactCount,
    required this.invalidAmountCount,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> j) => ReportSummary(
    totalDebt: _d(j['totalDebt']),
    totalReceivable: _d(j['totalReceivable']),
    paidDebt: _d(j['paidDebt']),
    paidReceivable: _d(j['paidReceivable']),
    unpaidDebt: _d(j['unpaidDebt']),
    unpaidReceivable: _d(j['unpaidReceivable']),
    overdueDebt: _d(j['overdueDebt']),
    overdueReceivable: _d(j['overdueReceivable']),
    recordCount: _i(j['recordCount']),
    debtCount: _i(j['debtCount']),
    receivableCount: _i(j['receivableCount']),
    paidCount: _i(j['paidCount']),
    unpaidCount: _i(j['unpaidCount']),
    overdueCount: _i(j['overdueCount']),
    starredCount: _i(j['starredCount']),
    contactCount: _i(j['contactCount']),
    invalidAmountCount: _i(j['invalidAmountCount']),
  );

  /// طلب باقی‌مانده منهای بدهی باقی‌مانده
  double get net => unpaidReceivable - unpaidDebt;
  double? get collectionRate =>
      totalReceivable <= 0 ? null : paidReceivable / totalReceivable;
  double? get repaymentRate => totalDebt <= 0 ? null : paidDebt / totalDebt;
}

class ReportMonth {
  final int year, month, count;
  final double debt, receivable;
  const ReportMonth({
    required this.year,
    required this.month,
    required this.count,
    required this.debt,
    required this.receivable,
  });
  factory ReportMonth.fromJson(Map<String, dynamic> j) => ReportMonth(
    year: _i(j['year']),
    month: _i(j['month']),
    count: _i(j['count']),
    debt: _d(j['debt']),
    receivable: _d(j['receivable']),
  );
}

class ReportAging {
  final String key;
  final int count;
  final double debt, receivable;
  const ReportAging({
    required this.key,
    required this.count,
    required this.debt,
    required this.receivable,
  });
  factory ReportAging.fromJson(Map<String, dynamic> j) => ReportAging(
    key: (j['key'] ?? '').toString(),
    count: _i(j['count']),
    debt: _d(j['debt']),
    receivable: _d(j['receivable']),
  );
  double get total => debt + receivable;
}

class ReportContact {
  final String contactId, name, phoneNumber;
  final double unpaidDebt, unpaidReceivable;
  final int unpaidCount;
  const ReportContact({
    required this.contactId,
    required this.name,
    required this.phoneNumber,
    required this.unpaidDebt,
    required this.unpaidReceivable,
    required this.unpaidCount,
  });
  factory ReportContact.fromJson(Map<String, dynamic> j) => ReportContact(
    contactId: (j['contactId'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    phoneNumber: (j['phoneNumber'] ?? '').toString(),
    unpaidDebt: _d(j['unpaidDebt']),
    unpaidReceivable: _d(j['unpaidReceivable']),
    unpaidCount: _i(j['unpaidCount']),
  );
  double get net => unpaidReceivable - unpaidDebt;
}

class ReportData {
  final DateTime? generatedAt;
  final DateTime? from, to;
  final ReportSummary summary;
  final List<ReportMonth> monthly;
  final List<ReportAging> aging;
  final List<ReportContact> topContacts;

  const ReportData({
    required this.generatedAt,
    required this.from,
    required this.to,
    required this.summary,
    required this.monthly,
    required this.aging,
    required this.topContacts,
  });

  factory ReportData.fromJson(Map<String, dynamic> j) => ReportData(
    generatedAt: DateTime.tryParse('${j['generatedAt']}'),
    from: DateTime.tryParse('${j['from']}'),
    to: DateTime.tryParse('${j['to']}'),
    summary: ReportSummary.fromJson(_m(j['summary'])),
    monthly: _l(j['monthly']).map(ReportMonth.fromJson).toList(),
    aging: _l(j['aging']).map(ReportAging.fromJson).toList(),
    topContacts: _l(j['topContacts']).map(ReportContact.fromJson).toList(),
  );
}
