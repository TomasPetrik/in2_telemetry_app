class SendDataHelper {
  //static int _h = 1;
  int? a;
  int? b;
  List<int> c = List.empty();
  int? d;
  //int? _i;
  int _j = 0;
  int? e;
  bool? f;

  SendDataHelper(List<int> paramArrayOfbyte, int paramInt) {
    c = paramArrayOfbyte;
    d = paramInt;
    //_i = _h++;
    f = false;
    _j = 0;
  }

  List<int>? calc() {
    int i = c.length;
    if (i - _j > 176) {
      List<int> arrayOfByte1 = c.sublist(_j, _j + 176);
      _j += 176;
      return arrayOfByte1;
    }
    if (i <= _j) {
      if (i == 0 && _j == 0) {
        _j = 1;
        return [];
      }
      return null;
    }
    int j = i - _j;
    List<int> arrayOfByte = c.sublist(_j, _j + j);
    _j += j;
    return arrayOfByte;
  }
}
