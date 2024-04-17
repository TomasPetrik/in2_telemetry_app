// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i24;
import '../api/client/auth_api_client.dart' as _i26;
import '../api/client/care_plan_api_client.dart' as _i27;
import '../api/client/device_api_client.dart' as _i30;
import '../api/client/time_settings_api_client.dart' as _i19;
import '../api/dio_module.dart' as _i55;
import '../api/interceptors/token_interceptor.dart' as _i45;
import '../bloc/auth/auth_bloc.dart' as _i52;
import '../bloc/calendar/calendar_bloc.dart' as _i35;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i7;
import '../bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i46;
import '../bloc/care_plan/care_plan_bloc.dart' as _i36;
import '../bloc/chart_bloc/chart_bloc.dart' as _i29;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i38;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i44;
import '../bloc/notifications/notifications_bloc.dart' as _i40;
import '../bloc/omron/omron_connection_bloc.dart' as _i48;
import '../bloc/register_device/register_device_bloc.dart' as _i49;
import '../bloc/report/report_bloc.dart' as _i50;
import '../bloc/results/results_bloc.dart' as _i42;
import '../bloc/settings/app_settings_bloc.dart' as _i25;
import '../bloc/sync/sync_bloc.dart' as _i54;
import '../bloc/user_content/content_bloc.dart' as _i47;
import '../cubit/background_measurement/background_measurement_cubit.dart'
    as _i5;
import '../cubit/device_management/device_management_cubit.dart' as _i32;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i11;
import '../cubit/loader/loader_cubit.dart' as _i13;
import '../data/app_database.dart' as _i3;
import '../data/providers/care_plan_db_provider.dart' as _i28;
import '../data/providers/log_db_provider.dart' as _i14;
import '../data/providers/measurements_db_provider.dart' as _i17;
import '../data/providers/settings_db_provider.dart' as _i18;
import '../data/providers/user_db_provider.dart' as _i31;
import '../data/providers/when_template_db_provider.dart' as _i23;
import '../managers/background_measurement_manager.dart' as _i53;
import '../mapper/care_plan_activity_mapper.dart' as _i8;
import '../mapper/care_plan_version_mapper.dart' as _i9;
import '../mapper/log_event_mapper.dart' as _i15;
import '../mapper/measurement_type_mapper.dart' as _i16;
import '../mapper/timing_mapper.dart' as _i20;
import '../mapper/user_mapper.dart' as _i21;
import '../mapper/when_code_mapper.dart' as _i22;
import '../repositories/account_repository.dart' as _i34;
import '../repositories/care_plans_repository.dart' as _i37;
import '../repositories/device_repository.dart' as _i39;
import '../repositories/time_settings_repository.dart' as _i43;
import '../services/auth_service.dart' as _i4;
import '../services/internet_service.dart' as _i12;
import '../services/report_service.dart' as _i41;
import '../services/sync_service.dart' as _i51;
import '../storage/user_cubit.dart' as _i33;
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
  gh.singleton<_i3.AppDatabase>(_i3.AppDatabase());
  gh.singleton<_i4.AuthService>(_i4.AuthService());
  gh.singleton<_i5.BackgroundMeasurementCubit>(
      _i5.BackgroundMeasurementCubit());
  gh.singleton<_i6.BtConnectionHelper>(_i6.BtConnectionHelper());
  gh.singleton<_i7.CalendarFooterBloc>(_i7.CalendarFooterBloc());
  gh.factory<_i8.CarePlanActivityMapper>(() => _i8.CarePlanActivityMapper());
  gh.factory<_i9.CarePlanVersionMapper>(() => _i9.CarePlanVersionMapper());
  gh.singleton<_i10.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i11.HospitalSearchCubit>(_i11.HospitalSearchCubit());
  gh.singleton<_i12.InternetService>(_i12.InternetService());
  gh.factory<_i13.LoaderCubit>(() => _i13.LoaderCubit());
  gh.factory<_i14.LogDbProvider>(
      () => _i14.LogDbProvider(gh<_i3.AppDatabase>()));
  gh.factory<_i15.LogEventMapper>(() => _i15.LogEventMapper());
  gh.factory<_i16.MeasurementTypeMapper>(
      () => const _i16.MeasurementTypeMapper());
  gh.factory<_i17.MeasurementsDbProvider>(
      () => _i17.MeasurementsDbProvider(gh<_i3.AppDatabase>()));
  gh.factory<_i18.SettingsDbProvider>(
      () => _i18.SettingsDbProvider(gh<_i3.AppDatabase>()));
  gh.factory<_i19.TimeSettingsApiClient>(() =>
      _i19.TimeSettingsApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.factory<_i20.TimingDayWhenMapper>(() => const _i20.TimingDayWhenMapper());
  gh.factory<_i21.UserMapper>(() => _i21.UserMapper());
  gh.factory<_i22.WhenCodeMapper>(() => const _i22.WhenCodeMapper());
  gh.factory<_i23.WhenTemplateDbProvider>(
      () => _i23.WhenTemplateDbProvider(gh<_i3.AppDatabase>()));
  gh.factory<_i24.AccountApiClient>(
      () => _i24.AccountApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i25.AppSettingsBloc>(
      _i25.AppSettingsBloc(gh<_i18.SettingsDbProvider>()));
  gh.factory<_i26.AuthApiClient>(
      () => _i26.AuthApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.factory<_i27.CarePlanApiClient>(
      () => _i27.CarePlanApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.factory<_i28.CarePlanDbProvider>(() => _i28.CarePlanDbProvider(
        gh<_i3.AppDatabase>(),
        gh<_i9.CarePlanVersionMapper>(),
        gh<_i8.CarePlanActivityMapper>(),
      ));
  gh.factory<_i29.ChartBloc>(
      () => _i29.ChartBloc(gh<_i28.CarePlanDbProvider>()));
  gh.factory<_i30.DeviceApiClient>(
      () => _i30.DeviceApiClient(gh<_i10.Dio>(instanceName: 'privateDio')));
  gh.factory<_i31.UserDbProvider>(() => _i31.UserDbProvider(
        gh<_i3.AppDatabase>(),
        gh<_i21.UserMapper>(),
        gh<_i22.WhenCodeMapper>(),
      ));
  gh.factory<_i32.DeviceManagementCubit>(
      () => _i32.DeviceManagementCubit(gh<_i31.UserDbProvider>()));
  await gh.lazySingletonAsync<_i33.UserCubit>(
    () => _i33.UserCubit.create(
      gh<_i31.UserDbProvider>(),
      gh<_i18.SettingsDbProvider>(),
    ),
    preResolve: true,
  );
  gh.singleton<_i34.AccountRepository>(_i34.AccountRepository(
    gh<_i24.AccountApiClient>(),
    gh<_i33.UserCubit>(),
  ));
  gh.factory<_i35.CalendarBloc>(() => _i35.CalendarBloc(
        gh<_i33.UserCubit>(),
        gh<_i7.CalendarFooterBloc>(),
      ));
  gh.singleton<_i36.CarePlanBloc>(_i36.CarePlanBloc(gh<_i33.UserCubit>()));
  gh.singleton<_i37.CarePlansRepository>(_i37.CarePlansRepository(
    gh<_i27.CarePlanApiClient>(),
    gh<_i33.UserCubit>(),
  ));
  gh.factory<_i38.ChartLoaderBloc>(() => _i38.ChartLoaderBloc(
        gh<_i37.CarePlansRepository>(),
        gh<_i17.MeasurementsDbProvider>(),
        gh<_i16.MeasurementTypeMapper>(),
      ));
  gh.singleton<_i39.DeviceRepository>(_i39.DeviceRepository(
    gh<_i30.DeviceApiClient>(),
    gh<_i33.UserCubit>(),
  ));
  gh.singleton<_i40.NotificationsBloc>(_i40.NotificationsBloc(
    gh<_i31.UserDbProvider>(),
    gh<_i18.SettingsDbProvider>(),
    gh<_i33.UserCubit>(),
  ));
  await gh.lazySingletonAsync<_i41.ReportService>(
    () => _i41.ReportService.create(
      gh<_i14.LogDbProvider>(),
      gh<_i34.AccountRepository>(),
      gh<_i15.LogEventMapper>(),
    ),
    preResolve: true,
  );
  gh.factory<_i42.ResultsBloc>(() => _i42.ResultsBloc(
        gh<_i33.UserCubit>(),
        gh<_i28.CarePlanDbProvider>(),
        gh<_i17.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i43.TimeSettingsRepository>(_i43.TimeSettingsRepository(
    gh<_i19.TimeSettingsApiClient>(),
    gh<_i33.UserCubit>(),
  ));
  gh.factory<_i44.TimesSettingsBloc>(() => _i44.TimesSettingsBloc(
        gh<_i12.InternetService>(),
        gh<_i43.TimeSettingsRepository>(),
        gh<_i23.WhenTemplateDbProvider>(),
        gh<_i22.WhenCodeMapper>(),
        gh<_i33.UserCubit>(),
      ));
  gh.factory<_i45.TokenInterceptor>(() => _i45.TokenInterceptor(
        gh<_i33.UserCubit>(),
        gh<_i24.AccountApiClient>(),
        gh<_i41.ReportService>(),
        gh<_i31.UserDbProvider>(),
      ));
  gh.factory<_i46.CalendarFulfillmentServiceBloc>(
      () => _i46.CalendarFulfillmentServiceBloc(
            gh<_i31.UserDbProvider>(),
            gh<_i7.CalendarFooterBloc>(),
            gh<_i37.CarePlansRepository>(),
            gh<_i33.UserCubit>(),
          ));
  gh.singleton<_i47.ContentBloc>(_i47.ContentBloc(
    gh<_i31.UserDbProvider>(),
    gh<_i33.UserCubit>(),
    gh<_i36.CarePlanBloc>(),
    gh<_i41.ReportService>(),
    gh<_i18.SettingsDbProvider>(),
  ));
  gh.factory<_i48.OmronConnectionBloc>(() => _i48.OmronConnectionBloc(
        gh<_i6.BtConnectionHelper>(),
        gh<_i31.UserDbProvider>(),
        gh<_i41.ReportService>(),
        gh<_i33.UserCubit>(),
      ));
  gh.factory<_i49.RegisterDeviceBloc>(() => _i49.RegisterDeviceBloc(
        gh<_i6.BtConnectionHelper>(),
        gh<_i39.DeviceRepository>(),
        gh<_i41.ReportService>(),
      ));
  gh.factory<_i50.ReportBloc>(() => _i50.ReportBloc(gh<_i41.ReportService>()));
  gh.singleton<_i51.SyncService>(_i51.SyncService(
    gh<_i33.UserCubit>(),
    gh<_i34.AccountRepository>(),
    gh<_i37.CarePlansRepository>(),
    gh<_i43.TimeSettingsRepository>(),
    gh<_i39.DeviceRepository>(),
    gh<_i31.UserDbProvider>(),
    gh<_i28.CarePlanDbProvider>(),
  ));
  gh.singleton<_i52.AuthBloc>(_i52.AuthBloc(
    gh<_i4.AuthService>(),
    gh<_i41.ReportService>(),
    gh<_i34.AccountRepository>(),
    gh<_i33.UserCubit>(),
    gh<_i31.UserDbProvider>(),
    gh<_i10.Dio>(instanceName: 'privateDio'),
    gh<_i51.SyncService>(),
    gh<_i18.SettingsDbProvider>(),
    gh<_i43.TimeSettingsRepository>(),
  ));
  gh.singleton<_i53.BackgroundMeasurementManager>(
      _i53.BackgroundMeasurementManager(
    gh<_i51.SyncService>(),
    gh<_i31.UserDbProvider>(),
    gh<_i5.BackgroundMeasurementCubit>(),
    gh<_i41.ReportService>(),
  ));
  gh.singleton<_i54.SyncBloc>(_i54.SyncBloc(
    gh<_i31.UserDbProvider>(),
    gh<_i51.SyncService>(),
    gh<_i33.UserCubit>(),
    gh<_i28.CarePlanDbProvider>(),
  ));
  return getIt;
}

class _$DioModule extends _i55.DioModule {}
