import 'package:dio/dio.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';

class ContactRemoteDataSource {
  final ApiClient apiClient;
  ContactRemoteDataSource(this.apiClient);

  /// لیست صفحه‌بندی‌شده با جستجو، فیلتر و مرتب‌سازی سمت سرور
  Future<PagedResult<ContactModel>> fetch({
    required int pageNumber,
    int pageSize = 20,
    String query = '',
    ContactFilter filter = ContactFilter.all,
    ContactSort sort = ContactSort.newest,
    CancelToken? cancelToken,
  }) async {
    final Response<dynamic> res = await apiClient.get<dynamic>(
      '/Search',
      cancelToken: cancelToken,
      queryParameters: {
        'type': 'contacts',
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'sortBy': sort.apiKey,
        'desc': sort.desc,
        if (query.isNotEmpty) 'query': query,
        if (filter == ContactFilter.demander) ...{
          'recordType': 'Receivable',
          'payStatus': false,
        },
        if (filter == ContactFilter.debtor) ...{
          'recordType': 'Debt',
          'payStatus': false,
        },
      },
    );

    final data = _unwrap(res.data);
    final raw = data is Map<String, dynamic> ? data['contacts'] : null;
    return PagedResult.parse<ContactModel>(raw, ContactModel.fromJson);
  }

  /// شمارنده‌های دقیق (بدون وابستگی به صفحه‌های لودشده)
  Future<ContactStats> stats() async {
    final r = await Future.wait([
      fetch(pageNumber: 1, pageSize: 1),
      fetch(pageNumber: 1, pageSize: 1, filter: ContactFilter.demander),
      fetch(pageNumber: 1, pageSize: 1, filter: ContactFilter.debtor),
    ]);
    return ContactStats(
      total: r[0].totalItems,
      demanders: r[1].totalItems,
      debtors: r[2].totalItems,
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

  Future<ContactModel> getContactById(String contactId) async {
    final res = await apiClient.get<dynamic>('/Contact/$contactId');
    return _toContact(_unwrap(res.data));
  }

  Future<void> delete(String contactId) async {
    final Response<dynamic> res = await apiClient.delete<dynamic>(
      '/Contact/$contactId',
    );
    _unwrap(res.data);
  }

  ContactModel _toContact(dynamic data) {
    if (data is Map<String, dynamic>) return ContactModel.fromJson(data);
    throw ContactApiException('پاسخ نامعتبر از سرور');
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
