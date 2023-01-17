import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.label,
    this.subLabel,
     this.onTap,
    this.icon,
    this.iconWidget,
    this.hasNavigationIcon = true,
  }) : assert(
          icon != null || iconWidget != null,
          'Either icon or iconWidget should be used',
        );

  final String label;
  final String? subLabel;
  final VoidCallback? onTap;
  final IconData? icon;
  final Widget? iconWidget;
  final bool hasNavigationIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadii.radius8,
            ),
            height: 64,
            width: 64,
            child: icon != null
                ? Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onSecondary,
                  )
                : Center(child: iconWidget),
          ),
          Gaps.gap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ScaleTextStyles.textAccent,
                ),
                if (subLabel?.isNotEmpty == true)
                  Text(
                    subLabel!,
                    style: ScaleTextStyles.label.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (hasNavigationIcon) ...[
            Icon(
              Icons.arrow_forward,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}
