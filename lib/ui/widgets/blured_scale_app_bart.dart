import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';

class BluredScaleAppBar extends StatelessWidget {
  const BluredScaleAppBar({
    super.key,
    required this.title,
    this.subTitle,
    this.actionLabel,
    this.showClose = false,
    this.onBackTap,
    this.onCloseTap,
    this.customLeftWidget,
  });

  final String title;
  final String? subTitle;
  final String? actionLabel;
  final bool showClose;
  final VoidCallback? onBackTap;
  final VoidCallback? onCloseTap;
  final Widget? customLeftWidget;

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
                height: topGap + Dimensions.appBarHeight,
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
          customLeftWidget: customLeftWidget,
        )
      ],
    );
  }
}
