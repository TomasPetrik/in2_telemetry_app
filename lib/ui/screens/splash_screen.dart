import 'package:flutter/material.dart';
import 'package:scalesoft_app/data/app_database.dart';

class SplashScreen extends StatelessWidget {
  final Future<AppSetting> Function() loadingFunction;
  final void Function(AppSetting) onLoaded;

  const SplashScreen({
    super.key,
    required this.loadingFunction,
    required this.onLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadingFunction().then((onLoaded)),
      builder: (context, snapshot) {
        return MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: Image.asset(
                  'assets/images/app_icon_64.png',
                  height: 64,
                  width: 64,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
