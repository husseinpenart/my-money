import 'package:dio/dio.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/report/report_models.dart';

class ReportRemoteDataSource {
  final ApiClient apiClient;
  ReportRemoteDataSource(this.apiClient);

  Future<ReportData> fetch({required ReportPeriod period}) async {
    final from = period.from;
    final to = period.to;

    final Response<dynamic> res = await apiClient.get<dynamic>(
      '/Report',
      queryParameters: {
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
    );

    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw ReportApiException('پاسخ نامعتبر از سرور');
    }

    final dynamic sc = body['statusCode'];
    if (body['success'] == false || (sc is int && sc >= 400)) {
      final errors = extractApiMessages(body['errors']);
      final msgs =
          errors.isNotEmpty ? errors : extractApiMessages(body['message']);
      throw ReportApiException(
        msgs.isNotEmpty ? msgs.join('\n') : 'دریافت گزارش ناموفق بود',
      );
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw ReportApiException('داده‌ای برای گزارش دریافت نشد');
    }
    return ReportData.fromJson(data);
  }
}