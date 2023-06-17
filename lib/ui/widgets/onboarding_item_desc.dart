import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class OnboardingItemDesc extends StatelessWidget {
  const OnboardingItemDesc({
    super.key,
    required this.imagePath,
    required this.desc,
  });

  final String imagePath;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          SvgPicture.asset(
            imagePath,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          Gaps.gap20,
          Expanded(
            child: Text(
              desc,
              style: ScaleTextStyles.textAccent
                  .apply(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
