import 'package:dio/dio.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/notification/notification_models.dart';
import 'package:money/feature/model/search_models/search_models.dart';

class NotificationRemoteDataSource {
  final ApiClient apiClient;
  NotificationRemoteDataSource(this.apiClient);

  static const int windowDays = 3;

  Future<PagedResult<AppNotification>> fetchPage({
    required String query,
    required NotificationFilter filter,
    required int pageNumber,
    int pageSize = 15,
    CancelToken? cancelToken,
  }) async {
    final res = await apiClient.get<dynamic>(
      '/Notification',
      queryParameters: {
        ...filter.toQuery(query: query, pageNumber: pageNumber, pageSize: pageSize),
        'windowDays': windowDays,
      },
      cancelToken: cancelToken,
    );
    return PagedResult.parse<AppNotification>(
      _unwrap(res.data),
      AppNotification.fromJson,
    );
  }

  Future<NotificationSummary> fetchSummary() async {
    final res = await apiClient.get<dynamic>(
      '/Notification/summary',
      queryParameters: {'windowDays': windowDays},
    );
    final data = _unwrap(res.data);
    return data is Map<String, dynamic>
        ? NotificationSummary.fromJson(data)
        : const NotificationSummary();
  }

  dynamic _unwrap(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final dynamic sc = body['statusCode'];
    if (body['success'] == false || (sc is int && sc >= 400)) {
      final errors = extractApiMessages(body['errors']);
      final msgs = errors.isNotEmpty ? errors : extractApiMessages(body['message']);
      throw NotificationApiException(
        msgs.isNotEmpty ? msgs.join('\n') : 'دریافت اعلان‌ها ناموفق بود',
      );
    }
    return body['data'];
  }
}