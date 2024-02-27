import 'package:json_annotation/json_annotation.dart';

part 'author_contract.g.dart';

@JsonSerializable()
class AuthorContract {
  final String muid;
  final List<String> firstNames;
  final List<String> lastNames;

  const AuthorContract({
    required this.muid,
    required this.firstNames,
    required this.lastNames,
  });

  factory AuthorContract.fromJson(Map<String, dynamic> json) => _$AuthorContractFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorContractToJson(this);

  @override
  String toString() => toJson().toString();

  String get fullName => [...firstNames, ...lastNames].join(' ');

  ;
}