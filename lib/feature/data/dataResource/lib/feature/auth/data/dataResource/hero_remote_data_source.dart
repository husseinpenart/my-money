import 'package:money/core/network/api_client.dart';
import 'package:money/feature/model/widgets/hero/hero_stats.dart';

class HeroRemoteDataSource {
  final ApiClient apiClient;
  HeroRemoteDataSource(this.apiClient);

  // 👇 این مسیر را با endpoint واقعی خودت ست کن (اگر نامش فرق دارد فقط همین یک خط)
  static const String statsPath = '/Debts/dashboard-stats';

  Future<HeroStats> fetch() async {
    final response = await apiClient.get<dynamic>(statsPath, requiresAuth: true);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return HeroStats.fromJson(inner);
      return HeroStats.fromJson(data);
    }
    throw const FormatException('ساختار پاسخ آمار نامعتبر است');
  }
}