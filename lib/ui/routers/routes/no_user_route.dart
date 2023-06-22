import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/onboarding_screen.dart';

class NoUserRoute extends ApplicationRoute with BottomSheetMixin {
  static const name = 'no-user';
  static const path = '/no-user';

  NoUserRoute({
    required super.navigator,
    super.routes,
  });

  Future<void> requestPermissionsIfNeed(BuildContext context) async {
    if (!Platform.isAndroid) {
      return;
    }

    Permission.notification.request().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.denied) {
        showNotificationsSettings(context: context)
            .then((openNotificationSettings) {
          if (openNotificationSettings == true) {
            AppSettings.openNotificationSettings();
          }
        });
      }
    });
  }

  @override
  GoRoute get route {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      parentNavigatorKey: navigator,
      builder: (context, state) {
        requestPermissionsIfNeed(context);

        return const OnboardingScreen();
      },
    );
  }
}
