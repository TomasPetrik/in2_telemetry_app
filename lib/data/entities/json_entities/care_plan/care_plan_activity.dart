import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/activity_type.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

part 'care_plan_activity.g.dart';

@JsonSerializable()
class CarePlanActivity {
  ActivityType activityType;
  MeasurementType measurementType;
  int? goalValue;

  CarePlanActivity(this.activityType, this.measurementType, {this.goalValue});

  factory CarePlanActivity.fromJson(Map<String, dynamic> json) => _$CarePlanActivityFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanActivityToJson(this);
}

class CarePlanActivityConverter extends TypeConverter<CarePlanActivity, String> {
  const CarePlanActivityConverter();

  @override
  CarePlanActivity fromSql(String fromDb) {
    return CarePlanActivity.fromJson(
      json.decode(fromDb) as Map<String, dynamic>,
    );
  }

  @override
  String toSql(CarePlanActivity value) {
    return json.encode(value.toJson());
  }
}
