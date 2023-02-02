import 'package:flutter/material.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';

class WarningItem extends StatelessWidget {
  const WarningItem({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.onTap,
  });

  final String title;
  final String description;
  final Widget? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: Paddings.all16,
        margin: Paddings.horizontal16,
        decoration: BoxDecoration(
          borderRadius: BorderRadii.radius16,
          color: Theme.of(context).colorScheme.onBackground,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              //icon_triangle_exclamation
              Container(
                height: 64,
                width: 64,
                padding: Paddings.all14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadii.radius8,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: icon,
              ),
              Gaps.gap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ScaleTextStyles.textAccent.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Gaps.gap16,
                    Text(
                      description,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Gaps.gap16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        NavigationTabChip(
                          label: context.locale.common_log_in,
                          onTap: onTap,
                          isSelected: true,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
