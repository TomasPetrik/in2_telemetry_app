import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/model/device_instruction_model.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:accordion/accordion.dart';

class ConnectionLevel extends StatelessWidget {
  const ConnectionLevel({
    super.key,
    required this.label,
    this.deviceInstruction,
    required this.iconPath,
    required this.isDone,
    required this.activeIndex,
    required this.index
  });

  final String label;
  final DeviceInstructionModel? deviceInstruction;
  final String iconPath;
  final bool isDone;
  final int activeIndex;
  final int index;

@override
Widget build(BuildContext context) {
  if (deviceInstruction != null) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Accordion(
        headerBackgroundColor: Theme.of(context).colorScheme.secondary,
        headerBorderColor: Theme.of(context).colorScheme.primary,
        contentBackgroundColor: Theme.of(context).colorScheme.secondary,
        contentBorderColor: Theme.of(context).colorScheme.secondary,
        paddingBetweenClosedSections: 0,
        paddingBetweenOpenSections: 0,
        disableScrolling: true,
        scaleWhenAnimating: false,
        headerPadding: const EdgeInsets.all(10),
        paddingListBottom: 0,
        rightIcon: (deviceInstruction?.instructionText != null && deviceInstruction!.instructionText.isNotEmpty) || (deviceInstruction?.image != null)
          ? const Icon(Icons.arrow_drop_down)
          : const SizedBox.shrink(),
        children: [
          AccordionSection(
            isOpen: activeIndex + 1 == index  && (deviceInstruction?.instructionText != null && deviceInstruction!.instructionText.isNotEmpty || deviceInstruction?.image != null),
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
            content: Column( 
              children: [
                SizedBox(
                  child: Html(
                  data: deviceInstruction?.instructionText ?? "",
                   style: {
                    "p": Style(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                   }
                  ),
                ),
                if (deviceInstruction?.image != null && deviceInstruction!.image!.isNotEmpty)
                  Image.memory(
                    deviceInstruction!.image!,
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    cacheHeight: 300,
                  ),
              ]
          ),
      )],
      ),
      ],
  );
} else {
  return Container(
    margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).colorScheme.secondary,
    ),
    child: 
      Column(
        children: [
          Row(
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
        ],
    )
  );
}
}
}