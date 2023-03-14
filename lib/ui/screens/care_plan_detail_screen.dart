import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/calendar_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/fullplan_evaluation_widget.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/sliver_name_value_row.dart';
import 'package:scalesoft_app/ui/widgets/times_settings_form.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class CarePlanDetailScreen extends StatefulWidget with BottomSheetMixin {
  const CarePlanDetailScreen({
    super.key,
    required this.carePlan,
  });

  final CarePlan carePlan;

  @override
  State<CarePlanDetailScreen> createState() => _CarePlanDetailScreenState();
}

class _CarePlanDetailScreenState extends State<CarePlanDetailScreen> {
  late SyncBloc syncBloc = getIt<SyncBloc>();
  TimesSettingsForm? timeSettingsForm;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    syncDataIfNeed();
    super.dispose();
  }

  void syncDataIfNeed() {
    if (timeSettingsForm?.settingsChanged() == true) {
      syncBloc.add(const SyncEvent.syncAll());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.carePlan.timingDayWhen.isNotEmpty == true) {
      timeSettingsForm = TimesSettingsForm(
        carePlan: widget.carePlan,
      );
    }

    return BlocBuilder<SyncBloc, SyncState>(
      bloc: syncBloc,
      builder: (context, state) {
        return Material(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverGap(
                    MediaQuery.of(context).viewPadding.top +
                        Constants.appBarHeight,
                  ),
                  const SliverGap(Dimensions.padding24),
                  if (widget.carePlan.wasChanged == true) ...[
                    SliverPadding(
                      padding: Paddings.horizontal16,
                      sliver: WarningItem(
                        title: context
                            .locale.notification_widget_plan_changed_title,
                        description: context.locale
                            .notification_widget_plan_changed_desc(
                          context.locale
                              .common_measurement_types_genitive(
                                widget.carePlan.activity.measurementType.name,
                              )
                              .toLowerCase(),
                        ),
                        buttonLabel: context.locale.common_understand,
                        buttonType: SmallButtonType.none,
                        icon: SvgPicture.asset(
                          'assets/icons/icon_circle_exclamation.svg',
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        onTap: () {
                          syncBloc.add(
                            SyncEvent.resolveUpdatedUserPlan(widget.carePlan),
                          );
                        },
                      ),
                    ),
                    const SliverGap(Dimensions.padding24),
                  ],
                  if (widget.carePlan.fullPlanEvaluation != null)
                    FullPlanEvaluationWidget(
                      carePlan: widget.carePlan,
                    ),
                  const SliverGap(Dimensions.padding42),
                  SliverPadding(
                    padding: Paddings.left16,
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        context.locale.care_plan_detail_screen_plan_info,
                        style: ScaleTextStyles.textAccent.apply(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SliverGap(Dimensions.padding26),
                  SliverNameValueRow(
                    name: context.locale.care_plan_detail_screen_managed_by,
                    value: widget.carePlan.author.fullName,
                  ),
                  const SliverGap(Dimensions.padding8),
                  SliverNameValueRow(
                    name:
                        context.locale.care_plan_detail_screen_active_from_date,
                    value: widget.carePlan.scheduledStart.toRegularDate(),
                  ),
                  if (widget.carePlan.scheduledEnd != null) ...[
                    const SliverGap(Dimensions.padding8),
                    SliverNameValueRow(
                      name:
                          context.locale.care_plan_detail_screen_active_to_date,
                      value: widget.carePlan.scheduledEnd!.toRegularDate(),
                    ),
                  ],
                  const SliverGap(Dimensions.padding8),
                  SliverNameValueRow(
                    name: context.locale.care_plan_detail_screen_measurement,
                    value: context.locale.common_measurement_types(
                      widget.carePlan.activity.measurementType.name,
                    ),
                  ),
                  const SliverGap(Dimensions.padding26),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: Paddings.horizontal16,
                      child: HighlightedElevatedButton(
                        label: context
                            .locale.care_plan_detail_screen_show_calendar,
                        buttonType: ButtonType.primary,
                        onPressed: () async {
                          GoRouter.of(context).pushNamed(
                            CalendarRoute.name,
                            extra: [
                              DateTime(2022, 3, 24),
                              DateTime.now(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  if (timeSettingsForm != null) ...[
                    const SliverGap(Dimensions.padding42),
                    timeSettingsForm!,
                  ],
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: BluredScaleAppBar(
                  title: context.locale.common_measurement_types(
                    widget.carePlan.activity.measurementType.name,
                  ),
                  onBackTap: syncDataIfNeed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
