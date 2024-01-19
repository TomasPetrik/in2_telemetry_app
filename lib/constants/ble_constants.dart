import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleConstants {
  BleConstants._();

  static const int dataOper = 0x05;
  static const int confirmFetchData = 0x80;
  static final Guid gattServiceMain = Guid("be940000-7333-be46-b7ae-689e71722bd5");
  static final Guid gattCharMainCmd = Guid("be940001-7333-be46-b7ae-689e71722bd5");
  static final Guid gattCharMainRes = Guid("be940003-7333-be46-b7ae-689e71722bd5");

  static const int bleTimeout = 10;
}