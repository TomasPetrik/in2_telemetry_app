import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/bloc/results/results_bloc.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_event.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/routers/routes/calendar_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blurred_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/care_plans_evaluation_header.dart';
import 'package:scalesoft_app/ui/widgets/no_plans_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/results_list.dart';
import 'package:scalesoft_app/ui/widgets/sync_widget.dart';
import 'package:scalesoft_app/ui/widgets/users_profiles_evaluation_header.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
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
        final sessionAccounts = session.getSessionAccounts();
        final allCarePlans = session.getActiveCarePlans();
        final allPendingResults = session.getPendingResults();
        final allMeasurementResults =
            sessionAccounts.fold<List<MeasurementDataContract>>(
          [],
          (prevResults, userAccount) =>
              [...prevResults, ...userAccount.measurementResults ?? []],
        );

        final resultsBloc = getIt<ResultsBloc>()
          ..add(
            ResultsBlocEvent.init(
              carePlans: allCarePlans,
              whenPeriod: ResultsWhenPeriod.today,
              allServerResults: allMeasurementResults,
              pendingResults: allPendingResults,
            ),
          );

        return Stack(
          children: [
            BlocBuilder<ResultsBloc, ResultsBlocState>(
              bloc: resultsBloc,
              builder: (context, state) {
                Future<void> openWhenSelector() async {
                  showResultsWhenSelector(
                    context,
                    state.selectedWhenPeriod,
                    state.plansEvaluationPerPeriod ?? {},
                    sessionAccounts.any(
                      (userAccount) =>
                          userAccount.carePlans?.isNotEmpty == true,
                    ),
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
                        extra: session
                            .getAllCarePlans()
                            .map((carePlan) => carePlan.id)
                            .toList(),
                      );
                    }
                  });
                }

                if (state.results == null ||
                    state.selectedWhenPeriod == null ||
                    state.currentCarePlans == null) {
                  return const SizedBox.shrink();
                } else {
                  /*
                  final supportedMeasurementTypes =
                      CarePlanHelper.getMeasurementTypesByResults(
                    state.results!,
                  );
                  */
                  final allMeasurementTypes = state.allMeasurementTypes!;

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
                            allMeasurementTypes.toList()[tabIndex - 1],
                          ),
                        );
                      }
                    },
                    onRefresh: () async {
                      syncBloc.add(const SyncEvent.syncAll());
                    },
                    syncWidget: SyncWidget(syncState: syncState),
                    topSlivers: [
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
                    noContentWidget: allMeasurementTypes.isEmpty
                        ? NoContentPlaceholder(
                            userAccount: session.isMultiUser != true
                                ? sessionAccounts[0]
                                : null,
                            enterMeasurementWithoutPlan: false,
                            supportedMeasurementTypes:
                                allMeasurementTypes,
                            noContentType: session.isMultiUser != true &&
                                    !sessionAccounts[0].viewOwnMeasurementData
                                ? NoContentType.notAllowedSeeOwnMeasurements
                                : NoContentType.noHistoricalData,
                          )
                        : null,
                    navigationHeader: Row(
                      children: [
                        Text(
                          localization.results_screen_results_title,
                          style: ScaleTextStyles.textAccent.apply(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                    tabs: [
                      if (allMeasurementTypes.length > 1) ...{
                        NavigationTabBarItem(
                          label: localization.dashboard_screen_all,
                          slivers: [
                            ResultsList(
                              dayDt: state.selectedWhenPeriod ==
                                      ResultsWhenPeriod.today
                                  ? DateTime.now().date
                                  : DateTime.now().yesterday,
                              isMultiUser: getIt<Session>().isMultiUser == true,
                              mResults: state.results!,
                              canOpenChart: true,
                            ),
                          ],
                          bottomSlivers: [],
                        ),
                      },
                      ...allMeasurementTypes
                          .map(
                            (measurementType) => NavigationTabBarItem(
                              label: localization.common_measurement_types(
                                measurementType.name,
                              ),
                              slivers: [
                                ResultsList(
                                  dayDt: state.selectedWhenPeriod ==
                                          ResultsWhenPeriod.today
                                      ? DateTime.now().date
                                      : DateTime.now().yesterday,
                                  isMultiUser:
                                      getIt<Session>().isMultiUser == true,
                                  mResults: state.results!,
                                  canOpenChart: true,
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
              child: BlurredUserAppBar(),
            ),
          ],
        );
      },
    );
  }
}
