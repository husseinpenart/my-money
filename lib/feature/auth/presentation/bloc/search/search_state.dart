import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState {
  final SearchStatus status;
  final String query;
  final SearchFilter filter;
  final PagedResult<SearchContact> contacts;
  final PagedResult<SearchDebt> debts;
  final bool isLoadingMore;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.filter = const SearchFilter(),
    this.contacts = const PagedResult.empty(),
    this.debts = const PagedResult.empty(),
    this.isLoadingMore = false,
    this.error,
  });

  bool get isEmptyResult =>
      status == SearchStatus.success &&
      contacts.items.isEmpty &&
      debts.items.isEmpty;

  bool get hasMore {
    switch (filter.type) {
      case SearchType.contacts:
        return contacts.hasMore;
      case SearchType.debts:
        return debts.hasMore;
      case SearchType.all:
        return contacts.hasMore || debts.hasMore;
    }
  }

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchFilter? filter,
    PagedResult<SearchContact>? contacts,
    PagedResult<SearchDebt>? debts,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) => SearchState(
    status: status ?? this.status,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    contacts: contacts ?? this.contacts,
    debts: debts ?? this.debts,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: clearError ? null : (error ?? this.error),
  );
}
