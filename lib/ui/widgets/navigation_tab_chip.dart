import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class NavigationTabChip extends StatelessWidget {
  const NavigationTabChip({
    Key? key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadii.radius8,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.padding10,
          ),
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).selectedRowColor,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              style: ScaleTextStyles.label.copyWith(
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
