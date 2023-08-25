import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'register_device_bloc_event.freezed.dart';

@freezed
class RegisterDeviceBlocEvent with _$RegisterDeviceBlocEvent {
  const factory RegisterDeviceBlocEvent.init({
    required String userId,
    bool? onlyPairingMode,
  }) = _Init;
  const factory RegisterDeviceBlocEvent.newBtState(
    BluetoothAdapterState newBtState,
  ) = _NewBtState;

  const factory RegisterDeviceBlocEvent.searchDevices() = _SearchDevices;
  const factory RegisterDeviceBlocEvent.stopSearch() = _StopSearch;

  const factory RegisterDeviceBlocEvent.notifyAboutNewDevices(
    List<Device> foundDevices,
  ) = _NotifyAboutNewDevices;

  const factory RegisterDeviceBlocEvent.selectDevice(Device device) =
      _SelectDevice;

  const factory RegisterDeviceBlocEvent.registerDevice(
    UserAccount userAccount,
    Device device,
    String assignedIdentifier,
  ) = _RegisterDevice;
}
