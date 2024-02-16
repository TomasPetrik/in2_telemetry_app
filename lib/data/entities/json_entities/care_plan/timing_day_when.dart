import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/timing_day_when_type.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/time_only.dart';

part 'timing_day_when.g.dart';

@JsonSerializable()
class TimingDayWhen {
  TimingDayWhenType type;
  TimeOnly start;
  TimeOnly end;
  TimeOnly? timeOfDay;
  WhenCode? whenCode;

  TimingDayWhen(this.type, this.start, this.end, {this.timeOfDay, this.whenCode});

  bool isInInterval(TimeOnly time) {
    return time.isBefore(end) && time.isAfter(start) ? true : false;
  }

  factory TimingDayWhen.fromJson(Map<String, dynamic> json) => _$TimingDayWhenFromJson(json);

  Map<String, dynamic> toJson() => _$TimingDayWhenToJson(this);
}
