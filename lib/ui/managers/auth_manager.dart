import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/auth_web_screen.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class AuthManager extends StatelessWidget {
  const AuthManager({super.key});

  @override
  Widget build(BuildContext context) {
    final ContentBloc userContentBloc = getIt<ContentBloc>();
    final AuthBloc authBloc = getIt<AuthBloc>();
    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        state.whenOrNull(
          openAuthRequest: (authUri) {
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
            GoRouter.of(context).pop();
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              useRootNavigator: true,
              builder: (context) => const LoadingIndicator(),
            );
            authBloc.add(const VerifyUser());
          },
          userVerified: (userAccount) => {
            GoRouter.of(context).pop(),
            userContentBloc
                .add(OnUserAddedContentEvent(userAccount: userAccount)),
          },
          inactiveUserRemoved: (userAccount) {
            GoRouter.of(context).pop();
          },
        );
      },
      child: const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
    );
  }
}
