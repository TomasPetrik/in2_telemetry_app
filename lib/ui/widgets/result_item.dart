import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class ResultItem extends StatelessWidget with BottomSheetMixin {
  const ResultItem({
    super.key,
    required this.mResult,
  });

  final MeasurementResult mResult;

  String _getMeasurementTime() {
    final actualMeasurementTimes =
        mResult.evaluationItem?.actualMeasurementTimes;
    if (actualMeasurementTimes != null &&
        actualMeasurementTimes.isNotEmpty == true) {
      return actualMeasurementTimes.last.toLocal().toTimeOfDay().toString();
    } else {
      return mResult.measurementDateTime.toLocal().toTimeOfDay().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMultiUser = getIt<Session>().isMultiUser == true;
    UserAccount? userAccount;
    if (mResult.userId != null && isMultiUser) {
      userAccount = getIt<AccountDbProvider>().get(mResult.userId!);
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
                _getMeasurementTime(),
                style: ScaleTextStyles.label.apply(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Gaps.gap16,
              SvgPicture.asset(
                'assets/icons/icon_wave_pulse.svg',
                color: mResult.evaluationItem?.wasMeasured() == false
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
                          context.locale.common_measurement_types(
                            mResult.measurementType!.name,
                          ),
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        if (mResult.evaluationItem?.wasMeasured() == false &&
                            mResult.measurementFinishDateTime != null) ...[
                          Gaps.gap6,
                          Text(
                            context.locale
                                .dashboard_screen_measurement_interval(
                              mResult.measurementDateTime
                                  .toLocal()
                                  .toTimeOfDay()
                                  .toString(),
                              mResult.measurementFinishDateTime!
                                  .toLocal()
                                  .toTimeOfDay()
                                  .toString(),
                            ),
                            style: ScaleTextStyles.label.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    if (mResult.evaluationItem?.wasMeasured() == false) ...{
                      Text(
                        context.locale.common_not_measured,
                        style: ScaleTextStyles.text
                            .apply(color: Theme.of(context).colorScheme.error),
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
