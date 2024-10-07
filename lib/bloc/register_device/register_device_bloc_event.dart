import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/user_model.dart';

part 'register_device_bloc_event.freezed.dart';

@freezed
class RegisterDeviceBlocEvent with _$RegisterDeviceBlocEvent {
  const factory RegisterDeviceBlocEvent.init({
    required int userId,
    bool? onlyPairingMode,
    @Default(false)
    bool isPersonalDevice,
  }) = _Init;
  const factory RegisterDeviceBlocEvent.checkHwState() = _CheckHwState;
  const factory RegisterDeviceBlocEvent.newBtState(
    BluetoothAdapterState newBtState,
  ) = _NewBtState;

  const factory RegisterDeviceBlocEvent.searchDevices() = _SearchDevices;
  const factory RegisterDeviceBlocEvent.stopSearch() = _StopSearch;

  const factory RegisterDeviceBlocEvent.notifyAboutNewDevices({
    required int timestamp,
    required List<DeviceCreateModel> foundDevices,
  }) = _NotifyAboutNewDevices;

  const factory RegisterDeviceBlocEvent.selectDevice(DeviceCreateModel device) =
      _SelectDevice;

  const factory RegisterDeviceBlocEvent.registerDevice(
    UserModel userAccount,
      DeviceCreateModel device,
    String assignedIdentifier,
  ) = _RegisterDevice;
}
