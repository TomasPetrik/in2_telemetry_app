import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/omron_flow_screen.dart';

class OmronFlowRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'omron-flow';
  static const path = '/omron-flow';

  OmronFlowRoute({
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
          final extras = state.extra! as List;
          final userId = extras[0] as String;
          final localDeviceId = extras[1] as int;
          final measurementTypeIndex = extras[2] as int;

          return OmronFlowScreen(
            userId: userId,
            localDeviceId: localDeviceId,
            measurementTypeIndex: measurementTypeIndex,
          );
        },
      ),
    );
  }
}
