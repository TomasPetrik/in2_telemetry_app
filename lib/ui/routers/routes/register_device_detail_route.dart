import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/model/device_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/register_device_detail_screen.dart';

class RegisterDeviceDetailRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'register-device-detail';
  static const path =
      '/register-device-detail/:userId';

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
          final userId = int.parse(state.pathParameters['userId']!);
          final userAccount = getIt<UserCubit>().state.allUsers.firstWhere((x)=>x.id == userId);
          final device = state.extra as DeviceModel;

          return RegisterDeviceDetailScreen(
            userAccount: userAccount,
            device: device,
          );
        },
      ),
    );
  }
}
