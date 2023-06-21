import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/auth_web_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthManager extends StatelessWidget with BottomSheetMixin {
  const AuthManager({
    super.key,
    required this.child,
  });

  final Widget child;

  Future<void> _goToAppStore() async {
    if (Platform.isAndroid) {
      await launchUrl(
        EGoverement.googlePlayUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(
        EGoverement.appStoreUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

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
                  openEGoverment: (redirectUri) async {
                    try {
                      if (await canLaunchUrl(redirectUri)) {
                        await launchUrl(
                          redirectUri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        _goToAppStore();
                      }
                    } catch (e) {
                      _goToAppStore();
                    }
                  },
                  onCancelled: () {
                    authBloc.add(const CancelAuth());
                  },
                  onLoadingError: () {
                    authBloc.add(const ErrorLoadDataEvent());
                  },
                );
              },
            );
          },
          handlingResponse: () {
            Navigator.of(context).pop();
          },
          authenticated: (credentials) {
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              useRootNavigator: true,
              builder: (context) => const LoadingIndicator(),
            );
            authBloc.add(const VerifyUser());
          },
          userVerified: (userAccount) => {
            Navigator.of(context).pop(),
            userContentBloc
                .add(OnUserAddedContentEvent(userAccount: userAccount)),
          },
          inactiveUserRemoved: (userAccount) {},
          errorLoadData: () {
            Navigator.of(context).pop();
            showServerError(context);
          },
          unauthenticated: () {
            Navigator.of(context).pop();
            showServerError(context);
          },
          cancelled: () {
            Navigator.of(context).pop();
          },
        );
      },
      child: child,
    );
  }
}
