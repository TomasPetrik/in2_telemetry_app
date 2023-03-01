import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class ActionWidget extends StatelessWidget with BottomSheetMixin {
  const ActionWidget({
    super.key,
    required this.nextMeasurement,
  });

  final PlannedMeasurement? nextMeasurement;

  MeasurementWhenType get measurementType {
    final now = DateTime.now();

    if (nextMeasurement != null) {
      final todayStart = nextMeasurement!.timingDayWhen.start.todayDateTime();
      final todayEnd = nextMeasurement!.timingDayWhen.end.todayDateTime();
      if (now.isBefore(todayEnd) && now.isAfter(todayStart)) {
        return MeasurementWhenType.ongoing;
      } else if (now.isBefore(todayStart)) {
        return MeasurementWhenType.upcoming;
      } else if (nextMeasurement?.carePlan.hasMeasurementsToday() == true) {
        return MeasurementWhenType.finished;
      }
    }

    return MeasurementWhenType.noMeasurement;
  }

  String getMeasurementText(BuildContext context) {
    switch (measurementType) {
      case MeasurementWhenType.ongoing:
        return '${context.locale.common_measurement} ${context.locale.common_measurement_types_genitive(
              nextMeasurement!.carePlan.activity.measurementType.name,
            ).toLowerCase()} ${nextMeasurement!.timingDayWhen.whenCode != null ? context.locale.common_when_code(
              nextMeasurement!.timingDayWhen.whenCode!.name,
            ).toLowerCase() : ''}';

      case MeasurementWhenType.upcoming:
        return '${context.locale.common_measurement} ${context.locale.common_measurement_types_genitive(
              nextMeasurement!.carePlan.activity.measurementType.name,
            ).toLowerCase()} ${nextMeasurement!.timingDayWhen.whenCode != null ? context.locale.common_when_code(
              nextMeasurement!.timingDayWhen.whenCode!.name,
            ).toLowerCase() : ''} v ${nextMeasurement!.timingDayWhen.start.toString()}';

      case MeasurementWhenType.finished:
        return context.locale.dashboard_screen_no_more_measurements;
      case MeasurementWhenType.noMeasurement:
        return context.locale.dashboard_screen_no_todays_measurements;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiUser = getIt<Session>().isMultiUser == true;
    UserAccount? userAccount;
    if (nextMeasurement?.userId != null && isMultiUser) {
      userAccount = getIt<AccountDbProvider>().get(nextMeasurement!.userId);
    }

    return Padding(
      padding: Paddings.horizontal16,
      child: Card(
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
                      nextMeasurement?.timingDayWhen.start.toString() ?? '',
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
              if (userAccount != null) ...[
                Gaps.gap16,
                Container(
                  height: 0.5,
                  color: Theme.of(context).colorScheme.surfaceTint,
                ),
                Gaps.gap12,
                Text(
                  userAccount.user.fullName,
                  style: ScaleTextStyles.text.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Gaps.gap6,
                Text(
                  userAccount.hospital!.title,
                  style: ScaleTextStyles.label.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
              if (measurementType == MeasurementWhenType.ongoing &&
                  nextMeasurement != null) ...[
                Gaps.gap16,
                HighlightedElevatedButton(
                  label: context.locale.common_measure_now,
                  buttonType: ButtonType.secondary,
                  onPressed: () {
                    doMeasurement(
                      context: context,
                      userId: nextMeasurement!.userId,
                      selectedMeasurementType:
                          nextMeasurement!.carePlan.activity.measurementType,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum MeasurementWhenType { ongoing, upcoming, finished, noMeasurement }
