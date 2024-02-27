import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/time_settings/timing_day_when_contract.dart';

part 'times_settings_state.freezed.dart';

@freezed
class TimesSettingsState with _$TimesSettingsState {
  const factory TimesSettingsState.loading() = _Loading;
  const factory TimesSettingsState.isNotAvailable() = _IsNotAvailable;

  const factory TimesSettingsState.data({
    required DateTime dateTime,
    required List<WhenTimeValue> templateWhenValues,
    required List<TimingDayWhenContract> timingsDayWhen,
  }) = _Updated;
  const factory TimesSettingsState.errorUpdate(DateTime dateTime) =
      _ErrorUpdate;
}
