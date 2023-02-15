import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/widgets/notification_item.dart';
import 'package:scalesoft_app/ui/widgets/sync_process_item.dart';
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
      syncUserDataFailed: (lastSync) => SyncProcessItem(
        syncProcessType: SyncProcessType.error,
        label: context.locale.sync_widget_sync_failed_title,
        desc: lastSync != null
            ? context.locale.sync_widget_sync_failed_desc(
                lastSync.toDateOrDay(context),
                lastSync.toTimeOfDay().toString(),
              )
            : null,
        onRefresh: onRefresh,
      ),
      syncSomeUsersDataFailed: () => SyncProcessItem(
        syncProcessType: SyncProcessType.error,
        label: context.locale.sync_widget_sync_failed_title,
        onRefresh: onRefresh,
      ),
      userResultsFailed: (measurements, lastSync) => SyncProcessItem(
        syncProcessType: SyncProcessType.error,
        label: context.locale.sync_widget_sync_failed_title,
        desc: lastSync != null
            ? context.locale.sync_widget_sync_failed_desc(
                lastSync.toDateOrDay(context),
                lastSync.toTimeOfDay().toString(),
              )
            : null,
        onRefresh: onRefresh,
      ),
      someUsersResultsFailed: (measurements) => SyncProcessItem(
        syncProcessType: SyncProcessType.error,
        label: context.locale.sync_widget_sync_failed_title,
        onRefresh: onRefresh,
      ),
      userCarePlanChanged: (carePlan) => WarningItem(
        title: context.locale.notification_widget_plan_changed_title,
        description: context.locale.notification_widget_plan_changed_desc(
          context.locale.common_measurement_types_genitive(
            carePlan.activity.measurementType.name,
          ),
        ),
        buttonLabel: context.locale.common_do_sync,
        icon: SvgPicture.asset(
          'assets/icons/icon_circle_exclamation.svg',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        onTap: () {
          getIt<SyncBloc>().add(SyncEvent.resolveUpdatedPlan(carePlan));
        },
      ),
      someUsersCarePlanChanged: (userAccount, carePlan) => WarningItem(
        title: context.locale.notification_widget_plan_changed_title,
        description:
            context.locale.notification_widget_plan_changed_for_user_desc(
          userAccount.user.fullName,
          context.locale.common_measurement_types_genitive(
            carePlan.activity.measurementType.name,
          ),
        ),
        buttonLabel: context.locale.common_do_sync,
        icon: SvgPicture.asset(
          'assets/icons/icon_circle_exclamation.svg',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        onTap: () {
          getIt<SyncBloc>().add(SyncEvent.resolveUpdatedPlan(carePlan));
        },
      ),
    );
  }
}
