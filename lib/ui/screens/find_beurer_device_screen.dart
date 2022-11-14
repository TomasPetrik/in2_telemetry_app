import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class FindBeurerDeviceScreen extends StatefulWidget {
  const FindBeurerDeviceScreen({super.key});

  @override
  State<FindBeurerDeviceScreen> createState() => _FindBeurerDeviceScreenState();
}

class _FindBeurerDeviceScreenState extends State<FindBeurerDeviceScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? device;
  List<String> events = [];
  StreamSubscription? subscription;

  late BluetoothService bpService;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (await checkPermission()) {
        findDevice();
      }
    });
  }

  Future<bool> checkPermission() async {
    if (!await Permission.bluetoothScan.isGranted) {
      PermissionStatus status = await Permission.bluetoothScan.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    if (!await Permission.bluetoothConnect.isGranted) {
      PermissionStatus status = await Permission.bluetoothConnect.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }

    if (!await Permission.bluetoothAdvertise.isGranted) {
      PermissionStatus status = await Permission.bluetoothAdvertise.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void findDevice() {
// Listen to scan results

    subscription = flutterBlue.scanResults.listen((results) async {
      // do something with scan results

      debugPrint('devices: ${results.length}');

      for (final ScanResult r in results) {
        device = r.device;
        if (device?.name == 'BM77') {
          debugPrint('${device?.name} rssi: ${r.rssi}');

          setState(() {
            events.add('Found ${device?.name}');
          });

          flutterBlue.stopScan();

          setState(() {
            events.add('Connecting to ${device?.name}..');
          });
          await device!.connect();

          setState(() {
            events.add('Connected to ${device?.name}');
          });
          pingDevice(device!);

          /*
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return DeviceScreen(device: device!);
              },
            ),
          );
          */

          break;
        }
      }
    });

    /*
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (final ScanResult r in results) {
        debugPrint('${r.device.name} found! rssi: ${r.rssi}');
      }
    });
    */

    // Start scanning
    flutterBlue.startScan(timeout: const Duration(seconds: 10));
    events.add('Looking for BM77');
    setState(() {});
  }

  Future<void> pingDevice(BluetoothDevice device) async {
    /*
    setState(() {
      events.add('Requesting MTU = 20..');
    });

    await device.requestMtu(20);
    */

    setState(() {
      events.add('Requested, discovering services..');
    });

    setState(() {
      events.add('Discovering services..');
    });

    List<BluetoothService> services = await device.discoverServices();

    setState(() {
      events.add('Discovered ${services.length} services');
    });

    for (final service in services) {
      setState(() {
        events.add('Discovered service ${service.uuid}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: events
            .map(
              Text.new,
            )
            .toList(),
      ),
      /*Column(
        children: [
          Expanded(
            child: AvatarGlow(
              glowColor: Colors.blue,
              endRadius: 200.0,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              child: Material(
                elevation: 0,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  radius: 100.0,
                  child: const SizedBox(
                    height: 50,
                    child: Center(child: Text('Connecting to device')),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
*/
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    flutterBlue.stopScan();
    device?.disconnect();
    super.dispose();
  }
}
