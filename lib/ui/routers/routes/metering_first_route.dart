import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/metering_first_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeteringFirstRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'metering-first';
  static const path = '/metering-first/:userId/:measurementType';

  MeteringFirstRoute({
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
          final userId = state.params['userId']!;
          final userAccount = getIt<AccountDbProvider>().get(userId)!;
          final measurementTypeName = state.params['measurementType'];
          MeasurementType? measurementType;
          if (measurementTypeName?.isNotEmpty == true) {
            measurementType = MeasurementType.values.firstWhereOrNull(
              (measurementType) => measurementType.name == measurementTypeName,
            );
          }
          final supportedUserMeasurementTypes =
              CarePlanHelper.getMeasurementTypes(userAccount.carePlans!);

          final allMeasurentTypes = MeasurementType.values.toSet();

          return MeteringFirstScreen(
            userId: userId,
            selectedMeasurementType: measurementType,
            allMeasurementTypes: supportedUserMeasurementTypes.isNotEmpty
                ? supportedUserMeasurementTypes
                : allMeasurentTypes,
          );
        },
      ),
    );
  }
}
