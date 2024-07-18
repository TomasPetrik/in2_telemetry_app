import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class ActionWidget extends StatelessWidget with BottomSheetMixin {
  const ActionWidget({
    super.key,
    required this.whenPeriod,
    required this.upcomingMeasurements,
    required this.allTodayMeasurements,
  });

  final PlanWhenPeriod whenPeriod;
  final List<MeasurementResultViewModel> upcomingMeasurements;
  final List<MeasurementResultViewModel> allTodayMeasurements;

  MeasurementResultViewModel? get nextMeasurement => upcomingMeasurements.firstOrNull;

  List<MeasurementResultViewModel> get _multiDayMeasurements =>
      upcomingMeasurements.where((measurement) => measurement.spansMultipleDays).toList();

  List<MeasurementResultViewModel> get _singleDayMeasurements => upcomingMeasurements
      .where(
        (measurement) => !measurement.spansMultipleDays,
      )
      .toList();

  MeasurementWhenType get measurementType {
    MeasurementWhenType? measurementWhenType;

    final now = DateTime.now();

    //we want to have this widget blank when there is no next measurement in next 10
    if (whenPeriod == PlanWhenPeriod.next10 && nextMeasurement == null) {
      measurementWhenType = MeasurementWhenType.notVisible;

      //or there are only long ongoing periodical measurements remaining in this day
    } else if (_singleDayMeasurements.isEmpty && _multiDayMeasurements.isNotEmpty) {
      measurementWhenType = MeasurementWhenType.notVisible;
    } else if (allTodayMeasurements.isEmpty) {
      measurementWhenType = MeasurementWhenType.noMeasurement;
    } else if (allTodayMeasurements.isNotEmpty && upcomingMeasurements.isEmpty) {
      measurementWhenType = MeasurementWhenType.finished;
    } else if (nextMeasurement != null) {
      final start = nextMeasurement!.measurementIntervalStart ?? nextMeasurement!.measurementTime;
      final end = nextMeasurement!.measurementIntervalEnd ?? nextMeasurement!.measurementTime;

      if (now.isBefore(end) && now.isAfter(start)) {
        measurementWhenType = MeasurementWhenType.ongoing;
      } else if (now.isBefore(start)) {
        measurementWhenType = MeasurementWhenType.upcoming;
      } else {
        measurementWhenType = MeasurementWhenType.finished;
      }
    }

    measurementWhenType ??= MeasurementWhenType.noMeasurement;

    return measurementWhenType;
  }

  String getMeasurementText(BuildContext context) {
    switch (measurementType) {
      case MeasurementWhenType.ongoing:
        return '${localization.common_measurement} ${localization.common_measurement_types_genitive(
              nextMeasurement!.measurementType.name,
            ).toLowerCase()} ${nextMeasurement!.whenCode != null ? localization.common_when_code(
              nextMeasurement!.whenCode!.name,
            ).toLowerCase() : ''}';

      case MeasurementWhenType.upcoming:
        return '${localization.common_measurement} ${localization.common_measurement_types_genitive(
              nextMeasurement!.measurementType.name,
            ).toLowerCase()} ${nextMeasurement!.whenCode != null ? localization.common_when_code(
              nextMeasurement!.whenCode!.name,
            ).toLowerCase() : ''} v ${(nextMeasurement!.measurementIntervalStart ?? nextMeasurement!.measurementTime).toTimeOfDay().toString()}';

      case MeasurementWhenType.finished:
        return localization.dashboard_screen_no_more_measurements;
      case MeasurementWhenType.noMeasurement:
        return localization.dashboard_screen_no_todays_measurements;
      case MeasurementWhenType.notVisible:
        return localization.dashboard_screen_no_more_future_measurements;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (measurementType == MeasurementWhenType.notVisible) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<UserCubit, UserCubitState>(
      bloc: getIt<UserCubit>(),
      builder: (context, state) {
        final isMultiUser = state.aggregateAllUsers;

        return Column(
          children: [
            Gaps.gap16,
            Padding(
              padding: Paddings.horizontal16,
              child: ScaleCard(
                child: Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: ScaleTextStyles.text.apply(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (measurementType == MeasurementWhenType.ongoing) ...[
                            Gaps.gap16,
                            Text(
                              (nextMeasurement?.measurementIntervalStart ?? nextMeasurement?.measurementTime)
                                      ?.toTimeOfDay()
                                      .toString() ??
                                  '',
                              style: ScaleTextStyles.text.apply(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isMultiUser && nextMeasurement != null) ...[
                        Gaps.gap16,
                        Container(
                          height: 0.5,
                          color: Theme.of(context).colorScheme.surfaceTint,
                        ),
                        Gaps.gap12,
                        Text(
                          nextMeasurement!.user.fullName,
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Gaps.gap6,
                        Text(
                          nextMeasurement!.user.hospital.title,
                          style: ScaleTextStyles.label.apply(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                      if (measurementType == MeasurementWhenType.ongoing && nextMeasurement != null) ...[
                        Gaps.gap16,
                        HighlightedElevatedButton(
                          label: localization.common_measure_now,
                          buttonType: ButtonType.secondary,
                          onPressed: () {
                            MeasurementHelper.doMeasurement(
                              context: context,
                              userId: nextMeasurement!.user.id,
                              selectedMeasurementType: nextMeasurement!.measurementType,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Gaps.gap26,
          ],
        );
      },
    );
  }
}

enum MeasurementWhenType { ongoing, upcoming, finished, noMeasurement, notVisible }
