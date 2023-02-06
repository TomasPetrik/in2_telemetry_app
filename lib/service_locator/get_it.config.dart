// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i6;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i14;
import '../api/client/auth_api_client.dart' as _i16;
import '../api/client/care_plan_api_client.dart' as _i17;
import '../api/dio_module.dart' as _i25;
import '../api/interceptors/token_interceptor.dart' as _i22;
import '../bloc/auth/auth_bloc.dart' as _i23;
import '../bloc/care_plan/care_plan_bloc.dart' as _i24;
import '../bloc/settings/settings_bloc.dart' as _i20;
import '../bloc/sync/sync_bloc.dart' as _i21;
import '../bloc/user_content/content_bloc.dart' as _i19;
import '../bloc/warning/warning_bloc.dart' as _i13;
import '../cubit/auth_web/auth_web_cubit.dart' as _i5;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i7;
import '../cubit/omron/omron_connection_cubit.dart' as _i8;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/pending_results_dbs_provider.dart' as _i9;
import '../providers/settings_db_provider.dart' as _i11;
import '../repositories/account_repository.dart' as _i15;
import '../repositories/care_plans_repository.dart' as _i18;
import '../services/auth_service.dart' as _i4;
import '../services/settings_service.dart' as _i12;
import '../storage/session.dart'
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
  gh.singleton<_i3.AccountDbProvider>(_i3.AccountDbProvider());
  gh.singleton<_i4.AuthService>(_i4.AuthService());
  gh.factory<_i5.AuthWebCubit>(() => _i5.AuthWebCubit());
  gh.singleton<_i6.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.factory<_i7.HospitalSearchCubit>(() => _i7.HospitalSearchCubit());
  gh.singleton<_i8.OmronConnectionCubit>(_i8.OmronConnectionCubit());
  gh.singleton<_i9.PendingResultsDbProvider>(_i9.PendingResultsDbProvider());
  gh.singleton<_i10.Session>(_i10.Session());
  gh.singleton<_i11.SettingsDbProvider>(_i11.SettingsDbProvider());
  await gh.lazySingletonAsync<_i12.SettingsService>(
    () => _i12.SettingsService.create(),
    preResolve: true,
    dispose: (i) => i.dispose(),
  );
  gh.singleton<_i13.WarningBloc>(
      _i13.WarningBloc(get<_i3.AccountDbProvider>()));
  gh.factory<_i14.AccountApiClient>(
      () => _i14.AccountApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i15.AccountRepository>(
      _i15.AccountRepository(get<_i14.AccountApiClient>()));
  gh.factory<_i16.AuthApiClient>(
      () => _i16.AuthApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.factory<_i17.CarePlanApiClient>(
      () => _i17.CarePlanApiClient(get<_i6.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i18.CarePlansRepository>(_i18.CarePlansRepository(
    get<_i17.CarePlanApiClient>(),
    get<_i10.Session>(),
  ));
  gh.singleton<_i19.ContentBloc>(_i19.ContentBloc(
    get<_i3.AccountDbProvider>(),
    get<_i10.Session>(),
    get<_i18.CarePlansRepository>(),
  ));
  gh.factory<_i20.SettingsBloc>(() => _i20.SettingsBloc(
        get<_i12.SettingsService>(),
        get<_i11.SettingsDbProvider>(),
      ));
  gh.singleton<_i21.SyncBloc>(_i21.SyncBloc(
    get<_i9.PendingResultsDbProvider>(),
    get<_i3.AccountDbProvider>(),
    get<_i18.CarePlansRepository>(),
  ));
  gh.factory<_i22.TokenInterceptor>(() => _i22.TokenInterceptor(
        get<_i10.Session>(),
        get<_i14.AccountApiClient>(),
      ));
  gh.singleton<_i23.AuthBloc>(_i23.AuthBloc(
    get<_i4.AuthService>(),
    get<_i15.AccountRepository>(),
    get<_i18.CarePlansRepository>(),
    get<_i10.Session>(),
    get<_i3.AccountDbProvider>(),
    get<_i6.Dio>(instanceName: 'privateDio'),
  ));
  gh.factory<_i24.CarePlanBloc>(() => _i24.CarePlanBloc(
        get<_i18.CarePlansRepository>(),
        get<_i3.AccountDbProvider>(),
        get<_i10.Session>(),
      ));
  return get;
}

class _$DioModule extends _i25.DioModule {}
