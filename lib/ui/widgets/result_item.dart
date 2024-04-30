import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/chart_screen_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/constants/permissions.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class ResultItem extends StatelessWidget with BottomSheetMixin {
  const ResultItem({
    super.key,
    required this.viewModel,
    required this.canOpenChart,
    required this.showUserName,
    this.onRemove,
  });

  final MeasurementResultViewModel viewModel;
  final bool canOpenChart;
  final VoidCallback? onRemove;
  final bool showUserName;

  @override
  Widget build(BuildContext context) {
    final wasMeasured = viewModel.actualCount >= viewModel.requiredCount;

    final shouldShowDates = [viewModel.measurementIntervalStart, viewModel.measurementIntervalEnd]
        .whereNotNull()
        .any((x) => x != viewModel.measurementTime);
    final canShowMeasuredValues = viewModel.user.permissions.any((x) => x == Permissions.viewOwnMeasurementData);

    return InkWell(
      onTap: () {
        if (!canOpenChart) return;

        if (canShowMeasuredValues) {
          GoRouter.of(context).pushNamed(
            ChartRoute.name,
            params: {
              'userId': viewModel.user.id.toString(),
              'dateTime': viewModel.measurementTime.toIso8601String(),
              'measurementType': viewModel.measurementType.name,
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
                  shouldShowDates ? '00:00' : viewModel.measurementTime.toLocal().toTimeOfDay().toString(),
                  style: ScaleTextStyles.label.apply(
                    color: shouldShowDates ? Colors.transparent : Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Gaps.gap16,
                SvgPicture.asset(
                  shouldShowDates ? 'assets/icons/icon_wave_pulse_period.svg' : 'assets/icons/icon_wave_pulse.svg',
                  color: wasMeasured
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            Gaps.gap16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showUserName) ...[
                    Text(
                      viewModel.user.fullName,
                      style: ScaleTextStyles.textAccent.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Gaps.gap6,
                    Text(
                      viewModel.user.hospital.title,
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
                              viewModel.measurementType.name,
                            ),
                            style: ScaleTextStyles.text.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          if (viewModel.measurementIntervalStart != null &&
                              viewModel.measurementIntervalEnd != null) ...[
                            Gaps.gap6,
                            Text(
                              shouldShowDates
                                  ? localization.dashboard_screen_measurement_periodical_interval(
                                      viewModel.measurementIntervalStart!.dateFormatLong,
                                      viewModel.measurementIntervalEnd!.dateFormatLong,
                                    )
                                  : localization.dashboard_screen_measurement_interval(
                                      viewModel.measurementIntervalStart!.toLocal().toTimeOfDay().toString(),
                                      viewModel.measurementIntervalEnd!.toLocal().toTimeOfDay().toString(),
                                    ),
                              style: ScaleTextStyles.label.apply(
                                color: Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            if (viewModel.requiredCount > 1) //for periodical show count
                              Text(
                                localization.results_screen_measurements_completed(
                                  viewModel.actualCount,
                                  viewModel.requiredCount,
                                ),
                                style: ScaleTextStyles.label.apply(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            if (viewModel.whenCode != null)
                              Text(
                                localization.common_when_code(viewModel.whenCode!.name),
                                style: ScaleTextStyles.label.apply(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                          ],
                        ],
                      ),
                      if (!wasMeasured) ...{
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
                      } else if (canShowMeasuredValues && viewModel.result != null) ...{
                        Expanded(
                          child: Text(
                            viewModel.result!,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.fade,
                            style: ScaleTextStyles.text.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
