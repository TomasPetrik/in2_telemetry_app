import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/calendar_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class CalendarRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'calendar';
  static const path = '/calendar';

  CalendarRoute({
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
          final preSelectedDt = getIt<UserCubit>().preSelectedDtRestoration;
          final carePlansIds = state.extra! as List<int>;

          return CalendarScreen(
            preSelectedDt: preSelectedDt,
            carePlansIds: carePlansIds,
          );
        },
      ),
    );
  }
}
