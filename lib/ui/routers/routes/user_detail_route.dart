import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/cubit/care_plan/care_plan_cubit.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
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
          final userId = state.extra! as int;
          final carePlanCubit = CarePlanCubit()..init(userId);

          // Use BlocProvider to preserve carePlanCubit inside UserDetailsScreen when sync state changes
          // (Prevent care plan list flickering after synchronization)
          return BlocProvider(
            create: (_) => carePlanCubit,
            child: BlocBuilder<UserCubit, UserCubitState>(
              bloc: getIt<UserCubit>(),
              builder: (context, state) {
                final user = state.allUsers.firstWhereOrNull((x) => x.id == userId);

                if (user == null) {
                  return const BlankScreen();
                }

                return UserDetailScreen(userAccount: user);
              },
            ),
          );
        },
      ),
    );
  }
}
