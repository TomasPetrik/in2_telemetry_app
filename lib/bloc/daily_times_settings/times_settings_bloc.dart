import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_event.dart';
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_state.dart';
import 'package:scalesoft_app/repositories/time_settings_repository.dart';
import 'package:scalesoft_app/services/internet_service.dart';

@injectable
class TimesSettingsBloc extends Bloc<TimesSettingsEvent, TimesSettingsState> {
  final InternetService _internetService;
  final AccountDbProvider _accountDbProvider;
  final TimeSettingsRepository _timeSettingsRepository;
  bool? settingsChanged;

  TimesSettingsBloc(
    this._internetService,
    this._accountDbProvider,
    this._timeSettingsRepository,
  ) : super(const TimesSettingsState.loading()) {
    on<TimesSettingsEvent>(
      (event, emit) async {
        await event.when(
          init: (carePlan) async {
            final bool isInternetAvailable =
                await _internetService.isInternetAvailable();
            if (!isInternetAvailable) {
              emit(const TimesSettingsState.isNotAvailable());
            } else {
              final userAccount = _accountDbProvider.get(carePlan.userId!);
              final templateWhenValues =
                  userAccount!.templateTimeSet!.whenTimeValues;

              final timingsDayWhen = carePlan.timingDayWhen
                  .where((timingDayWhen) => timingDayWhen.whenCode != null)
                  .toList();

              emit(
                TimesSettingsState.data(
                  dateTime: DateTime.now(),
                  templateWhenValues: templateWhenValues,
                  timingsDayWhen: timingsDayWhen,
                ),
              );
            }
          },
          setTime: (
            carePlan,
            newStartTime,
            newEndTime,
            timingDayWhen,
          ) async {
            try {
              //1. prepare current user settings
              final userAccount = _accountDbProvider.get(carePlan.userId!);
              final timeSettingItems = userAccount!.timeSettingItems!;

              TimeSetting? newTimeSetting = timeSettingItems.firstWhereOrNull(
                (oldTime) => oldTime.code == timingDayWhen.whenCode,
              );

              //2. Add there new item if not exists
              if (newTimeSetting != null) {
                newTimeSetting.start = newStartTime;
                newTimeSetting.end = newEndTime;
              } else {
                newTimeSetting = TimeSetting(
                  code: timingDayWhen.whenCode!,
                  start: newStartTime,
                  end: newEndTime,
                );
                timeSettingItems.add(newTimeSetting);
              }
              //3. send new TimeSettings
              final newTimeSettings = TimeSettings(
                timeSettingItems,
                userAccount.user.muid,
              );
              await _timeSettingsRepository.updateTimeSettings(
                userAccount: userAccount,
                timeSettings: newTimeSettings,
              );

              settingsChanged = true;
            } on Exception catch (_) {
              emit(TimesSettingsState.errorUpdate(DateTime.now()));
            }

            //4. If fail ,catch and emit error for listener
          },
          resetTimes: (carePlan) async {
            try {
              final timingsDayWhen = carePlan.timingDayWhen
                  .where((timingDayWhen) => timingDayWhen.whenCode != null)
                  .toList();

              final userAccount = _accountDbProvider.get(carePlan.userId!);
              final templateWhenValues =
                  userAccount!.templateTimeSet!.whenTimeValues;

              List<TimeSetting> timeSettingItems = [];

              for (final timingDayWhen in timingsDayWhen) {
                final templateWhenTime = templateWhenValues.firstWhereOrNull(
                  (whenTime) => whenTime.codeValue == timingDayWhen.whenCode,
                );
                if (templateWhenTime != null) {
                  timingDayWhen.start = templateWhenTime.start;
                  timingDayWhen.end = templateWhenTime.end;

                  timeSettingItems.add(
                    TimeSetting(
                      code: templateWhenTime.codeValue,
                      start: templateWhenTime.start,
                      end: templateWhenTime.end,
                    ),
                  );
                }
              }

              //send new default time settings

              final newTimeSettings = TimeSettings(
                timeSettingItems,
                userAccount.user.muid,
              );
              await _timeSettingsRepository.updateTimeSettings(
                userAccount: userAccount,
                timeSettings: newTimeSettings,
              );

              settingsChanged = true;

              emit(
                TimesSettingsState.data(
                  dateTime: DateTime.now(),
                  templateWhenValues: templateWhenValues,
                  timingsDayWhen: timingsDayWhen,
                ),
              );
            } on Exception catch (_) {
              emit(TimesSettingsState.errorUpdate(DateTime.now()));
            }
          },
        );
      },
    );
  }
}
