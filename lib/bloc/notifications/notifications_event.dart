import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_event.freezed.dart';

@freezed
class NotificationsEvent with _$NotificationsEvent {
  const factory NotificationsEvent.initPlugin() = _InitPlugin;
  const factory NotificationsEvent.initSettings() = _InitSettings;
  const factory NotificationsEvent.setNotifications() = _SetNotifications;
  const factory NotificationsEvent.enableNotifications(bool enabled) =
      _EnableNotifications;

  const factory NotificationsEvent.notifyAtStartOfMeasurement(bool enabled) =
      _NotifyAtStartOfMeasurement;
  const factory NotificationsEvent.notify10MinBeforeMeasurement(
    bool enabled,
  ) = _Notify10MinBeforeMeasurement;
}
