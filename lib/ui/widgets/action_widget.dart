import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class ActionWidget extends StatelessWidget with BottomSheetMixin {
  const ActionWidget({
    super.key,
    required this.userAccount,
    required this.measurement,
  });

  final UserAccount userAccount;
  final PlannedMeasurement? measurement;

  MeasurementWhenType get measurementType {
    final now = DateTime.now();

    measurement?.carePlan.hasMeasurementsToday();

    if (measurement != null) {
      final todayStart = measurement!.timingDayWhen.start.todayDateTime();
      final todayEnd = measurement!.timingDayWhen.end.todayDateTime();
      if (now.isBefore(todayEnd) && now.isAfter(todayStart)) {
        return MeasurementWhenType.ongoing;
      } else if (now.isBefore(todayStart)) {
        return MeasurementWhenType.upcoming;
      } else if (measurement?.carePlan.hasMeasurementsToday() == true) {
        return MeasurementWhenType.finished;
      }
    }

    return MeasurementWhenType.noMeasurement;
  }

  String getMeasurementText(BuildContext context) {
    switch (measurementType) {
      case MeasurementWhenType.ongoing:
        return '${context.locale.common_measurement} ${context.locale.common_measurement_types_genitive(
              measurement!.carePlan.activity.measurementType.name,
            ).toLowerCase()} ${measurement!.timingDayWhen.whenCode != null ? context.locale.common_when_code(
              measurement!.timingDayWhen.whenCode!.name,
            ).toLowerCase() : ''}';

      case MeasurementWhenType.upcoming:
        return '${context.locale.common_measurement} ${context.locale.common_measurement_types_genitive(
              measurement!.carePlan.activity.measurementType.name,
            ).toLowerCase()} ${measurement!.timingDayWhen.whenCode != null ? context.locale.common_when_code(
              measurement!.timingDayWhen.whenCode!.name,
            ).toLowerCase() : ''} ve ${measurement!.timingDayWhen.start.toString()}';

      case MeasurementWhenType.finished:
        return context.locale.dashboard_screen_no_more_measurements;
      case MeasurementWhenType.noMeasurement:
        return context.locale.dashboard_screen_no_todays_measurements;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/icon_wave_pulse.svg',
                color: Theme.of(context).colorScheme.onSurface,
              ),
              Gaps.gap16,
              Expanded(
                child: Text(
                  getMeasurementText(context),
                ),
              ),
              if (measurementType == MeasurementWhenType.ongoing) ...[
                Gaps.gap16,
                Text(measurement?.timingDayWhen.start.toString() ?? ''),
              ],
            ],
          ),
          if (measurementType == MeasurementWhenType.ongoing &&
              measurement != null) ...[
            Gaps.gap16,
            HighlightedElevatedButton(
              label: context.locale.common_measure_now,
              buttonType: ButtonType.secondary,
              onPressed: () {
                doMeasurement(
                  context: context,
                  userId: measurement!.userId,
                  selectedMeasurementType:
                      measurement!.carePlan.activity.measurementType,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

enum MeasurementWhenType { ongoing, upcoming, finished, noMeasurement }
