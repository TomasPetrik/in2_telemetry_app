import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/care_pan/activity_type_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/data/entities/enums/activity_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/mapper/care_plan_activity_mapper.auto_mappr.dart';
import 'package:scalesoft_app/mapper/measurement_type_mapper.dart';

@injectable
@AutoMappr(
  [
    MapType<CarePlanActivityContract, CarePlanActivity>(),
    MapType<ActivityTypeContract, ActivityType>(),
  ],
  includes: [
    MeasurementTypeMapper(),
  ],
)
class CarePlanActivityMapper extends $CarePlanActivityMapper {}
