import 'package:flutter_blue/flutter_blue.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/measurement_result.dart';

part 'omron_connection_state.freezed.dart';

@freezed
class OmronConnectionState with _$OmronConnectionState {
  const factory OmronConnectionState.init() = _Init;
  const factory OmronConnectionState.searching() = _Searching;
  const factory OmronConnectionState.found({
    required BluetoothDevice device,
  }) = _Found;
  const factory OmronConnectionState.notFound() = _NotFound;
  const factory OmronConnectionState.pairing() = _Pairing;
  const factory OmronConnectionState.paired() = _Paired;
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
    required MeasurementResult measurementResult,
  }) = _Synced;
  const factory OmronConnectionState.error(Exception exception) = _Error;
}
