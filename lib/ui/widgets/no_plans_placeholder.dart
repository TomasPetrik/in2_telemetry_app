import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/personal_measurement_footer.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class NoPlansPlaceholder extends StatelessWidget with BottomSheetMixin {
  const NoPlansPlaceholder({
    super.key,
    required this.userAccount,
    required this.enterMeasurementWithoutPlan,
    required this.supportedMeasurementTypes,
  });

  final UserAccount? userAccount;
  final bool enterMeasurementWithoutPlan;
  final Set<MeasurementType> supportedMeasurementTypes;

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;

    return CustomScrollView(
      slivers: [
        SliverGap(topGap + Constants.twoLinedBarHeight),
        SliverPadding(
          padding: Paddings.horizontal64,
          sliver: InfoPlaceholder(
            icon: SvgPicture.asset(
              'assets/icons/icon_wave_pulse_big.svg',
              color: Theme.of(context).colorScheme.tertiary,
            ),
            label: userAccount != null
                ? context.locale.dashboard_screen_no_user_plan
                : context.locale.dashboard_screen_any_user_plan,
          ),
        ),
        if (enterMeasurementWithoutPlan) ...{
          PersonalMeasurementFooter(
            showInfo: false,
            onPressed: () async {
              MeasurementHelper.doMeasurement(
                context: context,
                userId: userAccount!.user.muid,
                allMeasurementTypes: supportedMeasurementTypes.isNotEmpty
                    ? supportedMeasurementTypes
                    : Constants.supportedMeasurements.keys.toSet(),
              );
            },
          ),
        },
      ],
    );
  }
}
