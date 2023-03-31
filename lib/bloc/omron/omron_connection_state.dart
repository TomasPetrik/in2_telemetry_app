import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

part 'omron_connection_state.freezed.dart';

@freezed
class OmronConnectionState with _$OmronConnectionState {
  const factory OmronConnectionState.init() = _Init;
  const factory OmronConnectionState.disabledBt() = _DisabledBt;
  const factory OmronConnectionState.noBtPermissions() = _NoBtPermissions;
  const factory OmronConnectionState.searching() = _Searching;
  const factory OmronConnectionState.found({
    required BluetoothDevice device,
  }) = _Found;
  const factory OmronConnectionState.notFound() = _NotFound;
  const factory OmronConnectionState.pairing() = _Pairing;
  const factory OmronConnectionState.paired({
    required DeviceInfo deviceInfo,
  }) = _Paired;
  const factory OmronConnectionState.connecting() = _Connecting;
  const factory OmronConnectionState.connected() = _Connected;
  const factory OmronConnectionState.verified({
    required BluetoothDevice device,
    required DeviceInfo deviceInfo,
  }) = _Verified;
  const factory OmronConnectionState.notVerified() = _notVerified;
  const factory OmronConnectionState.disconnected() = _Disconnected;
  const factory OmronConnectionState.syncing() = _Syncing;
  const factory OmronConnectionState.synced({
    required HwMeasurementResult measurementResult,
    required DeviceInfo deviceInfo,
  }) = _Synced;
  const factory OmronConnectionState.error(Exception exception) = _Error;
}
