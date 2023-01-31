import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({
    super.key,
    required this.measurement,
  });

  final Measurement? measurement;

  MeasurementType get measurementType {
    final now = DateTime.now();

    measurement?.carePlan.hasMeasurementsToday();

    if (measurement != null) {
      final todayStart = measurement!.timingDayWhen.start.todayDateTime();
      final todayEnd = measurement!.timingDayWhen.end.todayDateTime();
      if (now.isBefore(todayEnd) && now.isAfter(todayStart)) {
        return MeasurementType.ongoing;
      } else if (now.isBefore(todayStart)) {
        return MeasurementType.upcoming;
      } else if (measurement?.carePlan.hasMeasurementsToday() == true) {
        return MeasurementType.finished;
      }
    }

    return MeasurementType.noMeasurement;
  }

  String getMeasurementText(BuildContext context) {
    switch (measurementType) {
      case MeasurementType.ongoing:
        return '${context.locale.common_measurement} ${context.locale.common_measurement_types(
              measurement!.carePlan.activity.measurementType.name,
            ).toLowerCase()} ${measurement!.timingDayWhen.whenCode != null ? context.locale.common_when_code(
              measurement!.timingDayWhen.whenCode!.name,
            ).toLowerCase() : ''}';

      case MeasurementType.upcoming:
        return '${context.locale.common_measurement} ${context.locale.common_measurement_types(
              measurement!.carePlan.activity.measurementType.name,
            ).toLowerCase()} ${measurement!.timingDayWhen.whenCode != null ? context.locale.common_when_code(
              measurement!.timingDayWhen.whenCode!.name,
            ).toLowerCase() : ''} ve ${measurement!.timingDayWhen.start.toString()}';

      case MeasurementType.finished:
        return context.locale.dashboard_screen_no_more_measurements;
      case MeasurementType.noMeasurement:
        return context.locale.dashboard_screen_no_todays_measurements;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: measurementType == MeasurementType.ongoing
          ? Constants.actionActiveWidgetHeight
          : Constants.actionPassiveWidgetHeight,
      margin: Paddings.horizontal16,
      padding: Paddings.all16,
      decoration: BoxDecoration(
        borderRadius: BorderRadii.radius16,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.onPrimaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/icon_wave_pulse.svg',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                Gaps.gap16,
                Text(
                  getMeasurementText(context),
                ),
                if (measurementType == MeasurementType.ongoing) ...[
                  const Spacer(),
                  Text(measurement?.timingDayWhen.start.toString() ?? ''),
                ],
              ],
            ),
          ),
          if (measurementType == MeasurementType.ongoing) ...[
            const Spacer(),
            HighlightedElevatedButton(
              label: context.locale.common_measure_now,
              buttonType: ButtonType.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

enum MeasurementType { ongoing, upcoming, finished, noMeasurement }
