import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'functions.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStream;
  static bool _isRequestingPermission = false;

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkPermissions() async {
    if (_isRequestingPermission) {
      debugPrint('📍 [LOC_SERVICE] Permission request already in progress, waiting...');
      return await Geolocator.checkPermission();
    }

    _isRequestingPermission = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isRequestingPermission = false;
        return LocationPermission.unableToDetermine;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      _isRequestingPermission = false;
      return permission;
    } catch (e) {
      _isRequestingPermission = false;
      return LocationPermission.denied;
    }
  }

  static Future<Position?> getCurrentPosition({LocationAccuracy accuracy = LocationAccuracy.high}) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('📍 [LOC_SERVICE] getCurrentPosition failed or timed out: $e');
      return await Geolocator.getLastKnownPosition();
    }
  }

  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  static void startTracking(Function(LatLng, double) onLocationUpdate) {
    stopTracking();

    // Driver app needs more frequent updates for tracking
    LocationSettings locationSettings = (platform == TargetPlatform.android)
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // More frequent for drivers
            intervalDuration: const Duration(seconds: 5),
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationText: "Tracking your trip location",
              notificationTitle: "TrueCab Driver is active",
              enableWakeLock: true,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.high,
            activityType: ActivityType.otherNavigation,
            distanceFilter: 10,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
          );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      onLocationUpdate(LatLng(position.latitude, position.longitude), position.heading);
    });
  }

  static void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }
}
