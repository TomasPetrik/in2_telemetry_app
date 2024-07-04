import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/cubit/background_measurement_status_state.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';

@singleton
class BackgroundMeasurementStatusCubit extends Cubit<BackgroundMeasurementStatusState> {
  final BackgroundMeasurementManager _backgroundMeasurementManager;

  BackgroundMeasurementStatusCubit(this._backgroundMeasurementManager) : super(BackgroundMeasurementStatusState(false));

  Future<void> updateState() async {
    final shouldDisplayWatchSetupButton =
        (await _backgroundMeasurementManager.anyUserWatchAssignmentExists()) && Platform.isAndroid;
    emit(BackgroundMeasurementStatusState(shouldDisplayWatchSetupButton));
  }
}
