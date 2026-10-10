import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/budget/budget_models.dart';
import 'package:money/feature/model/search_models/search_models.dart';

class BudgetRemoteDataSource {
  final ApiClient apiClient;
  BudgetRemoteDataSource(this.apiClient);

  Future<BudgetPlan> getPlan(int? cycle) async {
    final res = await apiClient.get<dynamic>(
      '/Budget/plan',
      queryParameters: {if (cycle != null) 'cycle': cycle},
    );
    final d = _unwrap(res.data);
    if (d is! Map<String, dynamic>)
      throw BudgetApiException('پاسخ نامعتبر از سرور');
    return BudgetPlan.fromJson(d);
  }

  Future<List<CycleSummary>> getHistory() async {
    final res = await apiClient.get<dynamic>('/Budget/history');
    final d = _unwrap(res.data);
    return ((d as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CycleSummary.fromJson)
        .toList();
  }

  Future<List<BudgetItem>> getItems() async {
    final res = await apiClient.get<dynamic>('/Budget/items');
    final d = _unwrap(res.data);
    return ((d as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(BudgetItem.fromJson)
        .toList();
  }

  Future<SalaryProfile?> getProfile() async {
    final res = await apiClient.get<dynamic>('/Budget/profile');
    final d = _unwrap(res.data);
    return d is Map<String, dynamic> ? SalaryProfile.fromJson(d) : null;
  }

  Future<void> saveProfile(SalaryProfile p) async {
    final res = await apiClient.put<dynamic>(
      '/Budget/profile',
      data: p.toJson(),
    );
    _unwrap(res.data);
  }

  Future<void> confirmSalary(double amount, int? cycle) async {
    final res = await apiClient.post<dynamic>(
      '/Budget/salary-confirm',
      data: {'amount': amount, if (cycle != null) 'cycleKey': cycle},
    );
    _unwrap(res.data);
  }

  Future<void> saveItem(BudgetItem item) async {
    final res = item.itemId == null
        ? await apiClient.post<dynamic>('/Budget/items', data: item.toJson())
        : await apiClient.put<dynamic>(
            '/Budget/items/${item.itemId}',
            data: item.toJson(),
          );
    _unwrap(res.data);
  }

  Future<void> deleteItem(String id) async {
    final res = await apiClient.delete<dynamic>('/Budget/items/$id');
    _unwrap(res.data);
  }

  Future<void> addExpense({
    String? itemId,
    String? title,
    required String category,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final res = await apiClient.post<dynamic>(
      '/Budget/expenses',
      data: {
        if (itemId != null) 'budgetItemId': itemId,
        if ((title ?? '').trim().isNotEmpty) 'title': title!.trim(),
        'category': category,
        'amount': amount,
        'date': date.toUtc().toIso8601String(),
        if ((note ?? '').trim().isNotEmpty) 'note': note!.trim(),
      },
    );
    _unwrap(res.data);
  }

  Future<void> deleteExpense(String id) async {
    final res = await apiClient.delete<dynamic>('/Budget/expenses/$id');
    _unwrap(res.data);
  }

  Future<PagedResult<ExpenseModel>> getExpenses({
    required int pageNumber,
    int? cycle,
    String query = '',
    String? category,
    int pageSize = 20,
  }) async {
    final res = await apiClient.get<dynamic>(
      '/Budget/expenses',
      queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (cycle != null) 'cycle': cycle,
        if (query.isNotEmpty) 'query': query,
        if (category != null) 'category': category,
      },
    );
    return PagedResult.parse<ExpenseModel>(
      _unwrap(res.data),
      ExpenseModel.fromJson,
    );
  }

  dynamic _unwrap(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final dynamic sc = body['statusCode'];
    if (body['success'] == false || (sc is int && sc >= 400)) {
      final errors = extractApiMessages(body['errors']);
      final msgs = errors.isNotEmpty
          ? errors
          : extractApiMessages(body['message']);
      throw BudgetApiException(
        msgs.isNotEmpty ? msgs.join('\n') : 'عملیات ناموفق بود',
      );
    }
    return body['data'];
  }
}
