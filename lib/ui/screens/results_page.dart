import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/results/results_bloc.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_event.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/widgets/blured_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/no_plans_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/results_header.dart';
import 'package:scalesoft_app/ui/widgets/results_list.dart';
import 'package:scalesoft_app/ui/widgets/sync_widget.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

class ResultsPage extends StatelessWidget with BottomSheetMixin {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final syncBloc = getIt<SyncBloc>();

    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) => previous != current,
      bloc: syncBloc..add(const SyncEvent.init()),
      builder: (context, syncState) {
        final UserAccount userAccount = getIt<Session>().userAccount!;
        final allCarePlans = userAccount.carePlans!;
        final allMeasurementResults = userAccount.measurementResults!;
        final allPendingResults =
            getIt<PendingResultsDbProvider>().getPerUser(userAccount.user.muid);

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
                  if (state.selectedWhenPeriod == null ||
                      state.currentCarePlans == null ||
                      state.results == null) {
                    return const SizedBox.shrink();
                  } else {
                    Map<ResultsWhenPeriod, int>? measurements;

                    if (state.currentCarePlans?.isNotEmpty == true) {
                      measurements = ResultsHelper.getPeriodFultillments(
                        state.currentCarePlans!,
                      );
                    }
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
                      ],
                      navigationHeader: measurements?.isNotEmpty == true
                          ? ResultsHeader(
                              whenPeriod: state.selectedWhenPeriod ??
                                  ResultsWhenPeriod.today,
                              openTimeSelector: () async {
                                final selected = await showResultsWhenSelector(
                                  context,
                                  state.selectedWhenPeriod,
                                  ResultsHelper.getPeriodFultillments(
                                    state.currentCarePlans ?? allCarePlans,
                                  ),
                                );
                                if (selected?.selectedPeriod != null) {
                                  resultsBloc.add(
                                    ResultsBlocEvent.whenPeriodChange(
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
                        if (supportedMeasurementTypes.length > 1) ...{
                          NavigationBarTabItem(
                            label: context.locale.dashboard_screen_all,
                            slivers: [
                              ResultsList(
                                mResults: state.results!,
                                userAccount: userAccount,
                              ),
                            ],
                            bottomSlivers: [],
                          ),
                        },
                        ...supportedMeasurementTypes
                            .map(
                              (measurementType) => NavigationBarTabItem(
                                label: context.locale.common_measurement_types(
                                  measurementType.name,
                                ),
                                slivers: [
                                  ResultsList(
                                    mResults: state.results!,
                                    userAccount: userAccount,
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
