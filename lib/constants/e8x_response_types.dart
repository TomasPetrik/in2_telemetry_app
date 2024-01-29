class E8xResponseTypes {
  static const int heartRate = 0x06;
  static const int bloodPressure = 0x08;
  static const int oxygenSaturation = 0x09;
  static const List<int> batteryLevel = [0x02, 0x00];

  // command check response
  static const List<int> metricUnitsSet = [0x01, 0x04];
  static const List<int> timeSet = [0x01, 0x00];
  static const List<int> measurementIntervalSet = [0x01, 0x0C];

  // delete history check
  static const List<int> heartRateHistoryDeleted = [5, 66];
  static const List<int> bloodPressureHistoryDeleted = [5, 67];
  static const List<int> oxygenSaturationHistoryDeleted = [5, 68];

  // when history is empty
  static const List<int> emptyOxygenSaturationHistory = [5, 9];
  static const List<int> emptyHeartRateHistory = [5, 6];
  static const List<int> emptyBloodPressureHistory = [5, 8];
}
