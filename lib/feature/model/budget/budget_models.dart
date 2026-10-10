import 'package:flutter/material.dart';
import 'package:money/widgets/report/report_format.dart';

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
Map<String, dynamic> _m(dynamic v) =>
    v is Map<String, dynamic> ? v : <String, dynamic>{};
List<Map<String, dynamic>> _l(dynamic v) =>
    ((v as List?) ?? []).whereType<Map<String, dynamic>>().toList();
DateTime? _dt(dynamic v) => DateTime.tryParse('${v ?? ''}');

class BudgetApiException implements Exception {
  final String message;
  BudgetApiException(this.message);
  @override
  String toString() => message;
}

String cycleLabel(int key) => '${kMonthNames[key % 12]} ${fa('${key ~/ 12}')}';

// ───────────────────── دسته‌ها ─────────────────────
class BudgetCategory {
  final String key, label;
  final IconData icon;
  final Color color;
  const BudgetCategory(this.key, this.label, this.icon, this.color);

  static const all = <BudgetCategory>[
    BudgetCategory(
      'Utilities',
      'آب، برق و گاز',
      Icons.bolt_rounded,
      Color(0xFF0EA5E9),
    ),
    BudgetCategory(
      'Insurance',
      'بیمه',
      Icons.shield_outlined,
      Color(0xFF6366F1),
    ),
    BudgetCategory(
      'Car',
      'خودرو',
      Icons.directions_car_filled_outlined,
      Color(0xFFF97316),
    ),
    BudgetCategory(
      'Groceries',
      'خرید خانه',
      Icons.shopping_basket_outlined,
      Color(0xFF10B981),
    ),
    BudgetCategory(
      'Home',
      'منزل و لوازم',
      Icons.chair_outlined,
      Color(0xFF8B5CF6),
    ),
    BudgetCategory(
      'Rent',
      'اجاره و مسکن',
      Icons.home_work_outlined,
      Color(0xFF14B8A6),
    ),
    BudgetCategory(
      'Installment',
      'قسط و وام',
      Icons.account_balance_outlined,
      Color(0xFFEF4444),
    ),
    BudgetCategory(
      'Health',
      'درمان',
      Icons.medical_services_outlined,
      Color(0xFFEC4899),
    ),
    BudgetCategory(
      'Education',
      'آموزش',
      Icons.school_outlined,
      Color(0xFF3B82F6),
    ),
    BudgetCategory(
      'Fun',
      'تفریح',
      Icons.celebration_outlined,
      Color(0xFFF59E0B),
    ),
    BudgetCategory(
      'Savings',
      'پس‌انداز',
      Icons.savings_outlined,
      Color(0xFF059669),
    ),
    BudgetCategory('Other', 'سایر', Icons.category_outlined, Color(0xFF64748B)),
  ];

  static BudgetCategory of(String key) =>
      all.firstWhere((c) => c.key == key, orElse: () => all.last);
}

const Map<int, String> kFrequencies = {
  1: 'هر ماه',
  2: 'هر ۲ ماه',
  3: 'هر ۳ ماه',
  4: 'هر ۴ ماه',
  6: 'هر ۶ ماه',
  12: 'سالانه',
};

// ───────────────────── حقوق ─────────────────────
class SalaryProfile {
  final String title;
  final double amount;
  final int payDay;
  const SalaryProfile({
    required this.title,
    required this.amount,
    required this.payDay,
  });

  factory SalaryProfile.fromJson(Map<String, dynamic> j) => SalaryProfile(
    title: (j['title'] ?? 'حقوق').toString(),
    amount: _d(j['amount']),
    payDay: _i(j['payDay']),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'payDay': payDay,
  };
}

// ───────────────────── آیتم بودجه ─────────────────────
class BudgetItem {
  final String? itemId;
  final String name, category;
  final double plannedAmount;
  final bool isFixed;
  final int frequencyMonths, startKey, dueDay;

  const BudgetItem({
    this.itemId,
    required this.name,
    required this.category,
    required this.plannedAmount,
    this.isFixed = true,
    this.frequencyMonths = 1,
    this.startKey = 0,
    this.dueDay = 1,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> j) => BudgetItem(
    itemId: j['itemId']?.toString(),
    name: (j['name'] ?? '').toString(),
    category: (j['category'] ?? 'Other').toString(),
    plannedAmount: _d(j['plannedAmount']),
    isFixed: j['isFixed'] != false,
    frequencyMonths: _i(j['frequencyMonths']).clamp(1, 12),
    startKey: _i(j['startKey']),
    dueDay: _i(j['dueDay']).clamp(1, 31),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'plannedAmount': plannedAmount,
    'isFixed': isFixed,
    'frequencyMonths': frequencyMonths,
    'startKey': startKey,
    'dueDay': dueDay,
  };
}

// ───────────────────── برنامه‌ی دوره ─────────────────────
class PlanItem {
  final String itemId, name, category, status;
  final bool isFixed;
  final double planned, spent;
  final DateTime? dueDate;
  const PlanItem({
    required this.itemId,
    required this.name,
    required this.category,
    required this.status,
    required this.isFixed,
    required this.planned,
    required this.spent,
    required this.dueDate,
  });

  factory PlanItem.fromJson(Map<String, dynamic> j) => PlanItem(
    itemId: (j['itemId'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    category: (j['category'] ?? 'Other').toString(),
    status: (j['status'] ?? 'pending').toString(),
    isFixed: j['isFixed'] != false,
    planned: _d(j['planned']),
    spent: _d(j['spent']),
    dueDate: _dt(j['dueDate']),
  );

  double get remaining => (planned - spent) < 0 ? 0 : planned - spent;
}

class CategoryTotal {
  final String category;
  final double planned, spent;
  const CategoryTotal({
    required this.category,
    required this.planned,
    required this.spent,
  });
  factory CategoryTotal.fromJson(Map<String, dynamic> j) => CategoryTotal(
    category: (j['category'] ?? 'Other').toString(),
    planned: _d(j['planned']),
    spent: _d(j['spent']),
  );
}

class BudgetPlan {
  final bool needsSetup, isCurrent, salaryConfirmed, awaitingSalary;
  final int cycleKey, pendingKey, totalDays, daysLeft, lateDays;
  final DateTime? start, end;
  final String salaryTitle;
  final double salary,
      committed,
      spent,
      unplanned,
      free,
      remaining,
      dailyAllowance;
  final double carryDeficit, leftover;
  final double? projectedBalance;
  final List<PlanItem> items;
  final List<CategoryTotal> categories;
  final List<PlanWarning> warnings;

  const BudgetPlan({
    required this.needsSetup,
    required this.isCurrent,
    required this.salaryConfirmed,
    required this.awaitingSalary,
    required this.cycleKey,
    required this.pendingKey,
    required this.totalDays,
    required this.daysLeft,
    required this.lateDays,
    required this.start,
    required this.end,
    required this.salaryTitle,
    required this.salary,
    required this.committed,
    required this.spent,
    required this.unplanned,
    required this.free,
    required this.remaining,
    required this.dailyAllowance,
    required this.carryDeficit,
    required this.leftover,
    required this.projectedBalance,
    required this.items,
    required this.categories,
    required this.warnings,
  });

  factory BudgetPlan.fromJson(Map<String, dynamic> j) => BudgetPlan(
    needsSetup: j['needsSetup'] == true,
    isCurrent: j['isCurrent'] != false,
    salaryConfirmed: j['salaryConfirmed'] == true,
    awaitingSalary: j['awaitingSalary'] == true,
    cycleKey: _i(j['cycleKey']),
    pendingKey: _i(j['pendingKey']),
    totalDays: _i(j['totalDays']),
    daysLeft: _i(j['daysLeft']),
    lateDays: _i(j['lateDays']),
    start: _dt(j['start']),
    end: _dt(j['end']),
    salaryTitle: (j['salaryTitle'] ?? 'حقوق').toString(),
    salary: _d(j['salary']),
    committed: _d(j['committed']),
    spent: _d(j['spent']),
    unplanned: _d(j['unplanned']),
    free: _d(j['free']),
    remaining: _d(j['remaining']),
    dailyAllowance: _d(j['dailyAllowance']),
    carryDeficit: _d(j['carryDeficit']),
    leftover: _d(j['leftover']),
    projectedBalance: j['projectedBalance'] == null
        ? null
        : _d(j['projectedBalance']),
    items: _l(j['items']).map(PlanItem.fromJson).toList(),
    categories: _l(j['categories']).map(CategoryTotal.fromJson).toList(),
    warnings: _l(j['warnings']).map(PlanWarning.fromJson).toList(),
  );
}

class CycleSummary {
  final int cycleKey, count;
  final DateTime? start, end;
  final double salary, spent, saved;
  final bool estimated;
  final List<CategoryTotal> top;
  final int shiftDays;
  const CycleSummary({
    required this.cycleKey,
    required this.count,
    required this.start,
    required this.end,
    required this.salary,
    required this.spent,
    required this.saved,
    required this.estimated,
    required this.top,
    required this.shiftDays,
  });

  factory CycleSummary.fromJson(Map<String, dynamic> j) => CycleSummary(
    cycleKey: _i(j['cycleKey']),
    count: _i(j['count']),
    start: _dt(j['start']),
    end: _dt(j['end']),
    salary: _d(j['salary']),
    spent: _d(j['spent']),
    saved: _d(j['saved']),
    estimated: j['estimated'] == true,
    top: _l(j['topCategories']).map(CategoryTotal.fromJson).toList(),
    shiftDays: _i(j['shiftDays']),
  );
}

class ExpenseModel {
  final String expenseId, title, category;
  final String? budgetItemId, budgetItemName, note;
  final double amount;
  final DateTime? date;
  const ExpenseModel({
    required this.expenseId,
    required this.title,
    required this.category,
    required this.budgetItemId,
    required this.budgetItemName,
    required this.note,
    required this.amount,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> j) => ExpenseModel(
    expenseId: (j['expenseId'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    category: (j['category'] ?? 'Other').toString(),
    budgetItemId: j['budgetItemId']?.toString(),
    budgetItemName: j['budgetItemName']?.toString(),
    note: j['note']?.toString(),
    amount: _d(j['amount']),
    date: _dt(j['date']),
  );
}

class PlanWarning {
  final String code, severity;
  final double? amount;
  final int? count;
  final String? name;
  const PlanWarning({
    required this.code,
    required this.severity,
    this.amount,
    this.count,
    this.name,
  });

  factory PlanWarning.fromJson(Map<String, dynamic> j) => PlanWarning(
    code: (j['code'] ?? '').toString(),
    severity: (j['severity'] ?? 'info').toString(),
    amount: j['amount'] == null ? null : _d(j['amount']),
    count: j['count'] == null ? null : _i(j['count']),
    name: j['name']?.toString(),
  );
}
