import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'theme_mode_local.freezed.dart';
part 'theme_mode_local.g.dart';
part 'theme_mode_local.hive.dart';

@freezed
class ThemeModeLocal with _$ThemeModeLocal {
  const ThemeModeLocal._();

  @HiveType(typeId: 111, adapterName: 'ThemeModeLocalAdapter')
  factory ThemeModeLocal({
    @HiveField(0) required int index,
  }) = _ThemeModeLocal;

  factory ThemeModeLocal.fromJson(Map<String, dynamic> json) =>
      _$ThemeModeLocalFromJson(json);

  ThemeMode get themeMode => index == 0 ? ThemeMode.light : ThemeMode.dark;
}
