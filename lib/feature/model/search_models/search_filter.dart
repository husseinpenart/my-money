enum SearchType { all, contacts, debts }

class SearchFilter {
  final SearchType type;
  final String? recordType; // Debt | Receivable
  final bool? payStatus;
  final bool? isStarred;

  const SearchFilter({
    this.type = SearchType.all,
    this.recordType,
    this.payStatus,
    this.isStarred,
  });

  bool get hasDebtFilters =>
      recordType != null || payStatus != null || isStarred != null;

  /// فیلترهای بدهی/طلب فقط به تب «بدهی/طلب» مربوط‌اند
  bool get isActive => hasDebtFilters;

  SearchFilter copyWith({
    SearchType? type,
    String? recordType,
    bool? payStatus,
    bool? isStarred,
    bool clearRecordType = false,
    bool clearPayStatus = false,
    bool clearIsStarred = false,
  }) => SearchFilter(
    type: type ?? this.type,
    recordType: clearRecordType ? null : (recordType ?? this.recordType),
    payStatus: clearPayStatus ? null : (payStatus ?? this.payStatus),
    isStarred: clearIsStarred ? null : (isStarred ?? this.isStarred),
  );

  Map<String, dynamic> toQuery({
    required String query,
    required int pageNumber,
    int pageSize = 10,
  }) {
    final typeStr = switch (type) {
      SearchType.all => 'all',
      SearchType.contacts => 'contacts',
      SearchType.debts => 'debts',
    };
    return {
      'query': query,
      'type': typeStr,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (recordType != null) 'recordType': recordType,
      if (payStatus != null) 'payStatus': payStatus,
      if (isStarred != null) 'isStarred': isStarred,
    };
  }
}
