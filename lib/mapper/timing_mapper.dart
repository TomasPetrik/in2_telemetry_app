import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/time_settings/timing_day_when_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/timing_when_type.dart';
import 'package:scalesoft_app/data/entities/enums/timing_day_when_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/time_only.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/mapper/timing_mapper.auto_mappr.dart';
import 'package:scalesoft_app/mapper/when_code_mapper.dart';

@injectable
@AutoMappr(
  [
    MapType<TimingDayWhenContract, TimingDayWhen>(
      converters: [TypeConverter<String, TimeOnly>(TimeOnly.fromString)],
    ),
    MapType<TimingDayWhenTypeContract, TimingDayWhenType>(
      reverse: true,
    ),
  ],
  includes: [WhenCodeMapper()],
)
class TimingDayWhenMapper extends $TimingDayWhenMapper {
  const TimingDayWhenMapper();
}
