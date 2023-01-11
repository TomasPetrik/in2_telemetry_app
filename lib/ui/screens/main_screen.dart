import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/user_content/user_content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/user_content_event.dart';
import 'package:scalesoft_app/bloc/user_content/user_content_state.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/storage.dart';
import 'package:scalesoft_app/ui/screens/auth_web_screen.dart';
import 'package:scalesoft_app/ui/screens/home_screen.dart';
import 'package:scalesoft_app/ui/screens/onboarding_account_added_screen.dart';
import 'package:scalesoft_app/ui/screens/onboarding_add_account_screen.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = getIt<AuthBloc>();
    final UserContentBloc userContentBloc = getIt<UserContentBloc>();

    final accountDbProvider = getIt<AccountDbProvider>();
    final session = getIt<Session>();

    return BlocConsumer<UserContentBloc, UserContentState>(
      bloc: userContentBloc..add(const CheckLastLoggedUserContentEvent()),
      listener: (context, state) {
        
      },
      builder: (context, state) {
        final screen = state.whenOrNull(
          initial: () => const Scaffold(
            body: Center(child: LoadingIndicator()),
          ),

          noUser: OnboardingAddAccountScreen.new,
          //activeAllUsers: HomeScreen.new,
          activeSingleUser: (userAccount) => HomeScreen(
            userAccount: userAccount,
          ),
        );

        return BlocListener<AuthBloc, AuthState>(
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
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => OnboardingAccountAddedScreen(userAccount: userAccount),
                  ),
                ),
              },
              logoutSuccess: () {
                final lastUsedAccount = accountDbProvider.getLast();

                if (lastUsedAccount != null) {
                  session.userAccount = lastUsedAccount;
                  session.token = lastUsedAccount.authToken;

                  Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(
                      builder: (c) => HomeScreen(
                        userAccount: lastUsedAccount,
                      ),
                    ),
                    (route) => false,
                  );
                } else {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    CupertinoPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                }
              },
            );
          },
          child: screen ??
              const Scaffold(
                body: Center(
                  child: Text('Uknow screen'),
                ),
              ),
        );
      },
    );
  }
}
