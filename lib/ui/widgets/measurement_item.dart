import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class MeasurementItem extends StatelessWidget with BottomSheetMixin {
  const MeasurementItem({
    super.key,
    required this.plannedMeasurement,
  });

  // TimingDayWhen get timingDayWhen => plannedMeasurement.timingDayWhen;
  CarePlan get carePlan => plannedMeasurement.carePlan;

  MeasurementNeed get measurementNeed => getMeasurementNeed(plannedMeasurement);

  int get requiredCount => plannedMeasurement.reqCount;

  int? get currentCount => plannedMeasurement.currentCount;

  DateTime get whenStart => plannedMeasurement.whenStart;

  DateTime get whenEnd => plannedMeasurement.whenEnd;

  final PlannedMeasurement plannedMeasurement;

  bool get showAsLongPeriodical =>
      carePlan.isPeriodical && carePlan.periodUnit != TimeUnit.hour;

  MeasurementNeed getMeasurementNeed(PlannedMeasurement measurement) {
    final dtNow = DateTime.now();

    if (dtNow.isBefore(measurement.whenEnd) &&
        dtNow.isAfter(measurement.whenStart)) {
      return MeasurementNeed.now;
    } else {
      return MeasurementNeed.upcoming;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiUser = getIt<Session>().isMultiUser == true;
    UserAccount? userAccount;
    if (carePlan.userId != null && isMultiUser) {
      userAccount = getIt<AccountDbProvider>().get(carePlan.userId!);
    }

    return Padding(
      padding: Paddings.all16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                showAsLongPeriodical
                    ? '00:00'
                    : plannedMeasurement.whenStart.toTimeOfDay().toString(),
                style: ScaleTextStyles.label.apply(
                  color: showAsLongPeriodical
                      ? Colors.transparent
                      : (measurementNeed == MeasurementNeed.now
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.tertiary),
                ),
              ),
              Gaps.gap16,
              SvgPicture.asset(
                measurementNeed == MeasurementNeed.now
                    ? (showAsLongPeriodical
                        ? 'assets/icons/icon_wave_pulse_period.svg'
                        : 'assets/icons/icon_wave_pulse.svg')
                    : 'assets/icons/icon_clock.svg',
                color: measurementNeed == MeasurementNeed.now
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
                if (userAccount != null) ...[
                  Text(
                    userAccount.user.fullName,
                    style: ScaleTextStyles.textAccent.apply(
                      color: measurementNeed == MeasurementNeed.now
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Gaps.gap6,
                  Text(
                    userAccount.hospital!.title,
                    style: ScaleTextStyles.label.apply(
                      color: measurementNeed == MeasurementNeed.now
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
                            carePlan.activity.measurementType.name,
                          ),
                          style: ScaleTextStyles.textAccent.apply(
                            color: measurementNeed == MeasurementNeed.now
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        Gaps.gap6,
                        Text(
                          showAsLongPeriodical
                              ? localization
                                  .dashboard_screen_measurement_periodical_interval(
                                  whenStart.toDateFormatLong(),
                                  whenEnd.toDateFormatLong(),
                                )
                              : localization
                                  .dashboard_screen_measurement_interval(
                                  plannedMeasurement.whenStart
                                      .toTimeOfDay()
                                      .toString(),
                                  plannedMeasurement.whenEnd
                                      .toTimeOfDay()
                                      .toString(),
                                ),
                          style: ScaleTextStyles.label.apply(
                            color: measurementNeed == MeasurementNeed.now
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        if (plannedMeasurement.whenCode != null)
                          Text(
                            localization
                                .common_when_code(plannedMeasurement.whenCode!.name),
                            style: ScaleTextStyles.label.apply(
                              color: measurementNeed == MeasurementNeed.now
                                  ? Theme.of(context).colorScheme.onSecondary
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        if (requiredCount > 1 && currentCount != null)
                          Text(
                            localization.dashboard_screen_measurements_left(
                              requiredCount - currentCount!,
                              requiredCount,
                            ),
                            style: ScaleTextStyles.label.apply(
                              color: measurementNeed == MeasurementNeed.now
                                  ? Theme.of(context).colorScheme.onSecondary
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (measurementNeed == MeasurementNeed.now) ...{
                      NavigationTabChip(
                        label: localization.common_measure,
                        isSelected: true,
                        onTap: () {
                          MeasurementHelper.doMeasurement(
                            context: context,
                            userId: carePlan.userId!,
                            selectedMeasurementType:
                                carePlan.activity.measurementType,
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
  }
}

enum MeasurementNeed { now, upcoming }
