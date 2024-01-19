import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'author.freezed.dart';
part 'author.g.dart';

@freezed
class Author with _$Author {
  const Author._();

  @HiveType(typeId: 14, adapterName: 'AuthorAdapter')
  const factory Author(
    @HiveField(0) String muid,
    @HiveField(1) List<String> firstNames,
    @HiveField(2) List<String> lastNames,
  ) = _Author;

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  @override
  String toString() => toJson().toString();

  String get fullName => '${firstNames[0]} ${lastNames[0]}';
}
