import 'package:scalesoft_app/utils/helpers/send_data_helper.dart';

class E8xHelper {
  E8xHelper._();

  static List<int>? setTime() {
    DateTime dateTime = DateTime.now();
    int dayM = dateTime.day;
    int dayW = dateTime.weekday;
    int minute = dateTime.minute;
    int second = dateTime.second;
    int hour = dateTime.hour;
    int month = dateTime.month;
    int year = dateTime.year;
    List<int> data = [
      year % 256,
      year ~/ 256,
      month,
      dayM,
      hour,
      minute,
      second,
      dayW,
    ];
    return processRawData(0x100, data, 2);
  }

  static List<int>? setMeasurementInterval(int interval) {
    return processRawData(268, [1, interval], 2);
  }

  static List<int>? processRawData(
    int paramInt1,
    List<int> paramArrayOfbyte,
    int paramInt3, {
    int paramInt2 = 1,
  }) {
    SendDataHelper mm = SendDataHelper(paramArrayOfbyte, paramInt3);
    mm.e = paramInt1;
    mm.a = paramInt2;
    return manageData(mm);
  }

  /*static List<int>? processRawData(int paramInt1, List<int> paramArrayOfbyte, int paramInt2) {
    return processRawData(paramInt1, 1, paramArrayOfbyte, paramInt2);
  }*/

  static List<int>? manageData(SendDataHelper helper) {
    List<int>? arrayOfByte = helper.calc();
    if (arrayOfByte != null) {
      return prepareData(helper.e ?? 0, arrayOfByte);
    }
    return null;
  }

  static List<int> prepareData(int paramInt, List<int> paramArrayOfbyte) {
    int i = paramArrayOfbyte.length + 6;
    List<int> arrayOfByte = List<int>.filled(i, 0, growable: false);
    int j = 0;
    arrayOfByte[j++] = (paramInt >> 8) & 0xFF;
    arrayOfByte[j++] = paramInt & 0xFF;
    arrayOfByte[j++] = i & 0xFF;
    arrayOfByte[j++] = (i >> 8) & 0xFF;
    arrayOfByte.setAll(j, paramArrayOfbyte);
    j += i - 6;
    int k = utilData(arrayOfByte, i - 2);
    arrayOfByte[j++] = k & 0xFF;
    arrayOfByte[j++] = (k >> 8) & 0xFF;
    return arrayOfByte;
  }

  static int utilData(List<int> paramArrayOfbyte, int paramInt) {
    int s = -1;
    for (int b = 0; b < paramInt; b++) {
      s = (s >> 8 & 0xFF | s << 8 & 0xFF00);
      s = (s ^ paramArrayOfbyte[b] & 0xFF);
      int s1 = (s & 0xFF) >> 4;
      s = (s ^ s1);
      s = (s ^ s << 8 << 4);
      s = (s ^ (s & 0xFF) << 4 << 1);
    }
    return s & 0xFFFF;
  }

  static List<List<int>> makeSendMsg(List<int> byteArray, int chunkSize) {
    List<List<int>> resultList = [];
    int length = byteArray.length ~/ chunkSize;
    if (byteArray.length % chunkSize > 0) {
      length++;
    }
    for (int i = 0; i < length; i++) {
      int start = i * chunkSize;
      int end = (start + chunkSize) > byteArray.length
          ? byteArray.length
          : (start + chunkSize);
      List<int> subList = byteArray.sublist(start, end);
      resultList.add(subList);
    }
    return resultList;
  }

  static int bytesToDec(List<int> byteArray) {
    int result = 0;
    for (int i = 0; i < byteArray.length; i++) {
      result += (byteArray[i] & 255) << ((3 - i) * 8);
    }
    return result;
  }

  static DateTime getTime(List<int> data) {
    // The watches send seconds since January 2000.
    // They ignore timezones - the received value is in "local time":
    // If the measurement took place in UTC+2, the value is (seconds since J2000 UTC) + (2 hours)
    int secondsSinceJ2000 = bytesToDec([data[3], data[2], data[1], data[0]]);

    var asUtc =
        DateTime.utc(2000, 1, 1).add(Duration(seconds: secondsSinceJ2000));

    // We have to reinterpret the calculated DateTime as a local DateTime
    var measurementTimeAsLocal = DateTime(
      asUtc.year,
      asUtc.month,
      asUtc.day,
      asUtc.hour,
      asUtc.minute,
      asUtc.second,
    );

    return measurementTimeAsLocal.toUtc();
  }
}
