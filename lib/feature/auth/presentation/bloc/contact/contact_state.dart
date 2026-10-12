import 'package:money/feature/model/contact/contact_model.dart';

enum ContactsStatus { initial, loading, success, failure }

class ContactFeedback {
  final String message;
  final bool isError;
  ContactFeedback.success(this.message) : isError = false;
  ContactFeedback.error(this.message) : isError = true;
}

class ContactState {
  final ContactsStatus status;
  final List<ContactModel> items;
  final int pageNumber, totalPages, totalItems;
  final bool isLoadingMore, isSubmitting;

  /// true یعنی در حال همگام‌سازی با سرور
  final bool isRefreshing;
  final int importDone, importTotal;
  final String query;
  final ContactFilter filter;
  final ContactSort sort;
  final ContactStats? stats;
  final DateTime? lastSyncedAt;
  final String? error;
  final ContactFeedback? feedback;

  const ContactState({
    this.status = ContactsStatus.initial,
    this.items = const [],
    this.pageNumber = 1,
    this.totalPages = 0,
    this.totalItems = 0,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.isRefreshing = false,
    this.importDone = 0,
    this.importTotal = 0,
    this.query = '',
    this.filter = ContactFilter.all,
    this.sort = ContactSort.newest,
    this.stats,
    this.lastSyncedAt,
    this.error,
    this.feedback,
  });

  bool get hasMore => pageNumber < totalPages;
  bool get hasActiveFilter => query.isNotEmpty || filter != ContactFilter.all;

  ContactState copyWith({
    ContactsStatus? status,
    List<ContactModel>? items,
    int? pageNumber,
    int? totalPages,
    int? totalItems,
    bool? isLoadingMore,
    bool? isSubmitting,
    bool? isRefreshing,
    int? importDone,
    int? importTotal,
    String? query,
    ContactFilter? filter,
    ContactSort? sort,
    ContactStats? stats,
    DateTime? lastSyncedAt,
    String? error,
    bool clearError = false,
    ContactFeedback? feedback,
  }) => ContactState(
    status: status ?? this.status,
    items: items ?? this.items,
    pageNumber: pageNumber ?? this.pageNumber,
    totalPages: totalPages ?? this.totalPages,
    totalItems: totalItems ?? this.totalItems,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    importDone: importDone ?? this.importDone,
    importTotal: importTotal ?? this.importTotal,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    sort: sort ?? this.sort,
    stats: stats ?? this.stats,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    error: clearError ? null : (error ?? this.error),
    feedback: feedback ?? this.feedback,
  );
}
