import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/dark_mode.dart';
import 'package:scalesoft_app/ui/themes/light_mode.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class ContentManager extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ContentState state,
  ) onInit;
  final ThemeMode themeMode;

  const ContentManager({
    super.key,
    required this.onInit,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final ContentBloc userContentBloc = getIt<ContentBloc>();

    return BlocBuilder<ContentBloc, ContentState>(
      bloc: userContentBloc..add(const CheckLastLoggedUserContentEvent()),
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final initialWidget = state.when(
          initial: () => MaterialApp(
            key: UniqueKey(),
            title: 'Telemetry App',
            theme: LightMode.theme,
            darkTheme: DarkMode.theme,
            themeMode: themeMode,
            home: const Scaffold(
              body: Center(child: LoadingIndicator()),
            ),
          ),
          unauthenticated: () => onInit(context, state),
          onAppearanceChanged: () => onInit(context, state),
          onUserAdded: (userAccount) => onInit(context, state),
          activeSingleUser: (userAccount) => onInit(context, state),
          activeAllUsers: () => onInit(context, state),
        );

        return initialWidget;
      },
    );
  }
}
