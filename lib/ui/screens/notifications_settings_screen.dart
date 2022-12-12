import 'package:flutter/material.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  static const routeName = '/notifications-settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScaleColorsLight.paper,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaleAppBar(
              onBackTap: () {},
              title: context.locale.notifications_screen_title,
            ),
            Padding(
              padding: Paddings.horizontal16,
              child: Column(
                children: const [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
