// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i12;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i26;
import '../api/client/auth_api_client.dart' as _i29;
import '../api/client/care_plan_api_client.dart' as _i31;
import '../api/client/device_api_client.dart' as _i35;
import '../api/client/time_settings_api_client.dart' as _i23;
import '../api/dio_module.dart' as _i45;
import '../api/interceptors/token_interceptor.dart' as _i41;
import '../bloc/auth/auth_bloc.dart' as _i42;
import '../bloc/calendar/calendar_bloc.dart' as _i30;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i8;
import '../bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i43;
import '../bloc/care_plan/care_plan_bloc.dart' as _i9;
import '../bloc/chart_bloc/chart_bloc.dart' as _i11;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i33;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i25;
import '../bloc/notifications/notifications_bloc.dart' as _i17;
import '../bloc/omron/omron_connection_bloc.dart' as _i38;
import '../bloc/register_device/register_device_bloc.dart' as _i39;
import '../bloc/results/results_bloc.dart' as _i20;
import '../bloc/settings/app_settings_bloc.dart' as _i28;
import '../bloc/sync/sync_bloc.dart' as _i44;
import '../bloc/user_content/content_bloc.dart' as _i34;
import '../cubit/auth_web/auth_web_cubit.dart' as _i6;
import '../cubit/device_management/device_management_cubit.dart' as _i36;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i13;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/calendar_evaluation_db_provider.dart' as _i7;
import '../providers/measurements_db_provider.dart' as _i16;
import '../providers/paired_devices_db_provider.dart' as _i18;
import '../providers/pending_results_dbs_provider.dart' as _i19;
import '../providers/session_db_provider.dart' as _i22;
import '../providers/settings_db_provider.dart' as _i4;
import '../repositories/account_repository.dart' as _i27;
import '../repositories/care_plans_repository.dart' as _i32;
import '../repositories/device_repository.dart' as _i37;
import '../repositories/time_settings_repository.dart' as _i24;
import '../services/auth_service.dart' as _i5;
import '../services/internet_service.dart' as _i14;
import '../services/location_service.dart' as _i15;
import '../services/sync_service.dart' as _i40;
import '../storage/session.dart' as _i21;
import '../utils/helpers/care_plan_helper.dart' as _i10;

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
  gh.singleton<_i10.CarePlanHelper>(_i10.CarePlanHelper());
  gh.factory<_i11.ChartBloc>(() => _i11.ChartBloc());
  gh.singleton<_i12.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i13.HospitalSearchCubit>(_i13.HospitalSearchCubit());
  gh.singleton<_i14.InternetService>(_i14.InternetService());
  gh.lazySingleton<_i15.LocationService>(() => _i15.LocationService());
  gh.singleton<_i16.MeasurementsDbProvider>(_i16.MeasurementsDbProvider());
  gh.singleton<_i17.NotificationsBloc>(_i17.NotificationsBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  gh.singleton<_i18.PairedDevicesDbProvider>(_i18.PairedDevicesDbProvider());
  gh.singleton<_i19.PendingResultsDbProvider>(_i19.PendingResultsDbProvider());
  gh.factory<_i20.ResultsBloc>(() => _i20.ResultsBloc());
  gh.singleton<_i21.Session>(_i21.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i19.PendingResultsDbProvider>(),
  ));
  gh.singleton<_i22.SessionDbProvider>(_i22.SessionDbProvider());
  gh.factory<_i23.TimeSettingsApiClient>(() =>
      _i23.TimeSettingsApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i24.TimeSettingsRepository>(_i24.TimeSettingsRepository(
    gh<_i23.TimeSettingsApiClient>(),
    gh<_i21.Session>(),
  ));
  gh.factory<_i25.TimesSettingsBloc>(() => _i25.TimesSettingsBloc(
        gh<_i14.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i24.TimeSettingsRepository>(),
      ));
  gh.factory<_i26.AccountApiClient>(
      () => _i26.AccountApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i27.AccountRepository>(_i27.AccountRepository(
    gh<_i26.AccountApiClient>(),
    gh<_i21.Session>(),
  ));
  gh.singleton<_i28.AppSettingsBloc>(_i28.AppSettingsBloc(
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i15.LocationService>(),
  ));
  gh.factory<_i29.AuthApiClient>(
      () => _i29.AuthApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.factory<_i30.CalendarBloc>(() => _i30.CalendarBloc(
        gh<_i21.Session>(),
        gh<_i8.CalendarFooterBloc>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i10.CarePlanHelper>(),
      ));
  gh.factory<_i31.CarePlanApiClient>(
      () => _i31.CarePlanApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i32.CarePlansRepository>(_i32.CarePlansRepository(
    gh<_i31.CarePlanApiClient>(),
    gh<_i21.Session>(),
  ));
  gh.factory<_i33.ChartLoaderBloc>(() => _i33.ChartLoaderBloc(
        gh<_i32.CarePlansRepository>(),
        gh<_i16.MeasurementsDbProvider>(),
        gh<_i19.PendingResultsDbProvider>(),
      ));
  gh.singleton<_i34.ContentBloc>(_i34.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i22.SessionDbProvider>(),
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i21.Session>(),
    gh<_i9.CarePlanBloc>(),
    gh<_i15.LocationService>(),
  ));
  gh.factory<_i35.DeviceApiClient>(
      () => _i35.DeviceApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.factory<_i36.DeviceManagementCubit>(() => _i36.DeviceManagementCubit(
        gh<_i3.AccountDbProvider>(),
        gh<_i18.PairedDevicesDbProvider>(),
      ));
  gh.singleton<_i37.DeviceRepository>(_i37.DeviceRepository(
    gh<_i35.DeviceApiClient>(),
    gh<_i21.Session>(),
  ));
  gh.factory<_i38.OmronConnectionBloc>(() => _i38.OmronConnectionBloc(
        gh<_i3.AccountDbProvider>(),
        gh<_i19.PendingResultsDbProvider>(),
        gh<_i18.PairedDevicesDbProvider>(),
      ));
  gh.factory<_i39.RegisterDeviceBloc>(
      () => _i39.RegisterDeviceBloc(gh<_i37.DeviceRepository>()));
  gh.singleton<_i40.SyncService>(_i40.SyncService(
    gh<_i21.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i19.PendingResultsDbProvider>(),
    gh<_i27.AccountRepository>(),
    gh<_i32.CarePlansRepository>(),
    gh<_i24.TimeSettingsRepository>(),
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i37.DeviceRepository>(),
  ));
  gh.factory<_i41.TokenInterceptor>(() => _i41.TokenInterceptor(
        gh<_i21.Session>(),
        gh<_i26.AccountApiClient>(),
        gh<_i3.AccountDbProvider>(),
      ));
  gh.singleton<_i42.AuthBloc>(_i42.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i27.AccountRepository>(),
    gh<_i21.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i19.PendingResultsDbProvider>(),
    gh<_i12.Dio>(instanceName: 'privateDio'),
    gh<_i40.SyncService>(),
  ));
  gh.factory<_i43.CalendarFulfillmentServiceBloc>(
      () => _i43.CalendarFulfillmentServiceBloc(
            gh<_i3.AccountDbProvider>(),
            gh<_i8.CalendarFooterBloc>(),
            gh<_i32.CarePlansRepository>(),
            gh<_i7.CalendarEvaluationDbProvider>(),
            gh<_i16.MeasurementsDbProvider>(),
            gh<_i19.PendingResultsDbProvider>(),
          ));
  gh.singleton<_i44.SyncBloc>(_i44.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i40.SyncService>(),
    gh<_i21.Session>(),
  ));
  return getIt;
}

class _$DioModule extends _i45.DioModule {}
