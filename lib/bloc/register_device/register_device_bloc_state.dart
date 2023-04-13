import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';

part 'register_device_bloc_state.freezed.dart';

@freezed
class RegisterDeviceBlocState with _$RegisterDeviceBlocState {
  const factory RegisterDeviceBlocState.init() = _Init;
  const factory RegisterDeviceBlocState.disabledBt() = _DisabledBt;
  const factory RegisterDeviceBlocState.noBtPermissions() = _NoBtPermissions;
  const factory RegisterDeviceBlocState.searching({
    List<Device>? devices,
  }) = _Searching;

  const factory RegisterDeviceBlocState.deviceRegistered() = _DeviceRegistered;
  const factory RegisterDeviceBlocState.deviceAlreadyRegistered(Key key) =
      _DeviceAlreadyRegistered;
  const factory RegisterDeviceBlocState.failedRegistration(Key key) =
      _FailedRegistration;
}
