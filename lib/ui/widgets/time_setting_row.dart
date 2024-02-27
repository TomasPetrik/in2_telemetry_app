import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/contracts/time_settings/timing_day_when_contract.dart';
import 'package:scalesoft_app/api/contracts/user/when_setting_contract.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/when_code_set.dart';

class TimeSettingRow extends StatefulWidget {
  const TimeSettingRow({
    super.key,
    required this.timingDayWhen,
    required this.templateWhenTime,
    required this.onNewStartTimeSet,
    required this.onNewEndTimeSet,
  });

  final TimingDayWhenContract timingDayWhen;
  final WhenTimeValue templateWhenTime;

  final Function(TimeOfDayContract dailyTime) onNewStartTimeSet;
  final Function(TimeOfDayContract dailyTime) onNewEndTimeSet;

  @override
  State<TimeSettingRow> createState() => _TimeSettingRowState();
}

class _TimeSettingRowState extends State<TimeSettingRow> with BottomSheetMixin {
  late TextEditingController startTimeTextController;
  late TextEditingController endTimeTextController;

  late TimeOfDayContract startDateTime;
  late TimeOfDayContract endDateTime;
  late WhenTimeValue whenTimeValue;
  late WhenTimeValue templateWhenTime;

  @override
  void initState() {
    startDateTime = widget.timingDayWhen.start;
    endDateTime = widget.timingDayWhen.end;
    startTimeTextController =
        TextEditingController(text: startDateTime.toString());
    endTimeTextController = TextEditingController(text: endDateTime.toString());
    templateWhenTime = widget.templateWhenTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WhenCodeSet(
            whenCode: widget.timingDayWhen.whenCode,
            defaultTime: startDateTime,
            minTime: templateWhenTime.userEditMin,
            maxTime: templateWhenTime.userEditMax,
            onNewTimeSet: widget.onNewStartTimeSet,
          ),
        ),
        Gaps.gap16,
        Expanded(
          child: WhenCodeSet(
            defaultTime: endDateTime,
            minTime: templateWhenTime.userEditMin,
            maxTime: templateWhenTime.userEditMax,
            onNewTimeSet: widget.onNewEndTimeSet,
          ),
        ),
      ],
    );
  }
}
