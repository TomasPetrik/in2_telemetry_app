// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i4;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:scalesoft_app/api/client/account_api_client.dart' as _i8;
import 'package:scalesoft_app/api/client/auth_api_client.dart' as _i10;
import 'package:scalesoft_app/api/dio_module.dart' as _i13;
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart' as _i12;
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart' as _i11;
import 'package:scalesoft_app/cubit/omron/omron_connection_cubit.dart' as _i6;
import 'package:scalesoft_app/repository/account_repository.dart' as _i9;
import 'package:scalesoft_app/services/auth_service.dart' as _i3;
import 'package:scalesoft_app/storage/secure_storage_module.dart' as _i14;
import 'package:scalesoft_app/storage/storage.dart'
    as _i7; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(
  _i1.GetIt get, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    get,
    environment,
    environmentFilter,
  );
  final dioModule = _$DioModule();
  final secureStorageModule = _$SecureStorageModule();
  gh.singleton<_i3.AuthService>(_i3.AuthService());
  gh.singleton<_i4.Dio>(
    dioModule.privateDio,
    instanceName: 'privateDio',
  );
  gh.singleton<_i5.FlutterSecureStorage>(secureStorageModule.storage);
  gh.singleton<_i6.OmronConnectionCubit>(_i6.OmronConnectionCubit());
  gh.singleton<_i7.Storage>(_i7.Storage(get<_i5.FlutterSecureStorage>()));
  gh.factory<_i8.AccountApiClient>(
      () => _i8.AccountApiClient(get<_i4.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i9.AccountRepository>(
      _i9.AccountRepository(get<_i8.AccountApiClient>()));
  gh.factory<_i10.AuthApiClient>(
      () => _i10.AuthApiClient(get<_i4.Dio>(instanceName: 'privateDio')));
  gh.singleton<_i11.AuthBloc>(_i11.AuthBloc(
    get<_i3.AuthService>(),
    get<_i9.AccountRepository>(),
    get<_i7.Storage>(),
  ));
  gh.factory<_i12.TokenInterceptor>(() => _i12.TokenInterceptor(
        get<_i7.Storage>(),
        get<_i8.AccountApiClient>(),
      ));
  return get;
}

class _$DioModule extends _i13.DioModule {}

class _$SecureStorageModule extends _i14.SecureStorageModule {}
