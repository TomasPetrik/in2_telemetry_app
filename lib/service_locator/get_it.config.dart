// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i12;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i28;
import '../api/client/auth_api_client.dart' as _i31;
import '../api/client/care_plan_api_client.dart' as _i33;
import '../api/client/device_api_client.dart' as _i36;
import '../api/client/time_settings_api_client.dart' as _i25;
import '../api/dio_module.dart' as _i50;
import '../api/interceptors/token_interceptor.dart' as _i41;
import '../bloc/auth/auth_bloc.dart' as _i42;
import '../bloc/calendar/calendar_bloc.dart' as _i32;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i9;
import '../bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i44;
import '../bloc/care_plan/care_plan_bloc.dart' as _i10;
import '../bloc/chart_bloc/chart_bloc.dart' as _i11;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i35;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i27;
import '../bloc/notifications/notifications_bloc.dart' as _i18;
import '../bloc/omron/omron_connection_bloc.dart' as _i46;
import '../bloc/register_device/register_device_bloc.dart' as _i47;
import '../bloc/report/report_bloc.dart' as _i48;
import '../bloc/results/results_bloc.dart' as _i22;
import '../bloc/settings/app_settings_bloc.dart' as _i30;
import '../bloc/sync/sync_bloc.dart' as _i49;
import '../bloc/user_content/content_bloc.dart' as _i45;
import '../cubit/background_measurement/background_measurement_cubit.dart'
    as _i6;
import '../cubit/device_management/device_management_cubit.dart' as _i37;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i14;
import '../cubit/loader/loader_cubit.dart' as _i16;
import '../managers/background_measurement_manager.dart' as _i43;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/calendar_evaluation_db_provider.dart' as _i8;
import '../providers/hospital_db_provider.dart' as _i13;
import '../providers/measurements_db_provider.dart' as _i17;
import '../providers/paired_devices_db_provider.dart' as _i19;
import '../providers/pending_results_dbs_provider.dart' as _i20;
import '../providers/reports_db_provider.dart' as _i21;
import '../providers/session_db_provider.dart' as _i24;
import '../providers/settings_db_provider.dart' as _i4;
import '../repositories/account_repository.dart' as _i29;
import '../repositories/care_plans_repository.dart' as _i34;
import '../repositories/device_repository.dart' as _i38;
import '../repositories/time_settings_repository.dart' as _i26;
import '../services/auth_service.dart' as _i5;
import '../services/internet_service.dart' as _i15;
import '../services/report_service.dart' as _i39;
import '../services/sync_service.dart' as _i40;
import '../storage/session.dart' as _i23;
import '../utils/helpers/bt_connection_helper.dart' as _i7;

// initializes the registration of main-scope dependencies inside of GetIt
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
  await gh.singletonAsync<_i3.AccountDbProvider>(
    () {
      final i = _i3.AccountDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i4.AppSettingsDbProvider>(
    () {
      final i = _i4.AppSettingsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i5.AuthService>(_i5.AuthService());
  gh.singleton<_i6.BackgroundMeasurementCubit>(
      _i6.BackgroundMeasurementCubit());
  gh.singleton<_i7.BtConnectionHelper>(_i7.BtConnectionHelper());
  await gh.singletonAsync<_i8.CalendarEvaluationDbProvider>(
    () {
      final i = _i8.CalendarEvaluationDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i9.CalendarFooterBloc>(_i9.CalendarFooterBloc());
  gh.singleton<_i10.CarePlanBloc>(_i10.CarePlanBloc());
  gh.factory<_i11.ChartBloc>(() => _i11.ChartBloc());
  gh.singleton<_i12.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  await gh.singletonAsync<_i13.HospitalDbProvider>(
    () {
      final i = _i13.HospitalDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i14.HospitalSearchCubit>(_i14.HospitalSearchCubit());
  gh.singleton<_i15.InternetService>(_i15.InternetService());
  gh.factory<_i16.LoaderCubit>(() => _i16.LoaderCubit());
  await gh.singletonAsync<_i17.MeasurementsDbProvider>(
    () {
      final i = _i17.MeasurementsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i18.NotificationsBloc>(_i18.NotificationsBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  await gh.singletonAsync<_i19.PairedDevicesDbProvider>(
    () {
      final i = _i19.PairedDevicesDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i20.PendingResultsDbProvider>(
    () {
      final i = _i20.PendingResultsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i21.ReportsDbProvider>(
    () {
      final i = _i21.ReportsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.factory<_i22.ResultsBloc>(() => _i22.ResultsBloc());
  gh.singleton<_i23.Session>(_i23.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i20.PendingResultsDbProvider>(),
  ));
  await gh.singletonAsync<_i24.SessionDbProvider>(
    () {
      final i = _i24.SessionDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.factory<_i25.TimeSettingsApiClient>(() =>
      _i25.TimeSettingsApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i26.TimeSettingsRepository>(_i26.TimeSettingsRepository(
    gh<_i25.TimeSettingsApiClient>(),
    gh<_i23.Session>(),
  ));
  gh.factory<_i27.TimesSettingsBloc>(() => _i27.TimesSettingsBloc(
        gh<_i15.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i26.TimeSettingsRepository>(),
      ));
  gh.factory<_i28.AccountApiClient>(
      () => _i28.AccountApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i29.AccountRepository>(_i29.AccountRepository(
    gh<_i28.AccountApiClient>(),
    gh<_i23.Session>(),
  ));
  gh.singleton<_i30.AppSettingsBloc>(
      _i30.AppSettingsBloc(gh<_i4.AppSettingsDbProvider>()));
  gh.factory<_i31.AuthApiClient>(
      () => _i31.AuthApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.factory<_i32.CalendarBloc>(() => _i32.CalendarBloc(
        gh<_i23.Session>(),
        gh<_i9.CalendarFooterBloc>(),
        gh<_i3.AccountDbProvider>(),
      ));
  gh.factory<_i33.CarePlanApiClient>(
      () => _i33.CarePlanApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i34.CarePlansRepository>(_i34.CarePlansRepository(
    gh<_i33.CarePlanApiClient>(),
    gh<_i23.Session>(),
  ));
  gh.factory<_i35.ChartLoaderBloc>(() => _i35.ChartLoaderBloc(
        gh<_i34.CarePlansRepository>(),
        gh<_i17.MeasurementsDbProvider>(),
        gh<_i20.PendingResultsDbProvider>(),
      ));
  gh.factory<_i36.DeviceApiClient>(
      () => _i36.DeviceApiClient(gh<_i12.Dio>(instanceName: 'privateDio')));
  gh.factory<_i37.DeviceManagementCubit>(() => _i37.DeviceManagementCubit(
        gh<_i3.AccountDbProvider>(),
        gh<_i19.PairedDevicesDbProvider>(),
      ));
  gh.singleton<_i38.DeviceRepository>(_i38.DeviceRepository(
    gh<_i36.DeviceApiClient>(),
    gh<_i23.Session>(),
  ));
  await gh.lazySingletonAsync<_i39.ReportService>(
    () => _i39.ReportService.create(
      gh<_i3.AccountDbProvider>(),
      gh<_i21.ReportsDbProvider>(),
      gh<_i29.AccountRepository>(),
    ),
    preResolve: true,
  );
  gh.singleton<_i40.SyncService>(_i40.SyncService(
    gh<_i23.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i20.PendingResultsDbProvider>(),
    gh<_i29.AccountRepository>(),
    gh<_i34.CarePlansRepository>(),
    gh<_i26.TimeSettingsRepository>(),
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i38.DeviceRepository>(),
  ));
  gh.factory<_i41.TokenInterceptor>(() => _i41.TokenInterceptor(
        gh<_i23.Session>(),
        gh<_i28.AccountApiClient>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i39.ReportService>(),
      ));
  gh.singleton<_i42.AuthBloc>(_i42.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i39.ReportService>(),
    gh<_i29.AccountRepository>(),
    gh<_i23.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i20.PendingResultsDbProvider>(),
    gh<_i13.HospitalDbProvider>(),
    gh<_i12.Dio>(instanceName: 'privateDio'),
    gh<_i40.SyncService>(),
  ));
  gh.singleton<_i43.BackgroundMeasurementManager>(
      _i43.BackgroundMeasurementManager(
    gh<_i40.SyncService>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i6.BackgroundMeasurementCubit>(),
    gh<_i39.ReportService>(),
  ));
  gh.factory<_i44.CalendarFulfillmentServiceBloc>(
      () => _i44.CalendarFulfillmentServiceBloc(
            gh<_i3.AccountDbProvider>(),
            gh<_i9.CalendarFooterBloc>(),
            gh<_i34.CarePlansRepository>(),
            gh<_i8.CalendarEvaluationDbProvider>(),
            gh<_i17.MeasurementsDbProvider>(),
            gh<_i20.PendingResultsDbProvider>(),
          ));
  gh.singleton<_i45.ContentBloc>(_i45.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i24.SessionDbProvider>(),
    gh<_i23.Session>(),
    gh<_i10.CarePlanBloc>(),
    gh<_i39.ReportService>(),
  ));
  gh.factory<_i46.OmronConnectionBloc>(() => _i46.OmronConnectionBloc(
        gh<_i7.BtConnectionHelper>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i19.PairedDevicesDbProvider>(),
        gh<_i39.ReportService>(),
      ));
  gh.factory<_i47.RegisterDeviceBloc>(() => _i47.RegisterDeviceBloc(
        gh<_i7.BtConnectionHelper>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i38.DeviceRepository>(),
        gh<_i39.ReportService>(),
      ));
  gh.factory<_i48.ReportBloc>(() => _i48.ReportBloc(gh<_i39.ReportService>()));
  gh.singleton<_i49.SyncBloc>(_i49.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i40.SyncService>(),
    gh<_i23.Session>(),
  ));
  return getIt;
}

class _$DioModule extends _i50.DioModule {}
