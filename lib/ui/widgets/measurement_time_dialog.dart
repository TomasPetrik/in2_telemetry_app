import 'package:flutter/material.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';
import 'package:scalesoft_app/ui/widgets/period_item.dart';

class MeasurementTimeDialog extends StatelessWidget {
  const MeasurementTimeDialog({
    super.key,
    required this.selectedTime,
  });

  final PeriodType selectedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(RadiusSize.radius16),
          topRight: Radius.circular(RadiusSize.radius16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Gaps.gap34,
          Padding(
            padding: Paddings.horizontal16,
            child: Text(
              context.locale.common_measurement,
              style: ScaleTextStyles.textAccent
                  .apply(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          Gaps.gap24,
          InkWell(
            onTap: () {
              Navigator.of(context).pop(
                TypePeriodSelection(selectedPeriod: PeriodType.upcomming),
              );
            },
            child: Padding(
              padding: Paddings.horizontal16,
              child: PeriodItem(
                periodTime: PeriodType.upcomming,
                isSelected: selectedTime == PeriodType.upcomming,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .pop(TypePeriodSelection(selectedPeriod: PeriodType.today));
            },
            child: Padding(
              padding: Paddings.horizontal16,
              child: PeriodItem(
                periodTime: PeriodType.today,
                isSelected: selectedTime == PeriodType.today,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop(
                TypePeriodSelection(selectedPeriod: PeriodType.tomorrow),
              );
            },
            child: Padding(
              padding: Paddings.horizontal16,
              child: PeriodItem(
                periodTime: PeriodType.tomorrow,
                isSelected: selectedTime == PeriodType.tomorrow,
              ),
            ),
          ),
          Gaps.gap24,
          Padding(
            padding: Paddings.horizontal16,
            child: HighlightedElevatedButton(
              label: context.locale.common_show_calendar,
              onPressed: () {
                Navigator.of(context)
                    .pop(TypePeriodSelection(showCalendar: true));
              },
            ),
          ),
          Gaps.gap48,
        ],
      ),
    );
  }
}
