import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';

part 'care_plan_author.g.dart';

@JsonSerializable()
class CarePlanAuthor {
  String muid;
  List<String> firstNames;
  List<String> lastNames;

  CarePlanAuthor(this.muid, this.firstNames, this.lastNames);

  factory CarePlanAuthor.fromJson(Map<String, dynamic> json) => _$CarePlanAuthorFromJson(json);

  Map<String, dynamic> toJson() => _$CarePlanAuthorToJson(this);
}

class CarePlanAuthorConverter extends TypeConverter<CarePlanAuthor, String> {
  const CarePlanAuthorConverter();

  @override
  CarePlanAuthor fromSql(String fromDb) {
    return CarePlanAuthor.fromJson(
      json.decode(fromDb) as Map<String, dynamic>,
    );
  }

  @override
  String toSql(CarePlanAuthor value) {
    return json.encode(value.toJson());
  }
}
