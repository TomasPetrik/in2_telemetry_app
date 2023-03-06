import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/hospital_details_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class HospitalDetailRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'hospital-detail';
  static const path = 'hospital-detail';

  HospitalDetailRoute({
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
          final extras = state.extra! as List;
          final hospitalTitle = extras[0] as String;
          final usersIds = extras[1] as List<String>;

          final List<UserAccount> userAccounts = [];
          for (final userId in usersIds) {
            final userAccount = getIt<AccountDbProvider>().get(userId);
            if (userAccount != null) {
              userAccounts.add(userAccount);
            }
          }

          return HospitalDetailScreen(
            hospitalTitle: hospitalTitle,
            userAccounts: userAccounts,
          );
        },
      ),
    );
  }
}
