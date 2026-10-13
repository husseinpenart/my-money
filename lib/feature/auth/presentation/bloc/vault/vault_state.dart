import 'package:money/feature/model/vault/vault_models.dart';

enum VaultStatus { initial, loading, needsSetup, locked, unlocked, failure }

class VaultFeedback {
  final bool isError;
  final String message;

  const VaultFeedback._(this.isError, this.message);

  factory VaultFeedback.error(String message) => VaultFeedback._(true, message);

  factory VaultFeedback.success(String message) =>
      VaultFeedback._(false, message);
}

class VaultState {
  final VaultStatus status;
  final bool isBusy;

  final List<VaultEntry> entries;
  final Map<int, int> counts;

  final int total;
  final int pending;
  final bool syncing;
  final DateTime? lastSyncedAt;

  final String query;
  final VaultCategory? category;

  final VaultFeedback? feedback;
  final String? error;

  /// کلید بازیابی تازه‌ساخته‌شده؛ فقط یک‌بار نمایش داده می‌شود.
  final String? newRecoveryKey;

  const VaultState({
    this.status = VaultStatus.initial,
    this.isBusy = false,
    this.entries = const [],
    this.counts = const {},
    this.total = 0,
    this.pending = 0,
    this.syncing = false,
    this.lastSyncedAt,
    this.query = '',
    this.category,
    this.feedback,
    this.error,
    this.newRecoveryKey,
  });

  VaultState copyWith({
    VaultStatus? status,
    bool? isBusy,
    List<VaultEntry>? entries,
    Map<int, int>? counts,
    int? total,
    int? pending,
    bool? syncing,
    DateTime? lastSyncedAt,
    String? query,
    VaultCategory? category,
    bool clearCategory = false,
    VaultFeedback? feedback,
    bool clearFeedback = false,
    String? error,
    String? newRecoveryKey,
    bool clearRecoveryKey = false,
  }) {
    return VaultState(
      status: status ?? this.status,
      isBusy: isBusy ?? this.isBusy,
      entries: entries ?? this.entries,
      counts: counts ?? this.counts,
      total: total ?? this.total,
      pending: pending ?? this.pending,
      syncing: syncing ?? this.syncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      error: clearFeedback ? null : (error ?? this.error),
      newRecoveryKey: clearRecoveryKey
          ? null
          : (newRecoveryKey ?? this.newRecoveryKey),
    );
  }
}
