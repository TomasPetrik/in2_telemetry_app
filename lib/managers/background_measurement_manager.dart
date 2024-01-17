import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/source_device_info.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/constants/native_code_constants.dart';
import 'package:scalesoft_app/cubit/background_measurement/background_measurement_cubit.dart';
import 'package:scalesoft_app/managers/ble_e8x_manager.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/utils/helpers/mac_address_helper.dart';

@singleton
class BackgroundMeasurementManager {
  final SyncService _syncService;
  final AccountDbProvider _accountDbProvider;
  final BackgroundMeasurementCubit _backgroundMeasurementCubit;
  final ReportService _reportService;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static const nativeCode = MethodChannel(NativeCodeConstants.methodChannelName);

  BackgroundMeasurementManager(
    this._syncService,
    this._accountDbProvider,
    this._backgroundMeasurementCubit,
    this._reportService,
  );

  void configureBackgroundServiceMethodCallHandler() {
    nativeCode.setMethodCallHandler((call) async {
      if (call.method != NativeCodeConstants.bluetoothSyncMethod) {
        debugPrint("Unsupported method called: ${call.method}");
        return Future.error("Unsupported method");
      }

      final devices = call.arguments[NativeCodeConstants.macAddressesKey] as List;
      await syncArmbandMeasurements(devices.map((x) => x.toString()));
    });
  }

  Future<void> updateBackgroundSynchronizationState() async {
    final assignedDevices = _getAssignedDevices();
    final associatedDevices = (await getAssociatedMacAddresses()).toSet();

    debugPrint("assigned devices count: ${assignedDevices.length}");
    debugPrint("associated devices count: ${associatedDevices.length}");

    if (associatedDevices.isEmpty || assignedDevices.isEmpty) {
      _backgroundMeasurementCubit.disabled();
    } else if (associatedDevices.containsAll(assignedDevices)) {
      _backgroundMeasurementCubit.enabled();
    } else {
      _backgroundMeasurementCubit.partial();
    }
  }

  Future<void> activateBackgroundSynchronization() async {
    final assignedDevices = _getAssignedDevices();

    await associateDevices(assignedDevices);
  }

  Future<void> deactivateBackgroundSynchronization() async {
    final associatedDevices = await getAssociatedMacAddresses();
    disassociateDevices(associatedDevices);
  }

  Future<void> removeUnassignedDevices() async {
    final assignedDevices = _getAssignedDevices().toList();
    final associatedDevices = (await getAssociatedMacAddresses()).toSet();

    final unassignedDevices = associatedDevices.whereNot(assignedDevices.contains);
    await disassociateDevices(unassignedDevices);
  }

  Iterable<MapEntry<UserAccount, Device>> _getUsersWithWatches() {
    final accounts = _accountDbProvider.getAll();
    final accountDevicePairs = accounts
        .expand<MapEntry<UserAccount, Device>>(
          (account) => (account.assignedDevices ?? []).map((device) => MapEntry(account, device)),
        )
        .where((pair) => pair.value.deviceModelType == DeviceModelType.e8x)
        .where((pair) => pair.value.bluetoothAddress != null);

    return accountDevicePairs;
  }

  Iterable<String> _getAssignedDevices() {
    return _getUsersWithWatches().map((x) => x.value.bluetoothAddress!).map(MacAddressHelper.normalizeFormat);
  }

  /// Uses CompanionDeviceManager to disassociate devices with the specified [macAddresses].
  /// Removes background service if no associated devices are left.
  Future<bool> disassociateDevices(Iterable<String> macAddresses) async {
    try {
      await nativeCode.invokeMethod(
        NativeCodeConstants.disassociateDevices,
        {NativeCodeConstants.macAddressesKey: macAddresses.toList()},
      );
      return true;
    } on PlatformException catch (e) {
      debugPrint("Disassociate devices: native code invocation failed: $e");
      _reportService.trackEvent(
        severity: Severity.error,
        message: e.toString(),
      );
      return false;
    }
  }

  /// Uses CompanionDeviceManager to associate devices with the specified [macAddresses].
  /// Reschedules (or creates) a background service that periodically calls [syncArmbandMeasurements]
  Future<bool> associateDevices(Iterable<String> macAddresses) async {
    try {
      await nativeCode.invokeMethod(
        NativeCodeConstants.associateDevices,
        {NativeCodeConstants.macAddressesKey: macAddresses.toList()},
      );
      return true;
    } on PlatformException catch (e) {
      debugPrint("Associate devices: native code invocation failed: $e");
      _reportService.trackEvent(
        severity: Severity.error,
        message: e.toString(),
      );
      return false;
    }
  }

  Future<void> syncArmbandMeasurements(Iterable<String> associatedAddresses) async {
    final accountDevicePairs = _getUsersWithWatches().where(
      (pair) => associatedAddresses.any((address) => MacAddressHelper.compare(address, pair.value.bluetoothAddress)),
    );

    final results = await Future.wait([
      for (final pair in accountDevicePairs) _getMeasurementsFromDevice(pair.key, pair.value),
    ]);

    final flatResults = results.expand((x) => x);

    await getIt<PendingResultsDbProvider>().saveAll(flatResults);

    // Update devices' lastMeasurementTimes
    for (final pair in accountDevicePairs) {
      _accountDbProvider.save(pair.key);
    }

    await _syncService.syncResults();
  }

  Future<Iterable<String>> getAssociatedMacAddresses() async {
    try {
      final addresses = await nativeCode.invokeListMethod<String>(NativeCodeConstants.getAssociatedDevices);
      return addresses?.map(MacAddressHelper.normalizeFormat) ?? [];
    } on PlatformException catch (e) {
      debugPrint("Associate devices: native code invocation failed: $e");
      _reportService.trackEvent(
        severity: Severity.error,
        message: e.toString(),
      );
      return [];
    }
  }

  Future<Iterable<Measurement>> _getMeasurementsFromDevice(
    UserAccount account,
    Device device,
  ) async {
    final watchManager = BleE8xManager();

    List<Measurement> results = [];

    final btDevice = BluetoothDevice(
      remoteId: DeviceIdentifier(MacAddressHelper.normalizeFormat(device.bluetoothAddress!)),
    );

    try {
      await btDevice.connect(timeout: const Duration(seconds: 30));
    } catch (e) {
      await _notificationsPlugin.show(
        1,
        localization.common_app_name,
        localization.watch_synchronization_failed,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scalesoft_android',
            'scalesoft_android_channel',
            channelDescription: 'scalesoft_android_channel_description',
            color: Color.fromARGB(255, 33, 100, 123),
            icon: "ic_notification_foreground",
          ),
        ),
      );
    }

    await watchManager.registerNotifications(btDevice);
    await watchManager.setTime(btDevice);
    results.addAll(await watchManager.getBatteryLevel(btDevice));
    results.addAll(await watchManager.getBloodPressureHistory(btDevice));
    results.addAll(await watchManager.getHeartRateHistory(btDevice));
    results.addAll(await watchManager.getOxygenSaturationHistory(btDevice));

    if (device.lastMeasurementTime != null) {
      results = results.where((x) => x.measurementDateTime?.isAfter(device.lastMeasurementTime!) ?? true).toList();
    }

    final lastMeasurementTime = results.map((x) => x.measurementDateTime!).max;
    device.lastMeasurementTime = lastMeasurementTime;

    return results.map(
      (x) => x.copyWith(
        patientMuid: account.user.muid,
        sourceDeviceWithMetadata: SourceDeviceInfo(
          sourceDevice: device,
        ),
      ),
    );
  }
}
