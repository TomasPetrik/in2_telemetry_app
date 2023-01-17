import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/hospital_details_screen.dart';

class HospitalDetailRoute extends ApplicationRoute {
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
      builder: (context, state) {
        final extras = state.extra! as List;
        final hospital = extras[0] as Hospital;
        final userAccounts = extras[1] as List<UserAccount>;
        return HospitalDetailScreen(
          hospital: hospital,
          userAccounts: userAccounts,
        );
      },
    );
  }
}
