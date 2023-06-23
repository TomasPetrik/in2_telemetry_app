// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i25;
import '../api/client/auth_api_client.dart' as _i28;
import '../api/client/care_plan_api_client.dart' as _i30;
import '../api/client/device_api_client.dart' as _i34;
import '../api/client/time_settings_api_client.dart' as _i22;
import '../api/dio_module.dart' as _i44;
import '../api/interceptors/token_interceptor.dart' as _i39;
import '../bloc/auth/auth_bloc.dart' as _i40;
import '../bloc/calendar/calendar_bloc.dart' as _i29;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i8;
import '../bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i41;
import '../bloc/care_plan/care_plan_bloc.dart' as _i9;
import '../bloc/chart_bloc/chart_bloc.dart' as _i10;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i32;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i24;
import '../bloc/notifications/notifications_bloc.dart' as _i16;
import '../bloc/omron/omron_connection_bloc.dart' as _i43;
import '../bloc/register_device/register_device_bloc.dart' as _i37;
import '../bloc/results/results_bloc.dart' as _i19;
import '../bloc/settings/app_settings_bloc.dart' as _i27;
import '../bloc/sync/sync_bloc.dart' as _i42;
import '../bloc/user_content/content_bloc.dart' as _i33;
import '../cubit/auth_web/auth_web_cubit.dart' as _i6;
import '../cubit/device_management/device_management_cubit.dart' as _i35;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i12;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/calendar_evaluation_db_provider.dart' as _i7;
import '../providers/measurements_db_provider.dart' as _i15;
import '../providers/paired_devices_db_provider.dart' as _i17;
import '../providers/pending_results_dbs_provider.dart' as _i18;
import '../providers/session_db_provider.dart' as _i21;
import '../providers/settings_db_provider.dart' as _i4;
import '../repositories/account_repository.dart' as _i26;
import '../repositories/care_plans_repository.dart' as _i31;
import '../repositories/device_repository.dart' as _i36;
import '../repositories/time_settings_repository.dart' as _i23;
import '../services/auth_service.dart' as _i5;
import '../services/internet_service.dart' as _i13;
import '../services/location_service.dart' as _i14;
import '../services/sync_service.dart' as _i38;
import '../storage/session.dart' as _i20;

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
  gh.singleton<_i7.CalendarEvaluationDbProvider>(
      _i7.CalendarEvaluationDbProvider());
  gh.singleton<_i8.CalendarFooterBloc>(_i8.CalendarFooterBloc());
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
  gh.singleton<_i16.NotificationsBloc>(_i16.NotificationsBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.singleton<_i17.PairedDevicesDbProvider>(_i17.PairedDevicesDbProvider());
  gh.singleton<_i18.PendingResultsDbProvider>(_i18.PendingResultsDbProvider());
  gh.factory<_i19.ResultsBloc>(() => _i19.ResultsBloc());
  gh.singleton<_i20.Session>(_i20.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i18.PendingResultsDbProvider>(),
  ));
  gh.singleton<_i21.SessionDbProvider>(_i21.SessionDbProvider());
  gh.factory<_i22.TimeSettingsApiClient>(() =>
      _i22.TimeSettingsApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i23.TimeSettingsRepository>(_i23.TimeSettingsRepository(
    gh<_i22.TimeSettingsApiClient>(),
    gh<_i20.Session>(),
  ));
  gh.factory<_i24.TimesSettingsBloc>(() => _i24.TimesSettingsBloc(
        gh<_i13.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i23.TimeSettingsRepository>(),
      ));
  gh.factory<_i25.AccountApiClient>(
      () => _i25.AccountApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i26.AccountRepository>(_i26.AccountRepository(
    gh<_i25.AccountApiClient>(),
    gh<_i20.Session>(),
  ));
  gh.singleton<_i27.AppSettingsBloc>(_i27.AppSettingsBloc(
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i14.LocationService>(),
  ));
  gh.factory<_i28.AuthApiClient>(
      () => _i28.AuthApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.factory<_i29.CalendarBloc>(() => _i29.CalendarBloc(
        gh<_i20.Session>(),
        gh<_i8.CalendarFooterBloc>(),
        gh<_i3.AccountDbProvider>(),
      ));
  gh.factory<_i30.CarePlanApiClient>(
      () => _i30.CarePlanApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i31.CarePlansRepository>(_i31.CarePlansRepository(
    gh<_i30.CarePlanApiClient>(),
    gh<_i20.Session>(),
  ));
  gh.factory<_i32.ChartLoaderBloc>(() => _i32.ChartLoaderBloc(
        gh<_i31.CarePlansRepository>(),
        gh<_i15.MeasurementsDbProvider>(),
        gh<_i18.PendingResultsDbProvider>(),
      ));
  gh.singleton<_i33.ContentBloc>(_i33.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i21.SessionDbProvider>(),
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i20.Session>(),
    gh<_i9.CarePlanBloc>(),
    gh<_i14.LocationService>(),
  ));
  gh.factory<_i34.DeviceApiClient>(
      () => _i34.DeviceApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.factory<_i35.DeviceManagementCubit>(() => _i35.DeviceManagementCubit(
        gh<_i3.AccountDbProvider>(),
        gh<_i17.PairedDevicesDbProvider>(),
      ));
  gh.singleton<_i36.DeviceRepository>(_i36.DeviceRepository(
    gh<_i34.DeviceApiClient>(),
    gh<_i20.Session>(),
  ));
  gh.factory<_i37.RegisterDeviceBloc>(
      () => _i37.RegisterDeviceBloc(gh<_i36.DeviceRepository>()));
  gh.singleton<_i38.SyncService>(_i38.SyncService(
    gh<_i20.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i18.PendingResultsDbProvider>(),
    gh<_i26.AccountRepository>(),
    gh<_i31.CarePlansRepository>(),
    gh<_i23.TimeSettingsRepository>(),
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i36.DeviceRepository>(),
  ));
  gh.factory<_i39.TokenInterceptor>(() => _i39.TokenInterceptor(
        gh<_i20.Session>(),
        gh<_i25.AccountApiClient>(),
        gh<_i3.AccountDbProvider>(),
      ));
  gh.singleton<_i40.AuthBloc>(_i40.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i26.AccountRepository>(),
    gh<_i20.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i18.PendingResultsDbProvider>(),
    gh<_i11.Dio>(instanceName: 'privateDio'),
    gh<_i38.SyncService>(),
  ));
  gh.factory<_i41.CalendarFulfillmentServiceBloc>(
      () => _i41.CalendarFulfillmentServiceBloc(
            gh<_i3.AccountDbProvider>(),
            gh<_i8.CalendarFooterBloc>(),
            gh<_i31.CarePlansRepository>(),
            gh<_i7.CalendarEvaluationDbProvider>(),
            gh<_i15.MeasurementsDbProvider>(),
            gh<_i18.PendingResultsDbProvider>(),
          ));
  gh.singleton<_i42.SyncBloc>(_i42.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i38.SyncService>(),
    gh<_i20.Session>(),
  ));
  gh.factory<_i43.OmronConnectionBloc>(() => _i43.OmronConnectionBloc(
        gh<_i3.AccountDbProvider>(),
        gh<_i18.PendingResultsDbProvider>(),
        gh<_i17.PairedDevicesDbProvider>(),
        gh<_i42.SyncBloc>(),
      ));
  return getIt;
}

class _$DioModule extends _i44.DioModule {}
