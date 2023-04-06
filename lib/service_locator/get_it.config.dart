// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:scalesoft_app/api/client/account_api_client.dart' as _i24;
import 'package:scalesoft_app/api/client/auth_api_client.dart' as _i27;
import 'package:scalesoft_app/api/client/care_plan_api_client.dart' as _i29;
import 'package:scalesoft_app/api/client/time_settings_api_client.dart' as _i21;
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart' as _i37;
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart' as _i38;
import 'package:scalesoft_app/bloc/calendar/calendar_bloc.dart' as _i28;
import 'package:scalesoft_app/bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i39;
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart' as _i9;
import 'package:scalesoft_app/bloc/chart_bloc/chart_bloc.dart' as _i10;
import 'package:scalesoft_app/bloc/chart_loader_bloc/chart_loader_bloc.dart'
    as _i31;
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_bloc.dart'
    as _i23;
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart'
    as _i34;
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc.dart' as _i41;
import 'package:scalesoft_app/bloc/register_device/register_device_bloc.dart'
    as _i35;
import 'package:scalesoft_app/bloc/results/results_bloc.dart' as _i18;
import 'package:scalesoft_app/bloc/settings/app_settings_bloc.dart' as _i26;
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart' as _i40;
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart' as _i32;
import 'package:scalesoft_app/cubit/auth_web/auth_web_cubit.dart' as _i6;
import 'package:scalesoft_app/cubit/calendar_footer/calendar_footer_cubit.dart'
    as _i8;
import 'package:scalesoft_app/cubit/device_management/device_management_cubit.dart'
    as _i33;
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_cubit.dart'
    as _i12;
import 'package:scalesoft_app/providers/account_db_provider.dart' as _i3;
import 'package:scalesoft_app/providers/calendar_db_provider.dart' as _i7;
import 'package:scalesoft_app/providers/measurements_db_provider.dart' as _i15;
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart'
    as _i16;
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart'
    as _i17;
import 'package:scalesoft_app/providers/session_db_provider.dart' as _i20;
import 'package:scalesoft_app/providers/settings_db_provider.dart' as _i4;
import 'package:scalesoft_app/repositories/account_repository.dart' as _i25;
import 'package:scalesoft_app/repositories/care_plans_repository.dart' as _i30;
import 'package:scalesoft_app/repositories/time_settings_repository.dart'
    as _i22;
import 'package:scalesoft_app/services/auth_service.dart' as _i5;
import 'package:scalesoft_app/services/internet_service.dart' as _i13;
import 'package:scalesoft_app/services/location_service.dart' as _i14;
import 'package:scalesoft_app/services/sync_service.dart' as _i36;
import 'package:scalesoft_app/storage/session.dart' as _i19;

import '../api/dio_module.dart' as _i42;

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// initializes the registration of main-scope dependencies inside of GetIt
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
  gh.factory<_i10.ChartBloc>(() => _i10.ChartBloc());
  gh.singleton<_i11.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i12.HospitalSearchCubit>(_i12.HospitalSearchCubit());
  gh.singleton<_i13.InternetService>(_i13.InternetService());
  gh.lazySingleton<_i14.LocationService>(() => _i14.LocationService());
  gh.singleton<_i15.MeasurementsDbProvider>(_i15.MeasurementsDbProvider());
  gh.singleton<_i16.PairedDevicesDbProvider>(_i16.PairedDevicesDbProvider());
  gh.singleton<_i17.PendingResultsDbProvider>(_i17.PendingResultsDbProvider());
  gh.singleton<_i18.ResultsBloc>(_i18.ResultsBloc());
  gh.singleton<_i19.Session>(_i19.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i17.PendingResultsDbProvider>(),
  ));
  gh.singleton<_i20.SessionDbProvider>(_i20.SessionDbProvider());
  gh.factory<_i21.TimeSettingsApiClient>(() =>
      _i21.TimeSettingsApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i22.TimeSettingsRepository>(_i22.TimeSettingsRepository(
    gh<_i21.TimeSettingsApiClient>(),
    gh<_i19.Session>(),
  ));
  gh.factory<_i23.TimesSettingsBloc>(() => _i23.TimesSettingsBloc(
        gh<_i13.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i22.TimeSettingsRepository>(),
      ));
  gh.factory<_i24.AccountApiClient>(
      () => _i24.AccountApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i25.AccountRepository>(
      _i25.AccountRepository(gh<_i24.AccountApiClient>()));
  gh.singleton<_i26.AppSettingsBloc>(_i26.AppSettingsBloc(
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i14.LocationService>(),
  ));
  gh.factory<_i27.AuthApiClient>(
      () => _i27.AuthApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.factory<_i28.CalendarBloc>(() => _i28.CalendarBloc(
        gh<_i19.Session>(),
        gh<_i8.CalendarFooterCubit>(),
      ));
  gh.factory<_i29.CarePlanApiClient>(
      () => _i29.CarePlanApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i30.CarePlansRepository>(_i30.CarePlansRepository(
    gh<_i29.CarePlanApiClient>(),
    gh<_i19.Session>(),
  ));
  gh.factory<_i31.ChartLoaderBloc>(() => _i31.ChartLoaderBloc(
        gh<_i30.CarePlansRepository>(),
        gh<_i15.MeasurementsDbProvider>(),
        gh<_i17.PendingResultsDbProvider>(),
      ));
  gh.singleton<_i32.ContentBloc>(_i32.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i20.SessionDbProvider>(),
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i19.Session>(),
    gh<_i9.CarePlanBloc>(),
    gh<_i14.LocationService>(),
  ));
  gh.factory<_i33.DeviceManagementCubit>(
      () => _i33.DeviceManagementCubit(gh<_i16.PairedDevicesDbProvider>()));
  gh.singleton<_i34.NotificationsBloc>(_i34.NotificationsBloc(
    gh<_i19.Session>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.factory<_i35.RegisterDeviceBloc>(
      () => _i35.RegisterDeviceBloc(gh<_i30.CarePlansRepository>()));
  gh.singleton<_i36.SyncService>(_i36.SyncService(
    gh<_i19.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i17.PendingResultsDbProvider>(),
    gh<_i30.CarePlansRepository>(),
    gh<_i22.TimeSettingsRepository>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.factory<_i37.TokenInterceptor>(() => _i37.TokenInterceptor(
        gh<_i19.Session>(),
        gh<_i24.AccountApiClient>(),
      ));
  gh.singleton<_i38.AuthBloc>(_i38.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i25.AccountRepository>(),
    gh<_i19.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i17.PendingResultsDbProvider>(),
    gh<_i11.Dio>(instanceName: 'privateDio'),
    gh<_i36.SyncService>(),
  ));
  gh.factory<_i39.CalendarFulfillmentServiceBloc>(
      () => _i39.CalendarFulfillmentServiceBloc(
            gh<_i3.AccountDbProvider>(),
            gh<_i8.CalendarFooterCubit>(),
            gh<_i30.CarePlansRepository>(),
            gh<_i7.CalendarDbProvider>(),
          ));
  gh.singleton<_i40.SyncBloc>(_i40.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i36.SyncService>(),
    gh<_i19.Session>(),
  ));
  gh.factory<_i41.OmronConnectionBloc>(() => _i41.OmronConnectionBloc(
        gh<_i17.PendingResultsDbProvider>(),
        gh<_i16.PairedDevicesDbProvider>(),
        gh<_i40.SyncBloc>(),
      ));
  return getIt;
}

class _$DioModule extends _i42.DioModule {}
