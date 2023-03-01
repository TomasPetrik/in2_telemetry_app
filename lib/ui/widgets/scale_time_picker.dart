import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class ScaleTimePicker extends StatefulWidget {
  const ScaleTimePicker({
    super.key,
    this.defaultTime,
    this.minTime,
    this.maxTime,
  });

  final DailyTime? defaultTime;
  final DailyTime? minTime;
  final DailyTime? maxTime;

  @override
  State<ScaleTimePicker> createState() => _ScaleTimePickerState();
}

class _ScaleTimePickerState extends State<ScaleTimePicker> {
  late int minHour;
  late int minMinute;
  late int maxHour;
  late int maxMinute;
  late DateTime currentDateTime;
  late int selectedHour;
  late int selectedMinute;
  late MinuteMode minuteMode;

  @override
  void initState() {
    currentDateTime = DateTime.now();

    if (widget.maxTime != null) {
      maxHour = widget.maxTime!.hour;
      maxMinute = widget.maxTime!.minute;
      minHour = widget.minTime!.hour;
      minMinute = widget.minTime!.minute;
    } else {
      maxHour = currentDateTime.hour;
      maxMinute = currentDateTime.minute;
      minHour = 0;
      minMinute = 0;
    }

    if (widget.defaultTime != null) {
      selectedHour = widget.defaultTime!.hour;
      selectedMinute = widget.defaultTime!.minute;
    } else {
      selectedHour = currentDateTime.hour;
      selectedMinute = currentDateTime.minute;
    }

    if (selectedHour == minHour) {
      minuteMode = MinuteMode.minMinute;
    } else if (selectedHour == maxHour) {
      minuteMode = MinuteMode.maxMinute;
    } else {
      minuteMode = MinuteMode.fullMinute;
    }
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
                  final minute = minuteMode == MinuteMode.maxMinute
                      ? selectedMinute
                      : minuteMode == MinuteMode.minMinute
                          ? selectedMinute + minMinute
                          : selectedMinute;
                  GoRouter.of(context).pop(DailyTime(selectedHour, minute, 0));
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
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedHour - minHour,
                    ),
                    onSelectedItemChanged: (index) {
                      selectedHour = minHour + index;
                      if (selectedHour == minHour) {
                        minuteMode = MinuteMode.minMinute;
                        maxMinute = 60;
                        minMinute =
                            widget.minTime?.minute ?? currentDateTime.minute;
                      } else if (selectedHour < maxHour) {
                        minuteMode = MinuteMode.fullMinute;
                      } else {
                        minuteMode = MinuteMode.maxMinute;
                        maxMinute =
                            widget.maxTime?.minute ?? currentDateTime.minute;
                      }
                      setState(() {});
                    },
                    children: List.generate(
                      maxHour - minHour + 1,
                      (index) => Center(
                        child: Text(
                          '${minHour + index}'.padLeft(2, '0'),
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
                    scrollController: FixedExtentScrollController(
                      initialItem: minuteMode == MinuteMode.maxMinute
                          ? selectedMinute
                          : minuteMode == MinuteMode.minMinute
                              ? selectedMinute - minMinute
                              : selectedMinute,
                    ),
                    onSelectedItemChanged: (index) {
                      selectedMinute = index;
                    },
                    children: minuteMode == MinuteMode.maxMinute
                        ? List.generate(
                            maxMinute + 1,
                            (index) => Center(
                              child: Text(
                                '$index'.padLeft(2, '0'),
                                style: ScaleTextStyles.title.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : minuteMode == MinuteMode.minMinute
                            ? List.generate(
                                60 - minMinute,
                                (index) => Center(
                                  child: Text(
                                    '${minMinute + index}'.padLeft(2, '0'),
                                    style: ScaleTextStyles.title.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : List.generate(
                                60,
                                (index) => Center(
                                  child: Text(
                                    '$index'.padLeft(2, '0'),
                                    style: ScaleTextStyles.title.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
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

enum MinuteMode {
  minMinute,
  maxMinute,
  fullMinute,
}
