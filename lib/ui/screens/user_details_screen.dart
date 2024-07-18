import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/report/report_bloc.dart';
import 'package:scalesoft_app/bloc/report/report_bloc_event.dart';
import 'package:scalesoft_app/bloc/report/report_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/constants/permissions.dart';
import 'package:scalesoft_app/cubit/care_plan/care_plan_cubit.dart';
import 'package:scalesoft_app/cubit/loader/loader_cubit.dart';
import 'package:scalesoft_app/cubit/loader/loader_state.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/enum/user_problem_type.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/care_plan_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/device_search_route.dart';
import 'package:scalesoft_app/ui/routers/routes/register_device_detail_route.dart';
import 'package:scalesoft_app/ui/screens/device_search_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/care_plan_item.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/sliver_name_value_row.dart';
import 'package:scalesoft_app/ui/widgets/user_warning_item.dart';

class UserDetailScreen extends StatelessWidget with BottomSheetMixin {
  const UserDetailScreen({
    super.key,
    required this.userAccount,
  });

  final UserModel userAccount;

  @override
  Widget build(BuildContext context) {
    final reportBloc = getIt<ReportBloc>()..add(const ReportBlocEvent.init());
    final loaderCubit = getIt<LoaderCubit>()..loaded();
    final carePlanCubit = context.watch<CarePlanCubit>();
    final carePlanState = carePlanCubit.state;

    final relevantProblems = [
      UserProblemType.sessionExpired,
      UserProblemType.lastSyncFailed,
      UserProblemType.syncResultsFailed,
    ];

    return Material(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverGap(
                MediaQuery.of(context).viewPadding.top + Dimensions.appBarHeight,
              ),
              const SliverGap(Dimensions.padding16),
              BlocBuilder<SyncBloc, SyncState>(
                bloc: getIt<SyncBloc>(),
                builder: (context, syncState) {
                  //1. Show always sync in progress when possible
                  final anyProgressWidget = syncState.whenOrNull(
                    inProgress: () => ProcessItem(
                      processType: ProcessType.inProgress,
                      label: localization.sync_widget_sync_in_progress,
                    ),
                    synced: () => ProcessItem(
                      processType: ProcessType.done,
                      label: localization.sync_widget_synced,
                    ),
                  );

                  syncState.whenOrNull(
                    synced: () {
                      carePlanCubit.init(userAccount.id);
                    },
                  );

                  //2. Otherwise check for high prioritized problem
                  final userProblemType = userAccount.problem;

                  Widget? userWarningWidget;
                  if (anyProgressWidget != null) {
                    userWarningWidget = anyProgressWidget;
                  } else if (userProblemType != null && relevantProblems.contains(userProblemType)) {
                    userWarningWidget = UserWarningItem(
                      userProblemType: userProblemType,
                      userAccount: userAccount,
                    );
                  }

                  //3. If has no user warning
                  final anyInfoWidget = userWarningWidget != null
                      ? SliverPadding(
                          padding: const EdgeInsets.only(
                            left: Dimensions.padding16,
                            right: Dimensions.padding16,
                            bottom: Dimensions.padding24,
                          ),
                          sliver: userWarningWidget,
                        )
                      : const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                  return anyInfoWidget;
                },
              ),
              if (carePlanState.carePlans.isNotEmpty) ...[
                SliverPadding(
                  padding: Paddings.left16,
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      localization.user_detail_screen_measurement_plans,
                      style: ScaleTextStyles.textAccent.apply(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
                const SliverGap(Dimensions.padding26),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, int index) {
                      final carePlan = carePlanState.carePlans[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              GoRouter.of(context).pushNamed(
                                CarePlanDetailRoute.name,
                                extra: carePlan,
                              );
                            },
                            child: Padding(
                              padding: Paddings.horizontal16,
                              child: CarePlanItem(
                                carePlan: carePlan,
                                viewOwnMeasurementData:
                                    userAccount.permissions.contains(Permissions.viewOwnMeasurementData),
                              ),
                            ),
                          ),
                          if (index != (carePlanState.carePlans.length - 1)) Gaps.gap16,
                        ],
                      );
                    },
                    childCount: carePlanState.carePlans.length,
                  ),
                ),
                const SliverGap(Dimensions.padding24),
              ],
              SliverPadding(
                padding: Paddings.left16,
                sliver: SliverToBoxAdapter(
                  child: Text(
                    localization.user_detail_screen_user_info,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
              const SliverGap(Dimensions.padding24),
              SliverNameValueRow(
                name: localization.user_detail_screen_user_name,
                value: userAccount.firstNames,
              ),
              const SliverGap(Dimensions.padding8),
              SliverNameValueRow(
                name: localization.user_detail_screen_user_surname,
                value: userAccount.lastNames,
              ),
              if (userAccount.phoneNumbers.isNotEmpty) ...[
                const SliverGap(Dimensions.padding8),
                SliverNameValueRow(
                  name: localization.user_detail_screen_user_phone,
                  value: userAccount.phoneNumbers[0],
                ),
              ],
              if (userAccount.emailAddresses.isNotEmpty == true) ...[
                const SliverGap(Dimensions.padding8),
                SliverNameValueRow(
                  name: localization.user_detail_screen_user_email,
                  value: userAccount.emailAddresses[0],
                ),
              ],
              const SliverGap(Dimensions.padding24),
              BlocConsumer<ReportBloc, ReportBlocState>(
                bloc: reportBloc,
                listener: (context, state) {
                  state.whenOrNull(
                    succed: () {
                      loaderCubit.loaded();
                      showReportsSent(context);
                    },
                    failed: () {
                      loaderCubit.loaded();
                      showServerError(context);
                    },
                    sending: () {
                      loaderCubit.loading();
                    },
                  );
                },
                builder: (context, state) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: Paddings.horizontal16,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            reportBloc.add(const ReportBlocEvent.sendReports());
                          },
                          child: Text(
                            localization.user_detail_screen_send_debug_logs,
                            style: ScaleTextStyles.textAccent.apply(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (userAccount.permissions.contains(Permissions.manageTelemonitoringDevices)) ...[
                const SliverGap(Dimensions.padding24),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: Paddings.horizontal16,
                    child: HighlightedElevatedButton(
                      label: localization.user_detail_screen_register_device_button,
                      buttonType: ButtonType.primary,
                      onPressed: () {
                        GoRouter.of(context).pushNamed<DeviceCreateModel?>(
                          DeviceSearchRoute.name,
                          pathParameters: {
                            'userId': userAccount.id.toString(),
                            'devicePurpose': DevicePurpose.registerDevice.name,
                          },
                        ).then((final DeviceCreateModel? device) {
                          if (device != null) {
                            GoRouter.of(context).pushNamed(
                              RegisterDeviceDetailRoute.name,
                              pathParameters: {
                                'userId': userAccount.id.toString(),
                              },
                              extra: device,
                            );
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
              if (userAccount.parentId == null) ...[
                const SliverGap(Dimensions.padding24),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: Paddings.horizontal16,
                    child: HighlightedElevatedButton(
                      label: localization.user_detail_screen_remove_account,
                      buttonType: ButtonType.alert,
                      onPressed: () async {
                        showAccountRemovalConfirmation(
                          context: context,
                          accountName: userAccount.fullName,
                        ).then((confirmed) {
                          if (confirmed) {
                            GoRouter.of(context).pop();
                            getIt<AuthBloc>().add(LogoutUser(userAccount: userAccount));
                          }
                        });
                      },
                    ),
                  ),
                ),
                const SliverGap(Dimensions.padding16),
              ],
            ],
          ),
          BlocBuilder<LoaderCubit, LoaderState>(
            bloc: loaderCubit,
            builder: ((context, state) {
              final widget = state.when(
                loaded: SizedBox.shrink,
                loading: LoadingIndicator.new,
              );

              return Align(alignment: Alignment.center, child: widget);
            }),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: userAccount.fullName,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
