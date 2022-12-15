import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/cubit/auth_web/auth_web_state.dart';

@injectable
class AuthWebCubit extends Cubit<AuthWebState> {
  bool search = true;

  AuthWebCubit()
      : super(
          const AuthWebState.loading(),
        );

  void loaded() {
    emit(const AuthWebState.loaded());
  }
}
