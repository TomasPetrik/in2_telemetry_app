import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                futureMeasurement.whenStart.toLocal().toTimeOfDay().toString(),
                style: ScaleTextStyles.label.apply(
                  color: Theme.of(context).colorScheme.onPrimary,
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
                          translactions.common_measurement_types(
                            futureMeasurement
                                .carePlan.activity.measurementType.name,
                          ),
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Gaps.gap6,
                        Text(
                          translactions.dashboard_screen_measurement_interval(
                            futureMeasurement.whenStart
                                .toLocal()
                                .toTimeOfDay()
                                .toString(),
                            futureMeasurement.whenEnd
                                .toLocal()
                                .toTimeOfDay()
                                .toString(),
                          ),
                          style: ScaleTextStyles.label.apply(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        if (futureMeasurement.whenCode != null)
                          Text(
                            translactions.common_when_code(
                              futureMeasurement.whenCode!.name,
                            ),
                            style: ScaleTextStyles.label.apply(
                              color: Theme.of(context).colorScheme.onSecondary,
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
