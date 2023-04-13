import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';

part 'times_settings_event.freezed.dart';

@freezed
class TimesSettingsEvent with _$TimesSettingsEvent {
  const factory TimesSettingsEvent.init(CarePlan carePlan) = _Init;
  const factory TimesSettingsEvent.setTime({
    required CarePlan carePlan,
    required DailyTime newStartTime,
    required DailyTime newEndTime,
    required TimingDayWhen timingDayWhen,
  }) = _SetTime;
  const factory TimesSettingsEvent.resetTimes(CarePlan carePlan) = _ResetTimes;
}
