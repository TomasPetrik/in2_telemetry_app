// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i27;
import '../api/client/auth_api_client.dart' as _i30;
import '../api/client/care_plan_api_client.dart' as _i32;
import '../api/client/device_api_client.dart' as _i35;
import '../api/client/time_settings_api_client.dart' as _i24;
import '../api/dio_module.dart' as _i48;
import '../api/interceptors/token_interceptor.dart' as _i40;
import '../bloc/auth/auth_bloc.dart' as _i41;
import '../bloc/calendar/calendar_bloc.dart' as _i31;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i8;
import '../bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i42;
import '../bloc/care_plan/care_plan_bloc.dart' as _i9;
import '../bloc/chart_bloc/chart_bloc.dart' as _i10;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i34;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i26;
import '../bloc/notifications/notifications_bloc.dart' as _i17;
import '../bloc/omron/omron_connection_bloc.dart' as _i44;
import '../bloc/register_device/register_device_bloc.dart' as _i45;
import '../bloc/report/report_bloc.dart' as _i46;
import '../bloc/results/results_bloc.dart' as _i21;
import '../bloc/settings/app_settings_bloc.dart' as _i29;
import '../bloc/sync/sync_bloc.dart' as _i47;
import '../bloc/user_content/content_bloc.dart' as _i43;
import '../cubit/device_management/device_management_cubit.dart' as _i36;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i13;
import '../cubit/loader/loader_cubit.dart' as _i15;
import '../providers/account_db_provider.dart' as _i3;
import '../providers/calendar_evaluation_db_provider.dart' as _i7;
import '../providers/hospital_db_provider.dart' as _i12;
import '../providers/measurements_db_provider.dart' as _i16;
import '../providers/paired_devices_db_provider.dart' as _i18;
import '../providers/pending_results_dbs_provider.dart' as _i19;
import '../providers/reports_db_provider.dart' as _i20;
import '../providers/session_db_provider.dart' as _i23;
import '../providers/settings_db_provider.dart' as _i4;
import '../repositories/account_repository.dart' as _i28;
import '../repositories/care_plans_repository.dart' as _i33;
import '../repositories/device_repository.dart' as _i37;
import '../repositories/time_settings_repository.dart' as _i25;
import '../services/auth_service.dart' as _i5;
import '../services/internet_service.dart' as _i14;
import '../services/report_service.dart' as _i38;
import '../services/sync_service.dart' as _i39;
import '../storage/session.dart' as _i22;
import '../utils/helpers/bt_connection_helper.dart' as _i6;

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
  gh.singleton<_i6.BtConnectionHelper>(_i6.BtConnectionHelper());
  await gh.singletonAsync<_i7.CalendarEvaluationDbProvider>(
    () {
      final i = _i7.CalendarEvaluationDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i8.CalendarFooterBloc>(_i8.CalendarFooterBloc());
  gh.singleton<_i9.CarePlanBloc>(_i9.CarePlanBloc());
  gh.factory<_i10.ChartBloc>(() => _i10.ChartBloc());
  gh.singleton<_i11.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  await gh.singletonAsync<_i12.HospitalDbProvider>(
    () {
      final i = _i12.HospitalDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i13.HospitalSearchCubit>(_i13.HospitalSearchCubit());
  gh.singleton<_i14.InternetService>(_i14.InternetService());
  gh.factory<_i15.LoaderCubit>(() => _i15.LoaderCubit());
  await gh.singletonAsync<_i16.MeasurementsDbProvider>(
    () {
      final i = _i16.MeasurementsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.singleton<_i17.NotificationsBloc>(_i17.NotificationsBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i4.AppSettingsDbProvider>(),
  ));
  await gh.singletonAsync<_i18.PairedDevicesDbProvider>(
    () {
      final i = _i18.PairedDevicesDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i19.PendingResultsDbProvider>(
    () {
      final i = _i19.PendingResultsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  await gh.singletonAsync<_i20.ReportsDbProvider>(
    () {
      final i = _i20.ReportsDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.factory<_i21.ResultsBloc>(() => _i21.ResultsBloc());
  gh.singleton<_i22.Session>(_i22.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i19.PendingResultsDbProvider>(),
  ));
  await gh.singletonAsync<_i23.SessionDbProvider>(
    () {
      final i = _i23.SessionDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.factory<_i24.TimeSettingsApiClient>(() =>
      _i24.TimeSettingsApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i25.TimeSettingsRepository>(_i25.TimeSettingsRepository(
    gh<_i24.TimeSettingsApiClient>(),
    gh<_i22.Session>(),
  ));
  gh.factory<_i26.TimesSettingsBloc>(() => _i26.TimesSettingsBloc(
        gh<_i14.InternetService>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i25.TimeSettingsRepository>(),
      ));
  gh.factory<_i27.AccountApiClient>(
      () => _i27.AccountApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i28.AccountRepository>(_i28.AccountRepository(
    gh<_i27.AccountApiClient>(),
    gh<_i22.Session>(),
  ));
  gh.singleton<_i29.AppSettingsBloc>(
      _i29.AppSettingsBloc(gh<_i4.AppSettingsDbProvider>()));
  gh.factory<_i30.AuthApiClient>(
      () => _i30.AuthApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.factory<_i31.CalendarBloc>(() => _i31.CalendarBloc(
        gh<_i22.Session>(),
        gh<_i8.CalendarFooterBloc>(),
        gh<_i3.AccountDbProvider>(),
      ));
  gh.factory<_i32.CarePlanApiClient>(
      () => _i32.CarePlanApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i33.CarePlansRepository>(_i33.CarePlansRepository(
    gh<_i32.CarePlanApiClient>(),
    gh<_i22.Session>(),
  ));
  gh.factory<_i34.ChartLoaderBloc>(() => _i34.ChartLoaderBloc(
        gh<_i33.CarePlansRepository>(),
        gh<_i16.MeasurementsDbProvider>(),
        gh<_i19.PendingResultsDbProvider>(),
      ));
  gh.factory<_i35.DeviceApiClient>(
      () => _i35.DeviceApiClient(gh<_i11.Dio>(instanceName: 'privateDio')));
  gh.factory<_i36.DeviceManagementCubit>(() => _i36.DeviceManagementCubit(
        gh<_i3.AccountDbProvider>(),
        gh<_i18.PairedDevicesDbProvider>(),
      ));
  gh.singleton<_i37.DeviceRepository>(_i37.DeviceRepository(
    gh<_i35.DeviceApiClient>(),
    gh<_i22.Session>(),
  ));
  await gh.lazySingletonAsync<_i38.ReportService>(
    () => _i38.ReportService.create(
      gh<_i3.AccountDbProvider>(),
      gh<_i20.ReportsDbProvider>(),
      gh<_i28.AccountRepository>(),
    ),
    preResolve: true,
  );
  gh.singleton<_i39.SyncService>(_i39.SyncService(
    gh<_i22.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i19.PendingResultsDbProvider>(),
    gh<_i28.AccountRepository>(),
    gh<_i33.CarePlansRepository>(),
    gh<_i25.TimeSettingsRepository>(),
    gh<_i4.AppSettingsDbProvider>(),
    gh<_i37.DeviceRepository>(),
  ));
  gh.factory<_i40.TokenInterceptor>(() => _i40.TokenInterceptor(
        gh<_i22.Session>(),
        gh<_i27.AccountApiClient>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i38.ReportService>(),
      ));
  gh.singleton<_i41.AuthBloc>(_i41.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i38.ReportService>(),
    gh<_i28.AccountRepository>(),
    gh<_i22.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i19.PendingResultsDbProvider>(),
    gh<_i12.HospitalDbProvider>(),
    gh<_i11.Dio>(instanceName: 'privateDio'),
    gh<_i39.SyncService>(),
  ));
  gh.factory<_i42.CalendarFulfillmentServiceBloc>(
      () => _i42.CalendarFulfillmentServiceBloc(
            gh<_i3.AccountDbProvider>(),
            gh<_i8.CalendarFooterBloc>(),
            gh<_i33.CarePlansRepository>(),
            gh<_i7.CalendarEvaluationDbProvider>(),
            gh<_i16.MeasurementsDbProvider>(),
            gh<_i19.PendingResultsDbProvider>(),
          ));
  gh.singleton<_i43.ContentBloc>(_i43.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i23.SessionDbProvider>(),
    gh<_i22.Session>(),
    gh<_i9.CarePlanBloc>(),
    gh<_i38.ReportService>(),
  ));
  gh.factory<_i44.OmronConnectionBloc>(() => _i44.OmronConnectionBloc(
        gh<_i6.BtConnectionHelper>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i18.PairedDevicesDbProvider>(),
        gh<_i38.ReportService>(),
      ));
  gh.factory<_i45.RegisterDeviceBloc>(() => _i45.RegisterDeviceBloc(
        gh<_i6.BtConnectionHelper>(),
        gh<_i3.AccountDbProvider>(),
        gh<_i37.DeviceRepository>(),
        gh<_i38.ReportService>(),
      ));
  gh.factory<_i46.ReportBloc>(() => _i46.ReportBloc(gh<_i38.ReportService>()));
  gh.singleton<_i47.SyncBloc>(_i47.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i39.SyncService>(),
    gh<_i22.Session>(),
  ));
  return getIt;
}

class _$DioModule extends _i48.DioModule {}
