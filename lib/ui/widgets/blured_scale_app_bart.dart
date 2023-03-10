import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';

class BluredScaleAppBar extends StatelessWidget {
  const BluredScaleAppBar({
    super.key,
    required this.title,
    this.subTitle,
    this.showClose = false,
    this.onBackTap,
    this.onCloseTap,
  });

  final String title;
  final String? subTitle;
  final bool showClose;
  final VoidCallback? onBackTap;
  final VoidCallback? onCloseTap;

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
                height: topGap + Constants.appBarHeight,
                color:
                    Theme.of(context).colorScheme.background.withOpacity(0.8),
              ),
            ),
          ),
        ),
        ScaleAppBar(
          title: title,
          subTitle: subTitle,
          showClose: showClose,
          onBackTap: onBackTap,
          onCloseTap: onCloseTap,
        )
      ],
    );
  }
}
