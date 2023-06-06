import 'package:scalesoft_app/configuration/configuration_production.dart';
import 'package:scalesoft_app/configuration/configuration_base.dart';
import 'package:scalesoft_app/configuration/configuration_staging.dart';

enum Flavor { staging, production }

class Config {
  static Flavor appFlavor = Flavor.production;

  static BaseConfiguration get value {
    return switch (appFlavor) {
      Flavor.production => ProductionConfiguration(),
      Flavor.staging => StagingConfiguration()
    };
  }
}
