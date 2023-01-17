// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i7;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i14;
import '../api/client/auth_api_client.dart' as _i16;
import '../api/dio_module.dart' as _i21;
import '../api/interceptors/token_interceptor.dart' as _i20;
import '../bloc/auth/auth_bloc.dart' as _i17;
import '../bloc/care_plan/care_plan_bloc.dart' as _i6;
import '../bloc/settings/settings_bloc.dart' as _i19;
import '../bloc/user_content/content_bloc.dart' as _i18;
import '../cubit/auth_web/auth_web_cubit.dart' as _i5;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i9;
import '../cubit/omron/omron_connection_cubit.dart' as _i10;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/settings_db_provider.dart' as _i12;
import '../repositories/account_repository.dart' as _i15;
import '../services/auth_service.dart' as _i4;
import '../services/settings_service.dart' as _i13;
import '../storage/secure_storage_module.dart' as _i22;
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
  gh.singleton<_i3.AccountDbProvider>(_i3.AccountDbProvider());
  gh.singleton<_i4.AuthService>(_i4.AuthService());
  gh.factory<_i5.AuthWebCubit>(() => _i5.AuthWebCubit());
  gh.factory<_i6.CarePlanBloc>(() => _i6.CarePlanBloc());
  gh.singleton<_i7.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i8.FlutterSecureStorage>(secureStorageModule.storage);
  gh.factory<_i9.HospitalSearchCubit>(() => _i9.HospitalSearchCubit());
  gh.singleton<_i10.OmronConnectionCubit>(_i10.OmronConnectionCubit());
  gh.singleton<_i11.Session>(_i11.Session(get<_i8.FlutterSecureStorage>()));
  gh.singleton<_i12.SettingsDbProvider>(_i12.SettingsDbProvider());
  await gh.lazySingletonAsync<_i13.SettingsService>(
    () => _i13.SettingsService.create(),
    preResolve: true,
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i14.AccountApiClient>(
      () => _i14.AccountApiClient(get<_i7.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i15.AccountRepository>(
      _i15.AccountRepository(get<_i14.AccountApiClient>()));
  gh.factory<_i16.AuthApiClient>(
      () => _i16.AuthApiClient(get<_i7.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i17.AuthBloc>(_i17.AuthBloc(
    get<_i4.AuthService>(),
    get<_i15.AccountRepository>(),
    get<_i11.Session>(),
    get<_i3.AccountDbProvider>(),
  ));
  gh.singleton<_i18.ContentBloc>(_i18.ContentBloc(
    get<_i3.AccountDbProvider>(),
    get<_i11.Session>(),
  ));
  gh.factory<_i19.SettingsBloc>(() => _i19.SettingsBloc(
        get<_i13.SettingsService>(),
        get<_i12.SettingsDbProvider>(),
      ));
  gh.factory<_i20.TokenInterceptor>(() => _i20.TokenInterceptor(
        get<_i11.Session>(),
        get<_i14.AccountApiClient>(),
      ));
  return get;
}

class _$DioModule extends _i21.DioModule {}

class _$SecureStorageModule extends _i22.SecureStorageModule {}
