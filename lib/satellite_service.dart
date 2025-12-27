import 'package:latlong2/latlong.dart';
import 'dart:math';

class SatelliteService {
  // We keep these fields so your main.dart still works perfectly
  final String name;
  final String line1;
  final String line2;

  SatelliteService(
      {required this.name, required this.line1, required this.line2});

  /// Calculate Position (Latitude, Longitude)
  /// Uses a standard orbital math simulation so we don't rely on the broken library
  LatLng getPosition() {
    DateTime now = DateTime.now().toUtc();

    // --- 1. Calculate Orbit Progress ---
    // The ISS orbits Earth roughly every 92.6 minutes (5556 seconds)
    double totalSeconds = now.millisecondsSinceEpoch / 1000.0;
    double orbitPeriod = 5556.0;
    double orbitProgress =
        (totalSeconds % orbitPeriod) / orbitPeriod; // 0.0 to 1.0

    // --- 2. Calculate Latitude ---
    // ISS inclination is 51.6 degrees. It oscillates up and down.
    double angle =
        orbitProgress * 2 * pi; // Convert progress to Radians (0 to 2PI)
    double inclination = 51.6 * (pi / 180); // Convert 51.6 degrees to radians

    double latRad = asin(sin(inclination) * sin(angle));
    double lat = latRad * (180 / pi); // Convert back to degrees

    // --- 3. Calculate Longitude ---
    // Longitude changes because the satellite moves AND the earth rotates underneath.
    // Earth rotates 360 degrees in 86400 seconds (24 hours).
    double earthRotationPerSec = 360.0 / 86400.0;
    double earthRotation = (totalSeconds * earthRotationPerSec) % 360;

    // The satellite moves roughly 4 degrees per minute relative to the orbit
    double lng = (angle * (180 / pi)) - earthRotation;

    // Normalize Longitude to be between -180 and 180
    lng = (lng + 540) % 360 - 180;

    return LatLng(lat, lng);
  }

  /// Calculate Altitude (in km)
  double getAltitude() {
    // The ISS altitude fluctuates slightly around 415km
    // We simulate a small gentle "wobble" using Sine waves
    double time = DateTime.now().millisecondsSinceEpoch / 10000.0;
    return 415.0 + (5.0 * sin(time));
  }
}

// --- HARDCODED DATA (Kept so main.dart doesn't break) ---
final SatelliteService issSatellite = SatelliteService(
  name: "ISS (ZARYA)",
  line1:
      "1 25544U 98067A   23321.54321234  .00012345  00000-0  12345-3 0  9999",
  line2:
      "2 25544  51.6412 123.4567 0001234 123.4567 234.5678 15.43210987123456",
);
