import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/personal_measurement_footer.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';
import 'package:sliver_tools/sliver_tools.dart';

class NoContentPlaceholder extends StatelessWidget with BottomSheetMixin {
  const NoContentPlaceholder({
    super.key,
    required this.userAccount,
    required this.enterMeasurementWithoutPlan,
    required this.supportedMeasurementTypes,
    required this.noContentType,
  });

  final UserModel? userAccount;
  final bool enterMeasurementWithoutPlan;
  final Set<MeasurementType> supportedMeasurementTypes;
  final NoContentType noContentType;

  String _getLabelByType() {
    switch (noContentType) {
      case NoContentType.notAllowedSeeOwnMeasurements:
        return localization.results_screen_no_permission_to_see_results;
      case NoContentType.noHistoricalData:
        return localization.results_screen_no_historic_data;
      case NoContentType.noPlans:
        return localization.dashboard_screen_any_user_plan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;

    return MultiSliver(
      children: [
        SliverGap(topGap + Dimensions.twoLinedBarHeight),
        SliverPadding(
          padding: Paddings.horizontal64,
          sliver: InfoPlaceholder(
            icon: SvgPicture.asset(
              'assets/icons/icon_wave_pulse_big.svg',
              color: Theme.of(context).colorScheme.tertiary,
            ),
            label: _getLabelByType(),
          ),
        ),
        if (enterMeasurementWithoutPlan && userAccount != null) ...{
          PersonalMeasurementFooter(
            showInfo: false,
            onPressed: () async {
              MeasurementHelper.doMeasurement(
                context: context,
                userId: userAccount!.id,
                showAllMeasurementTypes: true,
              );
            },
          ),
        },
      ],
    );
  }
}

enum NoContentType {
  notAllowedSeeOwnMeasurements,
  noHistoricalData,
  noPlans,
}
