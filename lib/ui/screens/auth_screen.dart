import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/dashboard_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  static const routeName = '/auth';

  final AuthBloc authBloc = getIt<AuthBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: authBloc,
        listener: (context, state) {
          if (state is Authenticated) {
            authBloc.add(const VerifyUser());
          } else if (state is UserVerified) {
            Navigator.pushReplacementNamed(
              context,
              DashboardScreen.routeName,
              arguments: state.userInfo,
            );
          }
        },
        builder: (context, state) {
          Widget stateInfo;
          if (state is Unauthenticated) {
            stateInfo = Text(
              'Unauthenticated',
              style: ScaleTextStyles.title,
            );
          } else if (state is LogoutSuccess) {
            stateInfo = Text(
              'Logged out',
              style: ScaleTextStyles.title,
            );
          } else {
            stateInfo = const LoadingIndicator();
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    stateInfo,
                    Gaps.gap20,
                    TextButton(
                      onPressed: () {
                        authBloc.add(const Authenticate());
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
