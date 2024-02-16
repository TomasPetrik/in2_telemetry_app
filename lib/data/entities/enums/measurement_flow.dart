enum MeasurementFlow {
  none(0),
  foreground(1 << 0),
  background(1 << 2),
  all(0xFF);

  final int value;

  const MeasurementFlow(this.value);

  bool hasFlag(MeasurementFlow flag) {
    return flag.value & value != 0;
  }
}