import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/ui/dialogs/bottom_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/device_selector_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/planned_measurement_time_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/user_hospital_selection_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/user_selection_dialog.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_time_picker.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

mixin BottomSheetMixin {
  Future<DateTime?> showRestrictedTimePicker({
    required final BuildContext context,
    required final DateTime currentDateTime,
  }) async {
    final result = await showModalBottomSheet<DateTime?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 0.4,
          child: ScaleTimePicker(),
        );
      },
    );
    return result;
  }

  Future<void> showServerError(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomDialog.serverError(context: context);
      },
    );
  }

  Future<bool?> showAccounRemovalConfirmation({
    required final BuildContext context,
    required final String accountName,
  }) async {
    final result = await showModalBottomSheet<bool?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BottomDialog.accountConfirmationRemoval(
          context: context,
          accountName: accountName,
        );
      },
    );
    return result;
  }

  Future<PlannedPeriodSelection?> showPlannedMeasurementsSelector(
    final BuildContext context,
    final PlanWhenPeriod? whenPeriod,
    final Map<PlanWhenPeriod, int> measurements,
  ) async {
    final selected = await showModalBottomSheet<PlannedPeriodSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PlannedMeasurementTimeDialog(
          whenPeriod: whenPeriod ?? PlanWhenPeriod.today,
          measurements: measurements,
        );
      },
    );
    return selected;
  }

  Future<ResultPeriodSelection?> showResultsWhenSelector(
    final BuildContext context,
    final ResultsWhenPeriod? whenPeriod,
    final Map<ResultsWhenPeriod, int?> fulfillmentPlan,
  ) async {
    final selected = await showModalBottomSheet<ResultPeriodSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ResultsTimeDialog(
          whenPeriod: whenPeriod ?? ResultsWhenPeriod.today,
          fulfillmentPlan: fulfillmentPlan,
        );
      },
    );
    return selected;
  }

  Future<UserSelection?> selectHospital({
    required final BuildContext context,
  }) async {
    final selectedHospitalResult = await showModalBottomSheet<UserSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const FractionallySizedBox(
          heightFactor: 1.0,
          child: Padding(
            padding: EdgeInsets.only(
              top: 44,
            ),
            child: HospitalSelectionDialog(),
          ),
        );
      },
    );

    return selectedHospitalResult;
  }

  Future<SwitchUserResult?> switchUser({
    required final BuildContext context,
    final bool? supportMultiUser,
  }) async {
    final userHospitalSelectionResult =
        await showModalBottomSheet<UserSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return UserHospitalSelectionDialog(
          supportMultiUser: supportMultiUser,
        );
      },
    );

    if (userHospitalSelectionResult?.action ==
        SwitchUserAction.selectedMultiUser) {
      return SwitchUserResult(activeMultiUser: true);
    } else if (userHospitalSelectionResult?.action ==
        SwitchUserAction.addUserAccount) {
      return SwitchUserResult(addNewUser: true);
    } else if (userHospitalSelectionResult?.action ==
        SwitchUserAction.selectedUser) {
      return SwitchUserResult(
        selectedUser: userHospitalSelectionResult!.selectedUser,
      );
    } else if (userHospitalSelectionResult?.action ==
        SwitchUserAction.selectedHospital) {
      final userSelection = await _selectUserFromHospital(
        context: context,
        hospital: userHospitalSelectionResult!.selectedHospital!,
        userAccounts: userHospitalSelectionResult.hospitalUsers!,
      );

      if (userSelection?.action == SwitchUserAction.addUserAccount) {
        return SwitchUserResult(addNewUser: true);
      } else {
        return SwitchUserResult(selectedUser: userSelection?.selectedUser);
      }
    } else {
      return SwitchUserResult();
    }
  }

  Future<UserSelection?> _selectUserFromHospital({
    required final BuildContext context,
    required Hospital hospital,
    required List<UserAccount> userAccounts,
  }) async {
    final userSelectionResult = await showModalBottomSheet<UserSelection>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return UserSelectionDialog(
          hospital: hospital,
          userAccounts: userAccounts,
        );
      },
    );

    return userSelectionResult;
  }

  void doMeasurement({
    required final BuildContext context,
    required final String userId,
    final MeasurementType? selectedMeasurementType,
    final Set<MeasurementType>? allMeasurementTypes,
  }) async {
    if (selectedMeasurementType == null ||
        Constants.supportedDevices.any(
          (supportedDevice) => supportedDevice.supportedMeasurementTypes!
              .contains(selectedMeasurementType),
        )) {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DeviceSelectorDialog(
            userId: userId,
            selectedMeasurementType: selectedMeasurementType,
            allMeasurementTypes: allMeasurementTypes,
          );
        },
      );
    } else {
      GoRouter.of(context).pushNamed(
        ManualMeasurementRoute.name,
        extra: [userId, selectedMeasurementType],
      );
    }
  }
}

class DeviceSelectionResult {
  bool? manualMeasurement;

  DeviceSelectionResult({
    this.manualMeasurement,
  });
}

enum SwitchUserAction {
  addUserAccount,
  selectedUser,
  selectedHospital,
  selectedMultiUser,
}

class SwitchUserResult {
  UserAccount? selectedUser;
  bool? addNewUser;
  bool? activeMultiUser;

  SwitchUserResult({
    this.selectedUser,
    this.addNewUser,
    this.activeMultiUser,
  });
}

class UserSelection {
  UserAccount? selectedUser;
  Hospital? selectedHospital;
  List<UserAccount>? hospitalUsers;
  SwitchUserAction action;

  UserSelection({
    required this.action,
    this.selectedUser,
    this.selectedHospital,
    this.hospitalUsers,
  });
}

class PlannedPeriodSelection {
  PlanWhenPeriod? selectedPeriod;
  bool? showCalendar;

  PlannedPeriodSelection({this.selectedPeriod, this.showCalendar})
      : assert(
          selectedPeriod != null || showCalendar != null,
          'Either selectedPeriod or showCalendar should be set !',
        );
}

class ResultPeriodSelection {
  ResultsWhenPeriod? selectedPeriod;
  bool? showCalendar;

  ResultPeriodSelection({this.selectedPeriod, this.showCalendar})
      : assert(
          selectedPeriod != null || showCalendar != null,
          'Either selectedPeriod or showCalendar should be set !',
        );
}
