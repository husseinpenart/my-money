class SearchContact {
  final String contactId;
  final String name;
  final String phoneNumber;
  final DateTime? createdAt;
  final List<SearchDebt> debts;

  const SearchContact({
    required this.contactId,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
    required this.debts,
  });

  factory SearchContact.fromJson(Map<String, dynamic> j) => SearchContact(
    contactId: (j['contactId'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    phoneNumber: (j['phoneNumber'] ?? '').toString(),
    createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()),
    debts: ((j['debtReceivable'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(SearchDebt.fromJson)
        .toList(),
  );
}

class SearchDebt {
  final String payId;
  final String contactId;
  final String contactName;
  final String contactPhoneNumber;
  final String recordType; // Debt | Receivable
  final String wholePrice;
  final DateTime? registerdDate;
  final DateTime? endedDate;
  final String? description;
  final bool payStatus;
  final bool isStarred;
final List<String> covers;

  const SearchDebt({
    required this.payId,
    required this.contactId,
    required this.contactName,
    required this.contactPhoneNumber,
    required this.recordType,
    required this.wholePrice,
    required this.registerdDate,
    required this.endedDate,
    required this.description,
    required this.payStatus,
    required this.isStarred,
    required this.covers,
  });

  bool get isDebt => recordType.toLowerCase() == 'debt';

  factory SearchDebt.fromJson(Map<String, dynamic> j) => SearchDebt(
    payId: (j['payId'] ?? '').toString(),
    contactId: (j['contactId'] ?? '').toString(),
    contactName: (j['contactName'] ?? '').toString(),
    contactPhoneNumber: (j['contactPhoneNumber'] ?? '').toString(),
    recordType: (j['recordType'] ?? 'Debt').toString(),
    wholePrice: (j['wholePrice'] ?? '').toString(),
    registerdDate: DateTime.tryParse((j['registerdDate'] ?? '').toString()),
    endedDate: DateTime.tryParse((j['endedDate'] ?? '').toString()),
    description: j['description']?.toString(),
    payStatus: j['payStatus'] == true,
    isStarred: j['isStarred'] == true,
    covers: ((j['covers'] as List?) ?? []).map((e) => e.toString()).toList(),
  );
}

class PagedResult<T> {
  final List<T> items;
  final int pageNumber;
  final int totalPages;
  final int totalItems;

  const PagedResult({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.totalItems,
  });

  const PagedResult.empty()
    : items = const [],
      pageNumber = 1,
      totalPages = 0,
      totalItems = 0;

  bool get hasMore => pageNumber < totalPages;

  PagedResult<T> append(PagedResult<T> next) => PagedResult<T>(
    items: [...items, ...next.items],
    pageNumber: next.pageNumber,
    totalPages: next.totalPages,
    totalItems: next.totalItems,
  );

  static PagedResult<T> parse<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json is! Map<String, dynamic>) return PagedResult<T>.empty();
    final list = ((json['data'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
    return PagedResult<T>(
      items: list,
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? list.length,
    );
  }
}

class SearchResponse {
  final PagedResult<SearchContact> contacts;
  final PagedResult<SearchDebt> debts;

  const SearchResponse({required this.contacts, required this.debts});
}
