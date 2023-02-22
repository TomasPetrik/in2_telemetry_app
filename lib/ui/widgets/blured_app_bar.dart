import 'dart:ui';

import 'package:flutter/material.dart';

class BluredAppBar extends StatelessWidget {
  const BluredAppBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color:
                    Theme.of(context).colorScheme.background.withOpacity(0.8),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
