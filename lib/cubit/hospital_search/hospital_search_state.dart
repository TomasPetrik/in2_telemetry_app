import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';

part 'hospital_search_state.freezed.dart';

@freezed
class HospitalSearchState with _$HospitalSearchState {
  const factory HospitalSearchState.initial() = _Initial;
  const factory HospitalSearchState.result({
    required Iterable<Hospital> hospitals,
  }) = _Result;
}
