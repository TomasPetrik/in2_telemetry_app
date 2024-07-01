import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/results/results_bloc.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/constants/permissions.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
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
    final userCubit = getIt<UserCubit>();
    final resultsBloc = getIt<ResultsBloc>();

    syncBloc.add(const SyncEvent.init());

    resultsBloc.add(
      const ResultsBlocEvent.init(
        whenPeriod: ResultsWhenPeriod.today,
      ),
    );

    return Stack(
      children: [
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: syncBloc),
            BlocProvider.value(value: resultsBloc),
            BlocProvider.value(value: userCubit),
          ],
          child: Builder(
            builder: (context) {
              final syncState = context.watch<SyncBloc>().state;
              final resultsState = context.watch<ResultsBloc>().state;
              final userState = context.watch<UserCubit>().state;

              syncState.whenOrNull(
                synced: () => {
                  resultsBloc.add(
                    ResultsBlocEvent.init(whenPeriod: resultsState.selectedWhenPeriod ?? ResultsWhenPeriod.today),
                  ),
                },
              );

              Future<void> openWhenSelector() async {
                showResultsWhenSelector(
                  context,
                  resultsState.selectedWhenPeriod,
                  resultsState.plansEvaluationPerPeriod ?? {},
                  resultsState.allCarePlans?.isNotEmpty ?? false,
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
                    );
                  }
                });
              }

              if (resultsState.results == null ||
                  resultsState.selectedWhenPeriod == null ||
                  resultsState.currentCarePlans == null) {
                return const SizedBox.shrink();
              } else {
                /*
                  final supportedMeasurementTypes =
                      CarePlanHelper.getMeasurementTypesByResults(
                    state.results!,
                  );
                  */
                final allMeasurementTypes = resultsState.allMeasurementTypes!;
                final user = userState.aggregateAllUsers
                    ? null
                    : resultsState.sessionUsers?[0];

                return NavigationScreen(
                  onTabSelected: (tabIndex) {
                    if (tabIndex == 0) {
                      resultsBloc.add(
                        const ResultsBlocEvent.currentPlansChange(
                          null,
                        ),
                      );
                    } else {
                      resultsBloc.add(
                        ResultsBlocEvent.currentPlansChange(
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
                    userState.aggregateAllUsers
                        ? UsersProfilesEvaluationHeader(
                            userAccounts: resultsState.sessionUsers ?? [],
                            whenPeriod: resultsState.selectedWhenPeriod!,
                            openWhenSelector: openWhenSelector,
                          )
                        : CarePlansEvaluationHeader(
                            carePlans: CarePlanHelper.getCarePlansContainingMeasurements(
                              allCarePlans: resultsState.allCarePlans ?? [],
                              whenPeriod: resultsState.selectedWhenPeriod!,
                            ),
                            whenPeriod: resultsState.selectedWhenPeriod!,
                            openWhenSelector: openWhenSelector,
                            offlineResults: resultsState.offlineResults ?? [],
                          ),
                  ],
                  noContentWidget: allMeasurementTypes.isEmpty
                      ? NoContentPlaceholder(
                          userAccount: user,
                          enterMeasurementWithoutPlan: false,
                          supportedMeasurementTypes: allMeasurementTypes,
                          noContentType: user?.permissions.contains(Permissions.viewOwnMeasurementData) ?? false
                              ? NoContentType.noHistoricalData
                              : NoContentType.notAllowedSeeOwnMeasurements,
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
                            dayDt: resultsState.selectedWhenPeriod == ResultsWhenPeriod.today
                                ? DateTime.now().date
                                : DateTime.now().yesterday,
                            showUserNames: userState.aggregateAllUsers,
                            mResults: resultsState.results!,
                            canOpenChart: true,
                          ),
                        ],
                        bottomSlivers: [],
                      ),
                    },
                    ...allMeasurementTypes.map(
                      (measurementType) => NavigationTabBarItem(
                        label: localization.common_measurement_types(
                          measurementType.name,
                        ),
                        slivers: [
                          ResultsList(
                            dayDt: resultsState.selectedWhenPeriod == ResultsWhenPeriod.today
                                ? DateTime.now().date
                                : DateTime.now().yesterday,
                            showUserNames: userState.aggregateAllUsers,
                            mResults: resultsState.results!,
                            canOpenChart: true,
                          ),
                        ],
                        bottomSlivers: [],
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
