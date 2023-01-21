import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

mixin PageBuilderMixin {
  GoRouterPageBuilder pageBuilder({
    required Widget Function(GoRouterState state) builder,
    bool withTransition = true,
  }) {
    return (context, state) {
      return withTransition
          ? CupertinoPage(
              key: state.pageKey,
              child: builder(state),
            )
          : NoTransitionPage(
              key: state.pageKey,
              child: builder(state),
            );
    };
  }
}
