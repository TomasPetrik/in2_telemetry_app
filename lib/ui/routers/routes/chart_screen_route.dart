import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/chart_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class ChartRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'chart';
  static const path = '/chart/:dateTime/:userId/:measurementType';

  ChartRoute({
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
          final dateTimeString = state.pathParameters['dateTime']!;
          final initDt = DateTime.parse(dateTimeString);
          final measurementTypeName = state.pathParameters['measurementType']!;
          final measurementType = MeasurementType.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );

          return BlocBuilder<UserCubit, UserCubitState>(
            bloc: getIt<UserCubit>(),
            builder: (context, state) {
              return ChartScreen(
                initDt: initDt,
                userAccount: state.allUsers.firstWhere((x) => x.id == userId),
                measurementType: measurementType,
              );
            },
          );
        },
      ),
    );
  }
}
