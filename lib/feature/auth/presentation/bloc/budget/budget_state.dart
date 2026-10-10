import 'package:money/feature/model/budget/budget_models.dart';

enum BudgetStatus { initial, loading, success, failure }

class BudgetFeedback {
  final String message;
  final bool isError;
  BudgetFeedback.success(this.message) : isError = false;
  BudgetFeedback.error(this.message) : isError = true;
}

class BudgetState {
  final BudgetStatus status;
  final int? cycle;
  final BudgetPlan? plan;
  final List<CycleSummary> history;
  final List<BudgetItem> items;
  final SalaryProfile? profile;
  final bool isSubmitting;

  /// با هر تغییر موفق زیاد می‌شود تا لیست هزینه‌ها دوباره لود شود
  final int version;
  final BudgetFeedback? feedback;
  final String? error;

  const BudgetState({
    this.status = BudgetStatus.initial,
    this.cycle,
    this.plan,
    this.history = const [],
    this.items = const [],
    this.profile,
    this.isSubmitting = false,
    this.version = 0,
    this.feedback,
    this.error,
  });

  BudgetState copyWith({
    BudgetStatus? status,
    int? cycle,
    bool resetCycle = false,
    BudgetPlan? plan,
    List<CycleSummary>? history,
    List<BudgetItem>? items,
    SalaryProfile? profile,
    bool? isSubmitting,
    int? version,
    BudgetFeedback? feedback,
    String? error,
    bool clearError = false,
  }) => BudgetState(
    status: status ?? this.status,
    cycle: resetCycle ? null : (cycle ?? this.cycle),
    plan: plan ?? this.plan,
    history: history ?? this.history,
    items: items ?? this.items,
    profile: profile ?? this.profile,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    version: version ?? this.version,
    feedback: feedback ?? this.feedback,
    error: clearError ? null : (error ?? this.error),
  );
}
