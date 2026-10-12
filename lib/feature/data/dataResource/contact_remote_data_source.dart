import 'package:dio/dio.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/contact/contact_model.dart';

class ContactRemoteDataSource {
  final ApiClient apiClient;
  final ContactCache cache;
  ContactRemoteDataSource(this.apiClient, this.cache);

  Future<ContactModel> create({
    required String name,
    required String phoneNumber,
  }) async {
    final Response<dynamic> res = await apiClient.post<dynamic>(
      '/Contact',
      data: {'name': name, 'phoneNumber': phoneNumber},
    );
    return _apply(_unwrap(res.data));
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
    return _apply(_unwrap(res.data));
  }

  Future<ContactModel> getContactById(String contactId) async {
    final cached = cache.byId(contactId);
    if (cached != null) return cached;
    final res = await apiClient.get<dynamic>('/Contact/$contactId');
    return _apply(_unwrap(res.data));
  }

  Future<void> delete(String contactId) async {
    final Response<dynamic> res = await apiClient.delete<dynamic>(
      '/Contact/$contactId',
    );
    _unwrap(res.data);
    cache.removeContact(contactId);
  }

  /// پاسخ Command مستقیم به کش می‌رود؛ نیازی به Query دوباره نیست
  ContactModel _apply(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw ContactApiException('پاسخ نامعتبر از سرور');
    }
    cache.applyContact(data);
    return ContactModel.fromJson(data);
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
      throw ContactApiException(
        msgs.isNotEmpty ? msgs.join('\n') : 'عملیات ناموفق بود',
      );
    }
    return body['data'];
  }
}
