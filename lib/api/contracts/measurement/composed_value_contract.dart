import 'package:json_annotation/json_annotation.dart';

part 'composed_value_contract.g.dart';

@JsonSerializable(explicitToJson: true)
class ComposedValueContract {
  final double? firstValue;
  final double? secondValue;

  const ComposedValueContract({this.firstValue, this.secondValue});

  factory ComposedValueContract.fromJson(Map<String, dynamic> json) => _$ComposedValueContractFromJson(json);

  Map<String, dynamic> toJson() => _$ComposedValueContractToJson(this);

  @override
  String toString() => toJson().toString();
}
