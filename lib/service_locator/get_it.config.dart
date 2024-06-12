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
import '../api/dio_module.dart' as _i56;
import '../api/interceptors/token_interceptor.dart' as _i54;
import '../bloc/auth/auth_bloc.dart' as _i50;
import '../bloc/calendar/calendar_bloc.dart' as _i40;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i11;
import '../bloc/care_plan/care_plan_bloc.dart' as _i46;
import '../bloc/chart_bloc/chart_bloc.dart' as _i34;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i47;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i44;
import '../bloc/notifications/notifications_bloc.dart' as _i37;
import '../bloc/omron/omron_connection_bloc.dart' as _i52;
import '../bloc/register_device/register_device_bloc.dart' as _i49;
import '../bloc/report/report_bloc.dart' as _i55;
import '../bloc/results/results_bloc.dart' as _i45;
import '../bloc/settings/app_settings_bloc.dart' as _i24;
import '../bloc/sync/sync_bloc.dart' as _i43;
import '../bloc/user_content/content_bloc.dart' as _i51;
import '../cubit/background_measurement/background_measurement_cubit.dart'
    as _i12;
import '../cubit/device_management/device_management_cubit.dart' as _i25;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i13;
import '../cubit/loader/loader_cubit.dart' as _i3;
import '../cubit/plan_progress/plan_progress_cubit.dart' as _i31;
import '../data/app_database.dart' as _i14;
import '../data/providers/care_plan_db_provider.dart' as _i32;
import '../data/providers/device_prototype_db_provider.dart' as _i19;
import '../data/providers/log_db_provider.dart' as _i20;
import '../data/providers/measurements_db_provider.dart' as _i18;
import '../data/providers/settings_db_provider.dart' as _i21;
import '../data/providers/user_db_provider.dart' as _i23;
import '../data/providers/when_template_db_provider.dart' as _i22;
import '../managers/background_measurement_manager.dart' as _i53;
import '../mapper/care_plan_activity_mapper.dart' as _i4;
import '../mapper/care_plan_version_mapper.dart' as _i5;
import '../mapper/log_event_mapper.dart' as _i6;
import '../mapper/measurement_type_mapper.dart' as _i7;
import '../mapper/timing_mapper.dart' as _i8;
import '../mapper/user_mapper.dart' as _i9;
import '../mapper/when_code_mapper.dart' as _i10;
import '../repositories/account_repository.dart' as _i41;
import '../repositories/care_plans_repository.dart' as _i39;
import '../repositories/device_repository.dart' as _i35;
import '../repositories/time_settings_repository.dart' as _i36;
import '../services/auth_service.dart' as _i15;
import '../services/internet_service.dart' as _i16;
import '../services/report_service.dart' as _i48;
import '../services/sync_service.dart' as _i42;
import '../storage/user_cubit.dart' as _i33;
import '../utils/helpers/bt_connection_helper.dart' as _i38;

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
  gh.factory<_i19.DevicePrototypeDbProvider>(
      () => _i19.DevicePrototypeDbProvider(gh<_i14.AppDatabase>()));
  gh.factory<_i20.LogDbProvider>(
      () => _i20.LogDbProvider(gh<_i14.AppDatabase>()));
  gh.factory<_i21.SettingsDbProvider>(
      () => _i21.SettingsDbProvider(gh<_i14.AppDatabase>()));
  gh.factory<_i22.WhenTemplateDbProvider>(() => _i22.WhenTemplateDbProvider(
        gh<_i14.AppDatabase>(),
        gh<_i10.WhenCodeMapper>(),
      ));
  gh.factory<_i23.UserDbProvider>(() => _i23.UserDbProvider(
        gh<_i14.AppDatabase>(),
        gh<_i9.UserMapper>(),
        gh<_i10.WhenCodeMapper>(),
      ));
  gh.singleton<_i24.AppSettingsBloc>(
      () => _i24.AppSettingsBloc(gh<_i21.SettingsDbProvider>()));
  gh.factory<_i25.DeviceManagementCubit>(
      () => _i25.DeviceManagementCubit(gh<_i23.UserDbProvider>()));
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
      gh<_i23.UserDbProvider>(),
      gh<_i21.SettingsDbProvider>(),
      gh<_i18.MeasurementsDbProvider>(),
      gh<_i32.CarePlanDbProvider>(),
    ),
    preResolve: true,
  );
  gh.factory<_i34.ChartBloc>(() => _i34.ChartBloc(
        gh<_i32.CarePlanDbProvider>(),
        gh<_i18.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i35.DeviceRepository>(() => _i35.DeviceRepository(
        gh<_i29.DeviceApiClient>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i36.TimeSettingsRepository>(() => _i36.TimeSettingsRepository(
        gh<_i30.TimeSettingsApiClient>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i37.NotificationsBloc>(() => _i37.NotificationsBloc(
        gh<_i21.SettingsDbProvider>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i38.BtConnectionHelper>(
      () => _i38.BtConnectionHelper(gh<_i19.DevicePrototypeDbProvider>()));
  gh.singleton<_i39.CarePlansRepository>(() => _i39.CarePlansRepository(
        gh<_i28.CarePlanApiClient>(),
        gh<_i33.UserCubit>(),
      ));
  gh.factory<_i40.CalendarBloc>(() => _i40.CalendarBloc(
        gh<_i33.UserCubit>(),
        gh<_i11.CalendarFooterBloc>(),
        gh<_i32.CarePlanDbProvider>(),
        gh<_i18.MeasurementsDbProvider>(),
        gh<_i39.CarePlansRepository>(),
        gh<_i7.MeasurementTypeMapper>(),
      ));
  gh.singleton<_i41.AccountRepository>(() => _i41.AccountRepository(
        gh<_i26.AccountApiClient>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i42.SyncService>(() => _i42.SyncService(
        gh<_i33.UserCubit>(),
        gh<_i41.AccountRepository>(),
        gh<_i39.CarePlansRepository>(),
        gh<_i36.TimeSettingsRepository>(),
        gh<_i35.DeviceRepository>(),
        gh<_i32.CarePlanDbProvider>(),
        gh<_i7.MeasurementTypeMapper>(),
        gh<_i18.MeasurementsDbProvider>(),
        gh<_i23.UserDbProvider>(),
        gh<_i19.DevicePrototypeDbProvider>(),
        gh<_i22.WhenTemplateDbProvider>(),
      ));
  gh.singleton<_i43.SyncBloc>(() => _i43.SyncBloc(
        gh<_i23.UserDbProvider>(),
        gh<_i42.SyncService>(),
        gh<_i33.UserCubit>(),
        gh<_i32.CarePlanDbProvider>(),
      ));
  gh.factory<_i44.TimesSettingsBloc>(() => _i44.TimesSettingsBloc(
        gh<_i16.InternetService>(),
        gh<_i36.TimeSettingsRepository>(),
        gh<_i22.WhenTemplateDbProvider>(),
        gh<_i10.WhenCodeMapper>(),
        gh<_i33.UserCubit>(),
      ));
  gh.factory<_i45.ResultsBloc>(() => _i45.ResultsBloc(
        gh<_i33.UserCubit>(),
        gh<_i32.CarePlanDbProvider>(),
        gh<_i18.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i46.CarePlanBloc>(() => _i46.CarePlanBloc(
        gh<_i33.UserCubit>(),
        gh<_i32.CarePlanDbProvider>(),
        gh<_i18.MeasurementsDbProvider>(),
      ));
  gh.factory<_i47.ChartLoaderBloc>(() => _i47.ChartLoaderBloc(
        gh<_i39.CarePlansRepository>(),
        gh<_i18.MeasurementsDbProvider>(),
        gh<_i7.MeasurementTypeMapper>(),
      ));
  await gh.lazySingletonAsync<_i48.ReportService>(
    () => _i48.ReportService.create(
      gh<_i20.LogDbProvider>(),
      gh<_i41.AccountRepository>(),
      gh<_i6.LogEventMapper>(),
    ),
    preResolve: true,
  );
  gh.factory<_i49.RegisterDeviceBloc>(() => _i49.RegisterDeviceBloc(
        gh<_i38.BtConnectionHelper>(),
        gh<_i35.DeviceRepository>(),
        gh<_i48.ReportService>(),
      ));
  gh.singleton<_i50.AuthBloc>(() => _i50.AuthBloc(
        gh<_i15.AuthService>(),
        gh<_i48.ReportService>(),
        gh<_i41.AccountRepository>(),
        gh<_i33.UserCubit>(),
        gh<_i23.UserDbProvider>(),
        gh<_i17.Dio>(instanceName: 'privateDio'),
        gh<_i42.SyncService>(),
        gh<_i21.SettingsDbProvider>(),
        gh<_i36.TimeSettingsRepository>(),
      ));
  gh.singleton<_i51.ContentBloc>(() => _i51.ContentBloc(
        gh<_i23.UserDbProvider>(),
        gh<_i33.UserCubit>(),
        gh<_i46.CarePlanBloc>(),
        gh<_i48.ReportService>(),
        gh<_i21.SettingsDbProvider>(),
      ));
  gh.factory<_i52.OmronConnectionBloc>(() => _i52.OmronConnectionBloc(
        gh<_i38.BtConnectionHelper>(),
        gh<_i23.UserDbProvider>(),
        gh<_i48.ReportService>(),
        gh<_i33.UserCubit>(),
      ));
  gh.singleton<_i53.BackgroundMeasurementManager>(
      () => _i53.BackgroundMeasurementManager(
            gh<_i42.SyncService>(),
            gh<_i23.UserDbProvider>(),
            gh<_i12.BackgroundMeasurementCubit>(),
            gh<_i48.ReportService>(),
          ));
  gh.factory<_i54.TokenInterceptor>(() => _i54.TokenInterceptor(
        gh<_i33.UserCubit>(),
        gh<_i26.AccountApiClient>(),
        gh<_i48.ReportService>(),
        gh<_i23.UserDbProvider>(),
      ));
  gh.factory<_i55.ReportBloc>(() => _i55.ReportBloc(gh<_i48.ReportService>()));
  return getIt;
}

class _$DioModule extends _i56.DioModule {}
