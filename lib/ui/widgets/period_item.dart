import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class PlannedPeriodItem extends StatelessWidget {
  const PlannedPeriodItem({
    super.key,
    required this.whenPeriod,
    required this.count,
    this.isSelected = false,
  });

  final PlanWhenPeriod whenPeriod;
  final int count;
  final bool isSelected;

  static final Map<PlanWhenPeriod, String> periodItemIcons = {
    PlanWhenPeriod.today: 'assets/icons/icon_calendar_today.svg',
    PlanWhenPeriod.tomorrow: 'assets/icons/icon_calendar_tomorrow.svg',
    PlanWhenPeriod.next10: 'assets/icons/icon_calendar_upcomming.svg',
  };

  String _getSubtitle(BuildContext context, int measurements) {
    switch (whenPeriod) {
      case PlanWhenPeriod.today:
        return localization
            .measurement_screen_today_n_measurements(measurements);
      case PlanWhenPeriod.next10:
        return localization
            .measurement_screen_upcomming_n_measurements(measurements);
      case PlanWhenPeriod.tomorrow:
        return localization
            .measurement_screen_tomorrow_n_measurements(measurements);
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
                style: ScaleTextStyles.textAccent.apply(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Gaps.gap6,
              Text(
                _getSubtitle(context, count),
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
