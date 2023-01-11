import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/cubit/hospital_search/hospital_search_state.dart';

@injectable
class HospitalSearchCubit extends Cubit<HospitalSearchState> {
  HospitalSearchCubit() : super(const HospitalSearchState.initial());

  void search({required String criteria, required List<Hospital> initialList}) {
    final result = initialList.where((hospital) => hospital.title.contains(criteria));
    emit(HospitalSearchState.result(hospitals: result));
  }
}
