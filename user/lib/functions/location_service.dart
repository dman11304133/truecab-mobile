import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'functions.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStream;

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermission.unableToDetermine;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  static Future<Position?> getCurrentPosition(
      {LocationAccuracy accuracy = LocationAccuracy.high}) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  static Future<Position?> getLastKnownPosition() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      return null;
    }
  }

  static void startTracking(Function(LatLng) onLocationUpdate) {
    stopTracking();

    LocationSettings locationSettings = (defaultTargetPlatform == TargetPlatform.android)
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
          )
        : AppleSettings(
            accuracy: LocationAccuracy.high,
            activityType: ActivityType.otherNavigation,
            distanceFilter: 100,
          );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      onLocationUpdate(LatLng(position.latitude, position.longitude));
    });
  }

  static void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }
}
