import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_create_model.dart';

part 'device_connection_bloc_event.freezed.dart';

@freezed
class DeviceConnectionBlocEvent with _$DeviceConnectionBlocEvent {
  const factory DeviceConnectionBlocEvent.init(
    int userId,
    MeasurementType measurementType,
    DeviceCreateModel device,
  ) = _Init;
  const factory DeviceConnectionBlocEvent.checkHwState() = _CheckHwState;
  const factory DeviceConnectionBlocEvent.newBtState(
    BluetoothAdapterState newBtState,
  ) = _NewBtState;
  const factory DeviceConnectionBlocEvent.stopSearch() = _StopSearch;

  const factory DeviceConnectionBlocEvent.searchDevice() = _SearchDevice;
  const factory DeviceConnectionBlocEvent.connectDevice() = _ConnectDevice;
  const factory DeviceConnectionBlocEvent.pairDevice() = _PairDevice;
  const factory DeviceConnectionBlocEvent.loadMeasurement() = _LoadMeasurement;

}
