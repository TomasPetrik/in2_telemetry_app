// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i12;
import '../api/client/auth_api_client.dart' as _i14;
import '../api/client/care_plan_api_client.dart' as _i15;
import '../api/dio_module.dart' as _i22;
import '../api/interceptors/token_interceptor.dart' as _i19;
import '../bloc/auth/auth_bloc.dart' as _i20;
import '../bloc/care_plan/care_plan_bloc.dart' as _i21;
import '../bloc/settings/settings_bloc.dart' as _i18;
import '../bloc/user_content/content_bloc.dart' as _i17;
import '../cubit/auth_web/auth_web_cubit.dart' as _i5;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i7;
import '../cubit/omron/omron_connection_cubit.dart' as _i8;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/settings_db_provider.dart' as _i10;
import '../repositories/account_repository.dart' as _i13;
import '../repositories/care_plans_repository.dart' as _i16;
import '../services/auth_service.dart' as _i4;
import '../services/settings_service.dart' as _i11;
import '../storage/session.dart' as _i9; // ignore_for_file: unnecessary_lambdas

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
  gh.singleton<_i3.AccountDbProvider>(_i3.AccountDbProvider());
  gh.singleton<_i4.AuthService>(_i4.AuthService());
  gh.factory<_i5.AuthWebCubit>(() => _i5.AuthWebCubit());
  gh.singleton<_i6.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.factory<_i7.HospitalSearchCubit>(() => _i7.HospitalSearchCubit());
  gh.singleton<_i8.OmronConnectionCubit>(_i8.OmronConnectionCubit());
  gh.singleton<_i9.Session>(_i9.Session());
  gh.singleton<_i10.SettingsDbProvider>(_i10.SettingsDbProvider());
  await gh.lazySingletonAsync<_i11.SettingsService>(
    () => _i11.SettingsService.create(),
    preResolve: true,
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i12.AccountApiClient>(
      () => _i12.AccountApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i13.AccountRepository>(
      _i13.AccountRepository(get<_i12.AccountApiClient>()));
  gh.factory<_i14.AuthApiClient>(
      () => _i14.AuthApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.factory<_i15.CarePlanApiClient>(
      () => _i15.CarePlanApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i16.CarePlansRepository>(_i16.CarePlansRepository(
    get<_i15.CarePlanApiClient>(),
    get<_i9.Session>(),
  ));
  gh.singleton<_i17.ContentBloc>(_i17.ContentBloc(
    get<_i3.AccountDbProvider>(),
    get<_i9.Session>(),
    get<_i16.CarePlansRepository>(),
  ));
  gh.factory<_i18.SettingsBloc>(() => _i18.SettingsBloc(
        get<_i11.SettingsService>(),
        get<_i10.SettingsDbProvider>(),
      ));
  gh.factory<_i19.TokenInterceptor>(() => _i19.TokenInterceptor(
        get<_i9.Session>(),
        get<_i12.AccountApiClient>(),
      ));
  gh.singleton<_i20.AuthBloc>(_i20.AuthBloc(
    get<_i4.AuthService>(),
    get<_i13.AccountRepository>(),
    get<_i16.CarePlansRepository>(),
    get<_i9.Session>(),
    get<_i3.AccountDbProvider>(),
    get<_i6.Dio>(instanceName: 'privateDio'),
  ));
  gh.factory<_i21.CarePlanBloc>(() => _i21.CarePlanBloc(
        get<_i16.CarePlansRepository>(),
        get<_i3.AccountDbProvider>(),
        get<_i9.Session>(),
      ));
  return get;
}

class _$DioModule extends _i22.DioModule {}
