import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/localization/generated/l10n.dart';
import 'package:scalesoft_app/service_locator/get_it.config.dart';

final getIt = GetIt.instance;
final I10n localization = getIt<I10n>();

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<GetIt> configureDependencies(BuildContext context) async {
  getIt.registerLazySingleton(I10n.new);
  return await init(getIt);
}
