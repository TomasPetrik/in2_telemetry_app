import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/user_app_bar.dart';

class BluredUserAppBar extends StatelessWidget {
  const BluredUserAppBar({
    super.key,
    required this.userInfo,
  });

  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: topGap + Constants.twoLinedBarHeight,
                color: Theme.of(context).backgroundColor.withOpacity(0.8),
              ),
            ),
          ),
        ),
        UserAppBar(
          userInfo: userInfo,
        )
      ],
    );
  }
}
