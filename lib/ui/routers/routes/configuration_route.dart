import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/configuration_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class ConfigurationRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'configuration';
  static const path = '/configuration';

  ConfigurationRoute({
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
          return BlocBuilder<UserCubit, UserCubitState>(
            bloc: getIt<UserCubit>(),
            builder: (context, state) {
              final hospitalUserMap = getHospitalUserEntries(state.rootUsers);
              return ConfigurationScreen(
                key: UniqueKey(),
                hospitalUserEntries: hospitalUserMap,
              );
            },
          );
        },
      ),
    );
  }

  List<MapEntry<Hospital, List<UserModel>>> getHospitalUserEntries(List<UserModel> rootUsers) {
    return rootUsers.groupListsBy<Hospital>((userAccount) => userAccount.hospital).entries.toList();
  }
}
