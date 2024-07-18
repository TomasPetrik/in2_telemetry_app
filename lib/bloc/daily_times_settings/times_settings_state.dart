import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/timing_day_when.dart';

part 'times_settings_state.freezed.dart';

@freezed
class TimesSettingsState with _$TimesSettingsState {
  const factory TimesSettingsState.loading() = _Loading;
  const factory TimesSettingsState.isNotAvailable() = _IsNotAvailable;

  const factory TimesSettingsState.data({
    required DateTime dateTime,
    required List<WhenTemplate> templateWhenValues,
    required List<TimingDayWhen> timingsDayWhen,
  }) = _Updated;
  const factory TimesSettingsState.errorUpdate(DateTime dateTime) =
      _ErrorUpdate;
}
