import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/result_period_item.dart';

class ResultsTimeDialog extends StatelessWidget {
  const ResultsTimeDialog({
    super.key,
    required this.whenPeriod,
    required this.fulfillmentPlan,
  });

  final ResultsWhenPeriod whenPeriod;
  final Map<ResultsWhenPeriod, int> fulfillmentPlan;

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
              context.locale.results_measurements_when_selector_title,
              style: ScaleTextStyles.textAccent
                  .apply(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          Gaps.gap24,
          ...fulfillmentPlan.entries.map(
            (entry) {
              return InkWell(
                onTap: () {
                  GoRouter.of(context).pop(
                    ResultPeriodSelection(selectedPeriod: entry.key),
                  );
                },
                child: Padding(
                  padding: Paddings.horizontal16,
                  child: ResultPeriodItem(
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
                GoRouter.of(context)
                    .pop(ResultPeriodSelection(showCalendar: true));
              },
            ),
          ),
          Gaps.gap24,
          Padding(
            padding: Paddings.horizontal16,
            child: HighlightedElevatedButton(
              label: context.locale.common_close,
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

enum ResultsWhenPeriod {
  yesterday,
  today,
}
