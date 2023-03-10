import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';

part 'omron_connection_bloc_event.freezed.dart';

@freezed
class OmronConnectionBlocEvent with _$OmronConnectionBlocEvent {
  const factory OmronConnectionBlocEvent.init(
    String userId,
    MeasurementType measurementType,
    DeviceModel? reqModelPairing,
  ) = _Init;
  const factory OmronConnectionBlocEvent.newBtState(BluetoothState newBtState) =
      _NewBtState;
  const factory OmronConnectionBlocEvent.checkDeviceAvailability() =
      _CheckDeviceAvailability;
  const factory OmronConnectionBlocEvent.stopSearch() = _StopSearch;

  const factory OmronConnectionBlocEvent.searchDevice() = _SearchDevice;

  const factory OmronConnectionBlocEvent.connectToDevice(
    BluetoothDevice device,
  ) = _ConnectToDevice;

  const factory OmronConnectionBlocEvent.verifyDevice(
    BluetoothDevice device,
  ) = _VerifyDevice;

  const factory OmronConnectionBlocEvent.foundDevice(
    BluetoothDevice device,
  ) = _FoundDevice;
}
