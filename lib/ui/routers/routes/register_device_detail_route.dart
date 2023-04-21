import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/register_device_detail_screen.dart';
import 'package:scalesoft_app/utils/constants.dart';

class RegisterDeviceDetailRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'register-device-detail';
  static const path = '/register-device-detail/:userId/:localId/:deviceIdentifier';

  RegisterDeviceDetailRoute({
    required super.navigator,
    super.routes,
  });

  @override
  GoRoute get route {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      parentNavigatorKey: navigator,
      pageBuilder: pageBuilder(
        withTransition: false,
        builder: (state) {
          final userId = state.params['userId']!;
          final userAccount = getIt<AccountDbProvider>().get(userId)!;
          final localId = int.parse(state.params['localId']!);
          final deviceIdentifier = state.params['deviceIdentifier']!;
          final device = Constants.supportedDevices
              .firstWhere((device) => device.localId == localId)
              .copyWith(deviceIdentifier: deviceIdentifier);

          return RegisterDeviceDetailScreen(
            userAccount: userAccount,
            device: device,
          );
        },
      ),
    );
  }
}
