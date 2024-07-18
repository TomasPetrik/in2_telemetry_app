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
import 'package:scalesoft_app/ui/routers/routes/setup_watch_route.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class SyncItem extends StatelessWidget {
  const SyncItem({
    super.key,
    required this.syncState,
    required this.onRefresh,
  });

  final SyncState syncState;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return syncState.when(
      none: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      inProgress: () => ProcessItem(
        processType: ProcessType.inProgress,
        label: localization.sync_widget_sync_in_progress,
      ),
      synced: () => ProcessItem(
        processType: ProcessType.done,
        label: localization.sync_widget_synced,
      ),
      userSessionExpired: (userAccount) => WarningItem(
        title: localization.session_expired_title,
        description: localization.session_expired_description(
          userAccount.fullName,
        ),
        buttonLabel: localization.common_log_in,
        icon: SvgPicture.asset(
          'assets/icons/icon_triangle_exclamation_medium.svg',
          color: Theme.of(context).colorScheme.error,
        ),
        onTap: () {
          getIt<AuthBloc>().add(
            Authenticate(
              hospital: userAccount.hospital,
            ),
          );
        },
      ),
      syncUserDataFailed: (offlineResults, lastSync) => ProcessItem(
        processType: ProcessType.error,
        label: localization.sync_widget_sync_failed_title,
        desc: lastSync != null
            ? localization.sync_widget_sync_failed_desc(
                lastSync.toDateOrDay().toLowerCase(),
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
        label: localization.sync_widget_sync_failed_title,
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
        label: localization.sync_widget_sync_failed_title,
        desc: lastSync != null
            ? localization.sync_widget_sync_failed_desc(
                lastSync.toDateOrDay().toLowerCase(),
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
        label: localization.sync_widget_sync_failed_title,
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
        title: localization.notification_widget_plan_changed_title,
        description: localization.notification_widget_plan_changed_desc(
          localization
              .common_measurement_types_genitive(
                carePlan.activity.measurementType.name,
              )
              .toLowerCase(),
        ),
        buttonLabel: localization.common_understand,
        icon: SvgPicture.asset(
          'assets/icons/icon_circle_exclamation_medium.svg',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        buttonType: SmallButtonType.none,
        onTap: () {
          getIt<SyncBloc>().add(SyncEvent.resolveUpdatedUserPlan(carePlan.id));
        },
      ),
      someUsersCarePlanChanged: (userAccount, carePlan) => WarningItem(
        title: localization.notification_widget_plan_changed_title,
        description:
            localization.notification_widget_plan_changed_for_user_desc(
          userAccount.fullName,
          localization.common_measurement_types_genitive(
            carePlan.activity.measurementType.name,
          ),
        ),
        buttonLabel: localization.common_understand,
        icon: SvgPicture.asset(
          'assets/icons/icon_circle_exclamation_medium.svg',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        buttonType: SmallButtonType.none,
        onTap: () {
          getIt<SyncBloc>().add(SyncEvent.resolveUpdatedUserPlan(carePlan.id));
        },
      ),
      newWatchAssigned: () => WarningItem(
        title: localization.new_watch_assigned_title,
        description: localization.new_watch_assigned_description,
        buttonLabel: localization.dialog_req_localization_service_go_to_settings,
        icon: SvgPicture.asset(
          'assets/icons/icon_circle_exclamation_medium.svg',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        // buttonType: SmallButtonType.none,
        onTap: () {
          GoRouter.of(context).pushNamed(SetupWatchRoute.name);
        },
      ),
    );
  }
}
