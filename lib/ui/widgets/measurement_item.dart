import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class MeasurementItem extends StatelessWidget with BottomSheetMixin {
  const MeasurementItem({
    super.key,
    required this.measurement,
  });

  DateTime get measurementStart => measurement.measurementIntervalStart ?? measurement.measurementTime;

  DateTime get measurementEnd => measurement.measurementIntervalEnd ?? measurement.measurementTime;

  final MeasurementResultViewModel measurement;

  bool get showMeasurementDates => measurement.spansMultipleDays;

  MeasurementTiming determineMeasurementTiming() {
    final now = DateTime.now();

    if (now.isBefore(measurement.measurementIntervalEnd ?? measurement.measurementTime) &&
        now.isAfterOrAt(measurement.measurementIntervalStart ?? measurement.measurementTime)) {
      return MeasurementTiming.now;
    } else {
      return MeasurementTiming.upcoming;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserCubitState>(
      bloc: getIt<UserCubit>(),
      builder: (context, state) {
        final showUserNames = state.aggregateAllUsers;

        return Padding(
          padding: Paddings.all16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    showMeasurementDates ? '00:00' : measurementStart.toTimeOfDay().toString(),
                    style: ScaleTextStyles.label.apply(
                      color: showMeasurementDates
                          ? Colors.transparent
                          : (determineMeasurementTiming() == MeasurementTiming.now
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                  Gaps.gap16,
                  SvgPicture.asset(
                    determineMeasurementTiming() == MeasurementTiming.now
                        ? (showMeasurementDates
                            ? 'assets/icons/icon_wave_pulse_period.svg'
                            : 'assets/icons/icon_wave_pulse.svg')
                        : 'assets/icons/icon_clock.svg',
                    color: determineMeasurementTiming() == MeasurementTiming.now
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ],
              ),
              Gaps.gap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showUserNames) ...[
                      Text(
                        measurement.user.fullName,
                        style: ScaleTextStyles.textAccent.apply(
                          color: determineMeasurementTiming() == MeasurementTiming.now
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Gaps.gap6,
                      Text(
                        measurement.user.hospital.title,
                        style: ScaleTextStyles.label.apply(
                          color: determineMeasurementTiming() == MeasurementTiming.now
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Gaps.gap16,
                      Container(
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      Gaps.gap16,
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.common_measurement_types(
                                measurement.measurementType.name,
                              ),
                              style: ScaleTextStyles.textAccent.apply(
                                color: determineMeasurementTiming() == MeasurementTiming.now
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            Gaps.gap6,
                            Text(
                              showMeasurementDates
                                  ? localization.dashboard_screen_measurement_periodical_interval(
                                      measurementStart.dateFormatLong,
                                      measurementEnd.dateFormatLong,
                                    )
                                  : localization.dashboard_screen_measurement_interval(
                                      measurementStart.toTimeOfDay().toString(),
                                      measurementEnd.toTimeOfDay().toString(),
                                    ),
                              style: ScaleTextStyles.label.apply(
                                color: determineMeasurementTiming() == MeasurementTiming.now
                                    ? Theme.of(context).colorScheme.onSecondary
                                    : Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            if (measurement.whenCode != null)
                              Text(
                                localization.common_when_code(measurement.whenCode!.name),
                                style: ScaleTextStyles.label.apply(
                                  color: determineMeasurementTiming() == MeasurementTiming.now
                                      ? Theme.of(context).colorScheme.onSecondary
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            if (measurement.requiredCount > 1)
                              Text(
                                localization.dashboard_screen_measurements_left(
                                  measurement.requiredCount - measurement.actualCount,
                                  measurement.requiredCount,
                                ),
                                style: ScaleTextStyles.label.apply(
                                  color: determineMeasurementTiming() == MeasurementTiming.now
                                      ? Theme.of(context).colorScheme.onSecondary
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        if (determineMeasurementTiming() == MeasurementTiming.now) ...{
                          NavigationTabChip(
                            label: localization.common_measure,
                            isSelected: true,
                            onTap: () {
                              MeasurementHelper.doMeasurement(
                                context: context,
                                userId: measurement.user.id,
                                selectedMeasurementType: measurement.measurementType,
                              );
                            },
                          ),
                        },
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum MeasurementTiming { now, upcoming }
