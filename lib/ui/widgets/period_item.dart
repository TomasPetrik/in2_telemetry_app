import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';

class PeriodItem extends StatelessWidget {
  const PeriodItem({
    super.key,
    required this.periodTime,
    this.isSelected = false,
  });

  final PeriodType periodTime;
  final bool isSelected;

  static final Map<PeriodType, String> periodItemIcons = {
    PeriodType.today: 'assets/icons/icon_calendar_today.svg',
    PeriodType.tomorrow: 'assets/icons/icon_calendar_tomorrow.svg',
    PeriodType.upcomming: 'assets/icons/icon_calendar_upcomming.svg',
  };

  String _getSubtitle(BuildContext context, int measurements) {
    switch (periodTime) {
      case PeriodType.today:
        return context.locale.measurement_screen_today_n_measurements(measurements);
      case PeriodType.upcomming:
        return context.locale.measurement_screen_upcomming_n_measurements(measurements);
      case PeriodType.tomorrow:
        return context.locale.measurement_screen_tomorrow_n_measurements(measurements);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Row(
        children: [
          SvgPicture.asset(
            periodItemIcons[periodTime]!,
            color: Theme.of(context).hintColor,
          ),
          Gaps.gap16,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.locale.common_measurement_times(periodTime.name),
                style: ScaleTextStyles.textAccent,
              ),
              Gaps.gap6,
              Text(
                _getSubtitle(context, 10),
                style: ScaleTextStyles.label.apply(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              )
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
