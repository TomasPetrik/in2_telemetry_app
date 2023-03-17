// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:scalesoft_app/api/client/account_api_client.dart' as _i21;
import 'package:scalesoft_app/api/client/auth_api_client.dart' as _i24;
import 'package:scalesoft_app/api/client/care_plan_api_client.dart' as _i26;
import 'package:scalesoft_app/api/client/time_settings_api_client.dart' as _i18;
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart' as _i31;
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart' as _i32;
import 'package:scalesoft_app/bloc/calendar/calendar_bloc.dart' as _i25;
import 'package:scalesoft_app/bloc/calendar_service/calendar_service_bloc.dart'
    as _i33;
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart' as _i9;
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_bloc.dart'
    as _i20;
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart'
    as _i29;
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc.dart' as _i35;
import 'package:scalesoft_app/bloc/results/results_bloc.dart' as _i15;
import 'package:scalesoft_app/bloc/settings/app_settings_bloc.dart' as _i23;
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart' as _i34;
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart' as _i28;
import 'package:scalesoft_app/cubit/auth_web/auth_web_cubit.dart' as _i6;
import 'package:scalesoft_app/cubit/calendar_footer/calendar_footer_cubit.dart'
    as _i8;
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_cubit.dart'
    as _i11;
import 'package:scalesoft_app/providers/account_db_provider.dart' as _i3;
import 'package:scalesoft_app/providers/calendar_db_provider.dart' as _i7;
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart'
    as _i13;
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart'
    as _i14;
import 'package:scalesoft_app/providers/session_db_provider.dart' as _i17;
import 'package:scalesoft_app/providers/settings_db_provider.dart' as _i4;
import 'package:scalesoft_app/repositories/account_repository.dart' as _i22;
import 'package:scalesoft_app/repositories/care_plans_repository.dart' as _i27;
import 'package:scalesoft_app/repositories/time_settings_repository.dart'
    as _i19;
import 'package:scalesoft_app/services/auth_service.dart' as _i5;
import 'package:scalesoft_app/services/internet_service.dart' as _i12;
import 'package:scalesoft_app/services/sync_service.dart' as _i30;
import 'package:scalesoft_app/storage/session.dart' as _i16;

import '../api/dio_module.dart' as _i36;

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
  gh.singleton<_i7.CalendarDbProvider>(_i7.CalendarDbProvider());
  gh.singleton<_i8.CalendarFooterCubit>(_i8.CalendarFooterCubit());
  gh.singleton<_i9.CarePlanBloc>(_i9.CarePlanBloc());
  gh.singleton<_i10.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i11.HospitalSearchCubit>(_i11.HospitalSearchCubit());
  gh.singleton<_i12.InternetService>(_i12.InternetService());
  gh.singleton<_i13.PairedDevicesDbProvider>(_i13.PairedDevicesDbProvider());
  gh.singleton<_i14.PendingResultsDbProvider>(_i14.PendingResultsDbProvider());
  gh.singleton<_i15.ResultsBloc>(_i15.ResultsBloc());
  gh.singleton<_i16.Session>(_i16.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i14.PendingResultsDbProvider>(),
  ));
  gh.singleton<_i17.SessionDbProvider>(_i17.SessionDbProvider());
  gh.factory<_i18.TimeSettingsApiClient>(() =>
      _i18.TimeSettingsApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i19.TimeSettingsRepository>(_i19.TimeSettingsRepository(
    gh<_i18.TimeSettingsApiClient>(),
    gh<_i16.Session>(),
  ));
  gh.factory<_i20.TimesSettingsBloc>(() => _i20.TimesSettingsBloc(
        gh<_i12.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i19.TimeSettingsRepository>(),
      ));
  gh.factory<_i21.AccountApiClient>(
      () => _i21.AccountApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i22.AccountRepository>(
      _i22.AccountRepository(gh<_i21.AccountApiClient>()));
  gh.singleton<_i23.AppSettingsBloc>(
      _i23.AppSettingsBloc(gh<_i4.AppSettingsDbProvider>()));
  gh.factory<_i24.AuthApiClient>(
      () => _i24.AuthApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.factory<_i25.CalendarBloc>(() => _i25.CalendarBloc(
        gh<_i16.Session>(),
        gh<_i8.CalendarFooterCubit>(),
      ));
  gh.factory<_i26.CarePlanApiClient>(
      () => _i26.CarePlanApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i27.CarePlansRepository>(_i27.CarePlansRepository(
    gh<_i26.CarePlanApiClient>(),
    gh<_i16.Session>(),
  ));
  gh.singleton<_i28.ContentBloc>(_i28.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i17.SessionDbProvider>(),
    gh<_i16.Session>(),
  ));
  gh.singleton<_i29.NotificationsBloc>(_i29.NotificationsBloc(
    gh<_i16.Session>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.singleton<_i30.SyncService>(_i30.SyncService(
    gh<_i16.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i14.PendingResultsDbProvider>(),
    gh<_i27.CarePlansRepository>(),
    gh<_i19.TimeSettingsRepository>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.factory<_i31.TokenInterceptor>(() => _i31.TokenInterceptor(
        gh<_i16.Session>(),
        gh<_i21.AccountApiClient>(),
      ));
  gh.singleton<_i32.AuthBloc>(_i32.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i22.AccountRepository>(),
    gh<_i16.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i14.PendingResultsDbProvider>(),
    gh<_i10.Dio>(instanceName: 'privateDio'),
    gh<_i30.SyncService>(),
  ));
  gh.factory<_i33.CalendarServiceBloc>(() => _i33.CalendarServiceBloc(
        gh<_i16.Session>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i8.CalendarFooterCubit>(),
        gh<_i27.CarePlansRepository>(),
        gh<_i7.CalendarDbProvider>(),
        gh<_i14.PendingResultsDbProvider>(),
      ));
  gh.singleton<_i34.SyncBloc>(_i34.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i30.SyncService>(),
    gh<_i16.Session>(),
  ));
  gh.factory<_i35.OmronConnectionBloc>(() => _i35.OmronConnectionBloc(
        gh<_i14.PendingResultsDbProvider>(),
        gh<_i13.PairedDevicesDbProvider>(),
        gh<_i34.SyncBloc>(),
      ));
  return getIt;
}

class _$DioModule extends _i36.DioModule {}
