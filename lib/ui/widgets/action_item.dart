import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class ActionItem extends StatelessWidget {
  const ActionItem({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: ScaleTextStyles.textAccent.apply(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Gaps.gap16,
            SvgPicture.asset(
              'assets/icons/icon_arrow_sm_right.svg',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
