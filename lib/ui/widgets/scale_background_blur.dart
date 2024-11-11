import 'dart:ui';

import 'package:flutter/material.dart';

class ScaleBackgroundBlur extends StatelessWidget {
  final Widget child;
  final double sigma;

  const ScaleBackgroundBlur({required this.child, super.key, this.sigma = 1.2});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: sigma, sigmaX: sigma),
        child: child,
      ),
    );
  }
}
