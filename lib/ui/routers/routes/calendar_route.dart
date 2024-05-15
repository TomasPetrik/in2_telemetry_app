import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/calendar_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class CalendarRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'calendar';
  static const path = '/calendar';

  CalendarRoute({
    required super.navigator,
    super.routes,
  });

  @override
  GoRoute get route {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      parentNavigatorKey: navigator,
      pageBuilder: pageBuilder(
        withTransition: false,
        builder: (state) {
          final preSelectedDt = getIt<UserCubit>().preSelectedDtRestoration;
          final carePlansIds = state.extra as List<int>?;

          final syncBloc = getIt<SyncBloc>();

          return BlocBuilder<SyncBloc, SyncState>(
            bloc: syncBloc,
            buildWhen: (previous, current) {
              // We don't want to rebuild when state changes to none (usually from synced)
              // This happens on a timer after every sync

              final previousIsNone = previous.maybeWhen(orElse: () => false, none: () => true);
              final currentIsNone = current.maybeWhen(orElse: () => false, none: () => true);

              return previousIsNone || !currentIsNone;
            },
            builder: (context, state) {
              final showCalendar = state.whenOrNull(inProgress: () => false) ?? true;

              if (showCalendar) {
                return CalendarScreen(
                  carePlanIds: carePlansIds,
                  preSelectedDt: preSelectedDt,
                );
              }
              return const LoadingIndicator();
            },
          );
        },
      ),
    );
  }
}
