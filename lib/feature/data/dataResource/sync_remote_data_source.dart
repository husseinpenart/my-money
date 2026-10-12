import 'package:dio/dio.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/contact/contact_model.dart';

class SyncSnapshot {
  final bool unchanged;
  final int version, remaining, dailyLimit;
  final List<Map<String, dynamic>> contacts;
  const SyncSnapshot({
    required this.unchanged,
    required this.version,
    required this.remaining,
    required this.dailyLimit,
    required this.contacts,
  });
}

class SyncRemoteDataSource {
  final ApiClient apiClient;
  SyncRemoteDataSource(this.apiClient);

  Future<SyncSnapshot> snapshot({int? since}) async {
    try {
      final res = await apiClient.get<dynamic>(
        '/Sync/snapshot',
        queryParameters: {if (since != null) 'since': since},
      );
      final body = res.data;
      if (body is! Map<String, dynamic> ||
          body['success'] == false ||
          body['data'] is! Map<String, dynamic>) {
        throw ContactApiException(_message(body) ?? 'پاسخ نامعتبر از سرور');
      }
      final d = body['data'] as Map<String, dynamic>;
      return SyncSnapshot(
        unchanged: d['unchanged'] == true,
        version: (d['version'] as num?)?.toInt() ?? 0,
        remaining: (d['remaining'] as num?)?.toInt() ?? 0,
        dailyLimit: (d['dailyLimit'] as num?)?.toInt() ?? 0,
        contacts: ((d['contacts'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(),
      );
    } on DioException catch (e) {
      final msg = _message(e.response?.data);
      if (msg != null) throw ContactApiException(msg);
      if (e.response?.statusCode == 429) {
        throw ContactApiException(
          'تعداد درخواست‌ها زیاد است؛ کمی بعد دوباره تلاش کن',
        );
      }
      rethrow;
    }
  }

  String? _message(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final m = extractApiMessages(body['message']);
    return m.isEmpty ? null : m.join('\n');
  }
}
