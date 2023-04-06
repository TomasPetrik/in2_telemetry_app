import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class InfoPlaceholder extends StatelessWidget {
  const InfoPlaceholder({
    super.key,
    required this.icon,
    required this.label,
  });

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          icon,
          Gaps.gap24,
          Text(
            label,
            style: ScaleTextStyles.text.apply(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
