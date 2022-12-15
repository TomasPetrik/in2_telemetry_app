// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i5;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i11;
import '../api/client/auth_api_client.dart' as _i13;
import '../api/dio_module.dart' as _i17;
import '../api/interceptors/token_interceptor.dart' as _i16;
import '../bloc/auth/auth_bloc.dart' as _i14;
import '../bloc/settings/settings_bloc.dart' as _i15;
import '../cubit/auth_web/auth_web_cubit.dart' as _i4;
import '../cubit/omron/omron_connection_cubit.dart' as _i7;
import '../providers/settings_db_provider.dart' as _i8;
import '../repositories/account_repository.dart' as _i12;
import '../services/auth_service.dart' as _i3;
import '../services/settings_service.dart' as _i9;
import '../storage/secure_storage_module.dart' as _i18;
import '../storage/storage.dart'
    as _i10; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
Future<_i1.GetIt> $initGetIt(
  _i1.GetIt get, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i2.GetItHelper(
    get,
    environment,
    environmentFilter,
  );
  final dioModule = _$DioModule();
  final secureStorageModule = _$SecureStorageModule();
  gh.singleton<_i3.AuthService>(_i3.AuthService());
  gh.factory<_i4.AuthWebCubit>(() => _i4.AuthWebCubit());
  gh.singleton<_i5.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i6.FlutterSecureStorage>(secureStorageModule.storage);
  gh.singleton<_i7.OmronConnectionCubit>(_i7.OmronConnectionCubit());
  gh.singleton<_i8.SettingsDbProvider>(_i8.SettingsDbProvider());
  await gh.lazySingletonAsync<_i9.SettingsService>(
    () => _i9.SettingsService.create(),
    preResolve: true,
    dispose: (i) => i.dispose(),
  );
  gh.singleton<_i10.Storage>(_i10.Storage(get<_i6.FlutterSecureStorage>()));
  gh.factory<_i11.AccountApiClient>(
      () => _i11.AccountApiClient(get<_i5.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i12.AccountRepository>(
      _i12.AccountRepository(get<_i11.AccountApiClient>()));
  gh.factory<_i13.AuthApiClient>(
      () => _i13.AuthApiClient(get<_i5.Dio>(instanceName: 'privateDio')));
  gh.factory<_i14.AuthBloc>(() => _i14.AuthBloc(
        get<_i3.AuthService>(),
        get<_i12.AccountRepository>(),
        get<_i10.Storage>(),
      ));
  gh.factory<_i15.SettingsBloc>(() => _i15.SettingsBloc(
        get<_i9.SettingsService>(),
        get<_i8.SettingsDbProvider>(),
      ));
  gh.factory<_i16.TokenInterceptor>(() => _i16.TokenInterceptor(
        get<_i10.Storage>(),
        get<_i11.AccountApiClient>(),
      ));
  return get;
}

class _$DioModule extends _i17.DioModule {}

class _$SecureStorageModule extends _i18.SecureStorageModule {}
