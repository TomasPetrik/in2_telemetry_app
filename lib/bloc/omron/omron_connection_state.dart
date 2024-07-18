import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

part 'omron_connection_state.freezed.dart';

@freezed
class OmronConnectionState with _$OmronConnectionState {
  const factory OmronConnectionState.init() = _Init;
  const factory OmronConnectionState.disabledBt({
    required int timestamp,
  }) = _DisabledBt;
  const factory OmronConnectionState.disabledLocationService({
    required int timestamp,
  }) = _DisabledLocalizationService;
  factory OmronConnectionState.noBtPermissions({
    required int timestamp,
  }) = _NoBtPermissions;
  factory OmronConnectionState.searching({
    required int timestamp,
  }) = _Searching;
  const factory OmronConnectionState.found({
    required int timestamp,
    required BluetoothDevice device,
  }) = _Found;
  const factory OmronConnectionState.notFound({
    required int timestamp,
  }) = _NotFound;
  const factory OmronConnectionState.pairing({
    required int timestamp,
  }) = _Pairing;
  const factory OmronConnectionState.paired({
    required int timestamp,
    required DeviceInfo deviceInfo,
  }) = _Paired;
  const factory OmronConnectionState.connecting({
    required int timestamp,
  }) = _Connecting;
  const factory OmronConnectionState.connected({
    required int timestamp,
  }) = _Connected;
  const factory OmronConnectionState.verified({
    required int timestamp,
    required BluetoothDevice device,
    required DeviceInfo deviceInfo,
  }) = _Verified;
  const factory OmronConnectionState.notVerified({
    required int timestamp,
    required HwMeasurementResult measurementResult,
  }) = _NotVerified;
  const factory OmronConnectionState.disconnected({
    required int timestamp,
  }) = _Disconnected;
  const factory OmronConnectionState.syncing({
    required int timestamp,
  }) = _Syncing;
  const factory OmronConnectionState.synced({
    required int timestamp,
    required HwMeasurementResult measurementResult,
    required DeviceInfo deviceInfo,
  }) = _Synced;
  const factory OmronConnectionState.error({
    required int timestamp,
    required Exception exception,
  }) = _Error;
}
