import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

class TabIconWidget extends StatelessWidget {
  const TabIconWidget({
    super.key,
    required this.icon,
    required this.isActive,
    this.showWarning,
  });

  final Widget icon;
  final bool isActive;
  final bool? showWarning;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: Paddings.all4,
          margin: Paddings.bottom5,
          width: 40,
          height: 32,
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadii.radius8,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          child: SizedBox(height: 25, width: 25, child: icon),
        ),
        if (showWarning == true)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadii.radius4,
              ),
            ),
          ),
      ],
    );
  }
}
