import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class CarePlanHelper {
  static Map<WhenPeriod, int> getPossibleWhenPeriods(
    List<CarePlan> carePlans,
  ) {
    Map<WhenPeriod, int> periods = {};

    final currentWeekDay = DateTime.now().currentWeekDay();
    final tomorrowWeekDay = DateTime.now().tomorrowWeekDay();

    final todayMeasurements = carePlans
        .where(
          (final CarePlan carePlan) => ((carePlan.periodUnit == TimeUnit.day &&
                  carePlan.weekDays?.isEmpty == true) ||
              carePlan.weekDays?.contains(currentWeekDay) == true),
        )
        .fold(
          0,
          (sum, carePlan) =>
              sum + carePlan.getTodayRemainingMeasurements().length,
        );

    final tomorrowMeasurements = carePlans
        .where(
          (final CarePlan carePlan) =>
              (carePlan.periodUnit == TimeUnit.day &&
                  carePlan.weekDays?.isEmpty == true) ||
              carePlan.weekDays?.contains(tomorrowWeekDay) == true,
        )
        .fold(
          0,
          (sum, carePlan) => sum + carePlan.timingDayWhen.length,
        );

    periods[WhenPeriod.today] = todayMeasurements;

    if (tomorrowMeasurements > 0) {
      periods[WhenPeriod.tomorrow] = tomorrowMeasurements;
    }

    periods[WhenPeriod.next10] = 10;

    return periods;
  }

  static List<Measurement> getMeasurements(
    List<CarePlan> carePlans,
    WhenPeriod whenPeriod,
  ) {
    List<Measurement> measurements = [];

    switch (whenPeriod) {
      case WhenPeriod.today:
        measurements = Calendar.getTodayMeasurements(
          carePlans: carePlans,
        );
        break;
      case WhenPeriod.tomorrow:
        measurements = Calendar.getTomorrowMeasurements(
          carePlans: carePlans,
        );
        break;
      case WhenPeriod.next10:
        final upcomingMeasurements = Calendar.getNUpcomingMeasurements(
          carePlans: carePlans,
          reqCount: 10,
        );
        measurements.addAll(upcomingMeasurements);
        break;
    }

    measurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    return measurements;
  }
}

class Calendar {
  static List<Measurement> getTodayMeasurements({
    required List<CarePlan> carePlans,
  }) {
    List<Measurement> measurements = [];
    final currentWeekDay = DateTime.now().currentWeekDay();
    final todayCarePlans = carePlans.where(
      (final CarePlan carePlan) => ((carePlan.periodUnit == TimeUnit.day &&
              carePlan.weekDays?.isEmpty == true) ||
          carePlan.weekDays?.contains(currentWeekDay) == true),
    );

    for (final carePlan in todayCarePlans) {
      final timingDaysWhen = carePlan.getTodayRemainingMeasurements();
      for (final timingDayWhen in timingDaysWhen) {
        measurements.add(
          Measurement(
            userId: carePlan.userId!,
            whenStart: timingDayWhen.start.todayDateTime(),
            whenEnd: timingDayWhen.end.todayDateTime(),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
          ),
        );
      }
    }

    return measurements;
  }

  static List<Measurement> getTomorrowMeasurements({
    required List<CarePlan> carePlans,
  }) {
    List<Measurement> measurements = [];
    final tomorrowWeekDay = DateTime.now().tomorrowWeekDay();
    final tomorrowCarePlans = carePlans.where(
      (final CarePlan carePlan) =>
          (carePlan.periodUnit == TimeUnit.day &&
              carePlan.weekDays?.isEmpty == true) ||
          carePlan.weekDays?.contains(tomorrowWeekDay) == true,
    );
    for (final carePlan in tomorrowCarePlans) {
      for (final timingDayWhen in carePlan.timingDayWhen) {
        measurements.add(
          Measurement(
            userId: carePlan.userId!,
            whenStart: timingDayWhen.start.tomorrowDateTime(),
            whenEnd: timingDayWhen.end.tomorrowDateTime(),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
          ),
        );
      }
    }

    return measurements;
  }

  static List<Measurement> getNUpcomingMeasurements({
    required List<CarePlan> carePlans,
    required int reqCount,
  }) {
    final List<Measurement> upcomingMeasurements = [];

    for (final carePlan in carePlans) {
      final todayMeasurements = carePlan.getTodayRemainingMeasurements();
      upcomingMeasurements.addAll(
        todayMeasurements.map(
          (timingDayWhen) => Measurement(
            userId: carePlan.userId!,
            whenStart: timingDayWhen.start.todayDateTime(),
            whenEnd: timingDayWhen.end.todayDateTime(),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
          ),
        ),
      );
    }

    //start populating tomorrow and other days
    final currentDate = DateTime.now();
    int daysShift = 1;
    while (upcomingMeasurements.length < reqCount) {
      for (final carePlan in carePlans) {
        if (carePlan.periodUnit == TimeUnit.day) {
          if (carePlan.weekDays?.isNotEmpty == true) {
            //add them only in specific days
            final shiftedDate = currentDate.add(Duration(days: daysShift));
            final shiftedWeekDay = WeekDay.values[shiftedDate.weekday - 1];
            if (carePlan.weekDays?.contains(shiftedWeekDay) == true) {
              upcomingMeasurements.addAll(
                getShiftedMeasurements(carePlan, daysShift),
              );
            }
          } else {
            //add daily routes
            upcomingMeasurements.addAll(
              getShiftedMeasurements(carePlan, daysShift),
            );
          }
        }
      }

      daysShift += 1;
    }

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    final upcomingNMeasurements = upcomingMeasurements.take(reqCount).toList();

    return upcomingNMeasurements;
  }

  static List<Measurement> getShiftedMeasurements(
    CarePlan carePlan,
    int daysShift,
  ) {
    return carePlan.timingDayWhen
        .map(
          (timingDayWhen) => Measurement(
            userId: carePlan.userId!,
            whenStart: timingDayWhen.start
                .todayDateTime()
                .add(Duration(days: daysShift)),
            whenEnd: timingDayWhen.end
                .todayDateTime()
                .add(Duration(days: daysShift)),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
          ),
        )
        .toList();
  }
}

class Measurement {
  Measurement({
    required this.userId,
    required this.whenStart,
    required this.whenEnd,
    required this.timingDayWhen,
    required this.carePlan,
  });

  final String userId;
  final DateTime whenStart;
  final DateTime whenEnd;
  final TimingDayWhen timingDayWhen;
  final CarePlan carePlan;
}

enum WhenPeriod {
  today,
  tomorrow,
  next10,
}
