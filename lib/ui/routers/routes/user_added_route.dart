import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/user_added_screen.dart';

class UserAddedRoute extends ApplicationRoute {
  static const name = 'user-added';
  static const path = 'user-added/:userId';

  UserAddedRoute({
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
        final userId = state.params['userId']!;
        final accountDbProvider = getIt<AccountDbProvider>();
        final userAccount = accountDbProvider.get(userId)!;

        return UserAddedScreen(
          userAccount: userAccount,
        );
      },
    );
  }
}
