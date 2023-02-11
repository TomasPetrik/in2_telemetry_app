import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/action_widget.dart';
import 'package:scalesoft_app/ui/widgets/blured_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';
import 'package:scalesoft_app/ui/widgets/measurements_list.dart';
import 'package:scalesoft_app/ui/widgets/no_plans_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/notification_widget.dart';
import 'package:scalesoft_app/ui/widgets/personal_measurement_footer.dart';
import 'package:scalesoft_app/ui/widgets/sync_widget.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class DashboardPage extends StatelessWidget with BottomSheetMixin {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final syncBloc = getIt<SyncBloc>();

    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) => previous != current,
      bloc: syncBloc..add(const SyncEvent.init()),
      builder: (context, syncState) {
        final UserAccount userAccount = getIt<Session>().userAccount!;
        //TODO.. refactor for multiuser - it should comes in args
        final allCarePlans = userAccount.carePlans!;
        final allMeasurementResults = userAccount.measurementResults!;
        final allPendingResults =
            getIt<PendingResultsDbProvider>().getPerUser(userAccount.user.muid);

        final supportedMeasurementTypes =
            CarePlanHelper.getMeasurementTypes(allCarePlans);

        final carePlanBloc = getIt<CarePlanBloc>()
          ..add(
            CarePlanInitializeEvent(
              carePlans: allCarePlans,
              whenPeriod: PlanWhenPeriod.today,
              uncategorizedResults: allMeasurementResults,
              pendingResults: allPendingResults,
            ),
          );
        return Stack(
          children: [
            if (allCarePlans.isEmpty)
              NoPlansPlaceholder(
                userAccount: userAccount,
                enterMeasurementWithoutPlan: userAccount.enterMeasurementWithoutPlan,
                supportedMeasurementTypes: supportedMeasurementTypes,
              )
            else
              BlocBuilder<CarePlanBloc, CarePlanBlocState>(
                bloc: carePlanBloc,
                builder: (context, state) {
                  if (state.selectedWhenPeriod == null ||
                      state.measurements == null) {
                    return const SizedBox.shrink();
                  } else {
                    Map<PlanWhenPeriod, int>? measurements;

                    if (allCarePlans.isNotEmpty) {
                      measurements =
                          CarePlanHelper.getPossibleWhenPeriods(allCarePlans);
                    }

                    return NavigationScreen(
                      onTabSelected: (tabIndex) {
                        if (tabIndex == 0) {
                          carePlanBloc.add(
                            CurrentPlansChangeEvent(allCarePlans, null),
                          );
                        } else {
                          carePlanBloc.add(
                            CurrentPlansChangeEvent(
                              [
                                allCarePlans[tabIndex - 1],
                              ],
                              allCarePlans[tabIndex - 1]
                                  .activity
                                  .measurementType,
                            ),
                          );
                        }
                      },
                      onRefresh: () async {
                        syncBloc.add(SyncEvent.syncAll([userAccount]));
                      },
                      topSlivers: [
                        const NotificationWidget(),
                        SyncWidget(syncState: syncState),
                        if (allCarePlans.isNotEmpty == true &&
                            (state.selectedWhenPeriod == PlanWhenPeriod.today ||
                                state.selectedWhenPeriod ==
                                    PlanWhenPeriod.next10)) ...{
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Gaps.gap16,
                                ActionWidget(
                                  userAccount: userAccount,
                                  nextMeasurement: state.nextMeasurement,
                                ),
                                Gaps.gap26,
                              ],
                            ),
                          ),
                        }
                      ],
                      navigationHeader: measurements?.isNotEmpty == true
                          ? PlannedMeasurementHeader(
                              whenPeriod: state.selectedWhenPeriod ??
                                  PlanWhenPeriod.today,
                              openTimeSelector: () async {
                                final selected =
                                    await showPlannedMeasurementsSelector(
                                  context,
                                  state.selectedWhenPeriod,
                                  CarePlanHelper.getPossibleWhenPeriods(
                                    state.currentCarePlans!,
                                  ),
                                );
                                if (selected?.selectedPeriod != null) {
                                  carePlanBloc.add(
                                    TimePeriodChangeEvent(
                                      selected!.selectedPeriod!,
                                    ),
                                  );
                                } else if (selected?.showCalendar == true) {
                                  //TODO.. show calendar
                                }
                              },
                            )
                          : null,
                      tabs: [
                        if (allCarePlans.length > 1) ...{
                          NavigationBarTabItem(
                            label: context.locale.dashboard_screen_all,
                            slivers: [
                              MeasurementsList(
                                whenPeriod: state.selectedWhenPeriod!,
                                carePlans: [...state.currentCarePlans!],
                                measurements: state.measurements!,
                                nextMeasurement: state.nextMeasurement!,
                                planWhenPeriod: state.selectedWhenPeriod!,
                              ),
                            ],
                            bottomSlivers: [
                              if (userAccount.userPermissions?.contains(
                                    UserPermission.enterMeasurementWithoutPlan,
                                  ) ==
                                  true) ...{
                                PersonalMeasurementFooter(
                                  showInfo:
                                      state.measurements?.isNotEmpty == true,
                                  onPressed: () async {
                                    doMeasurement(
                                      context: context,
                                      userId: userAccount.user.muid,
                                      allMeasurementTypes:
                                          supportedMeasurementTypes,
                                    );
                                  },
                                ),
                              },
                            ],
                          ),
                        },
                        ...allCarePlans
                            .map(
                              (carePlan) => NavigationBarTabItem(
                                label: context.locale.common_measurement_types(
                                  carePlan.activity.measurementType.name,
                                ),
                                slivers: [
                                  MeasurementsList(
                                    whenPeriod: state.selectedWhenPeriod!,
                                    carePlans: [...state.currentCarePlans!],
                                    measurements: state.measurements!,
                                    nextMeasurement: state.nextMeasurement!,
                                    planWhenPeriod: state.selectedWhenPeriod!,
                                  ),
                                ],
                                bottomSlivers: [
                                  if (userAccount.userPermissions?.contains(
                                        UserPermission
                                            .enterMeasurementWithoutPlan,
                                      ) ==
                                      true) ...{
                                    PersonalMeasurementFooter(
                                      showInfo:
                                          state.measurements?.isNotEmpty ==
                                              true,
                                      onPressed: () async {
                                        doMeasurement(
                                          context: context,
                                          userId: userAccount.user.muid,
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BluredUserAppBar(
                userAccount: userAccount,
              ),
            ),
          ],
        );
      },
    );
  }
}
