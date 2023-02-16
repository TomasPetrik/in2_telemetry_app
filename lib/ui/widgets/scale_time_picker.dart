import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class ScaleTimePicker extends StatefulWidget {
  const ScaleTimePicker({
    super.key,
  });

  @override
  State<ScaleTimePicker> createState() => _ScaleTimePickerState();
}

class _ScaleTimePickerState extends State<ScaleTimePicker> {
  late int maxHour;
  late int maxMinute;
  late DateTime currentDateTime;
  int? selectedHour;
  int? selectedMinute;

  @override
  void initState() {
    currentDateTime = DateTime.now();
    maxHour = currentDateTime.hour;
    maxMinute = currentDateTime.minute;
    selectedHour = maxHour;
    selectedMinute = maxMinute;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(RadiusSize.radius16),
          topRight: Radius.circular(RadiusSize.radius16),
        ),
      ),
      padding: Paddings.all16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  GoRouter.of(context).pop(null);
                },
                child: Text(
                  context.locale.common_cancel,
                  style: ScaleTextStyles.text.apply(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final dateTime = DateTime.now().copyWith(
                    hour: selectedHour,
                    minute: selectedMinute,
                  );
                  GoRouter.of(context).pop(dateTime);
                },
                child: Text(
                  context.locale.common_confirm,
                  style: ScaleTextStyles.text.apply(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 33,
                    scrollController:
                        FixedExtentScrollController(initialItem: maxHour),
                    onSelectedItemChanged: (value) {
                      selectedHour = value;
                      if (value < maxHour) {
                        maxMinute = 60;
                      } else {
                        maxMinute = currentDateTime.minute;
                      }
                      setState(() {});
                    },
                    children: List.generate(
                      maxHour + 1,
                      (index) => Center(
                        child: Text(
                          '$index'.padLeft(2, '0'),
                          style: ScaleTextStyles.title.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(':'),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 33,
                    scrollController:
                        FixedExtentScrollController(initialItem: maxMinute),
                    onSelectedItemChanged: (value) {
                      selectedMinute = value;
                    },
                    children: List.generate(
                      maxMinute + 1,
                      (index) => Center(
                        child: Text(
                          '$index'.padLeft(2, '0'),
                          style: ScaleTextStyles.title.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
