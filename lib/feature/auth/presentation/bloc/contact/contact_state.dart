import 'package:money/feature/model/contact/contact_model.dart';

enum ContactsStatus { initial, loading, success, failure }

/// پیام یک‌بارمصرف (اسنک‌بار). هر نمونه‌ی جدید = یک رویداد جدید
class ContactFeedback {
  final String message;
  final bool isError;
  ContactFeedback.success(this.message) : isError = false;
  ContactFeedback.error(this.message) : isError = true;
}

class ContactState {
  final ContactsStatus status;
  final List<ContactModel> items;
  final int pageNumber;
  final int totalPages;
  final int totalItems;
  final bool isLoadingMore;
  final bool isSubmitting;
  final int importDone;
  final int importTotal;
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
    this.importDone = 0,
    this.importTotal = 0,
    this.error,
    this.feedback,
  });

  bool get hasMore => pageNumber < totalPages;

  ContactState copyWith({
    ContactsStatus? status,
    List<ContactModel>? items,
    int? pageNumber,
    int? totalPages,
    int? totalItems,
    bool? isLoadingMore,
    bool? isSubmitting,
    int? importDone,
    int? importTotal,
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
    importDone: importDone ?? this.importDone,
    importTotal: importTotal ?? this.importTotal,
    error: clearError ? null : (error ?? this.error),
    feedback: feedback ?? this.feedback,
  );
}
