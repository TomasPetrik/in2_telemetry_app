import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';

part 'register_device_bloc_state.freezed.dart';

@freezed
class RegisterDeviceBlocState with _$RegisterDeviceBlocState {
  const factory RegisterDeviceBlocState.init() = _Init;
  const factory RegisterDeviceBlocState.disabledBt({
    required int timestamp,
  }) = _DisabledBt;
  const factory RegisterDeviceBlocState.noBtPermissions({
    required int timestamp,
  }) = _NoBtPermissions;
  const factory RegisterDeviceBlocState.disabledLocalizationService({
    required int timestamp,
  }) = _DisabledLocalizationService;
  const factory RegisterDeviceBlocState.searching({
    required int timestamp,
    List<SourceDeviceContract>? devices,
  }) = _Searching;
  const factory RegisterDeviceBlocState.registering() = _Registering;

  const factory RegisterDeviceBlocState.deviceRegistered() = _DeviceRegistered;
  const factory RegisterDeviceBlocState.deviceAlreadyRegistered(Key key) =
      _DeviceAlreadyRegistered;
  const factory RegisterDeviceBlocState.failedRegistration(Key key) =
      _FailedRegistration;

  const factory RegisterDeviceBlocState.popDevice(SourceDeviceContract device) = _PopDevice;
}
