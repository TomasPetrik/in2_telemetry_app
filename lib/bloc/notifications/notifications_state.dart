import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/app_settings.dart';

part 'notifications_state.freezed.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.init() = _Init;
  const factory NotificationsState.denied() = _Denied;
  const factory NotificationsState.granted() = _Granted;
  const factory NotificationsState.loaded({
    required int timestamp,
    required AppSettings appSettings,
    bool? allowedInSystem,
  }) = _Loaded;
}
