// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:scalesoft_app/api/client/account_api_client.dart' as _i20;
import 'package:scalesoft_app/api/client/auth_api_client.dart' as _i22;
import 'package:scalesoft_app/api/client/care_plan_api_client.dart' as _i23;
import 'package:scalesoft_app/api/client/time_settings_api_client.dart' as _i17;
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart' as _i28;
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart' as _i29;
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart' as _i6;
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_bloc.dart'
    as _i19;
import 'package:scalesoft_app/bloc/results/results_bloc.dart' as _i12;
import 'package:scalesoft_app/bloc/settings/settings_bloc.dart' as _i26;
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart' as _i30;
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart' as _i25;
import 'package:scalesoft_app/cubit/auth_web/auth_web_cubit.dart' as _i5;
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_cubit.dart'
    as _i8;
import 'package:scalesoft_app/cubit/omron/omron_connection_cubit.dart' as _i10;
import 'package:scalesoft_app/providers/account_db_provider.dart' as _i3;
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart'
    as _i11;
import 'package:scalesoft_app/providers/session_db_provider.dart' as _i14;
import 'package:scalesoft_app/providers/settings_db_provider.dart' as _i15;
import 'package:scalesoft_app/repositories/account_repository.dart' as _i21;
import 'package:scalesoft_app/repositories/care_plans_repository.dart' as _i24;
import 'package:scalesoft_app/repositories/time_settings_repository.dart'
    as _i18;
import 'package:scalesoft_app/services/auth_service.dart' as _i4;
import 'package:scalesoft_app/services/internet_service.dart' as _i9;
import 'package:scalesoft_app/services/settings_service.dart' as _i16;
import 'package:scalesoft_app/services/sync_service.dart' as _i27;
import 'package:scalesoft_app/storage/session.dart' as _i13;

import '../api/dio_module.dart' as _i31;

/// ignore_for_file: unnecessary_lambdas
/// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of main-scope dependencies inside of [GetIt]
Future<_i1.GetIt> init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final dioModule = _$DioModule();
  gh.singleton<_i3.AccountDbProvider>(_i3.AccountDbProvider());
  gh.singleton<_i4.AuthService>(_i4.AuthService());
  gh.factory<_i5.AuthWebCubit>(() => _i5.AuthWebCubit());
  gh.singleton<_i6.CarePlanBloc>(_i6.CarePlanBloc());
  gh.singleton<_i7.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.factory<_i8.HospitalSearchCubit>(() => _i8.HospitalSearchCubit());
  gh.singleton<_i9.InternetService>(_i9.InternetService());
  gh.singleton<_i10.OmronConnectionCubit>(_i10.OmronConnectionCubit());
  gh.singleton<_i11.PendingResultsDbProvider>(_i11.PendingResultsDbProvider());
  gh.singleton<_i12.ResultsBloc>(_i12.ResultsBloc());
  gh.singleton<_i13.Session>(_i13.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i11.PendingResultsDbProvider>(),
  ));
  gh.singleton<_i14.SessionDbProvider>(_i14.SessionDbProvider());
  gh.singleton<_i15.SettingsDbProvider>(_i15.SettingsDbProvider());
  await gh.lazySingletonAsync<_i16.SettingsService>(
    () => _i16.SettingsService.create(),
    preResolve: true,
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i17.TimeSettingsApiClient>(() =>
      _i17.TimeSettingsApiClient(gh<_i7.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i18.TimeSettingsRepository>(_i18.TimeSettingsRepository(
    gh<_i17.TimeSettingsApiClient>(),
    gh<_i13.Session>(),
  ));
  gh.factory<_i19.TimesSettingsBloc>(() => _i19.TimesSettingsBloc(
        gh<_i9.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i18.TimeSettingsRepository>(),
      ));
  gh.factory<_i20.AccountApiClient>(
      () => _i20.AccountApiClient(gh<_i7.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i21.AccountRepository>(
      _i21.AccountRepository(gh<_i20.AccountApiClient>()));
  gh.factory<_i22.AuthApiClient>(
      () => _i22.AuthApiClient(gh<_i7.Dio>(instanceName: 'privateDio')));
  gh.factory<_i23.CarePlanApiClient>(
      () => _i23.CarePlanApiClient(gh<_i7.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i24.CarePlansRepository>(_i24.CarePlansRepository(
    gh<_i23.CarePlanApiClient>(),
    gh<_i13.Session>(),
  ));
  gh.singleton<_i25.ContentBloc>(_i25.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i14.SessionDbProvider>(),
    gh<_i13.Session>(),
  ));
  gh.factory<_i26.SettingsBloc>(() => _i26.SettingsBloc(
        gh<_i16.SettingsService>(),
        gh<_i15.SettingsDbProvider>(),
      ));
  gh.singleton<_i27.SyncService>(_i27.SyncService(
    gh<_i13.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i11.PendingResultsDbProvider>(),
    gh<_i24.CarePlansRepository>(),
    gh<_i18.TimeSettingsRepository>(),
  ));
  gh.factory<_i28.TokenInterceptor>(() => _i28.TokenInterceptor(
        gh<_i13.Session>(),
        gh<_i20.AccountApiClient>(),
      ));
  gh.singleton<_i29.AuthBloc>(_i29.AuthBloc(
    gh<_i4.AuthService>(),
    gh<_i21.AccountRepository>(),
    gh<_i13.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i11.PendingResultsDbProvider>(),
    gh<_i7.Dio>(instanceName: 'privateDio'),
    gh<_i27.SyncService>(),
  ));
  gh.singleton<_i30.SyncBloc>(_i30.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i27.SyncService>(),
    gh<_i13.Session>(),
  ));
  return getIt;
}

class _$DioModule extends _i31.DioModule {}
