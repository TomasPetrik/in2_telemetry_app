import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

part 'device_connection_state.freezed.dart';

@freezed
class DeviceConnectionState with _$DeviceConnectionState {
  const factory DeviceConnectionState.init() = _Init;
  const factory DeviceConnectionState.disabledBt({
    required int timestamp,
  }) = _DisabledBt;
  const factory DeviceConnectionState.disabledLocationService({
    required int timestamp,
  }) = _DisabledLocalizationService;
  factory DeviceConnectionState.noBtPermissions({
    required int timestamp,
  }) = _NoBtPermissions;
  factory DeviceConnectionState.searching({
    required int timestamp,
  }) = _Searching;
  const factory DeviceConnectionState.found({
    required int timestamp,
    required BluetoothDevice device,
  }) = _Found;
  const factory DeviceConnectionState.notFound({
    required int timestamp,
  }) = _NotFound;
  const factory DeviceConnectionState.pairing({
    required int timestamp,
  }) = _Pairing;
  const factory DeviceConnectionState.paired({
    required int timestamp,
    required DeviceInfo deviceInfo,
  }) = _Paired;
  const factory DeviceConnectionState.measuring({
    required int timestamp,
    required DeviceInfo deviceInfo,
  }) = _Measuring;
  const factory DeviceConnectionState.connecting({
    required int timestamp,
  }) = _Connecting;
  const factory DeviceConnectionState.connected({
    required int timestamp,
  }) = _Connected;
  // const factory OmronConnectionState.verified({
  //   required int timestamp,
  //   required BluetoothDevice device,
  //   required DeviceInfo deviceInfo,
  // }) = _Verified;
  const factory DeviceConnectionState.notVerified({
    required int timestamp,
    required HwMeasurementResult measurementResult,
  }) = _NotVerified;
  const factory DeviceConnectionState.disconnected({
    required int timestamp,
  }) = _Disconnected;
  const factory DeviceConnectionState.syncing({
    required int timestamp,
  }) = _Syncing;
  const factory DeviceConnectionState.synced({
    required int timestamp,
    required HwMeasurementResult measurementResult,
    required DeviceInfo deviceInfo,
  }) = _Synced;
  const factory DeviceConnectionState.error({
    required int timestamp,
    required Exception exception,
  }) = _Error;
}
