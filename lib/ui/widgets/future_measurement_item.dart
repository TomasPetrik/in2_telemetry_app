import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class FutureMeasurementItem extends StatelessWidget with BottomSheetMixin {
  const FutureMeasurementItem({
    super.key,
    required this.isMultiUser,
    required this.futureMeasurement,
  });

  final bool isMultiUser;
  final PlannedMeasurement futureMeasurement;

  CarePlan get carePlan => futureMeasurement.carePlan;

  int get requiredCount => futureMeasurement.reqCount;

  int? get currentCount => futureMeasurement.currentCount;

  DateTime get whenStart => futureMeasurement.whenStart;

  DateTime get whenEnd => futureMeasurement.whenEnd;

  bool get showAsLongPeriodical =>
      carePlan.isPeriodical && carePlan.periodUnit != TimeUnit.hour;

  @override
  Widget build(BuildContext context) {
    UserAccount? userAccount;
    if (isMultiUser) {
      userAccount = getIt<AccountDbProvider>().get(futureMeasurement.userId);
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
                    : futureMeasurement.whenStart.toTimeOfDay().toString(),
                style: ScaleTextStyles.label.apply(
                  color: showAsLongPeriodical
                      ? Colors.transparent
                      : Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.48),
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
                if (userAccount != null) ...[
                  Text(
                    userAccount.user.fullName,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.48),
                    ),
                  ),
                  Gaps.gap6,
                  Text(
                    userAccount.hospital!.title,
                    style: ScaleTextStyles.label.apply(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.48),
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
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.common_measurement_types(
                            futureMeasurement
                                .carePlan.activity.measurementType.name,
                          ),
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.48),
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
                                  futureMeasurement.whenStart
                                      .toTimeOfDay()
                                      .toString(),
                                  futureMeasurement.whenEnd
                                      .toTimeOfDay()
                                      .toString(),
                                ),
                          style: ScaleTextStyles.label.apply(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondary
                                .withOpacity(0.48),
                          ),
                        ),
                        if (futureMeasurement.whenCode != null)
                          Text(
                            localization.common_when_code(
                              futureMeasurement.whenCode!.name,
                            ),
                            style: ScaleTextStyles.label.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary
                                  .withOpacity(0.48),
                            ),
                          ),
                        if (requiredCount > 1 && currentCount != null)
                          Text(
                            localization.dashboard_screen_measurements_left(
                              requiredCount - currentCount!,
                              requiredCount,
                            ),
                            style: ScaleTextStyles.label.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary
                                  .withOpacity(0.48),
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
