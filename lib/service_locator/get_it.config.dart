// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i18;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i27;
import '../api/client/auth_api_client.dart' as _i28;
import '../api/client/care_plan_api_client.dart' as _i29;
import '../api/client/device_api_client.dart' as _i30;
import '../api/client/time_settings_api_client.dart' as _i31;
import '../api/dio_module.dart' as _i59;
import '../api/interceptors/token_interceptor.dart' as _i57;
import '../bloc/auth/auth_bloc.dart' as _i52;
import '../bloc/calendar/calendar_bloc.dart' as _i42;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i12;
import '../bloc/care_plan/care_plan_bloc.dart' as _i46;
import '../bloc/chart_bloc/chart_bloc.dart' as _i36;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i47;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i44;
import '../bloc/notifications/notifications_bloc.dart' as _i39;
import '../bloc/omron/omron_connection_bloc.dart' as _i54;
import '../bloc/register_device/register_device_bloc.dart' as _i50;
import '../bloc/report/report_bloc.dart' as _i58;
import '../bloc/results/results_bloc.dart' as _i45;
import '../bloc/settings/app_settings_bloc.dart' as _i25;
import '../bloc/sync/sync_bloc.dart' as _i53;
import '../bloc/user_content/content_bloc.dart' as _i56;
import '../cubit/background_measurement/background_measurement_cubit.dart'
    as _i13;
import '../cubit/background_measurement_status_cubit.dart' as _i55;
import '../cubit/device_management/device_management_cubit.dart' as _i35;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i14;
import '../cubit/loader/loader_cubit.dart' as _i3;
import '../cubit/plan_progress/plan_progress_cubit.dart' as _i32;
import '../data/app_database.dart' as _i15;
import '../data/providers/care_plan_db_provider.dart' as _i33;
import '../data/providers/device_db_provider.dart' as _i20;
import '../data/providers/device_prototype_db_provider.dart' as _i21;
import '../data/providers/log_db_provider.dart' as _i22;
import '../data/providers/measurements_db_provider.dart' as _i19;
import '../data/providers/settings_db_provider.dart' as _i23;
import '../data/providers/user_db_provider.dart' as _i26;
import '../data/providers/when_template_db_provider.dart' as _i24;
import '../managers/background_measurement_manager.dart' as _i51;
import '../mapper/care_plan_activity_mapper.dart' as _i4;
import '../mapper/care_plan_version_mapper.dart' as _i5;
import '../mapper/log_event_mapper.dart' as _i6;
import '../mapper/measurement_type_mapper.dart' as _i7;
import '../mapper/thresholds_mapper.dart' as _i8;
import '../mapper/timing_mapper.dart' as _i9;
import '../mapper/user_mapper.dart' as _i10;
import '../mapper/when_code_mapper.dart' as _i11;
import '../repositories/account_repository.dart' as _i43;
import '../repositories/care_plans_repository.dart' as _i41;
import '../repositories/device_repository.dart' as _i37;
import '../repositories/time_settings_repository.dart' as _i38;
import '../services/auth_service.dart' as _i16;
import '../services/internet_service.dart' as _i17;
import '../services/report_service.dart' as _i48;
import '../services/sync_service.dart' as _i49;
import '../storage/user_cubit.dart' as _i34;
import '../utils/helpers/bt_connection_helper.dart' as _i40;

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
  gh.factory<_i3.LoaderCubit>(() => _i3.LoaderCubit());
  gh.factory<_i4.CarePlanActivityMapper>(() => _i4.CarePlanActivityMapper());
  gh.factory<_i5.CarePlanVersionMapper>(() => _i5.CarePlanVersionMapper());
  gh.factory<_i6.LogEventMapper>(() => _i6.LogEventMapper());
  gh.factory<_i7.MeasurementTypeMapper>(
      () => const _i7.MeasurementTypeMapper());
  gh.factory<_i8.ThresholdsMapper>(() => _i8.ThresholdsMapper());
  gh.factory<_i9.TimingDayWhenMapper>(() => const _i9.TimingDayWhenMapper());
  gh.factory<_i10.UserMapper>(() => _i10.UserMapper());
  gh.factory<_i11.WhenCodeMapper>(() => const _i11.WhenCodeMapper());
  gh.singleton<_i12.CalendarFooterBloc>(() => _i12.CalendarFooterBloc());
  gh.singleton<_i13.BackgroundMeasurementCubit>(
      () => _i13.BackgroundMeasurementCubit());
  gh.singleton<_i14.HospitalSearchCubit>(() => _i14.HospitalSearchCubit());
  gh.singleton<_i15.AppDatabase>(() => _i15.AppDatabase());
  gh.singleton<_i16.AuthService>(() => _i16.AuthService());
  gh.singleton<_i17.InternetService>(() => _i17.InternetService());
  gh.singleton<_i18.Dio>(
    () => dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.factory<_i19.MeasurementsDbProvider>(() => _i19.MeasurementsDbProvider(
        gh<_i15.AppDatabase>(),
        gh<_i7.MeasurementTypeMapper>(),
      ));
  gh.factory<_i20.DeviceDbProvider>(
      () => _i20.DeviceDbProvider(gh<_i15.AppDatabase>()));
  gh.factory<_i21.DevicePrototypeDbProvider>(
      () => _i21.DevicePrototypeDbProvider(gh<_i15.AppDatabase>()));
  gh.factory<_i22.LogDbProvider>(
      () => _i22.LogDbProvider(gh<_i15.AppDatabase>()));
  gh.factory<_i23.SettingsDbProvider>(
      () => _i23.SettingsDbProvider(gh<_i15.AppDatabase>()));
  gh.factory<_i24.WhenTemplateDbProvider>(() => _i24.WhenTemplateDbProvider(
        gh<_i15.AppDatabase>(),
        gh<_i11.WhenCodeMapper>(),
      ));
  gh.singleton<_i25.AppSettingsBloc>(
      () => _i25.AppSettingsBloc(gh<_i23.SettingsDbProvider>()));
  gh.factory<_i26.UserDbProvider>(() => _i26.UserDbProvider(
        gh<_i15.AppDatabase>(),
        gh<_i10.UserMapper>(),
        gh<_i11.WhenCodeMapper>(),
        gh<_i8.ThresholdsMapper>(),
      ));
  gh.factory<_i27.AccountApiClient>(
      () => _i27.AccountApiClient(gh<_i18.Dio>(instanceName: 'privateDio')));
  gh.factory<_i28.AuthApiClient>(
      () => _i28.AuthApiClient(gh<_i18.Dio>(instanceName: 'privateDio')));
  gh.factory<_i29.CarePlanApiClient>(
      () => _i29.CarePlanApiClient(gh<_i18.Dio>(instanceName: 'privateDio')));
  gh.factory<_i30.DeviceApiClient>(
      () => _i30.DeviceApiClient(gh<_i18.Dio>(instanceName: 'privateDio')));
  gh.factory<_i31.TimeSettingsApiClient>(() =>
      _i31.TimeSettingsApiClient(gh<_i18.Dio>(instanceName: 'privateDio')));
  gh.factory<_i32.PlanProgressCubit>(
      () => _i32.PlanProgressCubit(gh<_i19.MeasurementsDbProvider>()));
  gh.factory<_i33.CarePlanDbProvider>(() => _i33.CarePlanDbProvider(
        gh<_i15.AppDatabase>(),
        gh<_i5.CarePlanVersionMapper>(),
        gh<_i4.CarePlanActivityMapper>(),
      ));
  await gh.lazySingletonAsync<_i34.UserCubit>(
    () => _i34.UserCubit.create(
      gh<_i26.UserDbProvider>(),
      gh<_i23.SettingsDbProvider>(),
      gh<_i19.MeasurementsDbProvider>(),
      gh<_i33.CarePlanDbProvider>(),
    ),
    preResolve: true,
  );
  gh.factory<_i35.DeviceManagementCubit>(() => _i35.DeviceManagementCubit(
        gh<_i20.DeviceDbProvider>(),
        gh<_i34.UserCubit>(),
        gh<_i21.DevicePrototypeDbProvider>(),
      ));
  gh.factory<_i36.ChartBloc>(() => _i36.ChartBloc(
        gh<_i33.CarePlanDbProvider>(),
        gh<_i19.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i37.DeviceRepository>(() => _i37.DeviceRepository(
        gh<_i30.DeviceApiClient>(),
        gh<_i34.UserCubit>(),
      ));
  gh.singleton<_i38.TimeSettingsRepository>(() => _i38.TimeSettingsRepository(
        gh<_i31.TimeSettingsApiClient>(),
        gh<_i34.UserCubit>(),
      ));
  gh.singleton<_i39.NotificationsBloc>(() => _i39.NotificationsBloc(
        gh<_i23.SettingsDbProvider>(),
        gh<_i34.UserCubit>(),
      ));
  gh.singleton<_i40.BtConnectionHelper>(
      () => _i40.BtConnectionHelper(gh<_i21.DevicePrototypeDbProvider>()));
  gh.singleton<_i41.CarePlansRepository>(() => _i41.CarePlansRepository(
        gh<_i29.CarePlanApiClient>(),
        gh<_i34.UserCubit>(),
      ));
  gh.factory<_i42.CalendarBloc>(() => _i42.CalendarBloc(
        gh<_i34.UserCubit>(),
        gh<_i12.CalendarFooterBloc>(),
        gh<_i33.CarePlanDbProvider>(),
        gh<_i19.MeasurementsDbProvider>(),
        gh<_i41.CarePlansRepository>(),
        gh<_i7.MeasurementTypeMapper>(),
      ));
  gh.singleton<_i43.AccountRepository>(() => _i43.AccountRepository(
        gh<_i27.AccountApiClient>(),
        gh<_i34.UserCubit>(),
      ));
  gh.factory<_i44.TimesSettingsBloc>(() => _i44.TimesSettingsBloc(
        gh<_i17.InternetService>(),
        gh<_i38.TimeSettingsRepository>(),
        gh<_i24.WhenTemplateDbProvider>(),
        gh<_i11.WhenCodeMapper>(),
        gh<_i34.UserCubit>(),
      ));
  gh.factory<_i45.ResultsBloc>(() => _i45.ResultsBloc(
        gh<_i34.UserCubit>(),
        gh<_i33.CarePlanDbProvider>(),
        gh<_i19.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i46.CarePlanBloc>(() => _i46.CarePlanBloc(
        gh<_i34.UserCubit>(),
        gh<_i33.CarePlanDbProvider>(),
        gh<_i19.MeasurementsDbProvider>(),
      ));
  gh.factory<_i47.ChartLoaderBloc>(() => _i47.ChartLoaderBloc(
        gh<_i41.CarePlansRepository>(),
        gh<_i19.MeasurementsDbProvider>(),
        gh<_i7.MeasurementTypeMapper>(),
      ));
  await gh.lazySingletonAsync<_i48.ReportService>(
    () => _i48.ReportService.create(
      gh<_i22.LogDbProvider>(),
      gh<_i43.AccountRepository>(),
      gh<_i6.LogEventMapper>(),
    ),
    preResolve: true,
  );
  gh.singleton<_i49.SyncService>(() => _i49.SyncService(
        gh<_i34.UserCubit>(),
        gh<_i43.AccountRepository>(),
        gh<_i41.CarePlansRepository>(),
        gh<_i38.TimeSettingsRepository>(),
        gh<_i37.DeviceRepository>(),
        gh<_i33.CarePlanDbProvider>(),
        gh<_i7.MeasurementTypeMapper>(),
        gh<_i19.MeasurementsDbProvider>(),
        gh<_i26.UserDbProvider>(),
        gh<_i21.DevicePrototypeDbProvider>(),
        gh<_i24.WhenTemplateDbProvider>(),
        gh<_i20.DeviceDbProvider>(),
        gh<_i23.SettingsDbProvider>(),
      ));
  gh.factory<_i50.RegisterDeviceBloc>(() => _i50.RegisterDeviceBloc(
        gh<_i40.BtConnectionHelper>(),
        gh<_i37.DeviceRepository>(),
        gh<_i48.ReportService>(),
      ));
  gh.singleton<_i51.BackgroundMeasurementManager>(
      () => _i51.BackgroundMeasurementManager(
            gh<_i49.SyncService>(),
            gh<_i13.BackgroundMeasurementCubit>(),
            gh<_i48.ReportService>(),
            gh<_i20.DeviceDbProvider>(),
            gh<_i19.MeasurementsDbProvider>(),
          ));
  gh.singleton<_i52.AuthBloc>(() => _i52.AuthBloc(
        gh<_i16.AuthService>(),
        gh<_i48.ReportService>(),
        gh<_i43.AccountRepository>(),
        gh<_i34.UserCubit>(),
        gh<_i26.UserDbProvider>(),
        gh<_i18.Dio>(instanceName: 'privateDio'),
        gh<_i49.SyncService>(),
        gh<_i23.SettingsDbProvider>(),
        gh<_i38.TimeSettingsRepository>(),
      ));
  gh.singleton<_i53.SyncBloc>(() => _i53.SyncBloc(
        gh<_i26.UserDbProvider>(),
        gh<_i49.SyncService>(),
        gh<_i34.UserCubit>(),
        gh<_i33.CarePlanDbProvider>(),
      ));
  gh.factory<_i54.OmronConnectionBloc>(() => _i54.OmronConnectionBloc(
        gh<_i40.BtConnectionHelper>(),
        gh<_i48.ReportService>(),
        gh<_i20.DeviceDbProvider>(),
      ));
  gh.singleton<_i55.BackgroundMeasurementStatusCubit>(() =>
      _i55.BackgroundMeasurementStatusCubit(
          gh<_i51.BackgroundMeasurementManager>()));
  gh.singleton<_i56.ContentBloc>(() => _i56.ContentBloc(
        gh<_i26.UserDbProvider>(),
        gh<_i34.UserCubit>(),
        gh<_i46.CarePlanBloc>(),
        gh<_i48.ReportService>(),
        gh<_i23.SettingsDbProvider>(),
      ));
  gh.factory<_i57.TokenInterceptor>(() => _i57.TokenInterceptor(
        gh<_i34.UserCubit>(),
        gh<_i27.AccountApiClient>(),
        gh<_i48.ReportService>(),
        gh<_i26.UserDbProvider>(),
      ));
  gh.factory<_i58.ReportBloc>(() => _i58.ReportBloc(gh<_i48.ReportService>()));
  return getIt;
}

class _$DioModule extends _i59.DioModule {}
