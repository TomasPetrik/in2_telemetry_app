// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i13;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../api/client/account_api_client.dart' as _i24;
import '../api/client/auth_api_client.dart' as _i26;
import '../api/client/care_plan_api_client.dart' as _i28;
import '../api/client/device_api_client.dart' as _i31;
import '../api/client/time_settings_api_client.dart' as _i21;
import '../api/dio_module.dart' as _i44;
import '../api/interceptors/token_interceptor.dart' as _i35;
import '../bloc/auth/auth_bloc.dart' as _i36;
import '../bloc/calendar/calendar_bloc.dart' as _i27;
import '../bloc/calendar_footer/calendar_footer_bloc.dart' as _i8;
import '../bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc.dart'
    as _i38;
import '../bloc/care_plan/care_plan_bloc.dart' as _i9;
import '../bloc/chart_bloc/chart_bloc.dart' as _i11;
import '../bloc/chart_loader_bloc/chart_loader_bloc.dart' as _i30;
import '../bloc/daily_times_settings/times_settings_bloc.dart' as _i23;
import '../bloc/notifications/notifications_bloc.dart' as _i17;
import '../bloc/omron/omron_connection_bloc.dart' as _i40;
import '../bloc/register_device/register_device_bloc.dart' as _i41;
import '../bloc/report/report_bloc.dart' as _i42;
import '../bloc/results/results_bloc.dart' as _i18;
import '../bloc/settings/app_settings_bloc.dart' as _i4;
import '../bloc/sync/sync_bloc.dart' as _i43;
import '../bloc/user_content/content_bloc.dart' as _i39;
import '../cubit/background_measurement/background_measurement_cubit.dart'
    as _i6;
import '../cubit/device_management/device_management_cubit.dart' as _i12;
import '../cubit/hospital_search/hospital_search_cubit.dart' as _i14;
import '../cubit/loader/loader_cubit.dart' as _i16;
import '../data/app_database.dart' as _i3;
import '../data/repositories/care_plan_repository.dart' as _i10;
import '../managers/background_measurement_manager.dart' as _i37;
import '../providers/session_db_provider.dart' as _i20;
import '../repositories/account_repository.dart' as _i25;
import '../repositories/care_plans_repository.dart' as _i29;
import '../repositories/device_repository.dart' as _i32;
import '../repositories/time_settings_repository.dart' as _i22;
import '../services/auth_service.dart' as _i5;
import '../services/internet_service.dart' as _i15;
import '../services/report_service.dart' as _i33;
import '../services/sync_service.dart' as _i34;
import '../storage/session.dart' as _i19;
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
  gh.singleton<_i3.AppDatabase>(_i3.AppDatabase());
  gh.singleton<_i4.AppSettingsBloc>(_i4.AppSettingsBloc(gh<InvalidType>()));
  gh.singleton<_i5.AuthService>(_i5.AuthService());
  gh.singleton<_i6.BackgroundMeasurementCubit>(
      _i6.BackgroundMeasurementCubit());
  gh.singleton<_i7.BtConnectionHelper>(_i7.BtConnectionHelper());
  gh.singleton<_i8.CalendarFooterBloc>(_i8.CalendarFooterBloc());
  gh.singleton<_i9.CarePlanBloc>(_i9.CarePlanBloc());
  gh.singleton<_i10.CarePlanRepository>(
      _i10.CarePlanRepository(gh<_i3.AppDatabase>()));
  gh.factory<_i11.ChartBloc>(() => _i11.ChartBloc());
  gh.factory<_i12.DeviceManagementCubit>(() => _i12.DeviceManagementCubit(
        gh<InvalidType>(),
        gh<InvalidType>(),
      ));
  gh.singleton<_i13.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i14.HospitalSearchCubit>(_i14.HospitalSearchCubit());
  gh.singleton<_i15.InternetService>(_i15.InternetService());
  gh.factory<_i16.LoaderCubit>(() => _i16.LoaderCubit());
  gh.singleton<_i17.NotificationsBloc>(_i17.NotificationsBloc(
    gh<InvalidType>(),
    gh<InvalidType>(),
  ));
  gh.factory<_i18.ResultsBloc>(() => _i18.ResultsBloc());
  gh.singleton<_i19.Session>(_i19.Session(
    gh<InvalidType>(),
    gh<InvalidType>(),
  ));
  await gh.singletonAsync<_i20.SessionDbProvider>(
    () {
      final i = _i20.SessionDbProvider();
      return i.init().then((_) => i);
    },
    preResolve: true,
  );
  gh.factory<_i21.TimeSettingsApiClient>(() =>
      _i21.TimeSettingsApiClient(gh<_i13.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i22.TimeSettingsRepository>(_i22.TimeSettingsRepository(
    gh<_i21.TimeSettingsApiClient>(),
    gh<_i19.Session>(),
  ));
  gh.factory<_i23.TimesSettingsBloc>(() => _i23.TimesSettingsBloc(
        gh<_i15.InternetService>(),
        gh<InvalidType>(),
        gh<_i22.TimeSettingsRepository>(),
      ));
  gh.factory<_i24.AccountApiClient>(
      () => _i24.AccountApiClient(gh<_i13.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i25.AccountRepository>(_i25.AccountRepository(
    gh<_i24.AccountApiClient>(),
    gh<_i19.Session>(),
  ));
  gh.factory<_i26.AuthApiClient>(
      () => _i26.AuthApiClient(gh<_i13.Dio>(instanceName: 'privateDio')));
  gh.factory<_i27.CalendarBloc>(() => _i27.CalendarBloc(
        gh<_i19.Session>(),
        gh<_i8.CalendarFooterBloc>(),
        gh<InvalidType>(),
      ));
  gh.factory<_i28.CarePlanApiClient>(
      () => _i28.CarePlanApiClient(gh<_i13.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i29.CarePlansRepository>(_i29.CarePlansRepository(
    gh<_i28.CarePlanApiClient>(),
    gh<_i19.Session>(),
  ));
  gh.factory<_i30.ChartLoaderBloc>(() => _i30.ChartLoaderBloc(
        gh<_i29.CarePlansRepository>(),
        gh<InvalidType>(),
        gh<InvalidType>(),
      ));
  gh.factory<_i31.DeviceApiClient>(
      () => _i31.DeviceApiClient(gh<_i13.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i32.DeviceRepository>(_i32.DeviceRepository(
    gh<_i31.DeviceApiClient>(),
    gh<_i19.Session>(),
  ));
  await gh.lazySingletonAsync<_i33.ReportService>(
    () => _i33.ReportService.create(
      gh<InvalidType>(),
      gh<InvalidType>(),
      gh<_i25.AccountRepository>(),
    ),
    preResolve: true,
  );
  gh.singleton<_i34.SyncService>(_i34.SyncService(
    gh<_i19.Session>(),
    gh<InvalidType>(),
    gh<InvalidType>(),
    gh<_i25.AccountRepository>(),
    gh<_i29.CarePlansRepository>(),
    gh<_i22.TimeSettingsRepository>(),
    gh<InvalidType>(),
    gh<_i32.DeviceRepository>(),
  ));
  gh.factory<_i35.TokenInterceptor>(() => _i35.TokenInterceptor(
        gh<_i19.Session>(),
        gh<_i24.AccountApiClient>(),
        gh<InvalidType>(),
        gh<_i33.ReportService>(),
      ));
  gh.singleton<_i36.AuthBloc>(_i36.AuthBloc(
    gh<_i5.AuthService>(),
    gh<_i33.ReportService>(),
    gh<_i25.AccountRepository>(),
    gh<_i19.Session>(),
    gh<InvalidType>(),
    gh<InvalidType>(),
    gh<InvalidType>(),
    gh<_i13.Dio>(instanceName: 'privateDio'),
    gh<_i34.SyncService>(),
  ));
  gh.singleton<_i37.BackgroundMeasurementManager>(
      _i37.BackgroundMeasurementManager(
    gh<_i34.SyncService>(),
    gh<InvalidType>(),
    gh<_i6.BackgroundMeasurementCubit>(),
    gh<_i33.ReportService>(),
  ));
  gh.factory<_i38.CalendarFulfillmentServiceBloc>(
      () => _i38.CalendarFulfillmentServiceBloc(
            gh<InvalidType>(),
            gh<_i8.CalendarFooterBloc>(),
            gh<_i29.CarePlansRepository>(),
            gh<InvalidType>(),
            gh<InvalidType>(),
            gh<InvalidType>(),
          ));
  gh.singleton<_i39.ContentBloc>(_i39.ContentBloc(
    gh<InvalidType>(),
    gh<_i20.SessionDbProvider>(),
    gh<_i19.Session>(),
    gh<_i9.CarePlanBloc>(),
    gh<_i33.ReportService>(),
  ));
  gh.factory<_i40.OmronConnectionBloc>(() => _i40.OmronConnectionBloc(
        gh<_i7.BtConnectionHelper>(),
        gh<InvalidType>(),
        gh<InvalidType>(),
        gh<_i33.ReportService>(),
      ));
  gh.factory<_i41.RegisterDeviceBloc>(() => _i41.RegisterDeviceBloc(
        gh<_i7.BtConnectionHelper>(),
        gh<InvalidType>(),
        gh<_i32.DeviceRepository>(),
        gh<_i33.ReportService>(),
      ));
  gh.factory<_i42.ReportBloc>(() => _i42.ReportBloc(gh<_i33.ReportService>()));
  gh.singleton<_i43.SyncBloc>(_i43.SyncBloc(
    gh<InvalidType>(),
    gh<_i34.SyncService>(),
    gh<_i19.Session>(),
  ));
  return getIt;
}

class _$DioModule extends _i44.DioModule {}
