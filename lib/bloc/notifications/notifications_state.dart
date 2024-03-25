import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/app_database.dart';

part 'notifications_state.freezed.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.init() = _Init;
  const factory NotificationsState.denied() = _Denied;
  const factory NotificationsState.granted() = _Granted;
  const factory NotificationsState.loaded({
    required int timestamp,
    required AppSetting appSettings,
    bool? allowedInSystem,
  }) = _Loaded;
}
