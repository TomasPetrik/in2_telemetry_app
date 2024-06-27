// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i17;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i26;
import '../api/client/auth_api_client.dart' as _i27;
import '../api/client/care_plan_api_client.dart' as _i28;
import '../api/client/device_api_client.dart' as _i29;
import '../api/client/time_settings_api_client.dart' as _i30;
import '../api/dio_module.dart' as _i57;
import '../api/interceptors/token_interceptor.dart' as _i55;
import '../bloc/auth/auth_bloc.dart' as _i51;
import '../bloc/calendar/calendar_bloc.dart' as _i41;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i11;
import '../bloc/care_plan/care_plan_bloc.dart' as _i47;
import '../bloc/chart_bloc/chart_bloc.dart' as _i35;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i48;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i45;
import '../bloc/notifications/notifications_bloc.dart' as _i38;
import '../bloc/omron/omron_connection_bloc.dart' as _i52;
import '../bloc/register_device/register_device_bloc.dart' as _i50;
import '../bloc/report/report_bloc.dart' as _i56;
import '../bloc/results/results_bloc.dart' as _i46;
import '../bloc/settings/app_settings_bloc.dart' as _i25;
import '../bloc/sync/sync_bloc.dart' as _i44;
import '../bloc/user_content/content_bloc.dart' as _i53;
import '../cubit/background_measurement/background_measurement_cubit.dart'
    as _i12;
import '../cubit/device_management/device_management_cubit.dart' as _i34;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i13;
import '../cubit/loader/loader_cubit.dart' as _i3;
import '../cubit/plan_progress/plan_progress_cubit.dart' as _i31;
import '../data/app_database.dart' as _i14;
import '../data/providers/care_plan_db_provider.dart' as _i32;
import '../data/providers/device_db_provider.dart' as _i19;
import '../data/providers/device_prototype_db_provider.dart' as _i20;
import '../data/providers/log_db_provider.dart' as _i21;
import '../data/providers/measurements_db_provider.dart' as _i18;
import '../data/providers/settings_db_provider.dart' as _i22;
import '../data/providers/user_db_provider.dart' as _i24;
import '../data/providers/when_template_db_provider.dart' as _i23;
import '../managers/background_measurement_manager.dart' as _i54;
import '../mapper/care_plan_activity_mapper.dart' as _i4;
import '../mapper/care_plan_version_mapper.dart' as _i5;
import '../mapper/log_event_mapper.dart' as _i6;
import '../mapper/measurement_type_mapper.dart' as _i7;
import '../mapper/timing_mapper.dart' as _i8;
import '../mapper/user_mapper.dart' as _i9;
import '../mapper/when_code_mapper.dart' as _i10;
import '../repositories/account_repository.dart' as _i42;
import '../repositories/care_plans_repository.dart' as _i40;
import '../repositories/device_repository.dart' as _i36;
import '../repositories/time_settings_repository.dart' as _i37;
import '../services/auth_service.dart' as _i15;
import '../services/internet_service.dart' as _i16;
import '../services/report_service.dart' as _i49;
import '../services/sync_service.dart' as _i43;
import '../storage/user_cubit.dart' as _i33;
import '../utils/helpers/bt_connection_helper.dart' as _i39;

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
  gh.factory<_i8.TimingDayWhenMapper>(() => const _i8.TimingDayWhenMapper());
  gh.factory<_i9.UserMapper>(() => _i9.UserMapper());
  gh.factory<_i10.WhenCodeMapper>(() => const _i10.WhenCodeMapper());
  gh.singleton<_i11.CalendarFooterBloc>(() => _i11.CalendarFooterBloc());
  gh.singleton<_i12.BackgroundMeasurementCubit>(
      () => _i12.BackgroundMeasurementCubit());
  gh.singleton<_i13.HospitalSearchCubit>(() => _i13.HospitalSearchCubit());
  gh.singleton<_i14.AppDatabase>(() => _i14.AppDatabase());
  gh.singleton<_i15.AuthService>(() => _i15.AuthService());
  gh.singleton<_i16.InternetService>(() => _i16.InternetService());
  gh.singleton<_i17.Dio>(
    () => dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.factory<_i18.MeasurementsDbProvider>(() => _i18.MeasurementsDbProvider(
        gh<_i14.AppDatabase>(),
        gh<_i7.MeasurementTypeMapper>(),
      ));
  gh.factory<_i19.DeviceDbProvider>(
      () => _i19.DeviceDbProvider(gh<_i14.AppDatabase>()));
  gh.factory<_i20.DevicePrototypeDbProvider>(
      () => _i20.DevicePrototypeDbProvider(gh<_i14.AppDatabase>()));
  gh.factory<_i21.LogDbProvider>(
      () => _i21.LogDbProvider(gh<_i14.AppDatabase>()));
  gh.factory<_i22.SettingsDbProvider>(
      () => _i22.SettingsDbProvider(gh<_i14.AppDatabase>()));
  gh.factory<_i23.WhenTemplateDbProvider>(() => _i23.WhenTemplateDbProvider(
        gh<_i14.AppDatabase>(),
        gh<_i10.WhenCodeMapper>(),
      ));
  gh.factory<_i24.UserDbProvider>(() => _i24.UserDbProvider(
        gh<_i14.AppDatabase>(),
        gh<_i9.UserMapper>(),
        gh<_i10.WhenCodeMapper>(),
      ));
  gh.singleton<_i25.AppSettingsBloc>(
      () => _i25.AppSettingsBloc(gh<_i22.SettingsDbProvider>()));
  gh.factory<_i26.AccountApiClient>(
      () => _i26.AccountApiClient(gh<_i17.Dio>(instanceName: 'privateDio')));
  gh.factory<_i27.AuthApiClient>(
      () => _i27.AuthApiClient(gh<_i17.Dio>(instanceName: 'privateDio')));
  gh.factory<_i28.CarePlanApiClient>(
      () => _i28.CarePlanApiClient(gh<_i17.Dio>(instanceName: 'privateDio')));
  gh.factory<_i29.DeviceApiClient>(
      () => _i29.DeviceApiClient(gh<_i17.Dio>(instanceName: 'privateDio')));
  gh.factory<_i30.TimeSettingsApiClient>(() =>
      _i30.TimeSettingsApiClient(gh<_i17.Dio>(instanceName: 'privateDio')));
  gh.factory<_i31.PlanProgressCubit>(
      () => _i31.PlanProgressCubit(gh<_i18.MeasurementsDbProvider>()));
  gh.factory<_i32.CarePlanDbProvider>(() => _i32.CarePlanDbProvider(
        gh<_i14.AppDatabase>(),
        gh<_i5.CarePlanVersionMapper>(),
        gh<_i4.CarePlanActivityMapper>(),
      ));
  await gh.lazySingletonAsync<_i33.UserCubit>(
    () => _i33.UserCubit.create(
      gh<_i24.UserDbProvider>(),
      gh<_i22.SettingsDbProvider>(),
      gh<_i18.MeasurementsDbProvider>(),
      gh<_i32.CarePlanDbProvider>(),
    ),
    preResolve: true,
  );
  gh.factory<_i34.DeviceManagementCubit>(() => _i34.DeviceManagementCubit(
        gh<_i19.DeviceDbProvider>(),
        gh<_i33.UserCubit>(),
        gh<_i20.DevicePrototypeDbProvider>(),
      ));
  gh.factory<_i35.ChartBloc>(() => _i35.ChartBloc(
        gh<_i32.CarePlanDbProvider>(),
        gh<_i18.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i36.DeviceRepository>(() => _i36.DeviceRepository(
        gh<_i29.DeviceApiClient>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i37.TimeSettingsRepository>(() => _i37.TimeSettingsRepository(
        gh<_i30.TimeSettingsApiClient>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i38.NotificationsBloc>(() => _i38.NotificationsBloc(
        gh<_i22.SettingsDbProvider>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i39.BtConnectionHelper>(
      () => _i39.BtConnectionHelper(gh<_i20.DevicePrototypeDbProvider>()));
  gh.singleton<_i40.CarePlansRepository>(() => _i40.CarePlansRepository(
        gh<_i28.CarePlanApiClient>(),
        gh<_i33.UserCubit>(),
      ));
  gh.factory<_i41.CalendarBloc>(() => _i41.CalendarBloc(
        gh<_i33.UserCubit>(),
        gh<_i11.CalendarFooterBloc>(),
        gh<_i32.CarePlanDbProvider>(),
        gh<_i18.MeasurementsDbProvider>(),
        gh<_i40.CarePlansRepository>(),
        gh<_i7.MeasurementTypeMapper>(),
      ));
  gh.singleton<_i42.AccountRepository>(() => _i42.AccountRepository(
        gh<_i26.AccountApiClient>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i43.SyncService>(() => _i43.SyncService(
        gh<_i33.UserCubit>(),
        gh<_i42.AccountRepository>(),
        gh<_i40.CarePlansRepository>(),
        gh<_i37.TimeSettingsRepository>(),
        gh<_i36.DeviceRepository>(),
        gh<_i32.CarePlanDbProvider>(),
        gh<_i7.MeasurementTypeMapper>(),
        gh<_i18.MeasurementsDbProvider>(),
        gh<_i24.UserDbProvider>(),
        gh<_i20.DevicePrototypeDbProvider>(),
        gh<_i23.WhenTemplateDbProvider>(),
        gh<_i19.DeviceDbProvider>(),
      ));
  gh.singleton<_i44.SyncBloc>(() => _i44.SyncBloc(
        gh<_i24.UserDbProvider>(),
        gh<_i43.SyncService>(),
        gh<_i33.UserCubit>(),
        gh<_i32.CarePlanDbProvider>(),
      ));
  gh.factory<_i45.TimesSettingsBloc>(() => _i45.TimesSettingsBloc(
        gh<_i16.InternetService>(),
        gh<_i37.TimeSettingsRepository>(),
        gh<_i23.WhenTemplateDbProvider>(),
        gh<_i10.WhenCodeMapper>(),
        gh<_i33.UserCubit>(),
      ));
  gh.factory<_i46.ResultsBloc>(() => _i46.ResultsBloc(
        gh<_i33.UserCubit>(),
        gh<_i32.CarePlanDbProvider>(),
        gh<_i18.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i47.CarePlanBloc>(() => _i47.CarePlanBloc(
        gh<_i33.UserCubit>(),
        gh<_i32.CarePlanDbProvider>(),
        gh<_i18.MeasurementsDbProvider>(),
      ));
  gh.factory<_i48.ChartLoaderBloc>(() => _i48.ChartLoaderBloc(
        gh<_i40.CarePlansRepository>(),
        gh<_i18.MeasurementsDbProvider>(),
        gh<_i7.MeasurementTypeMapper>(),
      ));
  await gh.lazySingletonAsync<_i49.ReportService>(
    () => _i49.ReportService.create(
      gh<_i21.LogDbProvider>(),
      gh<_i42.AccountRepository>(),
      gh<_i6.LogEventMapper>(),
    ),
    preResolve: true,
  );
  gh.factory<_i50.RegisterDeviceBloc>(() => _i50.RegisterDeviceBloc(
        gh<_i39.BtConnectionHelper>(),
        gh<_i36.DeviceRepository>(),
        gh<_i49.ReportService>(),
      ));
  gh.singleton<_i51.AuthBloc>(() => _i51.AuthBloc(
        gh<_i15.AuthService>(),
        gh<_i49.ReportService>(),
        gh<_i42.AccountRepository>(),
        gh<_i33.UserCubit>(),
        gh<_i24.UserDbProvider>(),
        gh<_i17.Dio>(instanceName: 'privateDio'),
        gh<_i43.SyncService>(),
        gh<_i22.SettingsDbProvider>(),
        gh<_i37.TimeSettingsRepository>(),
      ));
  gh.factory<_i52.OmronConnectionBloc>(() => _i52.OmronConnectionBloc(
        gh<_i39.BtConnectionHelper>(),
        gh<_i49.ReportService>(),
        gh<_i19.DeviceDbProvider>(),
      ));
  gh.singleton<_i53.ContentBloc>(() => _i53.ContentBloc(
        gh<_i24.UserDbProvider>(),
        gh<_i33.UserCubit>(),
        gh<_i47.CarePlanBloc>(),
        gh<_i49.ReportService>(),
        gh<_i22.SettingsDbProvider>(),
      ));
  gh.singleton<_i54.BackgroundMeasurementManager>(
      () => _i54.BackgroundMeasurementManager(
            gh<_i43.SyncService>(),
            gh<_i24.UserDbProvider>(),
            gh<_i12.BackgroundMeasurementCubit>(),
            gh<_i49.ReportService>(),
          ));
  gh.factory<_i55.TokenInterceptor>(() => _i55.TokenInterceptor(
        gh<_i33.UserCubit>(),
        gh<_i26.AccountApiClient>(),
        gh<_i49.ReportService>(),
        gh<_i24.UserDbProvider>(),
      ));
  gh.factory<_i56.ReportBloc>(() => _i56.ReportBloc(gh<_i49.ReportService>()));
  return getIt;
}

class _$DioModule extends _i57.DioModule {}
