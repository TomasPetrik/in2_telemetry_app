import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:scalesoft_app/ui/screens/bluetooth_off_screen.dart';
import 'package:scalesoft_app/ui/screens/find_beurer_device_screen.dart';

class BeurerScreen extends StatelessWidget {
  const BeurerScreen({Key? key}) : super(key: key);

  static const routeName = '/beurer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beurer')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<BluetoothState>(
              stream: FlutterBlue.instance.state,
              initialData: BluetoothState.unknown,
              builder: (c, snapshot) {
                final state = snapshot.data;
                if (state == BluetoothState.on) {
                  return const FindBeurerDeviceScreen();
                }
                return BluetoothOffScreen(state: state);
              },
            ),
          ),
        ],
      ),
    );
  }
}
