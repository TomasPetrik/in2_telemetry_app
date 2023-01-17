import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/painters/user_item_painter.dart';

class UserItemShape extends StatelessWidget {
  const UserItemShape({
    super.key,
    required this.userItemType,
    this.width = 15,
  });

  final UserItemType userItemType;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: UserItemPainter(
          borderColor: Theme.of(context).colorScheme.secondary,
          userItemType: userItemType,
        ),
      ),
    );
  }
}
