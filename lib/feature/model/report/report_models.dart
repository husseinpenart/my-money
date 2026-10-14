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

// ───────────────────── بدهی و طلب ─────────────────────
class ReportSummary {
  final double totalDebt,
      totalReceivable,
      paidDebt,
      paidReceivable,
      unpaidDebt,
      unpaidReceivable,
      overdueDebt,
      overdueReceivable,
      dueSoonDebt,
      dueSoonReceivable;
  final int recordCount,
      debtCount,
      receivableCount,
      paidCount,
      unpaidCount,
      overdueCount,
      starredCount,
      contactCount,
      invalidAmountCount,
      dueSoonDebtCount,
      dueSoonReceivableCount;

  const ReportSummary({
    required this.totalDebt,
    required this.totalReceivable,
    required this.paidDebt,
    required this.paidReceivable,
    required this.unpaidDebt,
    required this.unpaidReceivable,
    required this.overdueDebt,
    required this.overdueReceivable,
    required this.dueSoonDebt,
    required this.dueSoonReceivable,
    required this.recordCount,
    required this.debtCount,
    required this.receivableCount,
    required this.paidCount,
    required this.unpaidCount,
    required this.overdueCount,
    required this.starredCount,
    required this.contactCount,
    required this.invalidAmountCount,
    required this.dueSoonDebtCount,
    required this.dueSoonReceivableCount,
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
    dueSoonDebt: _d(j['dueSoonDebt']),
    dueSoonReceivable: _d(j['dueSoonReceivable']),
    recordCount: _i(j['recordCount']),
    debtCount: _i(j['debtCount']),
    receivableCount: _i(j['receivableCount']),
    paidCount: _i(j['paidCount']),
    unpaidCount: _i(j['unpaidCount']),
    overdueCount: _i(j['overdueCount']),
    starredCount: _i(j['starredCount']),
    contactCount: _i(j['contactCount']),
    invalidAmountCount: _i(j['invalidAmountCount']),
    dueSoonDebtCount: _i(j['dueSoonDebtCount']),
    dueSoonReceivableCount: _i(j['dueSoonReceivableCount']),
  );

  double get net => unpaidReceivable - unpaidDebt;
  double? get collectionRate =>
      totalReceivable <= 0 ? null : paidReceivable / totalReceivable;
  double? get repaymentRate => totalDebt <= 0 ? null : paidDebt / totalDebt;
  double get dueSoonNet => dueSoonReceivable - dueSoonDebt;
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

// ───────────────────── حقوق و هزینه ─────────────────────
class ReportBudgetCycle {
  final int cycleKey, count;
  final DateTime? start;
  final double salary, spent;
  final bool estimated;
  const ReportBudgetCycle({
    required this.cycleKey,
    required this.count,
    required this.start,
    required this.salary,
    required this.spent,
    required this.estimated,
  });
  factory ReportBudgetCycle.fromJson(Map<String, dynamic> j) =>
      ReportBudgetCycle(
        cycleKey: _i(j['cycleKey']),
        count: _i(j['count']),
        start: DateTime.tryParse('${j['start']}'),
        salary: _d(j['salary']),
        spent: _d(j['spent']),
        estimated: j['estimated'] == true,
      );
}

class ReportCategoryAmount {
  final String category;
  final double amount, share;
  final int count;
  const ReportCategoryAmount({
    required this.category,
    required this.amount,
    required this.share,
    required this.count,
  });
  factory ReportCategoryAmount.fromJson(Map<String, dynamic> j) =>
      ReportCategoryAmount(
        category: (j['category'] ?? 'Other').toString(),
        amount: _d(j['amount']),
        share: _d(j['share']),
        count: _i(j['count']),
      );
}

class ReportTopExpense {
  final String title, category;
  final double amount;
  final DateTime? date;
  const ReportTopExpense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });
  factory ReportTopExpense.fromJson(Map<String, dynamic> j) => ReportTopExpense(
    title: (j['title'] ?? '').toString(),
    category: (j['category'] ?? 'Other').toString(),
    amount: _d(j['amount']),
    date: DateTime.tryParse('${j['date']}'),
  );
}

class ReportBudget {
  final bool hasProfile;
  final double income, expense, saved, avgMonthlyIncome, avgMonthlyExpense;
  final double? savingsRate;
  final int cycleCount, estimatedCycles, expenseCount;
  final List<ReportBudgetCycle> cycles;
  final List<ReportCategoryAmount> categories;
  final List<ReportTopExpense> topExpenses;

  const ReportBudget({
    required this.hasProfile,
    required this.income,
    required this.expense,
    required this.saved,
    required this.avgMonthlyIncome,
    required this.avgMonthlyExpense,
    required this.savingsRate,
    required this.cycleCount,
    required this.estimatedCycles,
    required this.expenseCount,
    required this.cycles,
    required this.categories,
    required this.topExpenses,
  });

  factory ReportBudget.fromJson(Map<String, dynamic> j) => ReportBudget(
    hasProfile: j['hasProfile'] == true,
    income: _d(j['income']),
    expense: _d(j['expense']),
    saved: _d(j['saved']),
    avgMonthlyIncome: _d(j['avgMonthlyIncome']),
    avgMonthlyExpense: _d(j['avgMonthlyExpense']),
    savingsRate: j['savingsRate'] == null ? null : _d(j['savingsRate']),
    cycleCount: _i(j['cycleCount']),
    estimatedCycles: _i(j['estimatedCycles']),
    expenseCount: _i(j['expenseCount']),
    cycles: _l(j['cycles']).map(ReportBudgetCycle.fromJson).toList(),
    categories: _l(j['categories']).map(ReportCategoryAmount.fromJson).toList(),
    topExpenses: _l(j['topExpenses']).map(ReportTopExpense.fromJson).toList(),
  );
}

// ───────────────────── نکات و پیامدها ─────────────────────
class ReportInsight {
  final String code, severity;
  final double? amount, percent;
  final int? count;
  final String? name;
  const ReportInsight({
    required this.code,
    required this.severity,
    this.amount,
    this.percent,
    this.count,
    this.name,
  });
  factory ReportInsight.fromJson(Map<String, dynamic> j) => ReportInsight(
    code: (j['code'] ?? '').toString(),
    severity: (j['severity'] ?? 'info').toString(),
    amount: j['amount'] == null ? null : _d(j['amount']),
    percent: j['percent'] == null ? null : _d(j['percent']),
    count: j['count'] == null ? null : _i(j['count']),
    name: j['name']?.toString(),
  );
}

class ReportData {
  final DateTime? generatedAt, from, to;
  final ReportSummary summary;
  final List<ReportMonth> monthly;
  final List<ReportAging> aging;
  final List<ReportContact> topContacts;
  final ReportBudget budget;
  final List<ReportInsight> insights;

  const ReportData({
    required this.generatedAt,
    required this.from,
    required this.to,
    required this.summary,
    required this.monthly,
    required this.aging,
    required this.topContacts,
    required this.budget,
    required this.insights,
  });

  factory ReportData.fromJson(Map<String, dynamic> j) => ReportData(
    generatedAt: DateTime.tryParse('${j['generatedAt']}'),
    from: DateTime.tryParse('${j['from']}'),
    to: DateTime.tryParse('${j['to']}'),
    summary: ReportSummary.fromJson(_m(j['summary'])),
    monthly: _l(j['monthly']).map(ReportMonth.fromJson).toList(),
    aging: _l(j['aging']).map(ReportAging.fromJson).toList(),
    topContacts: _l(j['topContacts']).map(ReportContact.fromJson).toList(),
    budget: ReportBudget.fromJson(_m(j['budget'])),
    insights: _l(j['insights']).map(ReportInsight.fromJson).toList(),
  );
}
