import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/cubit/background_measurement/background_measurement_state.dart';

@singleton
class BackgroundMeasurementCubit extends Cubit<BackgroundMeasurementState> {
  BackgroundMeasurementCubit() : super(BackgroundMeasurementState.disabled);

  void enabled() {
    debugPrint("Background measurement enabled");
    emit(BackgroundMeasurementState.enabled);
  }

  void disabled() {
    debugPrint("Background measurement disabled");
    emit(BackgroundMeasurementState.disabled);
  }

  void partial() {
    debugPrint("Background measurement partially enabled");
    emit(BackgroundMeasurementState.partial);
  }

  void setupError() {
    debugPrint("Background measurement setup failed");
    emit(BackgroundMeasurementState.setupError);
  }
}
