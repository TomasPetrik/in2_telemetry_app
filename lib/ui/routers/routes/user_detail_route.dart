import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/blank_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/user_details_screen.dart';

class UserDetailRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'user-detail';
  static const path = 'user-detail';

  UserDetailRoute({
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
        withTransition: true,
        builder: (state) {
          final userId = state.extra! as String;
          final userAccount = getIt<AccountDbProvider>().get(userId);
          if (userAccount != null) {
            return UserDetailScreen(
              userAccount: userAccount,
            );
          } else {
            return const BlankScreen();
          }
        },
      ),
    );
  }
}
