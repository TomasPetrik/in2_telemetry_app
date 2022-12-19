import 'package:flutter/material.dart';

class FixedHeightItemDelegate extends SliverPersistentHeaderDelegate {
  FixedHeightItemDelegate({
    required this.child,
    required this.fixedHeight,
  });
  final Widget child;
  final double fixedHeight;
  double? offset;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Column(
      children: [
        child,
        const Expanded(
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  double get maxExtent => fixedHeight;

  @override
  double get minExtent => fixedHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
