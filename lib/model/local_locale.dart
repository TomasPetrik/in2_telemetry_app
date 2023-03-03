import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/adapters.dart';

part 'local_locale.freezed.dart';
part 'local_locale.g.dart';

@freezed
class LocalLocale with _$LocalLocale {
  const LocalLocale._();

  @HiveType(typeId: 112, adapterName: 'LocalLocaleAdapter')
  const factory LocalLocale({
    @HiveField(0) required String languageCode,
  }) = _LocalLocale;

  Locale get locale => Locale(languageCode);
}
