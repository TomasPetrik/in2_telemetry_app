import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/configuration_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

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
          return FutureBuilder<List<MapEntry<Hospital, List<UserModel>>>>(
            future: getHospitalUserEntries(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return ConfigurationScreen(
                  key: UniqueKey(),
                  hospitalUserEntries: snapshot.data!,
                );
              }
              return const LoadingIndicator();
            },
          );
        },
      ),
    );
  }

  Future<List<MapEntry<Hospital, List<UserModel>>>> getHospitalUserEntries() async {
    final users = await getIt<UserDbProvider>().getAllRootUsers();
    return users.groupListsBy<Hospital>((userAccount) => userAccount.hospital).entries.toList();
  }
}
