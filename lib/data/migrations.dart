import 'package:scalesoft_app/data/schema_versions.dart';

final upgradeStrategy = stepByStep(from1To2: from1To2);

Future<void> from1To2(m, schema) async {
    await m.createTable(schema.deviceInstructions);
}

