import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/cubit/loader/loader_state.dart';

@injectable
class LoaderCubit extends Cubit<LoaderState> {
  bool search = true;

  LoaderCubit()
      : super(
          const LoaderState.loading(),
        );

  void loaded() {
    emit(const LoaderState.loaded());
  }

  void loading() {
    emit(const LoaderState.loading());
  }
}
