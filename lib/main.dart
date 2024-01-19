import 'package:scalesoft_app/app.dart';
import 'package:scalesoft_app/config.dart';

Future<void> main() async {
  Config.appFlavor = Flavor.production;
  await run();
}

@pragma('vm:entry-point')
Future<void> watchSyncBackgroundTask() async {
  await watchSyncBackgroundTaskImpl();
}
