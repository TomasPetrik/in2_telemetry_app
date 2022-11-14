import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/service_locator/get_it.config.dart';

final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: false)
void setUpGetIt() => $initGetIt(getIt);
