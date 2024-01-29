import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';

part 'hospital.freezed.dart';
part 'hospital.g.dart';

@freezed
class Hospital with _$Hospital {
  const Hospital._();

  @HiveType(typeId: 4, adapterName: 'HospitalAdapter')
  const factory Hospital({
    @HiveField(0) required int id,
    @HiveField(1) required String title,
    @HiveField(2) required String iconPath,
    @HiveField(3) required AuthData authData,
    @HiveField(4) required List<MeasurementTypeContract> enabledMeasurementTypes,
  }) = _Hospital;

  factory Hospital.fromJson(Map<String, dynamic> json) =>
      _$HospitalFromJson(json);

  @override
  String toString() => toJson().toString();
}
