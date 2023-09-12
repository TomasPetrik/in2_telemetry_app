import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Datetime tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Tomorrow 1', () {
      final dayOfDSTChange = DateTime(2023, 10, 29, 13, 10, 56);
      final tomorrow = dayOfDSTChange.tomorrow;
      final nextDay = DateTime(2023, 10, 30);
      expect(tomorrow, nextDay);
    });

    test('Tomorrow 2', () {
      final dayOfDSTChange = DateTime(2023, 10, 29, 00, 00, 00);
      final tomorrow = dayOfDSTChange.tomorrow;
      final nextDay = DateTime(2023, 10, 30);
      expect(tomorrow, nextDay);
    });

    test('Tomorrow 3', () {
      final dayOfDSTChange = DateTime(2023, 10, 29, 23, 59, 59);
      final tomorrow = dayOfDSTChange.tomorrow;
      final nextDay = DateTime(2023, 10, 30);
      expect(tomorrow, nextDay);
    });

    test('Tomorrow 4', () {
      final dayOfDSTChange = DateTime(2023, 10, 30, 0, 0, 0);
      final tomorrow = dayOfDSTChange.tomorrow;
      final nextDay = DateTime(2023, 10, 31);
      expect(tomorrow, nextDay);
    });

    test('Tomorrow 5', () {
      final dayOfDSTChange = DateTime(2023, 10, 28, 23, 59, 59);
      final tomorrow = dayOfDSTChange.tomorrow;
      final nextDay = DateTime(2023, 10, 29);
      expect(tomorrow, nextDay);
    });

    test('Yesterday 1', () {
      final dayOfDSTChange = DateTime(2023, 10, 30, 13, 10, 56);
      final tomorrow = dayOfDSTChange.yesterday;
      final prevDay = DateTime(2023, 10, 29);
      expect(tomorrow, prevDay);
    });

    test('Yesterday 2', () {
      final dayOfDSTChange = DateTime(2023, 10, 30, 0, 0, 0);
      final tomorrow = dayOfDSTChange.yesterday;
      final prevDay = DateTime(2023, 10, 29);
      expect(tomorrow, prevDay);
    });

    test('Yesterday 3', () {
      final dayOfDSTChange = DateTime(2023, 10, 30, 23, 59, 59);
      final tomorrow = dayOfDSTChange.yesterday;
      final prevDay = DateTime(2023, 10, 29);
      expect(tomorrow, prevDay);
    });

    test('Yesterday 4', () {
      final dayOfDSTChange = DateTime(2023, 10, 29, 23, 59, 59);
      final tomorrow = dayOfDSTChange.yesterday;
      final prevDay = DateTime(2023, 10, 28);
      expect(tomorrow, prevDay);
    });

    test('Yesterday 5', () {
      final dayOfDSTChange = DateTime(2023, 10, 31, 0, 0, 0);
      final tomorrow = dayOfDSTChange.yesterday;
      final prevDay = DateTime(2023, 10, 30);
      expect(tomorrow, prevDay);
    });

    test('Date', () {
      final time = DateTime(2023, 10, 31, 10, 20, 30);
      final date = DateTime(2023, 10, 31);
      expect(date, time.date);
    });

    test('WeekDay', () {
      final time = DateTime(2023, 10, 31, 10, 20, 30);
      expect(time.weekDay, WeekDay.tuesday);
    });

    test('Tomorrow WeekDay', () {
      final time = DateTime(2023, 10, 31, 10, 20, 30);
      expect(time.tomorrow.weekDay, WeekDay.wednesday);
    });

    test('Yesterday WeekDay', () {
      final time = DateTime(2023, 10, 31, 10, 20, 30);
      expect(time.yesterday.weekDay, WeekDay.monday);
    });

    test('is Today', () {
      final time = DateTime.now();
      expect(time.isToday, true);
    });

    test('is not Today', () {
      final time = DateTime(2000, 01, 01, 10, 20, 30);
      expect(time.isToday, false);
    });

    test('was yesterday', () {
      final time = DateTime.now().subtract(const Duration(days: 1));
      expect(time.wasYesterday, true);
    });

    test('was not yesterday', () {
      final time = DateTime(2000, 01, 01, 10, 20, 30);
      expect(time.wasYesterday, false);
    });


  });
}
