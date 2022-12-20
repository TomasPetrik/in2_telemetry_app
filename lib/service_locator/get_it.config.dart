// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i6;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i12;
import '../api/client/auth_api_client.dart' as _i14;
import '../api/dio_module.dart' as _i18;
import '../api/interceptors/token_interceptor.dart' as _i17;
import '../bloc/auth/auth_bloc.dart' as _i15;
import '../bloc/care_plan/care_plan_bloc.dart' as _i5;
import '../bloc/settings/settings_bloc.dart' as _i16;
import '../cubit/auth_web/auth_web_cubit.dart' as _i4;
import '../cubit/omron/omron_connection_cubit.dart' as _i8;
import '../providers/settings_db_provider.dart' as _i9;
import '../repositories/account_repository.dart' as _i13;
import '../services/auth_service.dart' as _i3;
import '../services/settings_service.dart' as _i10;
import '../storage/secure_storage_module.dart' as _i19;
import '../storage/storage.dart'
    as _i11; // ignore_for_file: unnecessary_lambdas

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
  gh.factory<_i5.CarePlanBloc>(() => _i5.CarePlanBloc());
  gh.singleton<_i6.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i7.FlutterSecureStorage>(secureStorageModule.storage);
  gh.singleton<_i8.OmronConnectionCubit>(_i8.OmronConnectionCubit());
  gh.singleton<_i9.SettingsDbProvider>(_i9.SettingsDbProvider());
  await gh.lazySingletonAsync<_i10.SettingsService>(
    () => _i10.SettingsService.create(),
    preResolve: true,
    dispose: (i) => i.dispose(),
  );
  gh.singleton<_i11.Storage>(_i11.Storage(get<_i7.FlutterSecureStorage>()));
  gh.factory<_i12.AccountApiClient>(
      () => _i12.AccountApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i13.AccountRepository>(
      _i13.AccountRepository(get<_i12.AccountApiClient>()));
  gh.factory<_i14.AuthApiClient>(
      () => _i14.AuthApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.factory<_i15.AuthBloc>(() => _i15.AuthBloc(
        get<_i3.AuthService>(),
        get<_i13.AccountRepository>(),
        get<_i11.Storage>(),
      ));
  gh.factory<_i16.SettingsBloc>(() => _i16.SettingsBloc(
        get<_i10.SettingsService>(),
        get<_i9.SettingsDbProvider>(),
      ));
  gh.factory<_i17.TokenInterceptor>(() => _i17.TokenInterceptor(
        get<_i11.Storage>(),
        get<_i12.AccountApiClient>(),
      ));
  return get;
}

class _$DioModule extends _i18.DioModule {}

class _$SecureStorageModule extends _i19.SecureStorageModule {}
