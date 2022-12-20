import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  static const routeName = '/notifications-settings';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(MediaQuery.of(context).viewPadding.top + Constants.appBarHeight),
                  Gaps.gap16,
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleAppBar(
              title: context.locale.notifications_screen_title,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
