import 'package:flutter/material.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';

class PersonalMeasurementFooter extends StatelessWidget {
  const PersonalMeasurementFooter({
    super.key,
    required this.onPressed,
    required this.showInfo,
  });

  final VoidCallback onPressed;
  final bool showInfo;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: Paddings.horizontal16,
        child: Column(
          children: [
            if (showInfo) ...[
              Container(
                height: 0.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              Gaps.gap16,
              Text(
                localization.dashboard_screen_manual_measurement_info,
                style: ScaleTextStyles.text.apply(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            Gaps.gap24,
            HighlightedElevatedButton(
              label: localization.common_personal_measurement,
              buttonType: ButtonType.primary,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
