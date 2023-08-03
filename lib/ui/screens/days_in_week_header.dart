import 'package:flutter/material.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class DaysInWeekHeader extends StatelessWidget {
  const DaysInWeekHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Padding(
        padding: Paddings.bottom16,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: DayInWeek.values
              .map(
                (dayInWeek) => Expanded(
                  child: Center(
                    child: Text(
                      localization.common_days_in_week_short(dayInWeek.name),
                      style: ScaleTextStyles.label.apply(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

enum DayInWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}
