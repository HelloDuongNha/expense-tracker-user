import 'dart:async';
import 'dart:io' show Platform;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// Service for managing location operations: fetch current location, reverse geocode.
class LocationService {
  // Fetches the current device location with permission handling.
  Future<({double latitude, double longitude})> getCurrentLocation() async {
    // Check location service and permissions.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check and request location permission.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // Try cached position first, then request fresh one.
    Position? position = await Geolocator.getLastKnownPosition();

    if (position == null) {
      LocationSettings settings;
      if (Platform.isIOS) {
        settings = AppleSettings(accuracy: LocationAccuracy.medium);
      } else {
        settings = const LocationSettings(accuracy: LocationAccuracy.medium);
      }

      position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(const Duration(seconds: 15));
    }

    return (latitude: position.latitude, longitude: position.longitude);
  }

  // Converts lat/lng to a readable address string via reverse geocoding.
  Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks.first;

        // Assemble address from available placemark fields.
        List<String> parts = [];
        if ((p.street ?? '').isNotEmpty) {
          parts.add(p.street!);
        }
        if ((p.subLocality ?? '').isNotEmpty) {
          parts.add(p.subLocality!);
        }
        if ((p.locality ?? '').isNotEmpty) {
          parts.add(p.locality!);
        }
        if ((p.administrativeArea ?? '').isNotEmpty) {
          parts.add(p.administrativeArea!);
        }
        if ((p.country ?? '').isNotEmpty) {
          parts.add(p.country!);
        }
        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    } catch (_) {
      // Fall through to raw coordinates.
    }
    return '$latitude, $longitude';
  }
}

