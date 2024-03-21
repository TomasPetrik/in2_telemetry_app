import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_version_contract.dart';
import 'package:scalesoft_app/data/entities/enums/time_unit.dart';
import 'package:scalesoft_app/data/entities/enums/week_day.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/mapper/care_plan_version_mapper.auto_mappr.dart';
import 'package:scalesoft_app/mapper/timing_mapper.dart';

@injectable
@AutoMappr(
  [
    MapType<CarePlanVersionContract, CarePlanVersion>(),
    MapType<TimeUnitContract, TimeUnit>(reverse: true),
    MapType<WeekDayContract, WeekDay>(),
  ],
  includes: [TimingDayWhenMapper()],
)
class CarePlanVersionMapper extends $CarePlanVersionMapper {}
