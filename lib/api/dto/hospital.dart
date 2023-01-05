import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'hospital.freezed.dart';
part 'hospital.g.dart';

@freezed
class Hospital with _$Hospital {
  const Hospital._();

  const factory Hospital({
    required int id,
    required String title,
    required String iconPath,
  }) = _Hospital;

  factory Hospital.fromJson(Map<String, dynamic> json) => _$HospitalFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 3)
class HospitalLocal extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String iconPath;

  HospitalLocal({
    required this.id,
    required this.title,
    required this.iconPath,
  });
}
