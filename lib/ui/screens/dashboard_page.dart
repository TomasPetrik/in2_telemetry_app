import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/calendar_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/action_widget.dart';
import 'package:scalesoft_app/ui/widgets/blured_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';
import 'package:scalesoft_app/ui/widgets/measurements_list.dart';
import 'package:scalesoft_app/ui/widgets/no_plans_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/personal_measurement_footer.dart';
import 'package:scalesoft_app/ui/widgets/sync_widget.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with BottomSheetMixin {
  @override
  void dispose() {
    getIt<CarePlanBloc>().add(const StopWatchDog());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncBloc = getIt<SyncBloc>();

    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) => previous != current,
      bloc: syncBloc..add(const SyncEvent.init()),
      builder: (context, syncState) {
        final session = getIt<Session>();
        final sessionAccounts = session.getSessionAccounts();
        final allCarePlans = session.getActiveCarePlans();
        final allPendingResults = session.getPendingResults();

        final supportedMeasurementTypes =
            CarePlanHelper.getMeasurementTypes(allCarePlans);

        final carePlanBloc = getIt<CarePlanBloc>()
          ..add(
            CarePlanInitializeEvent(
              carePlans: allCarePlans,
              whenPeriod: PlanWhenPeriod.today,
              pendingResults: allPendingResults,
            ),
          );
        return Stack(
          children: [
            if (allCarePlans.isEmpty)
              NoPlansPlaceholder(
                userAccount:
                    session.isMultiUser != true ? sessionAccounts[0] : null,
                enterMeasurementWithoutPlan: session.isMultiUser != true &&
                    sessionAccounts[0].enterMeasurementWithoutPlan,
                supportedMeasurementTypes: supportedMeasurementTypes,
              )
            else
              BlocBuilder<CarePlanBloc, CarePlanBlocState>(
                bloc: carePlanBloc,
                builder: (context, state) {
                  if (state.selectedWhenPeriod == null ||
                      state.currentCarePlans == null ||
                      state.measurements == null ||
                      state.results == null) {
                    return const SizedBox.shrink();
                  } else {
                    return NavigationScreen(
                      onTabSelected: (tabIndex) {
                        if (tabIndex == 0) {
                          carePlanBloc.add(
                            const CurrentPlansChangeEvent(null),
                          );
                        } else {
                          carePlanBloc.add(
                            CurrentPlansChangeEvent(
                              supportedMeasurementTypes.toList()[tabIndex - 1],
                            ),
                          );
                        }
                      },
                      onRefresh: () async {
                        syncBloc.add(const SyncEvent.syncAll());
                      },
                      topSlivers: [
                        SyncWidget(syncState: syncState),
                        if ((state.selectedWhenPeriod == PlanWhenPeriod.today ||
                            state.selectedWhenPeriod ==
                                PlanWhenPeriod.next10)) ...{
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Gaps.gap16,
                                ActionWidget(
                                  nextMeasurement: state.nextMeasurement,
                                ),
                                Gaps.gap26,
                              ],
                            ),
                          ),
                        }
                      ],
                      navigationHeader: state
                                  .allMeasurementCountsPerPeriod?.isNotEmpty ==
                              true
                          ? PlannedMeasurementHeader(
                              whenPeriod: state.selectedWhenPeriod ??
                                  PlanWhenPeriod.today,
                              openTimeSelector: () async {
                                await showPlannedMeasurementsSelector(
                                  context,
                                  state.selectedWhenPeriod,
                                  state.allMeasurementCountsPerPeriod!,
                                ).then((selected) {
                                  if (selected?.selectedPeriod != null) {
                                    carePlanBloc.add(
                                      TimePeriodChangeEvent(
                                        selected!.selectedPeriod!,
                                      ),
                                    );
                                  } else if (selected?.showCalendar == true) {
                                    GoRouter.of(context).pushNamed(
                                      CalendarRoute.name,
                                      extra: DateTime(2022, 3, 24),
                                    );
                                  }
                                });
                              },
                            )
                          : null,
                      tabs: [
                        if (supportedMeasurementTypes.length > 1) ...{
                          NavigationTabBarItem(
                            label: context.locale.dashboard_screen_all,
                            slivers: [
                              MeasurementsList(
                                whenPeriod: state.selectedWhenPeriod!,
                                carePlans: [...state.currentCarePlans!],
                                measurements: state.measurements!,
                                nextMeasurement: state.nextMeasurement!,
                                planWhenPeriod: state.selectedWhenPeriod!,
                                results: state.results!,
                              ),
                            ],
                            bottomSlivers: [
                              if (session.isMultiUser != true &&
                                  sessionAccounts[0]
                                      .enterMeasurementWithoutPlan) ...{
                                PersonalMeasurementFooter(
                                  showInfo:
                                      state.measurements?.isNotEmpty == true,
                                  onPressed: () async {
                                    doMeasurement(
                                      context: context,
                                      userId: sessionAccounts[0].user.muid,
                                      allMeasurementTypes:
                                          supportedMeasurementTypes,
                                    );
                                  },
                                ),
                              },
                            ],
                          ),
                        },
                        ...supportedMeasurementTypes
                            .map(
                              (measurementType) => NavigationTabBarItem(
                                label: context.locale.common_measurement_types(
                                  measurementType.name,
                                ),
                                slivers: [
                                  MeasurementsList(
                                    whenPeriod: state.selectedWhenPeriod!,
                                    carePlans: [...state.currentCarePlans!],
                                    measurements: state.measurements!,
                                    nextMeasurement: state.nextMeasurement!,
                                    planWhenPeriod: state.selectedWhenPeriod!,
                                    results: state.results!,
                                  ),
                                ],
                                bottomSlivers: [
                                  if (session.isMultiUser != true &&
                                      sessionAccounts[0]
                                          .enterMeasurementWithoutPlan) ...{
                                    PersonalMeasurementFooter(
                                      showInfo:
                                          state.measurements?.isNotEmpty ==
                                              true,
                                      onPressed: () async {
                                        doMeasurement(
                                          context: context,
                                          userId: sessionAccounts[0].user.muid,
                                          selectedMeasurementType: state
                                              .currentCarePlans![0]
                                              .activity
                                              .measurementType,
                                          allMeasurementTypes:
                                              supportedMeasurementTypes,
                                        );
                                      },
                                    ),
                                  },
                                ],
                              ),
                            )
                            .toList(),
                      ],
                    );
                  }
                },
              ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BluredUserAppBar(),
            ),
          ],
        );
      },
    );
  }
}
