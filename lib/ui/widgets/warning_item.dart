import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';

class WarningItem extends StatelessWidget {
  const WarningItem({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.buttonType = SmallButtonType.regular,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final SmallButtonType buttonType;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _WarningItem(
      title: title,
      description: description,
      buttonLabel: buttonLabel,
      buttonType: buttonType,
      icon: icon,
      onTap: onTap,
    );
  }
}

class _WarningItem extends WarningItem {
  const _WarningItem({
    required String title,
    required String description,
    required String buttonLabel,
    required SmallButtonType buttonType,
    required Widget icon,
    required VoidCallback onTap,
  }) : super(
          title: title,
          description: description,
          buttonLabel: buttonLabel,
          buttonType: buttonType,
          icon: icon,
          onTap: onTap,
        );

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ScaleCard(
        child: Container(
          padding: Paddings.all16,
          decoration: BoxDecoration(
            borderRadius: BorderRadii.radius16,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          label: buttonLabel,
                          onTap: onTap,
                          isSelected: buttonType == SmallButtonType.regular,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum SmallButtonType {
  none,
  regular,
}
