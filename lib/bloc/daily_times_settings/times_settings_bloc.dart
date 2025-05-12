import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_setting_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_settings_update_contract.dart';
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_event.dart';
import 'package:scalesoft_app/bloc/daily_times_settings/times_settings_state.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/time_setting.dart';
import 'package:scalesoft_app/data/providers/when_template_db_provider.dart';
import 'package:scalesoft_app/mapper/when_code_mapper.dart';
import 'package:scalesoft_app/repositories/time_settings_repository.dart';
import 'package:scalesoft_app/services/internet_service.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';

@injectable
class TimesSettingsBloc extends Bloc<TimesSettingsEvent, TimesSettingsState> {
  final InternetService _internetService;
  final TimeSettingsRepository _timeSettingsRepository;
  final WhenTemplateDbProvider _whenTemplateDbProvider;
  final WhenCodeMapper _whenCodeMapper;
  final UserCubit _userCubit;
  bool? settingsChanged;

  TimesSettingsBloc(
    this._internetService,
    this._timeSettingsRepository,
    this._whenTemplateDbProvider,
    this._whenCodeMapper,
    this._userCubit,
  ) : super(const TimesSettingsState.loading()) {
    on<TimesSettingsEvent>(
      (event, emit) async {
        await event.when(
          init: (carePlan) async {
            final bool isInternetAvailable = await _internetService.isInternetAvailable();
            if (!isInternetAvailable) {
              emit(const TimesSettingsState.isNotAvailable());
            } else {
              final templateWhenValues = await _whenTemplateDbProvider.getByUser(carePlan.targetUserId);

              final timingsDayWhen = carePlan.versions.last.timingDayWhen
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
              final user = _userCubit.state.rootUsers.firstWhere((x) => x.id == carePlan.targetUserId);

              final timeSettingItems = user.timeSettings;

              TimeSetting? changedTimeSetting = timeSettingItems.firstWhereOrNull(
                (oldTime) => oldTime.code == timingDayWhen.whenCode,
              );

              //2. Add there new item if not exists
              if (changedTimeSetting != null) {
                changedTimeSetting.start = newStartTime;
                changedTimeSetting.end = newEndTime;
              } else {
                changedTimeSetting = TimeSetting(
                  code: timingDayWhen.whenCode!,
                  start: newStartTime,
                  end: newEndTime,
                );
                timeSettingItems.add(changedTimeSetting);
              }

              final contracts = timeSettingItems
                  .map(
                    (x) => TimeSettingContract(
                      code: _whenCodeMapper.convert(x.code),
                      start: x.start.toString(),
                      end: x.end.toString(),
                    ),
                  )
                  .toList();

              //3. send new TimeSettings
              final newTimeSettings = TimeSettingsUpdateContract(
                contracts,
                user.muid,
              );
              await _timeSettingsRepository.updateTimeSettings(
                userId: user.id,
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
              final timingsDayWhen = carePlan.versions.last.timingDayWhen
                  .where((timingDayWhen) => timingDayWhen.whenCode != null)
                  .toList();

              final user = _userCubit.state.rootUsers.firstWhere((x) => x.id == carePlan.targetUserId);
              final templateWhenValues = await _whenTemplateDbProvider.getByUser(carePlan.targetUserId);

              List<TimeSetting> timeSettingItems = [];

              for (final timingDayWhen in timingsDayWhen) {
                final templateWhenTime = templateWhenValues.firstWhereOrNull(
                  (whenTime) => whenTime.whenCode == timingDayWhen.whenCode,
                );
                if (templateWhenTime != null) {
                  timingDayWhen.start = templateWhenTime.start;
                  timingDayWhen.end = templateWhenTime.end;

                  timeSettingItems.add(
                    TimeSetting(
                      code: templateWhenTime.whenCode,
                      start: templateWhenTime.start,
                      end: templateWhenTime.end,
                    ),
                  );
                }
              }

              //send new default time settings

              final contracts = timeSettingItems
                  .map(
                    (x) => TimeSettingContract(
                      code: _whenCodeMapper.convert(x.code),
                      start: x.start.toString(),
                      end: x.end.toString(),
                    ),
                  )
                  .toList();

              final newTimeSettings = TimeSettingsUpdateContract(
                contracts,
                user.muid,
              );
              await _timeSettingsRepository.updateTimeSettings(
                userId: user.id,
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
