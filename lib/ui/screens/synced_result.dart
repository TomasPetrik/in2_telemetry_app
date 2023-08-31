import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/routers/routes/omron_flow_route.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';
import 'package:scalesoft_app/utils/events_constants.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class SyncedResult extends StatelessWidget {
  const SyncedResult({
    super.key,
    required this.userId,
    required this.deviceId,
    required this.hwMeasurementResult,
    required this.measurementType,
    this.deviceInfo,
  });

  final String userId;
  final String deviceId;
  final HwMeasurementResult hwMeasurementResult;
  final MeasurementType measurementType;
  final DeviceInfo? deviceInfo;

  String _getDesc(BuildContext context) {
    switch (hwMeasurementResult.resultState) {
      case ResultState.success:
        return localization.measurement_summary_screen_result_success_desc;
      case ResultState.noData:
        return localization.measurement_summary_screen_no_data_desc;
      case ResultState.connectionError:
        return localization.measurement_summary_screen_sync_error_desc;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (hwMeasurementResult.resultState) {
      case ResultState.success:
        return Theme.of(context).colorScheme.onTertiary;
      case ResultState.noData:
        return Theme.of(context).colorScheme.error;
      case ResultState.connectionError:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getIconPath() {
    switch (hwMeasurementResult.resultState) {
      case ResultState.success:
        return 'assets/icons/icon_circle_check_huge.svg';
      case ResultState.noData:
        return 'assets/icons/icon_triangle_exclamation_huge.svg';
      case ResultState.connectionError:
        return 'assets/icons/icon_triangle_exclamation_huge.svg';
    }
  }

  String? _getMeasurementValueFormatted() {
    if (hwMeasurementResult.resultState == ResultState.success) {
      switch (measurementType) {
        case MeasurementType.bloodPressure:
          final systolic =
              hwMeasurementResult.measurementInfo?.systolic ?? 'N/A';
          final diastolic =
              hwMeasurementResult.measurementInfo?.diastolic ?? 'N/A';
          return '$systolic / $diastolic mmHg';
        case MeasurementType.heartRate:
          final hearthRate =
              hwMeasurementResult.measurementInfo?.pulseRate ?? 'N/A';
          return '$hearthRate ${localization.common_heart_rate_unit}';

        default:
          return null;
      }
    }
    return null;
  }

  bool _exceededValues() {
    final UserAccount userAccount = getIt<AccountDbProvider>().get(userId)!;
    return userAccount.user.measurementThresholds
            ?.exceededValues(hwMeasurementResult.measurement!) ==
        true;
  }

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;
    final fixedHeight = topGap + Dimensions.twoLinedBarHeight;
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverGap(fixedHeight),
        if (hwMeasurementResult.resultState == ResultState.success) ...[
          const SliverGap(Dimensions.padding16),
          SliverToBoxAdapter(
            child: ScaleCard(
              child: Padding(
                padding: Paddings.all16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.measurement_summary_screen_success_title,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Gaps.gap6,
                    Text(
                      _exceededValues()
                          ? localization
                              .measurement_summary_screen_exceeded_values
                          : localization
                              .measurement_summary_screen_success_subtitle,
                      style: ScaleTextStyles.label.apply(
                        color: _exceededValues()
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    Gaps.gap16,
                    Container(
                      height: 0.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Gaps.gap16,
                    Row(
                      children: [
                        Text(
                          hwMeasurementResult.measurementDt.toTimeShort(),
                          style: ScaleTextStyles.label.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Gaps.gap16,
                        SvgPicture.asset(
                          'assets/icons/icon_wave_pulse.svg',
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                        Gaps.gap16,
                        Expanded(
                          child: Text(
                            localization.common_measurement_types(
                              measurementType.name,
                            ),
                            style: ScaleTextStyles.textAccent.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Gaps.gap16,
                        Text(
                          _getMeasurementValueFormatted() ?? '?',
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SliverGap(Dimensions.padding40),
        SliverToBoxAdapter(
          child: SvgPicture.asset(
            _getIconPath(),
            color: _getIconColor(context),
          ),
        ),
        const SliverGap(Dimensions.padding48),
        SliverToBoxAdapter(
          child: Padding(
            padding: Paddings.horizontal48,
            child: Text(
              _getDesc(context),
              style: ScaleTextStyles.text.apply(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (hwMeasurementResult.resultState == ResultState.success) ...[
          const SliverGap(Dimensions.padding24),
          SliverToBoxAdapter(
            child: HighlightedElevatedButton(
              label: localization.measurement_summary_screen_send_results,
              onPressed: () async {
                await getIt<PendingResultsDbProvider>()
                    .save(hwMeasurementResult.measurement!)
                    .then(
                  (_) {
                    getIt<ReportService>().trackEvent(
                      userId: userId,
                      severity: Severity.info,
                      message: EventsConstants.eventMeasurementSent,
                    );
                    getIt<SyncBloc>().add(const SyncEvent.syncResults());
                    GoRouter.of(context).goNamed(DashboardRoute.name);
                  },
                );
              },
              buttonType: ButtonType.primary,
            ),
          ),
        ] else if (hwMeasurementResult.resultState == ResultState.noData) ...[
          const SliverGap(Dimensions.padding24),
          SliverToBoxAdapter(
            child: HighlightedElevatedButton(
              label: localization
                  .measurement_summary_screen_no_data_repeat_measurement,
              onPressed: () {
                getIt<ReportService>().trackEvent(
                  userId: userId,
                  severity: Severity.info,
                  message: EventsConstants.eventMeasurementRepeat,
                );
                GoRouter.of(context).pushReplacementNamed(
                  OmronFlowRoute.name,
                  queryParams: {
                    'userId': userId,
                    'measurementType': measurementType.name,
                    'deviceId': deviceId,
                  },
                );
              },
              buttonType: ButtonType.primary,
            ),
          ),
        ],
        const SliverGap(Dimensions.padding24),
        if (hwMeasurementResult.resultState == ResultState.success)
          SliverToBoxAdapter(
            child: Padding(
              padding: Paddings.horizontal16,
              child: Center(
                child: InkWell(
                  onTap: () {
                    getIt<ReportService>().trackEvent(
                      userId: userId,
                      severity: Severity.info,
                      message: EventsConstants.eventMeasurementWontSend,
                    );
                    GoRouter.of(context).goNamed(DashboardRoute.name);
                  },
                  child: Text(
                    localization.measurement_summary_screen_disallow_to_send,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: HighlightedElevatedButton(
              label: localization.common_close,
              onPressed: () {
                GoRouter.of(context).goNamed(DashboardRoute.name);
              },
              buttonType: ButtonType.secondary,
            ),
          ),
        const SliverGap(Dimensions.padding16),
      ],
    );
  }
}
