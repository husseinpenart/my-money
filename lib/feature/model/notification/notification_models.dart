import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/report/report_format.dart';

enum NotificationKind { overdue, today, soon }

NotificationKind _kind(String s) => switch (s) {
  'overdue' => NotificationKind.overdue,
  'today' => NotificationKind.today,
  _ => NotificationKind.soon,
};

class NotificationApiException implements Exception {
  final String message;
  NotificationApiException(this.message);
  @override
  String toString() => message;
}

class AppNotification {
  final String key;
  final String payId;
  final String contactId;
  final String contactName;
  final String contactPhoneNumber;
  final String recordType;
  final String wholePrice;
  final DateTime? endedDate;
  final int daysLeft;
  final NotificationKind kind;
  final bool isStarred;

  const AppNotification({
    required this.key,
    required this.payId,
    required this.contactId,
    required this.contactName,
    required this.contactPhoneNumber,
    required this.recordType,
    required this.wholePrice,
    required this.endedDate,
    required this.daysLeft,
    required this.kind,
    required this.isStarred,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    key: (j['key'] ?? '').toString(),
    payId: (j['payId'] ?? '').toString(),
    contactId: (j['contactId'] ?? '').toString(),
    contactName: (j['contactName'] ?? '').toString(),
    contactPhoneNumber: (j['contactPhoneNumber'] ?? '').toString(),
    recordType: (j['recordType'] ?? 'Debt').toString(),
    wholePrice: (j['wholePrice'] ?? '').toString(),
    endedDate: DateTime.tryParse((j['endedDate'] ?? '').toString()),
    daysLeft: (j['daysLeft'] as num?)?.toInt() ?? 0,
    kind: _kind((j['kind'] ?? '').toString()),
    isStarred: j['isStarred'] == true,
  );

  bool get isDebt => recordType.toLowerCase() == 'debt';

  String get _amount {
    final v = parseAmount(wholePrice);
    return v == null ? wholePrice : money(v);
  }

  String get title => switch (kind) {
    NotificationKind.overdue => isDebt ? 'بدهی معوق' : 'طلب معوق',
    NotificationKind.today =>
      isDebt ? 'سررسید بدهی امروز است' : 'سررسید طلب امروز است',
    NotificationKind.soon =>
      isDebt ? 'نزدیک شدن سررسید بدهی' : 'نزدیک شدن سررسید طلب',
  };

  String get message {
    final n = fa('${daysLeft.abs()}');
    final who = contactName;
    if (isDebt) {
      return switch (kind) {
        NotificationKind.overdue =>
          'بدهی شما به $who به مبلغ $_amount، $n روز است که سررسید شده.',
        NotificationKind.today =>
          'امروز آخرین مهلت پرداخت بدهی شما به $who به مبلغ $_amount است.',
        NotificationKind.soon =>
          '$n روز تا سررسید بدهی شما به $who به مبلغ $_amount مانده است.',
      };
    }
    return switch (kind) {
      NotificationKind.overdue =>
        'طلب شما از $who به مبلغ $_amount، $n روز است که سررسید شده.',
      NotificationKind.today =>
        'امروز سررسید طلب شما از $who به مبلغ $_amount است.',
      NotificationKind.soon =>
        '$n روز تا سررسید طلب شما از $who به مبلغ $_amount مانده است.',
    };
  }
}

class NotificationSummary {
  final int overdue, today, soon, total;
  final List<String> keys;
  const NotificationSummary({
    this.overdue = 0,
    this.today = 0,
    this.soon = 0,
    this.total = 0,
    this.keys = const [],
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> j) =>
      NotificationSummary(
        overdue: (j['overdue'] as num?)?.toInt() ?? 0,
        today: (j['today'] as num?)?.toInt() ?? 0,
        soon: (j['soon'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        keys: ((j['keys'] as List?) ?? []).map((e) => e.toString()).toList(),
      );
}

enum NotificationKindFilter { all, overdue, today, soon }

class NotificationFilter {
  final NotificationKindFilter kind;
  final String? recordType; // Debt | Receivable

  const NotificationFilter({
    this.kind = NotificationKindFilter.all,
    this.recordType,
  });

  NotificationFilter copyWith({
    NotificationKindFilter? kind,
    String? recordType,
    bool clearRecordType = false,
  }) => NotificationFilter(
    kind: kind ?? this.kind,
    recordType: clearRecordType ? null : (recordType ?? this.recordType),
  );

  Map<String, dynamic> toQuery({
    required String query,
    required int pageNumber,
    int pageSize = 15,
  }) => {
    'kind': kind.name,
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    if (query.isNotEmpty) 'query': query,
    if (recordType != null) 'recordType': recordType,
  };
}
