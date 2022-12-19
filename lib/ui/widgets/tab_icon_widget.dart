import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

class TabIconWidget extends StatelessWidget {
  const TabIconWidget({
    super.key,
    required this.icon,
    required this.isActive,
  });

  final Widget icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Paddings.all10,
      decoration: isActive
          ? BoxDecoration(
              borderRadius: BorderRadii.radius8,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            )
          : null,
      child: SizedBox(height: 25, width: 25, child: icon),
    );
  }
}
