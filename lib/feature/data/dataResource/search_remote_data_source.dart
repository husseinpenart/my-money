import 'package:dio/dio.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';

class SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSource(this.apiClient);

  Future<SearchResponse> search({
    required String query,
    required SearchFilter filter,
    required int pageNumber,
    int pageSize = 10,
    CancelToken? cancelToken,
  }) async {
    final Response<dynamic> response = await apiClient.get<dynamic>(
      '/Search',
      queryParameters: filter.toQuery(
        query: query,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );

    final body = response.data;
    final data = (body is Map<String, dynamic>) ? body['data'] : null;
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return SearchResponse(
      contacts: PagedResult.parse<SearchContact>(
        map['contacts'],
        SearchContact.fromJson,
      ),
      debts: PagedResult.parse<SearchDebt>(
        map['debtReceivables'],
        SearchDebt.fromJson,
      ),
    );
  }
}
