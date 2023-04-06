import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/period_item.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class PlannedMeasurementTimeDialog extends StatelessWidget {
  const PlannedMeasurementTimeDialog({
    super.key,
    required this.whenPeriod,
    required this.measurements,
  });

  final PlanWhenPeriod whenPeriod;
  final Map<PlanWhenPeriod, int> measurements;

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
              translactions.common_measurement,
              style: ScaleTextStyles.textAccent
                  .apply(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          Gaps.gap24,
          ...measurements.entries.map(
            (entry) {
              return InkWell(
                onTap: () {
                  GoRouter.of(context).pop(
                    PlannedPeriodSelection(selectedPeriod: entry.key),
                  );
                },
                child: Padding(
                  padding: Paddings.horizontal16,
                  child: PlannedPeriodItem(
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
              label: translactions.common_show_calendar,
              onPressed: () {
                GoRouter.of(context)
                    .pop(PlannedPeriodSelection(showCalendar: true));
              },
            ),
          ),
          Gaps.gap24,
          Padding(
            padding: Paddings.horizontal16,
            child: HighlightedElevatedButton(
              label: translactions.common_close,
              onPressed: () {
                GoRouter.of(context).pop();
              },
              buttonType: ButtonType.secondary,
            ),
          ),
          Gaps.gap48,
        ],
      ),
    );
  }
}
