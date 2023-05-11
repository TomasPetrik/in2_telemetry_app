import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'device_model.freezed.dart';
part 'device_model.g.dart';

@freezed
class DeviceModel with _$DeviceModel {
  const DeviceModel._();

  @HiveType(typeId: 45, adapterName: 'DeviceModelAdapter')
  factory DeviceModel({
    @HiveField(0) required int id,
    @HiveField(1) String? manufacturer,
    @HiveField(2) String? modelName,
    @HiveField(3) String? aboutUrl,
  }) = _DeviceModel;

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);

  @override
  String toString() => toJson().toString();
}
