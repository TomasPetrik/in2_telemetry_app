import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/user_details_screen.dart';

class UserDetailRoute extends ApplicationRoute {
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
      builder: (context, state) {
        final userAccount = state.extra! as UserAccount;
        return UserDetailScreen(
          userAccount: userAccount,
        );
      },
    );
  }
}
