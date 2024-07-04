import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/localization/generated/l10n.dart';
import 'package:scalesoft_app/service_locator/get_it.config.dart';

final getIt = GetIt.instance;
final I10n localization = getIt<I10n>();

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies() async {
  if (!getIt.isRegistered<I10n>()) {
    getIt.registerLazySingleton(I10n.new);
    await init(getIt);
  }

  getIt<Dio>(instanceName: ConfigurationConstants.privateDioName).interceptors.add(getIt<TokenInterceptor>());
}
