import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'satellite_service.dart'; // Make sure this matches your file name

void main() {
  runApp(const MaterialApp(home: SatTrackerApp()));
}

class SatTrackerApp extends StatefulWidget {
  const SatTrackerApp({super.key});

  @override
  State<SatTrackerApp> createState() => _SatTrackerAppState();
}

class _SatTrackerAppState extends State<SatTrackerApp> {
  // We start at latitude 0, longitude 0 until data loads
  LatLng currentPos = const LatLng(0, 0);
  double currentAlt = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the loop to update position every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateSatellitePosition();
    });
  }

  void updateSatellitePosition() {
    setState(() {
      // 1. Get fresh data from our service
      currentPos = issSatellite.getPosition();
      currentAlt = issSatellite.getAltitude();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SatTracker Live"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(0, 0), // Start view at equator
          initialZoom: 2.0, // Zoom out to see the world
        ),
        children: [
          // Layer 1: The Map Images (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.sat_tracker.app',
          ),

          // Layer 2: The Satellite Icon
          MarkerLayer(
            markers: [
              Marker(
                point: currentPos,
                width: 45,
                height: 45,
                child: GestureDetector(
                  onTap: () => _showInfo(), // Click to see details
                  child: const Icon(
                    Icons.satellite_alt,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Shows the popup card at the bottom
  void _showInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(issSatellite.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Latitude:"),
                Text(currentPos.latitude.toStringAsFixed(4)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Longitude:"),
                Text(currentPos.longitude.toStringAsFixed(4)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Altitude:"),
                Text("${currentAlt.toStringAsFixed(1)} km"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
