import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.label,
    this.subLabel,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final String? subLabel;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ScaleColorsLight.content20,
              borderRadius: BorderRadii.radius8,
            ),
            height: 64,
            width: 64,
            child: Icon(
              icon,
              color: ScaleColorsLight.content80,
            ),
          ),
          Gaps.gap16,
          Column(
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
                    color: ScaleColorsLight.content80,
                  ),
                ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward,
            color: ScaleColorsLight.primary,
          ),
        ],
      ),
    );
  }
}
