import 'dart:convert';

import 'package:drift/drift.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return (json.decode(fromDb) as List<dynamic>).cast<String>();
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    return (json.decode(fromDb) as List<dynamic>).cast<int>();
  }

  @override
  String toSql(List<int> value) {
    return json.encode(value);
  }
}
