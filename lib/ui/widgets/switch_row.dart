import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_switch.dart';

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.height,
    required this.title,
    this.label,
    required this.onChanged,
    this.defaultValue,
  });

  final double height;
  final String title;
  final String? label;
  final Function(bool turnedOn) onChanged;
  final bool? defaultValue;

  factory SwitchRow.title({
    required String title,
    required Function(bool turnedOn) onChanged,
    bool? defaultValue,
  }) {
    return _TitleSwitchRow(
      height: Dimensions.singleLineSwitchRowHeight,
      title: title,
      onChanged: onChanged,
      defaultValue: defaultValue,
    );
  }

  factory SwitchRow.text({
    required String title,
    required Function(bool turnedOn) onChanged,
    bool? defaultValue,
  }) {
    return _TextSwitchRow(
      height: Dimensions.singleLineSwitchRowHeight,
      title: title,
      onChanged: onChanged,
      defaultValue: defaultValue,
    );
  }

  factory SwitchRow.titleAndLabel({
    required String title,
    required String label,
    required Function(bool turnedOn) onChanged,
    required bool defaultValue,
  }) {
    return _MultiLineSwitchRow(
      height: Dimensions.doubleLineSwitchRowHeight,
      title: title,
      label: label,
      onChanged: onChanged,
      defaultValue: defaultValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Text(
              translactions.notifications_screen_10_min_before_measurement,
              style: ScaleTextStyles.text.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          CupertinoSwitch(
            onChanged: onChanged,
            value: false,
          ),
        ],
      ),
    );
  }
}

class _TitleSwitchRow extends SwitchRow {
  const _TitleSwitchRow({
    required double height,
    required String title,
    required Function(bool turnedOn) onChanged,
    bool? defaultValue,
  }) : super(
          height: height,
          title: title,
          onChanged: onChanged,
          defaultValue: defaultValue,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: ScaleTextStyles.textAccent.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          Gaps.gap16,
          ScaleSwitch(
            onChanged: onChanged,
            value: defaultValue ?? false,
          ),
        ],
      ),
    );
  }
}

class _TextSwitchRow extends SwitchRow {
  const _TextSwitchRow({
    required double height,
    required String title,
    required Function(bool turnedOn) onChanged,
    bool? defaultValue,
  }) : super(
          height: height,
          title: title,
          onChanged: onChanged,
          defaultValue: defaultValue,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: ScaleTextStyles.text.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          Gaps.gap16,
          ScaleSwitch(
            onChanged: onChanged,
            value: defaultValue ?? false,
          ),
        ],
      ),
    );
  }
}

class _MultiLineSwitchRow extends SwitchRow {
  const _MultiLineSwitchRow({
    required double height,
    required String title,
    required String label,
    required Function(bool turnedOn) onChanged,
    required bool defaultValue,
  }) : super(
          height: height,
          title: title,
          label: label,
          onChanged: onChanged,
          defaultValue: defaultValue,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ScaleTextStyles.text.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Gaps.gap6,
                Text(
                  label ?? '',
                  style: ScaleTextStyles.label.apply(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          Gaps.gap16,
          ScaleSwitch(
            onChanged: onChanged,
            value: defaultValue ?? false,
          ),
        ],
      ),
    );
  }
}
