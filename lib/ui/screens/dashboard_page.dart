import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/constants/permissions.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
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

  void initCarePlanBloc(CarePlanBloc bloc, UserCubitState userState){
    final users = userState.aggregateAllUsers?userState.allUsers.toList():[userState.currentUser];

    bloc.add(
      CarePlanInitializeEvent(
        whenPeriod: PlanWhenPeriod.today,
        users: users,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncBloc = getIt<SyncBloc>();
    syncBloc.add(const SyncEvent.init());

    final userCubit = getIt<UserCubit>();

    final carePlanBloc = getIt<CarePlanBloc>();
    initCarePlanBloc(carePlanBloc, userCubit.state);

    userCubit.stream.listen((state){
      initCarePlanBloc(carePlanBloc, state);
    });

    return Stack(
      children: [
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: syncBloc),
            BlocProvider.value(value: carePlanBloc),
            BlocProvider.value(value: getIt<UserCubit>()),
          ],
          child: Builder(
            builder: (context) {
              final syncState = context.watch<SyncBloc>().state;
              final carePlanState = context.watch<CarePlanBloc>().state;
              final userState = context.watch<UserCubit>().state;

              if (carePlanState.selectedWhenPeriod == null ||
                  carePlanState.carePlansOfType == null ||
                  carePlanState.allCarePlans == null ||
                  carePlanState.allTodayMeasurements == null ||
                  carePlanState.results == null) {
                return const SizedBox.shrink();
              } else {
                final supportedMeasurementTypes = CarePlanHelper.getMeasurementTypes(
                  carePlanState.allCarePlans!,
                );

                final now = DateTime.now();

                final upcomingMeasurements = carePlanState.allTodayMeasurements
                    ?.where((x) => x.wasPlanned)
                    .where((x) => x.requiredCount > x.actualCount)
                    .where((x) => (x.measurementIntervalEnd ?? x.measurementTime).isAfter(now))
                    .toList();

                return NavigationScreen(
                  key: ValueKey(carePlanState.timestamp),
                  onTabSelected: (tabIndex) {
                    if (tabIndex == 0) {
                      carePlanBloc.add(
                        const MeasurementTypeChangeEvent(null),
                      );
                    } else {
                      carePlanBloc.add(
                        MeasurementTypeChangeEvent(
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
                    if (carePlanState.allCarePlans?.isNotEmpty == true &&
                        (carePlanState.selectedWhenPeriod ==
                                PlanWhenPeriod.today ||
                            carePlanState.selectedWhenPeriod ==
                                PlanWhenPeriod.next10)) ...{
                      SliverToBoxAdapter(
                        child: ActionWidget(
                          whenPeriod: carePlanState.selectedWhenPeriod!,
                          upcomingMeasurements: upcomingMeasurements ?? [],
                          allTodayMeasurements:
                              carePlanState.allTodayMeasurements!,
                        ),
                      ),
                    },
                  ],
                  noContentWidget: carePlanState.allCarePlans?.isEmpty ?? true
                      ? NoContentPlaceholder(
                          userAccount: userState.aggregateAllUsers ? null : userState.currentUser,
                          enterMeasurementWithoutPlan: !userState.aggregateAllUsers &&
                              (userState.currentUser.permissions.contains(Permissions.enterMeasurementWithoutPlan)),
                          supportedMeasurementTypes: supportedMeasurementTypes,
                          noContentType: NoContentType.noPlans,
                        )
                      : null,
                  navigationHeader: carePlanState.allMeasurementCountsPerPeriod?.isNotEmpty == true
                      ? PlannedMeasurementHeader(
                          whenPeriod: carePlanState.selectedWhenPeriod ?? PlanWhenPeriod.today,
                          openTimeSelector: () async {
                            await showPlannedMeasurementsSelector(
                              context,
                              carePlanState.selectedWhenPeriod,
                              carePlanState.allMeasurementCountsPerPeriod!,
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
                          if (carePlanState.nextMeasurement != null)
                            MeasurementsList(
                              whenPeriod: carePlanState.selectedWhenPeriod!,
                              carePlans: [...carePlanState.carePlansOfType!],
                              nextMeasurement: carePlanState.nextMeasurement!,
                              planWhenPeriod: carePlanState.selectedWhenPeriod!,
                              measurementsOfDay: carePlanState.allTodayMeasurements!,
                            ),
                        ],
                        bottomSlivers: [
                          if (!userState.aggregateAllUsers &&
                              (userState.currentUser.permissions
                                  .contains(Permissions.enterMeasurementWithoutPlan))) ...{
                            PersonalMeasurementFooter(
                              showInfo: upcomingMeasurements?.isNotEmpty == true,
                              onPressed: () async {
                                MeasurementHelper.doMeasurement(
                                  context: context,
                                  userId: userState.currentUserId,
                                  showAllMeasurementTypes: true,
                                );
                              },
                            ),
                          },
                        ],
                      ),
                    },
                    ...supportedMeasurementTypes.map(
                      (measurementType) => NavigationTabBarItem(
                        label: localization.common_measurement_types(
                          measurementType.name,
                        ),
                        slivers: [
                          if (carePlanState.nextMeasurement != null)
                            MeasurementsList(
                              whenPeriod: carePlanState.selectedWhenPeriod!,
                              carePlans: [...carePlanState.carePlansOfType!],
                              nextMeasurement: carePlanState.nextMeasurement!,
                              planWhenPeriod: carePlanState.selectedWhenPeriod!,
                              measurementsOfDay: carePlanState.allTodayMeasurements!,
                            ),
                        ],
                        bottomSlivers: [
                          if (!userState.aggregateAllUsers &&
                              (userState.currentUser.permissions
                                  .contains(Permissions.enterMeasurementWithoutPlan))) ...{
                            PersonalMeasurementFooter(
                              showInfo: upcomingMeasurements?.isNotEmpty == true,
                              onPressed: () async {
                                MeasurementHelper.doMeasurement(
                                  context: context,
                                  userId: userState.currentUser.id,
                                  selectedMeasurementType: measurementType,
                                  showAllMeasurementTypes: true,
                                );
                              },
                            ),
                          },
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
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
