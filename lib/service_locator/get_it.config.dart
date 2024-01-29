// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i14;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i30;
import '../api/client/auth_api_client.dart' as _i33;
import '../api/client/care_plan_api_client.dart' as _i35;
import '../api/client/device_api_client.dart' as _i38;
import '../api/client/time_settings_api_client.dart' as _i27;
import '../api/dio_module.dart' as _i52;
import '../api/interceptors/token_interceptor.dart' as _i43;
import '../bloc/auth/auth_bloc.dart' as _i44;
import '../bloc/calendar/calendar_bloc.dart' as _i34;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i10;
import '../bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i46;
import '../bloc/care_plan/care_plan_bloc.dart' as _i11;
import '../bloc/chart_bloc/chart_bloc.dart' as _i13;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i37;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i29;
import '../bloc/notifications/notifications_bloc.dart' as _i20;
import '../bloc/omron/omron_connection_bloc.dart' as _i48;
import '../bloc/register_device/register_device_bloc.dart' as _i49;
import '../bloc/report/report_bloc.dart' as _i50;
import '../bloc/results/results_bloc.dart' as _i24;
import '../bloc/settings/app_settings_bloc.dart' as _i32;
import '../bloc/sync/sync_bloc.dart' as _i51;
import '../bloc/user_content/content_bloc.dart' as _i47;
import '../cubit/background_measurement/background_measurement_cubit.dart'
    as _i7;
import '../cubit/device_management/device_management_cubit.dart' as _i39;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i16;
import '../cubit/loader/loader_cubit.dart' as _i18;
import '../data/app_database.dart' as _i4;
import '../data/repositories/care_plan_repository.dart' as _i12;
import '../managers/background_measurement_manager.dart' as _i45;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/calendar_evaluation_db_provider.dart' as _i9;
import '../providers/hospital_db_provider.dart' as _i15;
import '../providers/measurements_db_provider.dart' as _i19;
import '../providers/paired_devices_db_provider.dart' as _i21;
import '../providers/pending_results_dbs_provider.dart' as _i22;
import '../providers/reports_db_provider.dart' as _i23;
import '../providers/session_db_provider.dart' as _i26;
import '../providers/settings_db_provider.dart' as _i5;
import '../repositories/account_repository.dart' as _i31;
import '../repositories/care_plans_repository.dart' as _i36;
import '../repositories/device_repository.dart' as _i40;
import '../repositories/time_settings_repository.dart' as _i28;
import '../services/auth_service.dart' as _i6;
import '../services/internet_service.dart' as _i17;
import '../services/report_service.dart' as _i41;
import '../services/sync_service.dart' as _i42;
import '../storage/session.dart' as _i25;
import '../utils/helpers/bt_connection_helper.dart' as _i8;

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
  gh.singleton<_i4.AppDatabase>(_i4.AppDatabase());
  await gh.singletonAsync<_i5.AppSettingsDbProvider>(
    () {
      final i = _i5.AppSettingsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i6.AuthService>(_i6.AuthService());
  gh.singleton<_i7.BackgroundMeasurementCubit>(
      _i7.BackgroundMeasurementCubit());
  gh.singleton<_i8.BtConnectionHelper>(_i8.BtConnectionHelper());
  await gh.singletonAsync<_i9.CalendarEvaluationDbProvider>(
    () {
      final i = _i9.CalendarEvaluationDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i10.CalendarFooterBloc>(_i10.CalendarFooterBloc());
  gh.singleton<_i11.CarePlanBloc>(_i11.CarePlanBloc());
  gh.singleton<_i12.CarePlanRepository>(
      _i12.CarePlanRepository(gh<_i4.AppDatabase>()));
  gh.factory<_i13.ChartBloc>(() => _i13.ChartBloc());
  gh.singleton<_i14.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  await gh.singletonAsync<_i15.HospitalDbProvider>(
    () {
      final i = _i15.HospitalDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i16.HospitalSearchCubit>(_i16.HospitalSearchCubit());
  gh.singleton<_i17.InternetService>(_i17.InternetService());
  gh.factory<_i18.LoaderCubit>(() => _i18.LoaderCubit());
  await gh.singletonAsync<_i19.MeasurementsDbProvider>(
    () {
      final i = _i19.MeasurementsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i20.NotificationsBloc>(_i20.NotificationsBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i5.AppSettingsDbProvider>(),
  ));
  await gh.singletonAsync<_i21.PairedDevicesDbProvider>(
    () {
      final i = _i21.PairedDevicesDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i22.PendingResultsDbProvider>(
    () {
      final i = _i22.PendingResultsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i23.ReportsDbProvider>(
    () {
      final i = _i23.ReportsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.factory<_i24.ResultsBloc>(() => _i24.ResultsBloc());
  gh.singleton<_i25.Session>(_i25.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i22.PendingResultsDbProvider>(),
  ));
  await gh.singletonAsync<_i26.SessionDbProvider>(
    () {
      final i = _i26.SessionDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.factory<_i27.TimeSettingsApiClient>(() =>
      _i27.TimeSettingsApiClient(gh<_i14.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i28.TimeSettingsRepository>(_i28.TimeSettingsRepository(
    gh<_i27.TimeSettingsApiClient>(),
    gh<_i25.Session>(),
  ));
  gh.factory<_i29.TimesSettingsBloc>(() => _i29.TimesSettingsBloc(
        gh<_i17.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i28.TimeSettingsRepository>(),
      ));
  gh.factory<_i30.AccountApiClient>(
      () => _i30.AccountApiClient(gh<_i14.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i31.AccountRepository>(_i31.AccountRepository(
    gh<_i30.AccountApiClient>(),
    gh<_i25.Session>(),
  ));
  gh.singleton<_i32.AppSettingsBloc>(
      _i32.AppSettingsBloc(gh<_i5.AppSettingsDbProvider>()));
  gh.factory<_i33.AuthApiClient>(
      () => _i33.AuthApiClient(gh<_i14.Dio>(instanceName: 'privateDio')));
  gh.factory<_i34.CalendarBloc>(() => _i34.CalendarBloc(
        gh<_i25.Session>(),
        gh<_i10.CalendarFooterBloc>(),
        gh<_i3.AccountDbProvider>(),
      ));
  gh.factory<_i35.CarePlanApiClient>(
      () => _i35.CarePlanApiClient(gh<_i14.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i36.CarePlansRepository>(_i36.CarePlansRepository(
    gh<_i35.CarePlanApiClient>(),
    gh<_i25.Session>(),
  ));
  gh.factory<_i37.ChartLoaderBloc>(() => _i37.ChartLoaderBloc(
        gh<_i36.CarePlansRepository>(),
        gh<_i19.MeasurementsDbProvider>(),
        gh<_i22.PendingResultsDbProvider>(),
      ));
  gh.factory<_i38.DeviceApiClient>(
      () => _i38.DeviceApiClient(gh<_i14.Dio>(instanceName: 'privateDio')));
  gh.factory<_i39.DeviceManagementCubit>(() => _i39.DeviceManagementCubit(
        gh<_i3.AccountDbProvider>(),
        gh<_i21.PairedDevicesDbProvider>(),
      ));
  gh.singleton<_i40.DeviceRepository>(_i40.DeviceRepository(
    gh<_i38.DeviceApiClient>(),
    gh<_i25.Session>(),
  ));
  await gh.lazySingletonAsync<_i41.ReportService>(
    () => _i41.ReportService.create(
      gh<_i3.AccountDbProvider>(),
      gh<_i23.ReportsDbProvider>(),
      gh<_i31.AccountRepository>(),
    ),
    preResolve: true,
  );
  gh.singleton<_i42.SyncService>(_i42.SyncService(
    gh<_i25.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i22.PendingResultsDbProvider>(),
    gh<_i31.AccountRepository>(),
    gh<_i36.CarePlansRepository>(),
    gh<_i28.TimeSettingsRepository>(),
    gh<_i5.AppSettingsDbProvider>(),
    gh<_i40.DeviceRepository>(),
  ));
  gh.factory<_i43.TokenInterceptor>(() => _i43.TokenInterceptor(
        gh<_i25.Session>(),
        gh<_i30.AccountApiClient>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i41.ReportService>(),
      ));
  gh.singleton<_i44.AuthBloc>(_i44.AuthBloc(
    gh<_i6.AuthService>(),
    gh<_i41.ReportService>(),
    gh<_i31.AccountRepository>(),
    gh<_i25.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i22.PendingResultsDbProvider>(),
    gh<_i15.HospitalDbProvider>(),
    gh<_i14.Dio>(instanceName: 'privateDio'),
    gh<_i42.SyncService>(),
  ));
  gh.singleton<_i45.BackgroundMeasurementManager>(
      _i45.BackgroundMeasurementManager(
    gh<_i42.SyncService>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i7.BackgroundMeasurementCubit>(),
    gh<_i41.ReportService>(),
  ));
  gh.factory<_i46.CalendarFulfillmentServiceBloc>(
      () => _i46.CalendarFulfillmentServiceBloc(
            gh<_i3.AccountDbProvider>(),
            gh<_i10.CalendarFooterBloc>(),
            gh<_i36.CarePlansRepository>(),
            gh<_i9.CalendarEvaluationDbProvider>(),
            gh<_i19.MeasurementsDbProvider>(),
            gh<_i22.PendingResultsDbProvider>(),
          ));
  gh.singleton<_i47.ContentBloc>(_i47.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i26.SessionDbProvider>(),
    gh<_i25.Session>(),
    gh<_i11.CarePlanBloc>(),
    gh<_i41.ReportService>(),
  ));
  gh.factory<_i48.OmronConnectionBloc>(() => _i48.OmronConnectionBloc(
        gh<_i8.BtConnectionHelper>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i21.PairedDevicesDbProvider>(),
        gh<_i41.ReportService>(),
      ));
  gh.factory<_i49.RegisterDeviceBloc>(() => _i49.RegisterDeviceBloc(
        gh<_i8.BtConnectionHelper>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i40.DeviceRepository>(),
        gh<_i41.ReportService>(),
      ));
  gh.factory<_i50.ReportBloc>(() => _i50.ReportBloc(gh<_i41.ReportService>()));
  gh.singleton<_i51.SyncBloc>(_i51.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i42.SyncService>(),
    gh<_i25.Session>(),
  ));
  return getIt;
}

class _$DioModule extends _i52.DioModule {}
