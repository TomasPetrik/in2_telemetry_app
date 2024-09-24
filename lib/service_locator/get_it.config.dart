// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../api/client/account_api_client.dart' as _i708;
import '../api/client/auth_api_client.dart' as _i541;
import '../api/client/care_plan_api_client.dart' as _i409;
import '../api/client/device_api_client.dart' as _i122;
import '../api/client/time_settings_api_client.dart' as _i387;
import '../api/dio_module.dart' as _i784;
import '../api/interceptors/token_interceptor.dart' as _i750;
import '../bloc/auth/auth_bloc.dart' as _i79;
import '../bloc/calendar/calendar_bloc.dart' as _i444;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i795;
import '../bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i1002;
import '../bloc/care_plan/care_plan_bloc.dart' as _i260;
import '../bloc/chart_bloc/chart_bloc.dart' as _i1045;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i380;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i193;
import '../bloc/notifications/notifications_bloc.dart' as _i917;
import '../bloc/omron/omron_connection_bloc.dart' as _i362;
import '../bloc/register_device/register_device_bloc.dart' as _i768;
import '../bloc/report/report_bloc.dart' as _i243;
import '../bloc/results/results_bloc.dart' as _i206;
import '../bloc/settings/app_settings_bloc.dart' as _i486;
import '../bloc/sync/sync_bloc.dart' as _i24;
import '../bloc/user_content/content_bloc.dart' as _i951;
import '../cubit/background_measurement/background_measurement_cubit.dart'
    as _i207;
import '../cubit/device_management/device_management_cubit.dart' as _i961;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i745;
import '../cubit/loader/loader_cubit.dart' as _i1064;
import '../managers/background_measurement_manager.dart' as _i396;
import '../providers/account_db_provider.dart' as _i33;
import '../providers/calendar_evaluation_db_provider.dart' as _i258;
import '../providers/hospital_db_provider.dart' as _i251;
import '../providers/measurements_db_provider.dart' as _i720;
import '../providers/paired_devices_db_provider.dart' as _i204;
import '../providers/pending_results_dbs_provider.dart' as _i457;
import '../providers/reports_db_provider.dart' as _i495;
import '../providers/session_db_provider.dart' as _i967;
import '../providers/settings_db_provider.dart' as _i769;
import '../repositories/account_repository.dart' as _i319;
import '../repositories/care_plans_repository.dart' as _i744;
import '../repositories/device_repository.dart' as _i347;
import '../repositories/time_settings_repository.dart' as _i658;
import '../services/auth_service.dart' as _i745;
import '../services/internet_service.dart' as _i403;
import '../services/report_service.dart' as _i420;
import '../services/sync_service.dart' as _i979;
import '../storage/session.dart' as _i48;
import '../utils/helpers/bt_connection_helper.dart' as _i994;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final dioModule = _$DioModule();
  gh.factory<_i1045.ChartBloc>(() => _i1045.ChartBloc());
  gh.factory<_i206.ResultsBloc>(() => _i206.ResultsBloc());
  gh.factory<_i1064.LoaderCubit>(() => _i1064.LoaderCubit());
  gh.singleton<_i795.CalendarFooterBloc>(() => _i795.CalendarFooterBloc());
  gh.singleton<_i260.CarePlanBloc>(() => _i260.CarePlanBloc());
  gh.singleton<_i207.BackgroundMeasurementCubit>(
      () => _i207.BackgroundMeasurementCubit());
  gh.singleton<_i745.HospitalSearchCubit>(() => _i745.HospitalSearchCubit());
  await gh.singletonAsync<_i33.AccountDbProvider>(
    () {
      final i = _i33.AccountDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i258.CalendarEvaluationDbProvider>(
    () {
      final i = _i258.CalendarEvaluationDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i251.HospitalDbProvider>(
    () {
      final i = _i251.HospitalDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i720.MeasurementsDbProvider>(
    () {
      final i = _i720.MeasurementsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i204.PairedDevicesDbProvider>(
    () {
      final i = _i204.PairedDevicesDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i457.PendingResultsDbProvider>(
    () {
      final i = _i457.PendingResultsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i495.ReportsDbProvider>(
    () {
      final i = _i495.ReportsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i967.SessionDbProvider>(
    () {
      final i = _i967.SessionDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i769.AppSettingsDbProvider>(
    () {
      final i = _i769.AppSettingsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i745.AuthService>(() => _i745.AuthService());
  gh.singleton<_i403.InternetService>(() => _i403.InternetService());
  gh.singleton<_i994.BtConnectionHelper>(() => _i994.BtConnectionHelper());
  gh.singleton<_i917.NotificationsBloc>(() => _i917.NotificationsBloc(
        gh<_i33.AccountDbProvider>(),
        gh<_i769.AppSettingsDbProvider>(),
      ));
  gh.singleton<_i361.Dio>(
    () => dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i48.Session>(() => _i48.Session(
        gh<_i33.AccountDbProvider>(),
        gh<_i457.PendingResultsDbProvider>(),
      ));
  gh.factory<_i961.DeviceManagementCubit>(() => _i961.DeviceManagementCubit(
        gh<_i33.AccountDbProvider>(),
        gh<_i204.PairedDevicesDbProvider>(),
      ));
  gh.factory<_i708.AccountApiClient>(
      () => _i708.AccountApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.factory<_i541.AuthApiClient>(
      () => _i541.AuthApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.factory<_i409.CarePlanApiClient>(
      () => _i409.CarePlanApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.factory<_i122.DeviceApiClient>(
      () => _i122.DeviceApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.factory<_i387.TimeSettingsApiClient>(() =>
      _i387.TimeSettingsApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i486.AppSettingsBloc>(
      () => _i486.AppSettingsBloc(gh<_i769.AppSettingsDbProvider>()));
  gh.singleton<_i347.DeviceRepository>(() => _i347.DeviceRepository(
        gh<_i122.DeviceApiClient>(),
        gh<_i48.Session>(),
      ));
  gh.singleton<_i658.TimeSettingsRepository>(() => _i658.TimeSettingsRepository(
        gh<_i387.TimeSettingsApiClient>(),
        gh<_i48.Session>(),
      ));
  gh.factory<_i444.CalendarBloc>(() => _i444.CalendarBloc(
        gh<_i48.Session>(),
        gh<_i795.CalendarFooterBloc>(),
        gh<_i33.AccountDbProvider>(),
      ));
  gh.singleton<_i744.CarePlansRepository>(() => _i744.CarePlansRepository(
        gh<_i409.CarePlanApiClient>(),
        gh<_i48.Session>(),
      ));
  gh.singleton<_i319.AccountRepository>(() => _i319.AccountRepository(
        gh<_i708.AccountApiClient>(),
        gh<_i48.Session>(),
      ));
  gh.factory<_i380.ChartLoaderBloc>(() => _i380.ChartLoaderBloc(
        gh<_i744.CarePlansRepository>(),
        gh<_i720.MeasurementsDbProvider>(),
        gh<_i457.PendingResultsDbProvider>(),
      ));
  gh.singleton<_i979.SyncService>(() => _i979.SyncService(
        gh<_i48.Session>(),
        gh<_i33.AccountDbProvider>(),
        gh<_i457.PendingResultsDbProvider>(),
        gh<_i319.AccountRepository>(),
        gh<_i744.CarePlansRepository>(),
        gh<_i658.TimeSettingsRepository>(),
        gh<_i769.AppSettingsDbProvider>(),
        gh<_i347.DeviceRepository>(),
      ));
  gh.factory<_i193.TimesSettingsBloc>(() => _i193.TimesSettingsBloc(
        gh<_i403.InternetService>(),
        gh<_i33.AccountDbProvider>(),
        gh<_i658.TimeSettingsRepository>(),
      ));
  gh.singleton<_i24.SyncBloc>(() => _i24.SyncBloc(
        gh<_i33.AccountDbProvider>(),
        gh<_i979.SyncService>(),
        gh<_i48.Session>(),
      ));
  gh.factory<_i1002.CalendarFulfillmentServiceBloc>(
      () => _i1002.CalendarFulfillmentServiceBloc(
            gh<_i33.AccountDbProvider>(),
            gh<_i795.CalendarFooterBloc>(),
            gh<_i744.CarePlansRepository>(),
            gh<_i258.CalendarEvaluationDbProvider>(),
            gh<_i720.MeasurementsDbProvider>(),
            gh<_i457.PendingResultsDbProvider>(),
          ));
  await gh.lazySingletonAsync<_i420.ReportService>(
    () => _i420.ReportService.create(
      gh<_i33.AccountDbProvider>(),
      gh<_i495.ReportsDbProvider>(),
      gh<_i319.AccountRepository>(),
    ),
    preResolve: true,
  );
  gh.singleton<_i951.ContentBloc>(() => _i951.ContentBloc(
        gh<_i33.AccountDbProvider>(),
        gh<_i967.SessionDbProvider>(),
        gh<_i48.Session>(),
        gh<_i260.CarePlanBloc>(),
        gh<_i420.ReportService>(),
      ));
  gh.factory<_i768.RegisterDeviceBloc>(() => _i768.RegisterDeviceBloc(
        gh<_i994.BtConnectionHelper>(),
        gh<_i33.AccountDbProvider>(),
        gh<_i347.DeviceRepository>(),
        gh<_i420.ReportService>(),
      ));
  gh.factory<_i243.ReportBloc>(
      () => _i243.ReportBloc(gh<_i420.ReportService>()));
  gh.factory<_i362.OmronConnectionBloc>(() => _i362.OmronConnectionBloc(
        gh<_i994.BtConnectionHelper>(),
        gh<_i33.AccountDbProvider>(),
        gh<_i204.PairedDevicesDbProvider>(),
        gh<_i420.ReportService>(),
      ));
  gh.singleton<_i79.AuthBloc>(() => _i79.AuthBloc(
        gh<_i745.AuthService>(),
        gh<_i420.ReportService>(),
        gh<_i319.AccountRepository>(),
        gh<_i48.Session>(),
        gh<_i33.AccountDbProvider>(),
        gh<_i457.PendingResultsDbProvider>(),
        gh<_i251.HospitalDbProvider>(),
        gh<_i361.Dio>(instanceName: 'privateDio'),
        gh<_i979.SyncService>(),
      ));
  gh.factory<_i750.TokenInterceptor>(() => _i750.TokenInterceptor(
        gh<_i48.Session>(),
        gh<_i708.AccountApiClient>(),
        gh<_i33.AccountDbProvider>(),
        gh<_i420.ReportService>(),
      ));
  gh.singleton<_i396.BackgroundMeasurementManager>(
      () => _i396.BackgroundMeasurementManager(
            gh<_i979.SyncService>(),
            gh<_i33.AccountDbProvider>(),
            gh<_i207.BackgroundMeasurementCubit>(),
            gh<_i420.ReportService>(),
          ));
  return getIt;
}

class _$DioModule extends _i784.DioModule {}
