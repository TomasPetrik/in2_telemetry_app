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
import '../cubit/background_measurement_status_cubit.dart' as _i984;
import '../cubit/device_management/device_management_cubit.dart' as _i961;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i745;
import '../cubit/loader/loader_cubit.dart' as _i1064;
import '../cubit/plan_progress/plan_progress_cubit.dart' as _i198;
import '../data/app_database.dart' as _i133;
import '../data/providers/care_plan_db_provider.dart' as _i1047;
import '../data/providers/device_db_provider.dart' as _i331;
import '../data/providers/device_prototype_db_provider.dart' as _i847;
import '../data/providers/log_db_provider.dart' as _i640;
import '../data/providers/measurements_db_provider.dart' as _i477;
import '../data/providers/settings_db_provider.dart' as _i654;
import '../data/providers/user_db_provider.dart' as _i478;
import '../data/providers/when_template_db_provider.dart' as _i761;
import '../managers/background_measurement_manager.dart' as _i396;
import '../mapper/care_plan_activity_mapper.dart' as _i763;
import '../mapper/care_plan_version_mapper.dart' as _i728;
import '../mapper/log_event_mapper.dart' as _i517;
import '../mapper/measurement_type_mapper.dart' as _i89;
import '../mapper/thresholds_mapper.dart' as _i1000;
import '../mapper/timing_mapper.dart' as _i692;
import '../mapper/user_mapper.dart' as _i222;
import '../mapper/when_code_mapper.dart' as _i108;
import '../repositories/account_repository.dart' as _i319;
import '../repositories/care_plans_repository.dart' as _i744;
import '../repositories/device_repository.dart' as _i347;
import '../repositories/time_settings_repository.dart' as _i658;
import '../services/auth_service.dart' as _i745;
import '../services/internet_service.dart' as _i403;
import '../services/report_service.dart' as _i420;
import '../services/sync_service.dart' as _i979;
import '../storage/user_cubit.dart' as _i584;
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
  gh.factory<_i1064.LoaderCubit>(() => _i1064.LoaderCubit());
  gh.factory<_i763.CarePlanActivityMapper>(
      () => _i763.CarePlanActivityMapper());
  gh.factory<_i728.CarePlanVersionMapper>(() => _i728.CarePlanVersionMapper());
  gh.factory<_i517.LogEventMapper>(() => _i517.LogEventMapper());
  gh.factory<_i89.MeasurementTypeMapper>(
      () => const _i89.MeasurementTypeMapper());
  gh.factory<_i1000.ThresholdsMapper>(() => _i1000.ThresholdsMapper());
  gh.factory<_i692.TimingDayWhenMapper>(
      () => const _i692.TimingDayWhenMapper());
  gh.factory<_i222.UserMapper>(() => _i222.UserMapper());
  gh.factory<_i108.WhenCodeMapper>(() => const _i108.WhenCodeMapper());
  gh.singleton<_i795.CalendarFooterBloc>(() => _i795.CalendarFooterBloc());
  gh.singleton<_i207.BackgroundMeasurementCubit>(
      () => _i207.BackgroundMeasurementCubit());
  gh.singleton<_i745.HospitalSearchCubit>(() => _i745.HospitalSearchCubit());
  gh.singleton<_i133.AppDatabase>(() => _i133.AppDatabase());
  gh.singleton<_i745.AuthService>(() => _i745.AuthService());
  gh.singleton<_i403.InternetService>(() => _i403.InternetService());
  gh.singleton<_i361.Dio>(
    () => dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i361.Dio>(
    () => dioModule.authDio,
    instanceName: 'authDio',
  );
  gh.factory<_i477.MeasurementsDbProvider>(() => _i477.MeasurementsDbProvider(
        gh<_i133.AppDatabase>(),
        gh<_i89.MeasurementTypeMapper>(),
      ));
  gh.factory<_i331.DeviceDbProvider>(
      () => _i331.DeviceDbProvider(gh<_i133.AppDatabase>()));
  gh.factory<_i847.DevicePrototypeDbProvider>(
      () => _i847.DevicePrototypeDbProvider(gh<_i133.AppDatabase>()));
  gh.factory<_i640.LogDbProvider>(
      () => _i640.LogDbProvider(gh<_i133.AppDatabase>()));
  gh.factory<_i654.SettingsDbProvider>(
      () => _i654.SettingsDbProvider(gh<_i133.AppDatabase>()));
  gh.factory<_i761.WhenTemplateDbProvider>(() => _i761.WhenTemplateDbProvider(
        gh<_i133.AppDatabase>(),
        gh<_i108.WhenCodeMapper>(),
      ));
  gh.singleton<_i486.AppSettingsBloc>(
      () => _i486.AppSettingsBloc(gh<_i654.SettingsDbProvider>()));
  gh.factory<_i708.AccountApiClient>(
      () => _i708.AccountApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.factory<_i409.CarePlanApiClient>(
      () => _i409.CarePlanApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.factory<_i122.DeviceApiClient>(
      () => _i122.DeviceApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.factory<_i387.TimeSettingsApiClient>(() =>
      _i387.TimeSettingsApiClient(gh<_i361.Dio>(instanceName: 'privateDio')));
  gh.factory<_i198.PlanProgressCubit>(
      () => _i198.PlanProgressCubit(gh<_i477.MeasurementsDbProvider>()));
  gh.factory<_i1047.CarePlanDbProvider>(() => _i1047.CarePlanDbProvider(
        gh<_i133.AppDatabase>(),
        gh<_i728.CarePlanVersionMapper>(),
        gh<_i763.CarePlanActivityMapper>(),
      ));
  gh.factory<_i478.UserDbProvider>(() => _i478.UserDbProvider(
        gh<_i133.AppDatabase>(),
        gh<_i222.UserMapper>(),
        gh<_i108.WhenCodeMapper>(),
        gh<_i1000.ThresholdsMapper>(),
        gh<_i331.DeviceDbProvider>(),
        gh<_i847.DevicePrototypeDbProvider>(),
      ));
  gh.factory<_i541.AuthApiClient>(
      () => _i541.AuthApiClient(gh<_i361.Dio>(instanceName: 'authDio')));
  gh.factory<_i1045.ChartBloc>(() => _i1045.ChartBloc(
        gh<_i1047.CarePlanDbProvider>(),
        gh<_i477.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i994.BtConnectionHelper>(
      () => _i994.BtConnectionHelper(gh<_i847.DevicePrototypeDbProvider>()));
  await gh.lazySingletonAsync<_i584.UserCubit>(
    () => _i584.UserCubit.create(
      gh<_i478.UserDbProvider>(),
      gh<_i654.SettingsDbProvider>(),
      gh<_i477.MeasurementsDbProvider>(),
      gh<_i1047.CarePlanDbProvider>(),
    ),
    preResolve: true,
  );
  gh.factory<_i961.DeviceManagementCubit>(() => _i961.DeviceManagementCubit(
        gh<_i331.DeviceDbProvider>(),
        gh<_i584.UserCubit>(),
        gh<_i847.DevicePrototypeDbProvider>(),
      ));
  gh.singleton<_i347.DeviceRepository>(() => _i347.DeviceRepository(
        gh<_i122.DeviceApiClient>(),
        gh<_i584.UserCubit>(),
      ));
  gh.singleton<_i658.TimeSettingsRepository>(() => _i658.TimeSettingsRepository(
        gh<_i387.TimeSettingsApiClient>(),
        gh<_i584.UserCubit>(),
      ));
  gh.singleton<_i917.NotificationsBloc>(() => _i917.NotificationsBloc(
        gh<_i654.SettingsDbProvider>(),
        gh<_i584.UserCubit>(),
      ));
  gh.singleton<_i744.CarePlansRepository>(() => _i744.CarePlansRepository(
        gh<_i409.CarePlanApiClient>(),
        gh<_i584.UserCubit>(),
      ));
  gh.factory<_i444.CalendarBloc>(() => _i444.CalendarBloc(
        gh<_i584.UserCubit>(),
        gh<_i795.CalendarFooterBloc>(),
        gh<_i1047.CarePlanDbProvider>(),
        gh<_i477.MeasurementsDbProvider>(),
        gh<_i744.CarePlansRepository>(),
        gh<_i89.MeasurementTypeMapper>(),
      ));
  gh.singleton<_i319.AccountRepository>(() => _i319.AccountRepository(
        gh<_i708.AccountApiClient>(),
        gh<_i584.UserCubit>(),
      ));
  gh.factory<_i193.TimesSettingsBloc>(() => _i193.TimesSettingsBloc(
        gh<_i403.InternetService>(),
        gh<_i658.TimeSettingsRepository>(),
        gh<_i761.WhenTemplateDbProvider>(),
        gh<_i108.WhenCodeMapper>(),
        gh<_i584.UserCubit>(),
      ));
  gh.factory<_i206.ResultsBloc>(() => _i206.ResultsBloc(
        gh<_i584.UserCubit>(),
        gh<_i1047.CarePlanDbProvider>(),
        gh<_i477.MeasurementsDbProvider>(),
      ));
  gh.singleton<_i260.CarePlanBloc>(() => _i260.CarePlanBloc(
        gh<_i584.UserCubit>(),
        gh<_i1047.CarePlanDbProvider>(),
        gh<_i477.MeasurementsDbProvider>(),
      ));
  gh.factory<_i380.ChartLoaderBloc>(() => _i380.ChartLoaderBloc(
        gh<_i744.CarePlansRepository>(),
        gh<_i477.MeasurementsDbProvider>(),
        gh<_i89.MeasurementTypeMapper>(),
      ));
  await gh.lazySingletonAsync<_i420.ReportService>(
    () => _i420.ReportService.create(
      gh<_i640.LogDbProvider>(),
      gh<_i319.AccountRepository>(),
      gh<_i517.LogEventMapper>(),
    ),
    preResolve: true,
  );
  gh.singleton<_i979.SyncService>(() => _i979.SyncService(
        gh<_i584.UserCubit>(),
        gh<_i319.AccountRepository>(),
        gh<_i744.CarePlansRepository>(),
        gh<_i658.TimeSettingsRepository>(),
        gh<_i347.DeviceRepository>(),
        gh<_i1047.CarePlanDbProvider>(),
        gh<_i89.MeasurementTypeMapper>(),
        gh<_i477.MeasurementsDbProvider>(),
        gh<_i478.UserDbProvider>(),
        gh<_i847.DevicePrototypeDbProvider>(),
        gh<_i761.WhenTemplateDbProvider>(),
        gh<_i331.DeviceDbProvider>(),
        gh<_i654.SettingsDbProvider>(),
      ));
  gh.factory<_i768.RegisterDeviceBloc>(() => _i768.RegisterDeviceBloc(
        gh<_i994.BtConnectionHelper>(),
        gh<_i347.DeviceRepository>(),
        gh<_i420.ReportService>(),
      ));
  gh.singleton<_i396.BackgroundMeasurementManager>(
      () => _i396.BackgroundMeasurementManager(
            gh<_i979.SyncService>(),
            gh<_i207.BackgroundMeasurementCubit>(),
            gh<_i420.ReportService>(),
            gh<_i331.DeviceDbProvider>(),
            gh<_i477.MeasurementsDbProvider>(),
          ));
  gh.singleton<_i79.AuthBloc>(() => _i79.AuthBloc(
        gh<_i745.AuthService>(),
        gh<_i420.ReportService>(),
        gh<_i319.AccountRepository>(),
        gh<_i584.UserCubit>(),
        gh<_i478.UserDbProvider>(),
        gh<_i361.Dio>(instanceName: 'privateDio'),
        gh<_i979.SyncService>(),
        gh<_i654.SettingsDbProvider>(),
        gh<_i658.TimeSettingsRepository>(),
      ));
  gh.singleton<_i24.SyncBloc>(() => _i24.SyncBloc(
        gh<_i478.UserDbProvider>(),
        gh<_i979.SyncService>(),
        gh<_i584.UserCubit>(),
        gh<_i1047.CarePlanDbProvider>(),
      ));
  gh.factory<_i362.OmronConnectionBloc>(() => _i362.OmronConnectionBloc(
        gh<_i994.BtConnectionHelper>(),
        gh<_i420.ReportService>(),
        gh<_i331.DeviceDbProvider>(),
      ));
  gh.singleton<_i984.BackgroundMeasurementStatusCubit>(() =>
      _i984.BackgroundMeasurementStatusCubit(
          gh<_i396.BackgroundMeasurementManager>()));
  gh.singleton<_i951.ContentBloc>(() => _i951.ContentBloc(
        gh<_i478.UserDbProvider>(),
        gh<_i584.UserCubit>(),
        gh<_i260.CarePlanBloc>(),
        gh<_i420.ReportService>(),
        gh<_i654.SettingsDbProvider>(),
      ));
  gh.factory<_i750.TokenInterceptor>(() => _i750.TokenInterceptor(
        gh<_i584.UserCubit>(),
        gh<_i708.AccountApiClient>(),
        gh<_i420.ReportService>(),
        gh<_i478.UserDbProvider>(),
      ));
  gh.factory<_i243.ReportBloc>(
      () => _i243.ReportBloc(gh<_i420.ReportService>()));
  return getIt;
}

class _$DioModule extends _i784.DioModule {}
