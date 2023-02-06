import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class SyncItem extends StatelessWidget {
  const SyncItem({
    super.key,
    required this.syncState,
    this.onRefresh,
  });

  final SyncState syncState;
  final VoidCallback? onRefresh;

  Color _getLeadinIconColor(BuildContext context) {
    return syncState.when(
      none: () => Theme.of(context).colorScheme.onTertiary,
      inProgress: () => Theme.of(context).colorScheme.onError,
      synced: () => Theme.of(context).colorScheme.onTertiary,
      failed: () => Theme.of(context).colorScheme.error,
    );
  }

  String _getLeadinIconPath(BuildContext context) {
    return syncState.when(
      none: () => 'assets/icons/icon_check.svg',
      inProgress: () => 'assets/icons/icon_loader.svg',
      synced: () => 'assets/icons/icon_check.svg',
      failed: () => 'assets/icons/icon_triangle_exclamation.svg',
    );
  }

  String _getLabel(BuildContext context) {
    return syncState.when(
      none: () => context.locale.sync_widget_synced,
      inProgress: () => context.locale.sync_widget_sync_in_progress,
      synced: () => context.locale.sync_widget_synced,
      failed: () => context.locale.sync_widget_sync_failed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final failedRefreshIconPath = syncState.whenOrNull(
      failed: () => 'assets/icons/icon_rotate.svg',
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadii.radius16,
      ),
      padding: Paddings.all16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            _getLeadinIconPath(
              context,
            ),
            color: _getLeadinIconColor(context),
          ),
          Gaps.gap16,
          Expanded(
            child: Text(
              _getLabel(context),
              style: ScaleTextStyles.text.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          if (failedRefreshIconPath != null)
            InkWell(
              onTap: onRefresh,
              child: SvgPicture.asset(
                failedRefreshIconPath,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
