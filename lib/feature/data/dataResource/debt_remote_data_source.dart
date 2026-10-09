import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/DebtReceviable/debt_form_data.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/thousands_formatter.dart';

class DebtRemoteDataSource {
  final ApiClient apiClient;
  DebtRemoteDataSource(this.apiClient);

  // نام کنترلر را دقیقاً مطابق Swagger خودت بگذار
  static const String _path = '/DebtReceviableControllers';

  Future<void> create(DebtFormData d) async {
    final res = await apiClient.post<dynamic>(_path, data: _buildForm(d));
    _unwrap(res.data);
  }

  Future<void> update(DebtFormData d) async {
    final res = await apiClient.put<dynamic>(
      '$_path/${d.payId}',
      data: _buildForm(d),
    );
    _unwrap(res.data);
  }

  Future<void> delete(String payId) async {
    final res = await apiClient.delete<dynamic>('$_path/$payId');
    _unwrap(res.data);
  }

  /// ستاره‌دار/برداشتن بدون درگیرکردن covers (تا تصاویر قبلی پاک نشوند).
  /// 👈 سرور با [FromQuery] می‌خواند، پس حتماً queryParameters بفرست، نه data.
  Future<void> toggleStar(String payId, bool isStarred) async {
    final res = await apiClient.patch<dynamic>(
      '$_path/$payId/star',
      queryParameters: {'isStarred': isStarred}, // 👈 به‌جای data:
    );
    _unwrap(res.data);
  }

  FormData _buildForm(DebtFormData d) {
    final form = FormData.fromMap({
      'ContactId': d.contactId,
      'RecordType': d.recordType,
      'wholePrice': d.wholePrice,
      'RegisterdDate': d.registerdDate.toIso8601String(),
      'EndedDate': d.endedDate.toIso8601String(),
      if ((d.description ?? '').trim().isNotEmpty)
        'Description': d.description!.trim(),
      'payStatus': d.payStatus ? 'true' : 'false',
      'isStarred': d.isStarred ? 'true' : 'false',
    });

    // همه با کلید «covers» (مطابق Swagger: array)
    for (final c in d.newCovers) {
      final bytes = c.bytes;
      if (bytes == null) continue;
      form.files.add(
        MapEntry(
          'covers',
          MultipartFile.fromBytes(
            bytes,
            filename: c.name,
            contentType: _mediaType(c.name),
          ),
        ),
      );
    }
    return form;
  }
Future<SearchDebt> getById(String payId) async {
  final res = await apiClient.get<dynamic>('$_path/$payId');
  final data = _unwrap(res.data);
  if (data is Map<String, dynamic>) return SearchDebt.fromJson(data);
  throw DebtApiException('رکورد پیدا نشد');
}

/// فقط وضعیت پرداخت را عوض می‌کند. چون فایلی نمی‌فرستیم، تصاویر قبلی دست‌نخورده می‌ماند
Future<void> setPaid(SearchDebt d, {required bool paid}) async {
  final now = DateTime.now().toUtc();
  await update(DebtFormData(
    payId: d.payId,
    contactId: d.contactId,
    recordType: d.isDebt ? 'Debt' : 'Receivable',
    wholePrice: ThousandsInputFormatter.digitsOnly(d.wholePrice),
    registerdDate: (d.registerdDate ?? now).toUtc(),
    endedDate: (d.endedDate ?? now).toUtc(),
    description: d.description,
    payStatus: paid,
    isStarred: d.isStarred,
  ));
}
  MediaType _mediaType(String filename) {
    final ext = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  dynamic _unwrap(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final dynamic sc = body['statusCode'];
    final failed = body['success'] == false || (sc is int && sc >= 400);
    if (failed) {
      final errors = extractApiMessages(body['errors']);
      final msgs = errors.isNotEmpty
          ? errors
          : extractApiMessages(body['message']);
      throw DebtApiException(
        msgs.isNotEmpty ? msgs.join('\n') : 'عملیات ناموفق بود',
      );
    }
    return body['data'];
  }
}
