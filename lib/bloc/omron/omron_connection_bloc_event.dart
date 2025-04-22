import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_create_model.dart';

part 'omron_connection_bloc_event.freezed.dart';

@freezed
class OmronConnectionBlocEvent with _$OmronConnectionBlocEvent {
  const factory OmronConnectionBlocEvent.init(
    int userId,
    MeasurementType measurementType,
    DeviceCreateModel device,
  ) = _Init;
  const factory OmronConnectionBlocEvent.checkHwState() = _CheckHwState;
  const factory OmronConnectionBlocEvent.newBtState(
    BluetoothAdapterState newBtState,
  ) = _NewBtState;
  // const factory OmronConnectionBlocEvent.checkDeviceAvailability() =
  //     _CheckDeviceAvailability;
  const factory OmronConnectionBlocEvent.stopSearch() = _StopSearch;

  const factory OmronConnectionBlocEvent.searchDevice() = _SearchDevice;
  const factory OmronConnectionBlocEvent.connectDevice() = _ConnectDevice;
  const factory OmronConnectionBlocEvent.pairDevice() = _PairDevice;
  const factory OmronConnectionBlocEvent.loadMeasurement() = _LoadMeasurement;

}
