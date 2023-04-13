import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class MeasurementItem extends StatelessWidget with BottomSheetMixin {
  const MeasurementItem({
    super.key,
    required this.timingDayWhen,
    required this.carePlan,
    required this.measurementNeed,
  });

  final TimingDayWhen timingDayWhen;
  final CarePlan carePlan;
  final MeasurementNeed measurementNeed;

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
                timingDayWhen.start.toString(),
                style: ScaleTextStyles.label.apply(
                  color: measurementNeed == MeasurementNeed.now
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Gaps.gap16,
              SvgPicture.asset(
                measurementNeed == MeasurementNeed.now
                    ? 'assets/icons/icon_wave_pulse.svg'
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
                          translactions.common_measurement_types(
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
                          translactions.dashboard_screen_measurement_interval(
                            timingDayWhen.start.toString(),
                            timingDayWhen.end.toString(),
                          ),
                          style: ScaleTextStyles.label.apply(
                            color: measurementNeed == MeasurementNeed.now
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        if (timingDayWhen.whenCode != null)
                          Text(
                            translactions
                                .common_when_code(timingDayWhen.whenCode!.name),
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
                        label: translactions.common_measure,
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
