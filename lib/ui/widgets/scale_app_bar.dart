import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class ScaleAppBar extends StatelessWidget {
  const ScaleAppBar({
    super.key,
    required this.title,
    this.subTitle,
    this.showClose = false,
    this.onBackTap,
    this.onCloseTap,
    this.onActionTap,
    this.actionLabel,
  });

  final String title;
  final String? subTitle;
  final String? actionLabel;
  final bool showClose;
  final VoidCallback? onBackTap;
  final VoidCallback? onCloseTap;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top,
      ),
      child: SizedBox(
        height: subTitle == null
            ? Constants.appBarHeight
            : Constants.twoLinedBarHeight,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.padding16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: onBackTap != null
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    onBackTap?.call();
                                    Navigator.of(context).pop();
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/icon_back.svg',
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : onActionTap != null && actionLabel != null
                                  ? TextButton(
                                      onPressed: () {
                                        onActionTap?.call();
                                      },
                                      child: Text(
                                        actionLabel!,
                                        style: ScaleTextStyles.text.apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: ScaleTextStyles.textAccent.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          child: showClose
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    onCloseTap?.call();
                                    GoRouter.of(context).pop();
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/icon_close.svg',
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  if (subTitle != null) ...[
                    Gaps.gap4,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subTitle!,
                            style: ScaleTextStyles.label.apply(
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
