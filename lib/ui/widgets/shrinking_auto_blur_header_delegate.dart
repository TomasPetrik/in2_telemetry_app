import 'dart:ui';

import 'package:flutter/material.dart';

class ShrinkingAutoBlurHeaderDelegate extends SliverPersistentHeaderDelegate {
  ShrinkingAutoBlurHeaderDelegate({
    required this.shrinkingChild,
    required this.child,
    required this.childHeight,
    required this.shrinedChildHeight,
    required this.topOffset,
    required this.blurColor,
  });
  final Widget shrinkingChild;
  final Widget child;
  final double shrinedChildHeight;
  final double childHeight;
  final double topOffset;
  final Color blurColor;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    bool isBlured;
    if (shrinkOffset > 0 && shrinedChildHeight < topOffset) {
      isBlured = true;
    } else {
      isBlured = shrinkOffset > (shrinedChildHeight - topOffset).abs();
    }

    debugPrint('shrinkOffset : $shrinkOffset, isBlured: $isBlured');
    return Column(
      children: [
        if (isBlured)
          SizedBox(
            height: topOffset,
          )
        else
          Flexible(child: shrinkingChild),
        Stack(
          children: [
            if (isBlured)
              Positioned.fill(
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: blurColor,
                    ),
                  ),
                ),
              ),
            SizedBox(
              child: child,
            ),
          ],
        ),
      ],
    );
  }

  @override
  double get maxExtent =>
      childHeight +
      (shrinedChildHeight < topOffset ? topOffset + 1 : shrinedChildHeight);

  @override
  double get minExtent => childHeight + topOffset;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
