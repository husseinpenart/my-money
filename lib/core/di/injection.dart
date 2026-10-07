import 'package:get_it/get_it.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/feature/auth/data/dataResource/auth_remote_data_source.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  /// Token Storage
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  await getIt<TokenStorage>().init();

  /// Api Client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<TokenStorage>()),
  );

  /// Auth Remote Data Source
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );
}
