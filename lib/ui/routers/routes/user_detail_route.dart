import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
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
          final userAccount = state.extra! as UserAccount;
          return UserDetailScreen(
            userAccount: userAccount,
          );
        },
      ),
    );
  }
}
