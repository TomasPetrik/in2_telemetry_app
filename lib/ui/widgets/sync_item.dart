import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/offline_results_route.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class SyncItem extends StatelessWidget {
    const SyncItem({
    super.key,
    required this.syncState,
    this.onRefresh,
  });

  final SyncState syncState;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return syncState.when(
      none: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      inProgress: () => ProcessItem(
        processType: ProcessType.inProgress,
        label: translactions.sync_widget_sync_in_progress,
      ),
      synced: () => ProcessItem(
        processType: ProcessType.done,
        label: translactions.sync_widget_synced,
      ),
      userSessionExpired: (userAccount) => WarningItem(
        title: translactions.session_expired_title,
        description: translactions.session_expired_description(
          userAccount.user.fullName,
        ),
        buttonLabel: translactions.common_log_in,
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
      syncUserDataFailed: (offlineResults, lastSync) => ProcessItem(
        processType: ProcessType.error,
        label: translactions.sync_widget_sync_failed_title,
        desc: lastSync != null
            ? translactions.sync_widget_sync_failed_desc(
                lastSync.toDateOrDay(context),
                lastSync.toTimeOfDay().toString(),
              )
            : null,
        onRefresh: onRefresh,
        onTap: offlineResults == null
            ? null
            : () {
                GoRouter.of(context).pushNamed(
                  OfflineResultsRoute.name,
                );
              },
      ),
      syncSomeUsersDataFailed: (offlineResults) => ProcessItem(
        processType: ProcessType.error,
        label: translactions.sync_widget_sync_failed_title,
        onRefresh: onRefresh,
        onTap: offlineResults == null
            ? null
            : () {
                GoRouter.of(context).pushNamed(
                  OfflineResultsRoute.name,
                );
              },
      ),
      userResultsFailed: (offlineResults, lastSync) => ProcessItem(
        processType: ProcessType.error,
        label: translactions.sync_widget_sync_failed_title,
        desc: lastSync != null
            ? translactions.sync_widget_sync_failed_desc(
                lastSync.toDateOrDay(context),
                lastSync.toTimeOfDay().toString(),
              )
            : null,
        onRefresh: onRefresh,
        onTap: offlineResults == null
            ? null
            : () {
                GoRouter.of(context).pushNamed(
                  OfflineResultsRoute.name,
                );
              },
      ),
      someUsersResultsFailed: (offlineResults) => ProcessItem(
        processType: ProcessType.error,
        label: translactions.sync_widget_sync_failed_title,
        onRefresh: onRefresh,
        onTap: offlineResults == null
            ? null
            : () {
                GoRouter.of(context).pushNamed(
                  OfflineResultsRoute.name,
                );
              },
      ),
      userCarePlanChanged: (carePlan) => WarningItem(
        title: translactions.notification_widget_plan_changed_title,
        description: translactions.notification_widget_plan_changed_desc(
          translactions
              .common_measurement_types_genitive(
                carePlan.activity.measurementType.name,
              )
              .toLowerCase(),
        ),
        buttonLabel: translactions.common_understand,
        icon: SvgPicture.asset(
          'assets/icons/icon_circle_exclamation_medium.svg',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        buttonType: SmallButtonType.none,
        onTap: () {
          getIt<SyncBloc>().add(SyncEvent.resolveUpdatedUserPlan(carePlan));
        },
      ),
      someUsersCarePlanChanged: (userAccount, carePlan) => WarningItem(
        title: translactions.notification_widget_plan_changed_title,
        description:
            translactions.notification_widget_plan_changed_for_user_desc(
          userAccount.user.fullName,
          translactions.common_measurement_types_genitive(
            carePlan.activity.measurementType.name,
          ),
        ),
        buttonLabel: translactions.common_understand,
        icon: SvgPicture.asset(
          'assets/icons/icon_circle_exclamation_medium.svg',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        buttonType: SmallButtonType.none,
        onTap: () {
          getIt<SyncBloc>().add(SyncEvent.resolveUpdatedUserPlan(carePlan));
        },
      ),
    );
  }
}
