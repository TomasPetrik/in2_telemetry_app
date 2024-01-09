import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/blank_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class BlankRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'blank';
  static const path = '/blank';

  BlankRoute({
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
          return BlankScreen(
            key: UniqueKey(),
          );
        },
      ),
    );
  }
}
