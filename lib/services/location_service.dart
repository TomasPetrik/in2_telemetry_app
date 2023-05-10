import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';

@lazySingleton
class LocationService {
  LocationService();

  Future<ThemeMode> getThemeModeByDayLight() async {
    Position? currentLocation = await getCurrentLocation();
    final latitude = currentLocation?.latitude ?? Constants.defaultLat;
    final longitude = currentLocation?.longitude ?? Constants.defaultLng;

    var sunriseSunset = getSunriseSunset(
      latitude,
      longitude,
      Duration.zero,
      DateTime.now(),
    );

    DailyTime? sunrise = sunriseSunset.sunrise.toLocal().toTimeOfDay();
    DailyTime? sunset = sunriseSunset.sunset.toLocal().toTimeOfDay();

    debugPrint(
      'sunrise: $sunrise , sunset: $sunset , position: $latitude, $longitude',
    );

    final dtNow = DateTime.now().toTimeOfDay();
    if (sunset.isBefore(dtNow) == true || sunrise.isAfter(dtNow) == true) {
      debugPrint('is dark mode: ${dtNow.toString()}');
      return ThemeMode.dark;
    } else {
      debugPrint('is light mode: ${dtNow.toString()}');
      return ThemeMode.light;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      // Test if location services are enabled.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        debugPrint('Location services are disabled.');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        debugPrint(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return null;
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the last know position
      // if is not detected yet, try to find new position of the device.
      final lastKnowPosition = await Geolocator.getLastKnownPosition();

      return lastKnowPosition ?? await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }
}
