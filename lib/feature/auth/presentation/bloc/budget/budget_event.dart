import 'dart:async';

import 'package:money/feature/model/budget/budget_models.dart';

abstract class BudgetEvent {
  const BudgetEvent();
}

class BudgetRefreshed extends BudgetEvent {
  final Completer<void>? done;
  const BudgetRefreshed({this.done});
}

/// null یعنی دوره‌ی جاری
class BudgetCycleSelected extends BudgetEvent {
  final int? key;
  const BudgetCycleSelected(this.key);
}

class BudgetProfileSaved extends BudgetEvent {
  final SalaryProfile profile;
  const BudgetProfileSaved(this.profile);
}

class BudgetSalaryConfirmed extends BudgetEvent {
  final double amount;
  final int cycleKey;
  final DateTime date;
  const BudgetSalaryConfirmed({
    required this.amount,
    required this.cycleKey,
    required this.date,
  });
}

class BudgetItemSaved extends BudgetEvent {
  final BudgetItem item;
  const BudgetItemSaved(this.item);
}

class BudgetItemDeleted extends BudgetEvent {
  final String id;
  const BudgetItemDeleted(this.id);
}

class BudgetExpenseAdded extends BudgetEvent {
  final String? itemId, title, note;
  final String category;
  final double amount;
  final DateTime date;
  const BudgetExpenseAdded({
    this.itemId,
    this.title,
    this.note,
    required this.category,
    required this.amount,
    required this.date,
  });
}

class BudgetExpenseDeleted extends BudgetEvent {
  final String id;
  const BudgetExpenseDeleted(this.id);
}
