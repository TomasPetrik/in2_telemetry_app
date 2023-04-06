import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class UserWarningItem extends StatelessWidget {
  const UserWarningItem({
    super.key,
    required this.userProblemType,
    required this.userAccount,
  });

  final UserProblemType userProblemType;
  final UserAccount userAccount;

  @override
  Widget build(BuildContext context) {
    if (userProblemType == UserProblemType.sessionExpired) {
      return WarningItem(
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
      );
    } else if (userProblemType == UserProblemType.lastSyncFailed) {
      return WarningItem(
        title: translactions.sync_widget_sync_failed_title,
        description: userAccount.lastSyncAt != null
            ? translactions.sync_widget_sync_failed_desc(
                userAccount.lastSyncAt!.toDateOrDay(context),
                userAccount.lastSyncAt!.toTimeOfDay().toString(),
              )
            : '',
        buttonLabel: translactions.common_do_sync,
        icon: SvgPicture.asset(
          'assets/icons/icon_triangle_exclamation_medium.svg',
          color: Theme.of(context).colorScheme.error,
        ),
        onTap: () {
          getIt<SyncBloc>().add(
            const SyncEvent.syncAll(),
          );
        },
      );
    } else if (userProblemType == UserProblemType.syncResultsFailed) {
      return WarningItem(
        title: translactions.sync_widget_sync_results_failed_title,
        description: translactions.sync_widget_sync_results_failed_desc,
        buttonLabel: translactions.common_do_sync,
        icon: SvgPicture.asset(
          'assets/icons/icon_triangle_exclamation_medium.svg',
          color: Theme.of(context).colorScheme.error,
        ),
        onTap: () {
          getIt<SyncBloc>().add(
            const SyncEvent.syncAll(),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
