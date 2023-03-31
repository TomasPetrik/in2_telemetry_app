import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/register_device_screen.dart';

class RegisterDeviceRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'register-device';
  static const path = '/register-device';

  RegisterDeviceRoute({
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
          return const RegisterDeviceScreen();
        },
      ),
    );
  }
}
