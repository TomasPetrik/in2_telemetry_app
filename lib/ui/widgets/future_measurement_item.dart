import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class FutureMeasurementItem extends StatelessWidget with BottomSheetMixin {
  const FutureMeasurementItem({
    super.key,
    required this.showUserName,
    required this.measurement,
  });

  final bool showUserName;
  final MeasurementResultViewModel measurement;

  DateTime get from => measurement.measurementIntervalStart ?? measurement.measurementTime;

  DateTime get to => measurement.measurementIntervalEnd ?? measurement.measurementTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Paddings.all16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                measurement.spansMultipleDays ? '00:00' : measurement.measurementTime.toTimeOfDay().toString(),
                style: ScaleTextStyles.label.apply(
                  color: measurement.spansMultipleDays
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.onPrimary.withOpacity(0.48),
                ),
              ),
              Gaps.gap16,
              SvgPicture.asset(
                'assets/icons/icon_clock.svg',
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ],
          ),
          Gaps.gap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measurement.user.fullName,
                  style: ScaleTextStyles.textAccent.apply(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.48),
                  ),
                ),
                Gaps.gap6,
                Text(
                  measurement.user.hospital.title,
                  style: ScaleTextStyles.label.apply(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.48),
                  ),
                ),
                Gaps.gap16,
                Container(
                  height: 0.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Gaps.gap16,
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.common_measurement_types(
                            measurement.measurementType.name,
                          ),
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.48),
                          ),
                        ),
                        Gaps.gap6,
                        Text(
                          measurement.spansMultipleDays
                              ? localization.dashboard_screen_measurement_periodical_interval(
                                  from.dateFormatLong,
                                  to.dateFormatLong,
                                )
                              : localization.dashboard_screen_measurement_interval(
                                  from.toTimeOfDay().toString(),
                                  to.toTimeOfDay().toString(),
                                ),
                          style: ScaleTextStyles.label.apply(
                            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.48),
                          ),
                        ),
                        if (measurement.whenCode != null)
                          Text(
                            localization.common_when_code(
                              measurement.whenCode!.name,
                            ),
                            style: ScaleTextStyles.label.apply(
                              color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.48),
                            ),
                          ),
                        if (measurement.requiredCount > 1 && measurement.actualCount > 0)
                          Text(
                            localization.dashboard_screen_measurements_left(
                              measurement.requiredCount - measurement.actualCount,
                              measurement.requiredCount,
                            ),
                            style: ScaleTextStyles.label.apply(
                              color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.48),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
