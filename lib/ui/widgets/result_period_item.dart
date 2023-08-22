import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class ResultPeriodItem extends StatelessWidget {
  const ResultPeriodItem({
    super.key,
    required this.whenPeriod,
    required this.percentage,
    this.isSelected = false,
  });

  final ResultsWhenPeriod whenPeriod;
  final int? percentage;
  final bool isSelected;

  static final Map<ResultsWhenPeriod, String> periodItemIcons = {
    ResultsWhenPeriod.today: 'assets/icons/icon_calendar_today.svg',
    ResultsWhenPeriod.yesterday: 'assets/icons/icon_calendar_today.svg',
  };

  String _getSubtitle(BuildContext context) {
    if (percentage == null) {
      return localization.results_plan_no_measurement_needed;
    }
    switch (whenPeriod) {
      case ResultsWhenPeriod.today:
        return localization.results_plan_fulfilled_on(percentage!);
      case ResultsWhenPeriod.yesterday:
        return localization.results_plan_fulfilled_on(percentage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Row(
        children: [
          SvgPicture.asset(
            periodItemIcons[whenPeriod]!,
            color: Theme.of(context).hintColor,
          ),
          Gaps.gap16,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.common_measurement_times(whenPeriod.name),
                style: ScaleTextStyles.textAccent
                    .apply(color: Theme.of(context).colorScheme.onPrimary),
              ),
              Gaps.gap6,
              Text(
                _getSubtitle(context),
                style: ScaleTextStyles.label.apply(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isSelected)
            SvgPicture.asset(
              'assets/icons/icon_check.svg',
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }
}
