import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';
import 'package:scalesoft_app/model/device_info.dart';

part 'omron_connection_bloc_event.freezed.dart';

@freezed
class OmronConnectionBlocEvent with _$OmronConnectionBlocEvent {
  const factory OmronConnectionBlocEvent.init(
    String userId,
    MeasurementTypeContract measurementType,
    SourceDeviceContract device,
  ) = _Init;
  const factory OmronConnectionBlocEvent.checkHwState() = _CheckHwState;
  const factory OmronConnectionBlocEvent.newBtState(
    BluetoothAdapterState newBtState,
  ) = _NewBtState;
  const factory OmronConnectionBlocEvent.checkDeviceAvailability() =
      _CheckDeviceAvailability;
  const factory OmronConnectionBlocEvent.stopSearch() = _StopSearch;

  const factory OmronConnectionBlocEvent.searchDevice() = _SearchDevice;

  const factory OmronConnectionBlocEvent.connectToDevice(
    BluetoothDevice device,
    String localName,
  ) = _ConnectToDevice;

  const factory OmronConnectionBlocEvent.verifyDevice(
    BluetoothDevice device,
    String localName,
  ) = _VerifyDevice;

  const factory OmronConnectionBlocEvent.measureAndSync(
    BluetoothDevice device,
    DeviceInfo deviceInfo,
    String localName,
  ) = _MeasureAndSync;

  factory OmronConnectionBlocEvent.foundDevice(
    BluetoothDevice device,
    String localName,
  ) = _FoundDevice;
}
