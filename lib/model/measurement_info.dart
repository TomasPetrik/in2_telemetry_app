import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';

part 'measurement_info.freezed.dart';
part 'measurement_info.g.dart';

enum MeasurementChar {
  recordAccessCp,
  bloodPressureMeasurement,
  intermediateCuffPressure,
  bloodPressureFeature;

  Guid get address => switch (this) {
        MeasurementChar.recordAccessCp => Guid('2A52'),
        MeasurementChar.bloodPressureMeasurement => Guid('2A35'),
        MeasurementChar.intermediateCuffPressure => Guid('2A36'),
        MeasurementChar.bloodPressureFeature => Guid('2A49'),
      };
}

@freezed
class MeasurementInfo with _$MeasurementInfo {
  const factory MeasurementInfo({
    required int flags, //1 byte
    required int systolic, //sfloat 2 bytes
    required int diastolic, //sfloat 2 bytes
    required int meanArterialPressure, //sfloat 2 bytes
    required String timestamp, //7 bytes
    required int pulseRate, //sfloat 2 bytes
    required int userId, //uint8 1 byte
    required int measurementStatus, //2 bytes
  }) = _MeasurementInfo;

  factory MeasurementInfo.fromJson(Map<String, Object?> json) => _$MeasurementInfoFromJson(json);

  factory MeasurementInfo.fromIntList(List<int> btData) {
    int flags = btData.toInt8(0, 1); //will be always 30 (1E)
    int systolic = btData.toInt16(1, 3);
    int diastolic = btData.toInt16(3, 5);
    int meanArterialPressure = btData.toInt16(5, 7);
    String timestamp = btData.toTimestamp(7, 14);
    int pulseRate = btData.toInt16(14, 16);
    int userId = btData.toInt8(16, 17);
    int measurementStatus = btData.toInt16(17, 19);

    return MeasurementInfo(
      flags: flags,
      systolic: systolic,
      diastolic: diastolic,
      meanArterialPressure: meanArterialPressure,
      timestamp: timestamp,
      pulseRate: pulseRate,
      userId: userId,
      measurementStatus: measurementStatus,
    );
  }
}
