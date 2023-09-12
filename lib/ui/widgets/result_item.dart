import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/chart_screen_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class ResultItem extends StatelessWidget with BottomSheetMixin {
  const ResultItem({
    super.key,
    required this.isMultiUser,
    required this.mResult,
    this.canOpenChart = false,
    this.onRemove,
  });

  final bool isMultiUser;
  final MeasurementResult mResult;
  final bool canOpenChart;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    UserAccount? userAccount;
    if (mResult.userId != null && isMultiUser) {
      userAccount = getIt<AccountDbProvider>().get(mResult.userId!);
    }

    return InkWell(
      onTap: () {
        if (!canOpenChart) return;
        final userAccount = getIt<AccountDbProvider>().get(mResult.userId!);

        if (userAccount?.viewOwnMeasurementData == true) {
          GoRouter.of(context).pushNamed(
            ChartRoute.name,
            params: {
              'userId': mResult.userId!,
              'dateTime': mResult.measurementDateTime.toIso8601String(),
              'measurementType': mResult.measurementType!.name,
            },
          );
        }
      },
      child: Padding(
        padding: Paddings.all16,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  mResult.isLongPeriod
                      ? '00:00'
                      : mResult.measurementDateTime
                          .toLocal()
                          .toTimeOfDay()
                          .toString(),
                  style: ScaleTextStyles.label.apply(
                    color: mResult.isLongPeriod
                        ? Colors.transparent
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Gaps.gap16,
                SvgPicture.asset(
                  mResult.isLongPeriod
                      ? 'assets/icons/icon_wave_pulse_period.svg'
                      : 'assets/icons/icon_wave_pulse.svg',
                  color: mResult.wasMeasured != true
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onTertiary,
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
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Gaps.gap6,
                    Text(
                      userAccount.hospital!.title,
                      style: ScaleTextStyles.label.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
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
                              mResult.measurementType!.name,
                            ),
                            style: ScaleTextStyles.text.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          if (mResult.measurementIntervalStart != null &&
                              mResult.measurementIntervalEnd != null) ...[
                            Gaps.gap6,
                            Text(
                              mResult.isLongPeriod
                                  ? localization
                                      .dashboard_screen_measurement_periodical_interval(
                                      mResult.measurementIntervalStart!.dateFormatLong,
                                      mResult.measurementIntervalEnd!.dateFormatLong,
                                    )
                                  : localization
                                      .dashboard_screen_measurement_interval(
                                      mResult.measurementIntervalStart!
                                          .toLocal()
                                          .toTimeOfDay()
                                          .toString(),
                                      mResult.measurementIntervalEnd!
                                          .toLocal()
                                          .toTimeOfDay()
                                          .toString(),
                                    ),
                              style: ScaleTextStyles.label.apply(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            if (mResult.reqCount! >
                                1) //for periodical show count
                              Text(
                                localization
                                    .results_screen_measurements_completed(
                                  mResult.currentCount!,
                                  mResult.reqCount!,
                                ),
                                style: ScaleTextStyles.label.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            if (mResult.whenCode != null)
                              Text(
                                localization
                                    .common_when_code(mResult.whenCode!.name),
                                style: ScaleTextStyles.label.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                          ],
                        ],
                      ),
                      if (mResult.wasMeasured == false) ...{
                        Expanded(
                          child: Text(
                            localization.common_not_measured,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: ScaleTextStyles.text.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      },
                    ],
                  ),
                ],
              ),
            ),
            if (onRemove != null) ...[
              Gaps.gap16,
              InkWell(
                onTap: onRemove,
                child: SvgPicture.asset(
                  'assets/icons/icon_trash.svg',
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
