import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.label,
    this.subLabel,
    this.onTap,
    required this.iconWidget,
    this.hasNavigationIcon = true,
    this.showWarning,
  });

  final String label;
  final String? subLabel;
  final VoidCallback? onTap;
  final Widget iconWidget;
  final bool hasNavigationIcon;
  final bool? showWarning;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadii.radius8,
                ),
                height: 64,
                width: 64,
                child: Center(child: iconWidget),
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
          ),
          Gaps.gap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ScaleTextStyles.textAccent
                      .apply(color: Theme.of(context).colorScheme.onPrimary),
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
