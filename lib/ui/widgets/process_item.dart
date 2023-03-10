import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/rotating_icon.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';

class ProcessItem extends StatelessWidget {
  const ProcessItem({
    super.key,
    required this.processType,
    required this.label,
    this.desc,
    this.onRefresh,
    this.onTap,
  });

  final ProcessType processType;
  final String label;
  final String? desc;
  final VoidCallback? onRefresh;
  final VoidCallback? onTap;

  Color _getLeadinIconColor(BuildContext context) {
    switch (processType) {
      case ProcessType.done:
        return Theme.of(context).colorScheme.onTertiary;
      case ProcessType.inProgress:
        return Theme.of(context).colorScheme.onError;
      case ProcessType.connected:
        return Theme.of(context).colorScheme.onTertiary;
      case ProcessType.error:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getLeadinIconPath(BuildContext context) {
    switch (processType) {
      case ProcessType.done:
        return 'assets/icons/icon_check.svg';
      case ProcessType.inProgress:
        return 'assets/icons/icon_loader.svg';
      case ProcessType.connected:
        return 'assets/icons/icon_bluetooth_on.svg';
      case ProcessType.error:
        return 'assets/icons/icon_triangle_exclamation.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final failedRefreshIconPath = processType == ProcessType.error
        ? 'assets/icons/icon_rotate.svg'
        : null;

    final iconWidget = SvgPicture.asset(
      _getLeadinIconPath(
        context,
      ),
      color: _getLeadinIconColor(context),
    );

    return SliverToBoxAdapter(
      child: InkWell(
        onTap: () => onTap?.call(),
        child: ScaleCard(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onBackground,
              borderRadius: BorderRadii.radius16,
            ),
            padding: Paddings.all16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (processType == ProcessType.inProgress)
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
      ),
    );
  }
}

enum ProcessType {
  done,
  inProgress,
  connected,
  error,
}
