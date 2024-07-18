import 'package:scalesoft_app/app.dart';

Future<void> main() async {

  await run();
}

@pragma('vm:entry-point')
Future<void> watchSyncBackgroundTask() async {
  await watchSyncBackgroundTaskImpl();
}
