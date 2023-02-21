import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/rotating_icon.dart';

class SyncProcessItem extends StatelessWidget {
  const SyncProcessItem({
    super.key,
    required this.syncProcessType,
    required this.label,
    this.desc,
    this.onRefresh,
  });

  final SyncProcessType syncProcessType;
  final String label;
  final String? desc;
  final VoidCallback? onRefresh;

  Color _getLeadinIconColor(BuildContext context) {
    switch (syncProcessType) {
      case SyncProcessType.done:
        return Theme.of(context).colorScheme.onTertiary;
      case SyncProcessType.inProgress:
        return Theme.of(context).colorScheme.onError;
      case SyncProcessType.error:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getLeadinIconPath(BuildContext context) {
    switch (syncProcessType) {
      case SyncProcessType.done:
        return 'assets/icons/icon_check.svg';
      case SyncProcessType.inProgress:
        return 'assets/icons/icon_loader.svg';
      case SyncProcessType.error:
        return 'assets/icons/icon_triangle_exclamation.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final failedRefreshIconPath = syncProcessType == SyncProcessType.error
        ? 'assets/icons/icon_rotate.svg'
        : null;

    final iconWidget = SvgPicture.asset(
      _getLeadinIconPath(
        context,
      ),
      color: _getLeadinIconColor(context),
    );

    return SliverToBoxAdapter(
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onBackground,
            borderRadius: BorderRadii.radius16,
          ),
          padding: Paddings.all16,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (syncProcessType == SyncProcessType.inProgress)
                RotatingIcon(child: iconWidget)
              else
                iconWidget,
              Gaps.gap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    if (desc != null) ...[
                      Gaps.gap6,
                      Text(
                        desc!,
                        style: ScaleTextStyles.label.apply(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ],
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
        ),
      ),
    );
  }
}

enum SyncProcessType {
  done,
  inProgress,
  error,
}
