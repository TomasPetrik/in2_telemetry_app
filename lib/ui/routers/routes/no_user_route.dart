import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/onboarding_screen.dart';

class NoUserRoute extends ApplicationRoute {
  static const name = 'no-user';
  static const path = 'no-user';

  NoUserRoute({
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
        return const OnboardingScreen();
      },
    );
  }
}
