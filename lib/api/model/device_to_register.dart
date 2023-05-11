import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'device_to_register.freezed.dart';
part 'device_to_register.g.dart';
part 'device_to_register.hive.dart';

@freezed
class DeviceToRegister with _$DeviceToRegister {
  const DeviceToRegister._();

  @HiveType(typeId: 46, adapterName: 'DeviceToRegisterAdapter')
  factory DeviceToRegister({
    @HiveField(0) required int deviceModelId,
    @HiveField(1) String? assignedIdentifier,
    @HiveField(2) required String deviceIdentifier,
    @HiveField(3) String? imei,
    @HiveField(4) String? bluetoothAddress,
    @HiveField(5) String? wifiMacAddress,
    @HiveField(6) String? note,
  }) = _DeviceToRegister;

  factory DeviceToRegister.fromJson(Map<String, dynamic> json) =>
      _$DeviceToRegisterFromJson(json);

  @override
  String toString() => toJson().toString();
}
