import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/care_plan_detail_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/care_plan_item.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/notification_item.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/sliver_name_value_row.dart';
import 'package:scalesoft_app/ui/widgets/sync_process_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class UserDetailScreen extends StatelessWidget with BottomSheetMixin {
  const UserDetailScreen({
    super.key,
    required this.userAccount,
  });

  final UserAccount userAccount;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      bloc: getIt<SyncBloc>(),
      builder: (context, state) {
        final warningInner = state.whenOrNull(
          inProgress: () => SyncProcessItem(
            syncProcessType: SyncProcessType.inProgress,
            label: context.locale.sync_widget_sync_in_progress,
          ),
          synced: () => SyncProcessItem(
            syncProcessType: SyncProcessType.done,
            label: context.locale.sync_widget_synced,
          ),
          userSessionExpired: (userAccount) => WarningItem(
            title: context.locale.session_expired_title,
            description: context.locale.session_expired_description(
              userAccount.user.fullName,
            ),
            buttonLabel: context.locale.common_log_in,
            icon: SvgPicture.asset(
              'assets/icons/icon_triangle_exclamation_medium.svg',
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () {
              getIt<AuthBloc>().add(
                Authenticate(
                  hospital: userAccount.hospital!,
                ),
              );
            },
          ),
          syncUserDataFailed: (lastSync) => WarningItem(
            title: context.locale.sync_widget_sync_failed_title,
            description: lastSync != null
                ? context.locale.sync_widget_sync_failed_desc(
                    lastSync.toDateOrDay(context),
                    lastSync.toTimeOfDay().toString(),
                  )
                : '',
            buttonLabel: context.locale.common_do_sync,
            icon: SvgPicture.asset(
              'assets/icons/icon_triangle_exclamation_medium.svg',
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () {
              getIt<SyncBloc>().add(
                const SyncEvent.syncAll(),
              );
            },
          ),
          userResultsFailed: (measurements, lasySync) => WarningItem(
            title: context.locale.sync_widget_sync_results_failed_title,
            description: context.locale.sync_widget_sync_results_failed_desc,
            buttonLabel: context.locale.common_do_sync,
            icon: SvgPicture.asset(
              'assets/icons/icon_triangle_exclamation_medium.svg',
              color: Theme.of(context).colorScheme.error,
            ),
            onTap: () {
              getIt<SyncBloc>().add(
                const SyncEvent.syncAll(),
              );
            },
          ),
        );

        final userWarning = warningInner != null
            ? SliverPadding(
                padding: const EdgeInsets.only(
                  left: Dimensions.padding16,
                  right: Dimensions.padding16,
                  bottom: Dimensions.padding24,
                ),
                sliver: warningInner,
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
                        Constants.appBarHeight,
                  ),
                  const SliverGap(Dimensions.padding16),
                  userWarning,
                  if (userAccount.carePlans?.isNotEmpty == true) ...[
                    SliverPadding(
                      padding: Paddings.left16,
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          context.locale.user_detail_screen_measurement_plans,
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
                                    extra: carePlan,
                                  );
                                },
                                child: Padding(
                                  padding: Paddings.horizontal16,
                                  child: CarePlanItem(
                                    carePlan: carePlan,
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
                        context.locale.user_detail_screen_user_info,
                        style: ScaleTextStyles.textAccent.apply(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SliverGap(Dimensions.padding24),
                  SliverNameValueRow(
                    name: context.locale.user_detail_screen_user_name,
                    value: userAccount.user.firstNames[0],
                  ),
                  const SliverGap(Dimensions.padding8),
                  SliverNameValueRow(
                    name: context.locale.user_detail_screen_user_surname,
                    value: userAccount.user.lastNames[0],
                  ),
                  if (userAccount.user.phoneNumbers?.isNotEmpty == true) ...[
                    const SliverGap(Dimensions.padding8),
                    SliverNameValueRow(
                      name: context.locale.user_detail_screen_user_phone,
                      value: userAccount.user.phoneNumbers![0],
                    ),
                  ],
                  if (userAccount.user.emailAddresses?.isNotEmpty == true) ...[
                    const SliverGap(Dimensions.padding8),
                    SliverNameValueRow(
                      name: context.locale.user_detail_screen_user_email,
                      value: userAccount.user.emailAddresses![0],
                    ),
                  ],
                  if (userAccount.parentId == null) ...[
                    const SliverGap(Dimensions.padding24),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: Paddings.horizontal16,
                        child: HighlightedElevatedButton(
                          label:
                              context.locale.user_detail_screen_remove_account,
                          buttonType: ButtonType.alert,
                          onPressed: () async {
                            final confirmed =
                                await showAccounRemovalConfirmation(
                              context: context,
                              accountName: userAccount.user.fullName,
                            );

                            if (confirmed == true) {
                              getIt<AuthBloc>()
                                  .add(LogoutUser(userAccount: userAccount));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ScaleAppBar(
                      title: userAccount.user.fullName,
                      onBackTap: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
