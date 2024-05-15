import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/user_added_screen.dart';

class UserAddedRoute extends ApplicationRoute {
  static const name = 'user-added';
  static const path = '/user-added/:userId';

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
        final userId = int.parse(state.pathParameters['userId']!);

        return BlocBuilder<UserCubit, UserCubitState>(
          bloc: getIt<UserCubit>(),
          builder: (context, state) {
            final user = state.rootUsers.firstWhereOrNull((x) => x.id == userId);

            if (user == null) {
              return const CircularProgressIndicator();
            }

            return UserAddedScreen(userAccount: user);
          },
        );
      },
    );
  }
}
