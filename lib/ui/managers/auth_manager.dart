import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class AuthManager extends StatelessWidget with BottomSheetMixin {
  const AuthManager({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ContentBloc userContentBloc = getIt<ContentBloc>();
    final AuthBloc authBloc = getIt<AuthBloc>();
    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        state.whenOrNull(
          handlingResponse: () {},
          authenticated: (credentials) {
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              useRootNavigator: true,
              builder: (context) => const LoadingIndicator(),
            );
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
          unauthenticated: () async {
            await showServerError(context);
            userContentBloc.add(const CheckLastLoggedUserContentEvent());
          },
          cancelled: () {},
        );
      },
      child: child,
    );
  }
}
