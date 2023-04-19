import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/results/results_bloc.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_event.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/routers/routes/calendar_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/care_plans_evaluation_header.dart';
import 'package:scalesoft_app/ui/widgets/no_plans_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/results_list.dart';
import 'package:scalesoft_app/ui/widgets/sync_widget.dart';
import 'package:scalesoft_app/ui/widgets/users_profiles_evaluation_header.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class ResultsPage extends StatelessWidget with BottomSheetMixin {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final syncBloc = getIt<SyncBloc>();

    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) => previous != current,
      bloc: syncBloc..add(const SyncEvent.init()),
      builder: (context, syncState) {
        final session = getIt<Session>();
        final UserAccount userAccount = session.userAccount!;
        final allCarePlans = session.getActiveCarePlans();
        final allPendingResults = session.getPendingResults();
        final allMeasurementResults = userAccount.measurementResults ?? [];

        final supportedMeasurementTypes =
            CarePlanHelper.getMeasurementTypes(allCarePlans);

        final resultsBloc = getIt<ResultsBloc>()
          ..add(
            ResultsBlocEvent.init(
              carePlans: allCarePlans,
              whenPeriod: ResultsWhenPeriod.today,
              uncategorizedResults: allMeasurementResults,
              pendingResults: allPendingResults,
            ),
          );

        return Stack(
          children: [
            if (allCarePlans.isEmpty)
              NoPlansPlaceholder(
                userAccount: userAccount,
                enterMeasurementWithoutPlan: false,
                supportedMeasurementTypes: supportedMeasurementTypes,
              )
            else
              BlocBuilder<ResultsBloc, ResultsBlocState>(
                bloc: resultsBloc,
                builder: (context, state) {
                  Future<void> openWhenSelector() async {
                    showResultsWhenSelector(
                      context,
                      state.selectedWhenPeriod,
                      state.plansEvaluationPerPeriod ?? {},
                    ).then((selected) {
                      if (selected?.selectedPeriod != null) {
                        resultsBloc.add(
                          ResultsBlocEvent.whenPeriodChange(
                            selected!.selectedPeriod!,
                          ),
                        );
                      } else if (selected?.showCalendar == true) {
                        GoRouter.of(context).pushNamed(
                          CalendarRoute.name,
                          extra: session.getAllCarePlans()
                              .map((carePlan) => carePlan.id)
                              .toList(),
                        );
                      }
                    });
                  }

                  if (state.selectedWhenPeriod == null ||
                      state.currentCarePlans == null ||
                      state.results == null) {
                    return const SizedBox.shrink();
                  } else {
                    return NavigationScreen(
                      onTabSelected: (tabIndex) {
                        if (tabIndex == 0) {
                          resultsBloc.add(
                            const ResultsBlocEvent.curentPlansChange(
                              null,
                            ),
                          );
                        } else {
                          resultsBloc.add(
                            ResultsBlocEvent.curentPlansChange(
                              supportedMeasurementTypes.toList()[tabIndex - 1],
                            ),
                          );
                        }
                      },
                      onRefresh: () async {
                        syncBloc.add(const SyncEvent.syncAll());
                      },
                      topSlivers: [
                        SyncWidget(
                          syncState: syncState,
                        ),
                        session.isMultiUser == true
                            ? UsersProfilesEvaluationHeader(
                                userAccounts: session.getSessionAccounts(),
                                whenPeriod: state.selectedWhenPeriod!,
                                openWhenSelector: openWhenSelector,
                              )
                            : CarePlansEvaluationHeader(
                                carePlans: CarePlanHelper
                                    .getCarePlansContainingMeasurements(
                                  allCarePlans: allCarePlans,
                                  whenPeriod: state.selectedWhenPeriod!,
                                ),
                                whenPeriod: state.selectedWhenPeriod!,
                                openWhenSelector: openWhenSelector,
                              ),
                      ],
                      navigationHeader: Row(
                        children: [
                          Text(
                            translactions.results_screen_results_title,
                            style: ScaleTextStyles.textAccent.apply(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        ],
                      ),
                      tabs: [
                        if (supportedMeasurementTypes.length > 1) ...{
                          NavigationTabBarItem(
                            label: translactions.dashboard_screen_all,
                            slivers: [
                              ResultsList(
                                mResults: state.results!,
                                whenPeriod: state.selectedWhenPeriod!,
                              ),
                            ],
                            bottomSlivers: [],
                          ),
                        },
                        ...supportedMeasurementTypes
                            .map(
                              (measurementType) => NavigationTabBarItem(
                                label: translactions.common_measurement_types(
                                  measurementType.name,
                                ),
                                slivers: [
                                  ResultsList(
                                    mResults: state.results!,
                                    whenPeriod: state.selectedWhenPeriod!,
                                  ),
                                ],
                                bottomSlivers: [],
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
