import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:accordion/accordion.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ConnectionLevel extends StatelessWidget {
  const ConnectionLevel({
    super.key,
    required this.label,
    this.extraText,
    required this.iconPath,
    required this.isDone,
    required this.activeIndex,
    required this.index
  });

  final String label;
  final String? extraText;
  final String iconPath;
  final bool isDone;
  final int activeIndex;
  final int index;

@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Accordion(
        headerBackgroundColor: Theme.of(context).colorScheme.secondary,
        headerBorderColor: Theme.of(context).colorScheme.primary,
        contentBackgroundColor: Theme.of(context).colorScheme.secondary,
        contentBorderColor: Theme.of(context).colorScheme.secondary,
        paddingBetweenClosedSections: 0,
        disableScrolling: true,
        scaleWhenAnimating: false,
        headerPadding: const EdgeInsets.all(10),
        paddingListBottom: 0,
        children: [
          AccordionSection(
            isOpen: activeIndex + 1 == index  && (extraText != null && extraText!.isNotEmpty),
            header: Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  color: isDone
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context).colorScheme.tertiary,
                ),
                Gaps.gap16,
                Expanded(
                  child: Text(
                    label,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: Container(
              height: 100,
              child: Html(
                data: extraText ?? "",
                ),
                ),
          ),
        ],
      ),
    ],
  );
}
}