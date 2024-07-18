import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/register_device_success_screen.dart';

class RegisterDeviceSuccessRoute extends ApplicationRoute
    with PageBuilderMixin {
  static const name = 'register-device-success';
  static const path = '/register-device-success/:deviceName';

  RegisterDeviceSuccessRoute({
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
          final deviceName = state.pathParameters['deviceName']!;
          return RegisterDeviceSuccessScreen(deviceName: deviceName);
        },
      ),
    );
  }
}
