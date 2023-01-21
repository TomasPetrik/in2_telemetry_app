import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/dashboard_page.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class ResultsRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'single-user-results';
  static const path = 'single-user-results/:userId';

  ResultsRoute({
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
          final accountDbProvider = getIt<AccountDbProvider>();
          final userAccount = accountDbProvider.get(userId)!;

          return DashboardPage(
            key: UniqueKey(),
            userAccount: userAccount,
          );
        },
      ),
    );
  }
}
