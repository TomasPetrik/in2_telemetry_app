// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:scalesoft_app/api/client/account_api_client.dart' as _i19;
import 'package:scalesoft_app/api/client/auth_api_client.dart' as _i22;
import 'package:scalesoft_app/api/client/care_plan_api_client.dart' as _i23;
import 'package:scalesoft_app/api/client/time_settings_api_client.dart' as _i16;
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart' as _i28;
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart' as _i29;
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart' as _i7;
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_bloc.dart'
    as _i18;
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart'
    as _i26;
import 'package:scalesoft_app/bloc/results/results_bloc.dart' as _i13;
import 'package:scalesoft_app/bloc/settings/app_settings_bloc.dart' as _i21;
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart' as _i30;
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart' as _i25;
import 'package:scalesoft_app/cubit/auth_web/auth_web_cubit.dart' as _i6;
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_cubit.dart'
    as _i9;
import 'package:scalesoft_app/cubit/omron/omron_connection_cubit.dart' as _i11;
import 'package:scalesoft_app/providers/account_db_provider.dart' as _i3;
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart'
    as _i12;
import 'package:scalesoft_app/providers/session_db_provider.dart' as _i15;
import 'package:scalesoft_app/providers/settings_db_provider.dart' as _i4;
import 'package:scalesoft_app/repositories/account_repository.dart' as _i20;
import 'package:scalesoft_app/repositories/care_plans_repository.dart' as _i24;
import 'package:scalesoft_app/repositories/time_settings_repository.dart'
    as _i17;
import 'package:scalesoft_app/services/auth_service.dart' as _i5;
import 'package:scalesoft_app/services/internet_service.dart' as _i10;
import 'package:scalesoft_app/services/sync_service.dart' as _i27;
import 'package:scalesoft_app/storage/session.dart' as _i14;

import '../api/dio_module.dart' as _i31;

/// ignore_for_file: unnecessary_lambdas
/// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of main-scope dependencies inside of [GetIt]
_i1.GetIt init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final dioModule = _$DioModule();
  gh.singleton<_i3.AccountDbProvider>(_i3.AccountDbProvider());
  gh.singleton<_i4.AppSettingsDbProvider>(_i4.AppSettingsDbProvider());
  gh.singleton<_i5.AuthService>(_i5.AuthService());
  gh.factory<_i6.AuthWebCubit>(() => _i6.AuthWebCubit());
  gh.singleton<_i7.CarePlanBloc>(_i7.CarePlanBloc());
  gh.singleton<_i8.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.factory<_i9.HospitalSearchCubit>(() => _i9.HospitalSearchCubit());
  gh.singleton<_i10.InternetService>(_i10.InternetService());
  gh.singleton<_i11.OmronConnectionCubit>(_i11.OmronConnectionCubit());
  gh.singleton<_i12.PendingResultsDbProvider>(_i12.PendingResultsDbProvider());
  gh.singleton<_i13.ResultsBloc>(_i13.ResultsBloc());
  gh.singleton<_i14.Session>(_i14.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i12.PendingResultsDbProvider>(),
  ));
  gh.singleton<_i15.SessionDbProvider>(_i15.SessionDbProvider());
  gh.factory<_i16.TimeSettingsApiClient>(() =>
      _i16.TimeSettingsApiClient(gh<_i8.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i17.TimeSettingsRepository>(_i17.TimeSettingsRepository(
    gh<_i16.TimeSettingsApiClient>(),
    gh<_i14.Session>(),
  ));
  gh.factory<_i18.TimesSettingsBloc>(() => _i18.TimesSettingsBloc(
        gh<_i10.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i17.TimeSettingsRepository>(),
      ));
  gh.factory<_i19.AccountApiClient>(
      () => _i19.AccountApiClient(gh<_i8.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i20.AccountRepository>(
      _i20.AccountRepository(gh<_i19.AccountApiClient>()));
  gh.singleton<_i21.AppSettingsBloc>(
      _i21.AppSettingsBloc(gh<_i4.AppSettingsDbProvider>()));
  gh.factory<_i22.AuthApiClient>(
      () => _i22.AuthApiClient(gh<_i8.Dio>(instanceName: 'privateDio')));
  gh.factory<_i23.CarePlanApiClient>(
      () => _i23.CarePlanApiClient(gh<_i8.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i24.CarePlansRepository>(_i24.CarePlansRepository(
    gh<_i23.CarePlanApiClient>(),
    gh<_i14.Session>(),
  ));
  gh.singleton<_i25.ContentBloc>(_i25.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i15.SessionDbProvider>(),
    gh<_i14.Session>(),
  ));
  gh.singleton<_i26.NotificationsBloc>(_i26.NotificationsBloc(
    gh<_i14.Session>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.singleton<_i27.SyncService>(_i27.SyncService(
    gh<_i14.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i12.PendingResultsDbProvider>(),
    gh<_i24.CarePlansRepository>(),
    gh<_i17.TimeSettingsRepository>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.factory<_i28.TokenInterceptor>(() => _i28.TokenInterceptor(
        gh<_i14.Session>(),
        gh<_i19.AccountApiClient>(),
      ));
  gh.singleton<_i29.AuthBloc>(_i29.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i20.AccountRepository>(),
    gh<_i14.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i12.PendingResultsDbProvider>(),
    gh<_i8.Dio>(instanceName: 'privateDio'),
    gh<_i27.SyncService>(),
  ));
  gh.singleton<_i30.SyncBloc>(_i30.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i27.SyncService>(),
    gh<_i14.Session>(),
  ));
  return getIt;
}

class _$DioModule extends _i31.DioModule {}
