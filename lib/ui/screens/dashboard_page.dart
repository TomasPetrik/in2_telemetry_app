import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/action_widget.dart';
import 'package:scalesoft_app/ui/widgets/blured_user_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/measurement_header.dart';
import 'package:scalesoft_app/ui/widgets/measurements_list.dart';
import 'package:scalesoft_app/ui/widgets/notification_widget.dart';
import 'package:scalesoft_app/ui/widgets/personal_measurement_footer.dart';
import 'package:scalesoft_app/ui/widgets/sync_widget.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class DashboardPage extends StatelessWidget with BottomSheetMixin {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserAccount userAccount = getIt<Session>().userAccount!;
    final allCarePlans = userAccount.carePlans!;

    final supportedMeasurements = <MeasurementType>{};
    allCarePlans
        .where(
          (carePlan) =>
              supportedMeasurements.add(carePlan.activity.measurementType),
        )
        .toList();

    final carePlanBloc = getIt<CarePlanBloc>()
      ..add(
        CarePlanInitializeEvent(
          carePlans: allCarePlans,
          whenPeriod: WhenPeriod.today,
        ),
      );

    return BlocBuilder<CarePlanBloc, CarePlanBlocState>(
      bloc: carePlanBloc,
      builder: (context, state) {
        if (state.selectedWhenPeriod == null) {
          return const SizedBox.shrink();
        } else {
          Map<WhenPeriod, int>? measurements;

          if (allCarePlans.isNotEmpty) {
            measurements = CarePlanHelper.getPossibleWhenPeriods(allCarePlans);
          }

          return Stack(
            children: [
              NavigationScreen(
                onTabSelected: (tabIndex) {
                  if (tabIndex == 0) {
                    carePlanBloc.add(
                      CurrentPlansChangeEvent(allCarePlans),
                    );
                  } else {
                    carePlanBloc.add(
                      CurrentPlansChangeEvent(
                        [
                          allCarePlans[tabIndex - 1],
                        ],
                      ),
                    );
                  }
                },
                onRefresh: () async {
                  carePlanBloc.add(ReloadCarePlansEvent(userAccount));
                },
                topSlivers: [
                  const NotificationWidget(),
                  const SyncWidget(),
                  if ((state.selectedWhenPeriod == WhenPeriod.today ||
                          state.selectedWhenPeriod == WhenPeriod.next10) &&
                      (state.nextMeasurement?.carePlan
                              .getTodayRemainingMeasurements()
                              .isNotEmpty ==
                          true)) ...{
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Gaps.gap16,
                          ActionWidget(
                            userAccount: userAccount,
                            measurement: state.nextMeasurement,
                          ),
                          Gaps.gap26,
                        ],
                      ),
                    ),
                  }
                ],
                topHeaderHeight: (state.selectedWhenPeriod ==
                                WhenPeriod.today ||
                            state.selectedWhenPeriod == WhenPeriod.next10) &&
                        (state.nextMeasurement?.carePlan
                                .getTodayRemainingMeasurements()
                                .isNotEmpty ==
                            true)
                    ? Dimensions.padding16 +
                        Constants.actionActiveWidgetHeight +
                        Dimensions.padding26
                    : 0,
                topHeader: (state.selectedWhenPeriod == WhenPeriod.today ||
                            state.selectedWhenPeriod == WhenPeriod.next10) &&
                        (state.nextMeasurement?.carePlan
                                .getTodayRemainingMeasurements()
                                .isNotEmpty ==
                            true)
                    ? Column(
                        children: [
                          Gaps.gap16,
                          Flexible(
                            child: ActionWidget(
                              userAccount: userAccount,
                              measurement: state.nextMeasurement,
                            ),
                          ),
                          Gaps.gap26,
                        ],
                      )
                    : const SizedBox.shrink(),
                navigationHeader: measurements?.isNotEmpty == true
                    ? MeasurementHeader(
                        whenPeriod:
                            state.selectedWhenPeriod ?? WhenPeriod.today,
                        openTimeSelector: () async {
                          final selected = await showWhenSelector(
                            context,
                            state.selectedWhenPeriod,
                            CarePlanHelper.getPossibleWhenPeriods(
                              state.currentCarePlans ?? allCarePlans,
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
                  if (allCarePlans.isEmpty) ...{
                    NavigationBarTabItem(
                      label: '',
                      slivers: [
                        SliverPadding(
                          padding: Paddings.horizontal64,
                          sliver: InfoPlaceholder(
                            icon: SvgPicture.asset(
                              'assets/icons/icon_wave_pulse_big.svg',
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            label: context.locale.dashboard_screen_no_plan,
                          ),
                        )
                      ],
                      bottomSlivers: [
                        if (userAccount.userPermissions?.contains(
                              UserPermission.enterMeasurementWithoutPlan,
                            ) ==
                            true) ...{
                          PersonalMeasurementFooter(
                            showInfo: state.measurements?.isNotEmpty == true,
                            onPressed: () async {
                              showDeviceSelector(
                                context: context,
                                userId: userAccount.user.muid,
                                allMeasurementTypes:
                                    supportedMeasurements.isNotEmpty
                                        ? supportedMeasurements
                                        : Constants.supportedMeasurements.keys
                                            .toSet(),
                              );
                            },
                          ),
                        },
                      ],
                    )
                  } else ...[
                    if (allCarePlans.length > 1) ...{
                      NavigationBarTabItem(
                        label: context.locale.dashboard_screen_all,
                        slivers: [
                          MeasurementsList(
                            measurements: state.measurements!,
                            nextMeasurement: state.nextMeasurement!,
                            showDateHeader:
                                state.selectedWhenPeriod == WhenPeriod.next10,
                          ),
                        ],
                        bottomSlivers: [
                          if (userAccount.userPermissions?.contains(
                                UserPermission.enterMeasurementWithoutPlan,
                              ) ==
                              true) ...{
                            PersonalMeasurementFooter(
                              showInfo: state.measurements?.isNotEmpty == true,
                              onPressed: () async {
                                showDeviceSelector(
                                  context: context,
                                  userId: userAccount.user.muid,
                                  allMeasurementTypes: supportedMeasurements,
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
                                measurements: state.measurements!,
                                nextMeasurement: state.nextMeasurement!,
                                showDateHeader: state.selectedWhenPeriod ==
                                    WhenPeriod.next10,
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
                                    showDeviceSelector(
                                      context: context,
                                      userId: userAccount.user.muid,
                                      selectedMeasurementType: state
                                          .currentCarePlans![0]
                                          .activity
                                          .measurementType,
                                      allMeasurementTypes:
                                          supportedMeasurements,
                                    );
                                  },
                                ),
                              },
                            ],
                          ),
                        )
                        .toList(),
                  ],
                ],
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
        }
      },
    );
  }
}
