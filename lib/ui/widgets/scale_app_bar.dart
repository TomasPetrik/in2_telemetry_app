import 'package:flutter/material.dart';
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
  });

  final String title;
  final String? subTitle;
  final bool showClose;
  final VoidCallback? onBackTap;
  final VoidCallback? onCloseTap;

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
                        const SizedBox(
                          width: 56,
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
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
                                  icon: Icon(
                                    Icons.close,
                                    color: Theme.of(context).primaryColor,
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
            if (onBackTap != null)
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    onBackTap?.call();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
