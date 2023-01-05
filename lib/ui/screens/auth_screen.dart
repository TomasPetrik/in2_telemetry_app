import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/auth_web_screen.dart';
import 'package:scalesoft_app/ui/screens/home_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final AuthBloc authBloc = getIt<AuthBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: authBloc,
        listener: (context, state) {
          state.whenOrNull(
            openAuthReqest: (authUri) {
              showDialog(
                context: context,
                builder: (context) {
                  return AuthWebScreen(
                    authUri: authUri,
                    onRedirect: (redirectUri) {
                      authBloc.add(
                        HandleAuthResponse(authRespUri: redirectUri),
                      );
                    },
                    onCancelled: () {
                      authBloc.add(const CancelAuth());
                    },
                  );
                },
              );
            },
            authenticated: (credentials) {
              Navigator.of(context, rootNavigator: true).pop();
              authBloc.add(const VerifyUser());
            },
            userVerified: (userAccount) => {
              /*
              Navigator.pushReplacementNamed(
                context,
                HomeScreen.routeName,
                arguments: userInfo,
              )
              */

              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => HomeScreen(
                    userAccount: userAccount!,
                  ),
                ),
              )
            },
          );
        },
        builder: (context, state) {
          Widget? stateWidget = state.whenOrNull<Widget>(
            unauthenticated: (exception) {
              return Text(
                'Unauthenticated',
                style: ScaleTextStyles.title,
              );
            },
            logoutSuccess: () {
              return Text(
                'Logged out',
                style: ScaleTextStyles.title,
              );
            },
            cancelled: () {
              return Text(
                'Cancelled',
                style: ScaleTextStyles.title,
              );
            },
          );

          stateWidget ??= const LoadingIndicator();

          return Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    stateWidget,
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
