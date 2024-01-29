import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/device_search_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class DeviceSearchRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'device-search';
  static const path = '/device-search/:userId/:devicePurpose';

  DeviceSearchRoute({
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
          final devicePurposeName = state.params['devicePurpose']!;
          final DevicePurpose devicePurpose =
              DevicePurpose.values.firstWhere(
            (devicePurpose) => devicePurpose.name == devicePurposeName,
          );

          return DeviceSearchScreen(
            userId: userId,
            devicePurpose: devicePurpose,
          );
        },
      ),
    );
  }
}
