import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/widgets/scale_background_blur.dart';

class BlurredAppBar extends StatelessWidget {
  const BlurredAppBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ScaleBackgroundBlur(
            sigma:10,
            child: Container(
              color:
                  Theme.of(context).appBarTheme.backgroundColor,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
