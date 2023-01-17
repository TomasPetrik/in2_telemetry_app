import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/auth_data.dart';

part 'hospital.freezed.dart';
part 'hospital.g.dart';

@freezed
class Hospital with _$Hospital {
  const Hospital._();

  const factory Hospital({
    required int id,
    required String title,
    required String iconPath,
    required AuthData authData,
  }) = _Hospital;

  factory Hospital.fromJson(Map<String, dynamic> json) => _$HospitalFromJson(json);

  @override
  String toString() => toJson().toString();
}


@HiveType(typeId: 4)
class HospitalLocal extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String iconPath;

  @HiveField(3)
  final AuthDataLocal authData;

  HospitalLocal({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.authData,
  });
}
