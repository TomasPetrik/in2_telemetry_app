import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/timing_day_when_contract.dart';

part 'times_settings_event.freezed.dart';

@freezed
class TimesSettingsEvent with _$TimesSettingsEvent {
  const factory TimesSettingsEvent.init(CarePlanContract carePlan) = _Init;
  const factory TimesSettingsEvent.setTime({
    required CarePlanContract carePlan,
    required TimeOfDayContract newStartTime,
    required TimeOfDayContract newEndTime,
    required TimingDayWhenContract timingDayWhen,
  }) = _SetTime;
  const factory TimesSettingsEvent.resetTimes(CarePlanContract carePlan) = _ResetTimes;
}
