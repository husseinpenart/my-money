import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/alerts/alert_coordinator.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/cache/sync_repository.dart';
import 'package:money/core/network/notification_read_store.dart';
import 'package:money/core/storage/app_storage.dart';
import 'package:money/core/vault/vault_local_store.dart';
import 'package:money/core/vault/vault_repository.dart';
import 'package:money/feature/auth/presentation/bloc/DebtReceviable/debt_form_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/hero/hero_stats_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/notification/notification_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/vault/vault_bloc.dart';
import 'package:money/feature/data/dataResource/budget_remote_data_source.dart';
import 'package:money/feature/data/dataResource/contact_remote_data_source.dart';
import 'package:money/feature/data/dataResource/debt_remote_data_source.dart';
import 'package:money/feature/data/dataResource/hero_remote_data_source.dart';
import 'package:money/feature/data/dataResource/notification_remote_data_source.dart';
import 'package:money/feature/data/dataResource/report_remote_data_source.dart';
import 'package:money/feature/data/dataResource/search_remote_data_source.dart';
import 'package:money/feature/data/dataResource/sync_remote_data_source.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/feature/data/dataResource/auth_remote_data_source.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:money/feature/data/dataResource/vault_remote_data_source.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ۱. SharedPreferences
  // final sharedPreferences = await SharedPreferences.getInstance();
  // getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  final storage = await AppStorage.init();
  getIt.registerSingleton<AppStorage>(storage);
  getIt.registerSingleton<TokenStorage>(TokenStorage(storage));

  final vaultStore = VaultLocalStore();
  await vaultStore.init();
  getIt.registerSingleton<VaultLocalStore>(vaultStore);
  getIt.registerLazySingleton<VaultRemoteDataSource>(
    () => VaultRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<VaultRepository>(
    () => VaultRepository(
      getIt<VaultRemoteDataSource>(),
      getIt<VaultLocalStore>(),
      getIt<AppStorage>(),
    ),
  );
  getIt.registerLazySingleton<AlertCoordinator>(
    () => AlertCoordinator(getIt<ContactCache>(), getIt<AppStorage>()),
  );
  getIt.registerFactory<VaultBloc>(() => VaultBloc(getIt<VaultRepository>()));

  // ۳. ApiClient
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<TokenStorage>()),
  );

  // ───────────── Auth ─────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  // ───────────── Search ─────────────
  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(remoteDataSource: getIt<SearchRemoteDataSource>()),
  );

  // ───────────── Cache / Sync ─────────────
  getIt.registerLazySingleton<ContactCache>(
    () => ContactCache(getIt<AppStorage>()),
  );

  getIt.registerLazySingleton<SyncRemoteDataSource>(
    () => SyncRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepository(getIt<SyncRemoteDataSource>(), getIt<ContactCache>()),
  );

  // ───────────── Contact / Debt Data Sources ─────────────
  getIt.registerLazySingleton<ContactRemoteDataSource>(
    () => ContactRemoteDataSource(getIt<ApiClient>(), getIt<ContactCache>()),
  );

  getIt.registerLazySingleton<DebtRemoteDataSource>(
    () => DebtRemoteDataSource(getIt<ApiClient>(), getIt<ContactCache>()),
  );

  // ───────────── Contact Bloc ─────────────
  getIt.registerFactory<ContactBloc>(
    () => ContactBloc(
      remote: getIt<ContactRemoteDataSource>(),
      cache: getIt<ContactCache>(),
      sync: getIt<SyncRepository>(),
    ),
  );

  // نسخه‌ی سرور را بعد از هر Command از هدر بخوان
  getIt<ApiClient>().dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        final v = int.tryParse(response.headers.value('x-data-version') ?? '');
        if (v != null) getIt<ContactCache>().noteServerVersion(v);
        handler.next(response);
      },
    ),
  );

  // ───────────── Debt Form Bloc ─────────────
  getIt.registerFactory<DebtFormBloc>(
    () => DebtFormBloc(remoteDataSource: getIt<DebtRemoteDataSource>()),
  );

  // ───────────── Report ─────────────
  getIt.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<ReportBloc>(
    () => ReportBloc(remoteDataSource: getIt<ReportRemoteDataSource>()),
  );

  // ───────────── Hero ─────────────
  getIt.registerLazySingleton<HeroRemoteDataSource>(
    () => HeroRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<HeroStatsBloc>(
    () => HeroStatsBloc(getIt<HeroRemoteDataSource>()),
  );

  // ───────────── Notification ─────────────
  getIt.registerLazySingleton<NotificationReadStore>(
    () => NotificationReadStore(getIt<AppStorage>()),
  );

  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      remote: getIt<NotificationRemoteDataSource>(),
      store: getIt<NotificationReadStore>(),
      alerts: getIt<AlertCoordinator>(),
    ),
  );

  // ───────────── Budget ─────────────
  getIt.registerLazySingleton<BudgetRemoteDataSource>(
    () => BudgetRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<BudgetBloc>(
    () => BudgetBloc(ds: getIt<BudgetRemoteDataSource>()),
  );
}
