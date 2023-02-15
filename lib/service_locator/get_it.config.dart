// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:scalesoft_app/api/client/account_api_client.dart' as _i15;
import 'package:scalesoft_app/api/client/auth_api_client.dart' as _i17;
import 'package:scalesoft_app/api/client/care_plan_api_client.dart' as _i18;
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart' as _i23;
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart' as _i24;
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart' as _i6;
import 'package:scalesoft_app/bloc/results/results_bloc.dart' as _i11;
import 'package:scalesoft_app/bloc/settings/settings_bloc.dart' as _i21;
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart' as _i25;
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart' as _i20;
import 'package:scalesoft_app/cubit/auth_web/auth_web_cubit.dart' as _i5;
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_cubit.dart'
    as _i8;
import 'package:scalesoft_app/cubit/omron/omron_connection_cubit.dart' as _i9;
import 'package:scalesoft_app/providers/account_db_provider.dart' as _i3;
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart'
    as _i10;
import 'package:scalesoft_app/providers/settings_db_provider.dart' as _i13;
import 'package:scalesoft_app/repositories/account_repository.dart' as _i16;
import 'package:scalesoft_app/repositories/care_plans_repository.dart' as _i19;
import 'package:scalesoft_app/services/auth_service.dart' as _i4;
import 'package:scalesoft_app/services/settings_service.dart' as _i14;
import 'package:scalesoft_app/services/sync_service.dart' as _i22;
import 'package:scalesoft_app/storage/session.dart' as _i12;

import '../api/dio_module.dart' as _i26;

/// ignore_for_file: unnecessary_lambdas
/// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of main-scope dependencies inside of [GetIt]
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
  gh.singleton<_i3.AccountDbProvider>(_i3.AccountDbProvider());
  gh.singleton<_i4.AuthService>(_i4.AuthService());
  gh.factory<_i5.AuthWebCubit>(() => _i5.AuthWebCubit());
  gh.singleton<_i6.CarePlanBloc>(_i6.CarePlanBloc());
  gh.singleton<_i7.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.factory<_i8.HospitalSearchCubit>(() => _i8.HospitalSearchCubit());
  gh.singleton<_i9.OmronConnectionCubit>(_i9.OmronConnectionCubit());
  gh.singleton<_i10.PendingResultsDbProvider>(_i10.PendingResultsDbProvider());
  gh.singleton<_i11.ResultsBloc>(_i11.ResultsBloc());
  gh.singleton<_i12.Session>(_i12.Session(
    gh<_i3.AccountDbProvider>(),
    gh<_i10.PendingResultsDbProvider>(),
  ));
  gh.singleton<_i13.SettingsDbProvider>(_i13.SettingsDbProvider());
  await gh.lazySingletonAsync<_i14.SettingsService>(
    () => _i14.SettingsService.create(),
    preResolve: true,
    dispose: (i) => i.dispose(),
  );
  gh.factory<_i15.AccountApiClient>(
      () => _i15.AccountApiClient(gh<_i7.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i16.AccountRepository>(
      _i16.AccountRepository(gh<_i15.AccountApiClient>()));
  gh.factory<_i17.AuthApiClient>(
      () => _i17.AuthApiClient(gh<_i7.Dio>(instanceName: 'privateDio')));
  gh.factory<_i18.CarePlanApiClient>(
      () => _i18.CarePlanApiClient(gh<_i7.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i19.CarePlansRepository>(_i19.CarePlansRepository(
    gh<_i18.CarePlanApiClient>(),
    gh<_i12.Session>(),
  ));
  gh.singleton<_i20.ContentBloc>(_i20.ContentBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i12.Session>(),
  ));
  gh.factory<_i21.SettingsBloc>(() => _i21.SettingsBloc(
        gh<_i14.SettingsService>(),
        gh<_i13.SettingsDbProvider>(),
      ));
  gh.singleton<_i22.SyncService>(_i22.SyncService(
    gh<_i12.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i10.PendingResultsDbProvider>(),
    gh<_i19.CarePlansRepository>(),
  ));
  gh.factory<_i23.TokenInterceptor>(() => _i23.TokenInterceptor(
        gh<_i12.Session>(),
        gh<_i15.AccountApiClient>(),
      ));
  gh.singleton<_i24.AuthBloc>(_i24.AuthBloc(
    gh<_i4.AuthService>(),
    gh<_i16.AccountRepository>(),
    gh<_i12.Session>(),
    gh<_i3.AccountDbProvider>(),
    gh<_i10.PendingResultsDbProvider>(),
    gh<_i7.Dio>(instanceName: 'privateDio'),
    gh<_i22.SyncService>(),
  ));
  gh.singleton<_i25.SyncBloc>(_i25.SyncBloc(
    gh<_i3.AccountDbProvider>(),
    gh<_i22.SyncService>(),
    gh<_i12.Session>(),
  ));
  return getIt;
}

class _$DioModule extends _i26.DioModule {}
