import 'package:dio/dio.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';


class ContactRemoteDataSource {
  final ApiClient apiClient;
  ContactRemoteDataSource(this.apiClient);

  Future<PagedResult<ContactModel>> getAll({
    required int pageNumber,
    int pageSize = 20,
  }) async {
    final Response<dynamic> res = await apiClient.get<dynamic>(
      '/Contact',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    return PagedResult.parse<ContactModel>(
      _unwrap(res.data),
      ContactModel.fromJson,
    );
  }

  Future<ContactModel> create({
    required String name,
    required String phoneNumber,
  }) async {
    final Response<dynamic> res = await apiClient.post<dynamic>(
      '/Contact',
      data: {'name': name, 'phoneNumber': phoneNumber},
    );
    return _toContact(_unwrap(res.data));
  }

  Future<ContactModel> update({
    required String contactId,
    required String name,
    required String phoneNumber,
  }) async {
    final Response<dynamic> res = await apiClient.put<dynamic>(
      '/Contact/$contactId',
      data: {'name': name, 'phoneNumber': phoneNumber},
    );
    return _toContact(_unwrap(res.data));
  }

  Future<void> delete(String contactId) async {
    final Response<dynamic> res = await apiClient.delete<dynamic>(
      '/Contact/$contactId',
    );
    _unwrap(res.data);
  }

  // ---------------------------------------------------------------
  ContactModel _toContact(dynamic data) {
    if (data is Map<String, dynamic>) return ContactModel.fromJson(data);
    throw ContactApiException('پاسخ نامعتبر از سرور');
  }

  /// بدنه‌ی ApiResponseDto را باز می‌کند و در صورت خطا exception می‌اندازد
  dynamic _unwrap(dynamic body) {
    if (body is! Map<String, dynamic>) return null;

    final dynamic sc = body['statusCode'];
    final failed = body['success'] == false || (sc is int && sc >= 400);
    if (failed) {
      final msgs = <String>[
        ...extractApiMessages(body['errors']),
        if (extractApiMessages(body['errors']).isEmpty)
          ...extractApiMessages(body['message']),
      ];
      throw ContactApiException(
        msgs.isNotEmpty ? msgs.join('\n') : 'عملیات ناموفق بود',
      );
    }
    return body['data'];
  }
}
