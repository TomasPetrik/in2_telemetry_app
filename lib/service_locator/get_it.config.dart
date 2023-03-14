// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:scalesoft_app/api/client/account_api_client.dart' as _i20;
import 'package:scalesoft_app/api/client/auth_api_client.dart' as _i23;
import 'package:scalesoft_app/api/client/care_plan_api_client.dart' as _i24;
import 'package:scalesoft_app/api/client/time_settings_api_client.dart' as _i17;
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart' as _i29;
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart' as _i30;
import 'package:scalesoft_app/bloc/calendar/calendar_bloc.dart' as _i7;
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart' as _i8;
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_bloc.dart'
    as _i19;
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart'
    as _i27;
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc.dart' as _i32;
import 'package:scalesoft_app/bloc/results/results_bloc.dart' as _i14;
import 'package:scalesoft_app/bloc/settings/app_settings_bloc.dart' as _i22;
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart' as _i31;
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart' as _i26;
import 'package:scalesoft_app/cubit/auth_web/auth_web_cubit.dart' as _i6;
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_cubit.dart'
    as _i10;
import 'package:scalesoft_app/providers/account_db_provider.dart' as _i3;
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart'
    as _i12;
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart'
    as _i13;
import 'package:scalesoft_app/providers/session_db_provider.dart' as _i16;
import 'package:scalesoft_app/providers/settings_db_provider.dart' as _i4;
import 'package:scalesoft_app/repositories/account_repository.dart' as _i21;
import 'package:scalesoft_app/repositories/care_plans_repository.dart' as _i25;
import 'package:scalesoft_app/repositories/time_settings_repository.dart'
    as _i18;
import 'package:scalesoft_app/services/auth_service.dart' as _i5;
import 'package:scalesoft_app/services/internet_service.dart' as _i11;
import 'package:scalesoft_app/services/sync_service.dart' as _i28;
import 'package:scalesoft_app/storage/session.dart' as _i15;

import '../api/dio_module.dart' as _i33;

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
  gh.factory<_i7.CalendarBloc>(() => _i7.CalendarBloc());
  gh.singleton<_i8.CarePlanBloc>(_i8.CarePlanBloc());
  gh.singleton<_i9.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.factory<_i10.HospitalSearchCubit>(() => _i10.HospitalSearchCubit());
  gh.singleton<_i11.InternetService>(_i11.InternetService());
  gh.singleton<_i12.PairedDevicesDbProvider>(_i12.PairedDevicesDbProvider());
  gh.singleton<_i13.PendingResultsDbProvider>(_i13.PendingResultsDbProvider());
  gh.singleton<_i14.ResultsBloc>(_i14.ResultsBloc());
  gh.singleton<_i15.Session>(_i15.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i13.PendingResultsDbProvider>(),
  ));
  gh.singleton<_i16.SessionDbProvider>(_i16.SessionDbProvider());
  gh.factory<_i17.TimeSettingsApiClient>(() =>
      _i17.TimeSettingsApiClient(gh<_i9.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i18.TimeSettingsRepository>(_i18.TimeSettingsRepository(
    gh<_i17.TimeSettingsApiClient>(),
    gh<_i15.Session>(),
  ));
  gh.factory<_i19.TimesSettingsBloc>(() => _i19.TimesSettingsBloc(
        gh<_i11.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i18.TimeSettingsRepository>(),
      ));
  gh.factory<_i20.AccountApiClient>(
      () => _i20.AccountApiClient(gh<_i9.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i21.AccountRepository>(
      _i21.AccountRepository(gh<_i20.AccountApiClient>()));
  gh.singleton<_i22.AppSettingsBloc>(
      _i22.AppSettingsBloc(gh<_i4.AppSettingsDbProvider>()));
  gh.factory<_i23.AuthApiClient>(
      () => _i23.AuthApiClient(gh<_i9.Dio>(instanceName: 'privateDio')));
  gh.factory<_i24.CarePlanApiClient>(
      () => _i24.CarePlanApiClient(gh<_i9.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i25.CarePlansRepository>(_i25.CarePlansRepository(
    gh<_i24.CarePlanApiClient>(),
    gh<_i15.Session>(),
  ));
  gh.singleton<_i26.ContentBloc>(_i26.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i16.SessionDbProvider>(),
    gh<_i15.Session>(),
  ));
  gh.singleton<_i27.NotificationsBloc>(_i27.NotificationsBloc(
    gh<_i15.Session>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.singleton<_i28.SyncService>(_i28.SyncService(
    gh<_i15.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i13.PendingResultsDbProvider>(),
    gh<_i25.CarePlansRepository>(),
    gh<_i18.TimeSettingsRepository>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.factory<_i29.TokenInterceptor>(() => _i29.TokenInterceptor(
        gh<_i15.Session>(),
        gh<_i20.AccountApiClient>(),
      ));
  gh.singleton<_i30.AuthBloc>(_i30.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i21.AccountRepository>(),
    gh<_i15.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i13.PendingResultsDbProvider>(),
    gh<_i9.Dio>(instanceName: 'privateDio'),
    gh<_i28.SyncService>(),
  ));
  gh.singleton<_i31.SyncBloc>(_i31.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i28.SyncService>(),
    gh<_i15.Session>(),
  ));
  gh.factory<_i32.OmronConnectionBloc>(() => _i32.OmronConnectionBloc(
        gh<_i13.PendingResultsDbProvider>(),
        gh<_i12.PairedDevicesDbProvider>(),
        gh<_i31.SyncBloc>(),
      ));
  return getIt;
}

class _$DioModule extends _i33.DioModule {}
