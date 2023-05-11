import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'local_locale.freezed.dart';
part 'local_locale.g.dart';
part 'local_locale.hive.dart';

@freezed
class LocalLocale with _$LocalLocale {
  const LocalLocale._();

  @HiveType(typeId: 112, adapterName: 'LocalLocaleAdapter')
  factory LocalLocale({
    @HiveField(0) required String languageCode,
  }) = _LocalLocale;

  factory LocalLocale.fromJson(Map<String, dynamic> json) =>
      _$LocalLocaleFromJson(json);

  Locale get locale => Locale(languageCode);
}
