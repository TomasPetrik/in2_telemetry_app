import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/manual_measurement_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class ManualMeasurementRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'manual-measurement';
  static const path = '/manual-measurement/:userId/:measurementType';

  ManualMeasurementRoute({
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
          final userId = int.parse(state.pathParameters['userId']!);
          final measurementType =
              MeasurementType.values.firstWhere((x) => x.name == state.pathParameters['measurementType']);

          return BlocBuilder<UserCubit, UserCubitState>(
            bloc: getIt<UserCubit>(),
            builder: (context, userState) {
              final user = userState.allUsers.firstWhere((x) => x.id == userId);

              final measurementTypes = state.extra as Set<MeasurementType>? ?? user.hospital.enabledMeasurementTypes;

              return ManualMeasurementScreen(
                user: user,
                measurementType: measurementType,
                enabledMeasurementTypes: measurementTypes.toList(),
              );
            },
          );
        },
      ),
    );
  }
}
