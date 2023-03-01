import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/dto/care_plan/when_time_value.dart';

part 'times_settings_state.freezed.dart';

@freezed
class TimesSettingsState with _$TimesSettingsState {
  const factory TimesSettingsState.loading() = _Loading;
  const factory TimesSettingsState.isNotAvailable() = _IsNotAvailable;
  

  const factory TimesSettingsState.data({
    required DateTime dateTime,
    required List<WhenTimeValue> templateWhenValues,
    required List<TimingDayWhen> timingsDayWhen,
  }) = _Updated;
  const factory TimesSettingsState.errorUpdate(DateTime dateTime) = _ErrorUpdate;
  
}
