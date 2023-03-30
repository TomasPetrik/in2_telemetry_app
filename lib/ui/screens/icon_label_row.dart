import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class ConnectionLevel extends StatelessWidget {
  const ConnectionLevel({
    super.key,
    required this.label,
    required this.iconPath,
    required this.isActive,
  });

  final String label;
  final String iconPath;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          color: isActive
              ? Theme.of(context).colorScheme.onTertiary
              : Theme.of(context).colorScheme.tertiary,
        ),
        Gaps.gap16,
        Expanded(
          child: Text(
            label,
            style: ScaleTextStyles.textAccent.apply(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        )
      ],
    );
  }
}
