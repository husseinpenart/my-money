// lib/core/di/injection.dart (یا هر فایلی که داری)
import 'package:get_it/get_it.dart';
import 'package:money/feature/auth/presentation/bloc/DebtReceviable/debt_form_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_bloc.dart';
import 'package:money/feature/data/dataResource/contact_remote_data_source.dart';
import 'package:money/feature/data/dataResource/debt_remote_data_source.dart';
import 'package:money/feature/data/dataResource/report_remote_data_source.dart';
import 'package:money/feature/data/dataResource/search_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/feature/data/dataResource/auth_remote_data_source.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ۱. اول خود SharedPreferences را مقداردهی می‌کنیم
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // ۲. توکن استوریج با نمونه‌ی آماده ساخته می‌شود
  getIt.registerSingleton<TokenStorage>(
    TokenStorage(getIt<SharedPreferences>()),
  );

  // ۳. بقیه سرویس‌ها
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<TokenStorage>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(remoteDataSource: getIt<SearchRemoteDataSource>()),
  );

  getIt.registerLazySingleton<ContactRemoteDataSource>(
    () => ContactRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<ContactBloc>(
    () => ContactBloc(remoteDataSource: getIt<ContactRemoteDataSource>()),
  );

  getIt.registerLazySingleton<DebtRemoteDataSource>(
    () => DebtRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerFactory<DebtFormBloc>(
    () => DebtFormBloc(remoteDataSource: getIt<DebtRemoteDataSource>()),
  );

  getIt.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerFactory<ReportBloc>(
    () => ReportBloc(remoteDataSource: getIt<ReportRemoteDataSource>()),
  );
}
