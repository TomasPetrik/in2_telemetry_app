import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/calendar_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/widgets/action_widget.dart';
import 'package:scalesoft_app/ui/widgets/blurred_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';
import 'package:scalesoft_app/ui/widgets/measurements_list.dart';
import 'package:scalesoft_app/ui/widgets/no_plans_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/personal_measurement_footer.dart';
import 'package:scalesoft_app/ui/widgets/sync_widget.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class DashboardPage extends StatelessWidget with BottomSheetMixin {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final syncBloc = getIt<SyncBloc>();

    final carePlanBloc = getIt<CarePlanBloc>();
    final session = getIt<Session>();
    final allPendingResults = session.getPendingResults();

    return Stack(
      children: [
        BlocBuilder<SyncBloc, SyncState>(
          buildWhen: (previous, current) => previous != current,
          bloc: syncBloc..add(const SyncEvent.init()),
          builder: (context, syncState) {
            return BlocBuilder<CarePlanBloc, CarePlanBlocState>(
              bloc: carePlanBloc
                ..add(
                  CarePlanInitializeEvent(
                    carePlans: session.getActiveCarePlans(),
                    whenPeriod: PlanWhenPeriod.today,
                    pendingResults: allPendingResults,
                  ),
                ),
              builder: (context, state) {
                final sessionAccounts = session.getSessionAccounts();

                if (state.selectedWhenPeriod == null ||
                    state.currentCarePlans == null ||
                    state.allTodayMeasurements == null ||
                    state.results == null) {
                  return const SizedBox.shrink();
                } else {
                  final allCarePlans = session.getActiveCarePlans();
                  final supportedMeasurementTypes =
                      CarePlanHelper.getMeasurementTypes(
                    session.getActiveCarePlans(),
                  );

                  return NavigationScreen(
                    key: ValueKey(state.timestamp),
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
                    syncWidget: SyncWidget(syncState: syncState),
                    topSlivers: [
                      if ((state.selectedWhenPeriod == PlanWhenPeriod.today ||
                          state.selectedWhenPeriod ==
                              PlanWhenPeriod.next10)) ...{
                        SliverToBoxAdapter(
                          child: ActionWidget(
                            whenPeriod: state.selectedWhenPeriod!,
                            upcomingMeasurements:
                                state.upcomingMeasurements ?? [],
                            allTodayMeasurements: state.allTodayMeasurements!,
                          ),
                        ),
                      },
                    ],
                    noContentWidget: allCarePlans.isEmpty
                        ? NoContentPlaceholder(
                            userAccount: session.isMultiUser != true
                                ? sessionAccounts[0]
                                : null,
                            enterMeasurementWithoutPlan: session.isMultiUser !=
                                    true &&
                                sessionAccounts[0].enterMeasurementWithoutPlan,
                            supportedMeasurementTypes:
                                supportedMeasurementTypes,
                            noContentType: NoContentType.noPlans,
                          )
                        : null,
                    navigationHeader:
                        state.allMeasurementCountsPerPeriod?.isNotEmpty == true
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
                                        extra: session
                                            .getAllCarePlans()
                                            .map((carePlan) => carePlan.id)
                                            .toList(),
                                      );
                                    }
                                  });
                                },
                              )
                            : null,
                    tabs: [
                      if (supportedMeasurementTypes.length > 1) ...{
                        NavigationTabBarItem(
                          label: localization.dashboard_screen_all,
                          slivers: [
                            if (state.nextMeasurement != null)
                              MeasurementsList(
                                whenPeriod: state.selectedWhenPeriod!,
                                carePlans: [...state.currentCarePlans!],
                                measurements: state.upcomingMeasurements!,
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
                                    state.upcomingMeasurements?.isNotEmpty ==
                                        true,
                                onPressed: () async {
                                  MeasurementHelper.doMeasurement(
                                    context: context,
                                    userId: sessionAccounts[0].user.muid,
                                    showAllMeasurementTypes: true,
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
                              label: localization.common_measurement_types(
                                measurementType.name,
                              ),
                              slivers: [
                                if (state.nextMeasurement != null)
                                  MeasurementsList(
                                    whenPeriod: state.selectedWhenPeriod!,
                                    carePlans: [...state.currentCarePlans!],
                                    measurements: state.upcomingMeasurements!,
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
                                    showInfo: state
                                            .upcomingMeasurements?.isNotEmpty ==
                                        true,
                                    onPressed: () async {
                                      MeasurementHelper.doMeasurement(
                                        context: context,
                                        userId: sessionAccounts[0].user.muid,
                                        selectedMeasurementType: state
                                            .currentCarePlans![0]
                                            .activity
                                            .measurementType,
                                        showAllMeasurementTypes: true,
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
            );
          },
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BlurredUserAppBar(),
        ),
      ],
    );
  }
}
