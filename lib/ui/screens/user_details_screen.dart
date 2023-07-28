import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/care_plan_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/register_device_search_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/care_plan_item.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/sliver_name_value_row.dart';
import 'package:scalesoft_app/ui/widgets/user_warning_item.dart';

class UserDetailScreen extends StatelessWidget with BottomSheetMixin {
  const UserDetailScreen({
    super.key,
    required this.userAccount,
  });

  final UserAccount userAccount;

  @override
  Widget build(BuildContext context) {
    final relevantProblems = [
      UserProblemType.sessionExpired,
      UserProblemType.lastSyncFailed,
      UserProblemType.syncResultsFailed
    ];

    return BlocBuilder<SyncBloc, SyncState>(
      bloc: getIt<SyncBloc>(),
      builder: (context, state) {
        //1. Show awalys sync in progress when possible
        final anyProgressWidget = state.whenOrNull(
          inProgress: () => ProcessItem(
            processType: ProcessType.inProgress,
            label: localization.sync_widget_sync_in_progress,
          ),
          synced: () => ProcessItem(
            processType: ProcessType.done,
            label: localization.sync_widget_synced,
          ),
        );

        //2. Otherwise check for high pioritised problem
        final userProblemType =
            getIt<Session>().getProblemIfExists(userAccount);

        Widget? userWarningWidget;
        if (anyProgressWidget != null) {
          userWarningWidget = anyProgressWidget;
        } else if (userProblemType != null &&
            relevantProblems.contains(userProblemType)) {
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

        return Material(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverGap(
                    MediaQuery.of(context).viewPadding.top +
                        Dimensions.appBarHeight,
                  ),
                  const SliverGap(Dimensions.padding16),
                  anyInfoWidget,
                  if (userAccount.carePlans?.isNotEmpty == true) ...[
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
                          final carePlan = userAccount.carePlans![index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  GoRouter.of(context).pushNamed(
                                    CarePlanDetailRoute.name,
                                    extra: carePlan.id,
                                  );
                                },
                                child: Padding(
                                  padding: Paddings.horizontal16,
                                  child: CarePlanItem(
                                    carePlan: carePlan,
                                    viewOwnMeasurementData:
                                        userAccount.viewOwnMeasurementData,
                                  ),
                                ),
                              ),
                              if (index != (userAccount.carePlans!.length - 1))
                                Gaps.gap16,
                            ],
                          );
                        },
                        childCount: userAccount.carePlans!.length,
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
                    value: userAccount.user.firstNames[0],
                  ),
                  const SliverGap(Dimensions.padding8),
                  SliverNameValueRow(
                    name: localization.user_detail_screen_user_surname,
                    value: userAccount.user.lastNames[0],
                  ),
                  if (userAccount.user.phoneNumbers?.isNotEmpty == true) ...[
                    const SliverGap(Dimensions.padding8),
                    SliverNameValueRow(
                      name: localization.user_detail_screen_user_phone,
                      value: userAccount.user.phoneNumbers![0],
                    ),
                  ],
                  if (userAccount.user.emailAddresses?.isNotEmpty == true) ...[
                    const SliverGap(Dimensions.padding8),
                    SliverNameValueRow(
                      name: localization.user_detail_screen_user_email,
                      value: userAccount.user.emailAddresses![0],
                    ),
                  ],
                  if (userAccount.canManageTelemonitoringDevices) ...[
                    const SliverGap(Dimensions.padding24),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Paddings.horizontal16,
                        child: HighlightedElevatedButton(
                          label: localization
                              .user_detail_screen_register_device_button,
                          buttonType: ButtonType.primary,
                          onPressed: () {
                            GoRouter.of(context).pushNamed(
                              RegisterDeviceSearchRoute.name,
                              params: {'userId': userAccount.user.muid},
                            );
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
                          label:
                              localization.user_detail_screen_remove_account,
                          buttonType: ButtonType.alert,
                          onPressed: () async {
                            showAccounRemovalConfirmation(
                              context: context,
                              accountName: userAccount.user.fullName,
                            ).then((confirmed) {
                              if (confirmed == true) {
                                GoRouter.of(context).pop();
                                getIt<AuthBloc>()
                                    .add(LogoutUser(userAccount: userAccount));
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
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: BluredScaleAppBar(
                  title: userAccount.user.fullName,
                  onBackTap: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
