import 'package:flutter/material.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/period_item.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeasurementTimeDialog extends StatelessWidget {
  const MeasurementTimeDialog({
    super.key,
    required this.whenPeriod,
    required this.measurements,
  });

  final WhenPeriod whenPeriod;
  final Map<WhenPeriod, int> measurements;

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
          ...measurements.entries.map(
            (entry) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).pop(
                    TypePeriodSelection(selectedPeriod: entry.key),
                  );
                },
                child: Padding(
                  padding: Paddings.horizontal16,
                  child: PeriodItem(
                    whenPeriod: entry.key,
                    isSelected: whenPeriod == entry.key,
                    count: entry.value,
                  ),
                ),
              );
            },
          ).toList(),
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
