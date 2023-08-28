import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/manual_measurement_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class ManualMeasurementRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'manual-measurement';
  static const path =
      '/manual-measurement/:userId/:measurementType/:showAllMeasurementTypes';

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
          final userId = state.params['userId']!;
          final measurementTypeName = state.params['measurementType'];
          final showAllMeasurementTypes =
              bool.parse(state.params['showAllMeasurementTypes'] ?? 'false');

          final measurementType = MeasurementTypeContract.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );
          final userAccount = getIt<AccountDbProvider>().get(userId)!;

          late List<MeasurementTypeContract> displayedMeasurementTypes;

          final supportedUserMeasurementTypes =
              CarePlanHelper.getMeasurementTypes(userAccount.carePlans!);

          if (showAllMeasurementTypes ||
              supportedUserMeasurementTypes.isEmpty) {
            displayedMeasurementTypes =
                userAccount.hospital?.enabledMeasurementTypes ??
                    Constants.supportedMeasurementTypes.toList();
          } else {
            displayedMeasurementTypes = supportedUserMeasurementTypes.toList();
          }

          return ManualMeasurementScreen(
            userId: userId,
            measurementType: measurementType,
            enabledMeasurementTypes: displayedMeasurementTypes,
          );
        },
      ),
    );
  }
}
