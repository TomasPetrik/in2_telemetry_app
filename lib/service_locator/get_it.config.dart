// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i13;
import '../api/client/auth_api_client.dart' as _i15;
import '../api/client/care_plan_api_client.dart' as _i16;
import '../api/dio_module.dart' as _i23;
import '../api/interceptors/token_interceptor.dart' as _i20;
import '../bloc/auth/auth_bloc.dart' as _i21;
import '../bloc/care_plan/care_plan_bloc.dart' as _i22;
import '../bloc/settings/settings_bloc.dart' as _i19;
import '../bloc/user_content/content_bloc.dart' as _i18;
import '../bloc/warning/warning_bloc.dart' as _i12;
import '../cubit/auth_web/auth_web_cubit.dart' as _i5;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i7;
import '../cubit/omron/omron_connection_cubit.dart' as _i8;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/settings_db_provider.dart' as _i10;
import '../repositories/account_repository.dart' as _i14;
import '../repositories/care_plans_repository.dart' as _i17;
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
  gh.singleton<_i12.WarningBloc>(_i12.WarningBloc(get<_i9.Session>()));
  gh.factory<_i13.AccountApiClient>(
      () => _i13.AccountApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i14.AccountRepository>(
      _i14.AccountRepository(get<_i13.AccountApiClient>()));
  gh.factory<_i15.AuthApiClient>(
      () => _i15.AuthApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.factory<_i16.CarePlanApiClient>(
      () => _i16.CarePlanApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i17.CarePlansRepository>(_i17.CarePlansRepository(
    get<_i16.CarePlanApiClient>(),
    get<_i9.Session>(),
  ));
  gh.singleton<_i18.ContentBloc>(_i18.ContentBloc(
    get<_i3.AccountDbProvider>(),
    get<_i9.Session>(),
    get<_i17.CarePlansRepository>(),
  ));
  gh.factory<_i19.SettingsBloc>(() => _i19.SettingsBloc(
        get<_i11.SettingsService>(),
        get<_i10.SettingsDbProvider>(),
      ));
  gh.factory<_i20.TokenInterceptor>(() => _i20.TokenInterceptor(
        get<_i9.Session>(),
        get<_i13.AccountApiClient>(),
      ));
  gh.singleton<_i21.AuthBloc>(_i21.AuthBloc(
    get<_i4.AuthService>(),
    get<_i14.AccountRepository>(),
    get<_i17.CarePlansRepository>(),
    get<_i9.Session>(),
    get<_i3.AccountDbProvider>(),
    get<_i6.Dio>(instanceName: 'privateDio'),
  ));
  gh.factory<_i22.CarePlanBloc>(() => _i22.CarePlanBloc(
        get<_i17.CarePlansRepository>(),
        get<_i3.AccountDbProvider>(),
        get<_i9.Session>(),
      ));
  return get;
}

class _$DioModule extends _i23.DioModule {}
