import 'package:money/feature/model/notification/notification_models.dart';
import 'package:money/feature/model/search_models/search_models.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState {
  final NotificationStatus status;
  final String query;
  final NotificationFilter filter;
  final List<AppNotification> items;
  final int pageNumber;
  final int totalPages;
  final int totalItems;
  final bool isLoadingMore;
  final NotificationSummary summary;
  final Set<String> readKeys;
  final String? error;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.query = '',
    this.filter = const NotificationFilter(),
    this.items = const [],
    this.pageNumber = 1,
    this.totalPages = 0,
    this.totalItems = 0,
    this.isLoadingMore = false,
    this.summary = const NotificationSummary(),
    this.readKeys = const {},
    this.error,
  });

  bool get hasMore => pageNumber < totalPages;

  /// نخوانده‌ها بر اساس کلیدهای سرور (حداکثر ۱۰۰۰ مورد)
  int get unreadCount => summary.keys.where((k) => !readKeys.contains(k)).length;

  bool get hasActiveFilter =>
      query.isNotEmpty ||
      filter.kind != NotificationKindFilter.all ||
      filter.recordType != null;

  NotificationState copyWith({
    NotificationStatus? status,
    String? query,
    NotificationFilter? filter,
    List<AppNotification>? items,
    int? pageNumber,
    int? totalPages,
    int? totalItems,
    bool? isLoadingMore,
    NotificationSummary? summary,
    Set<String>? readKeys,
    String? error,
    bool clearError = false,
  }) =>
      NotificationState(
        status: status ?? this.status,
        query: query ?? this.query,
        filter: filter ?? this.filter,
        items: items ?? this.items,
        pageNumber: pageNumber ?? this.pageNumber,
        totalPages: totalPages ?? this.totalPages,
        totalItems: totalItems ?? this.totalItems,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        summary: summary ?? this.summary,
        readKeys: readKeys ?? this.readKeys,
        error: clearError ? null : (error ?? this.error),
      );

  // برای استفاده‌ی PagedResult در صورت نیاز
  PagedResult<AppNotification> get paged => PagedResult(
        items: items,
        pageNumber: pageNumber,
        totalPages: totalPages,
        totalItems: totalItems,
      );
}