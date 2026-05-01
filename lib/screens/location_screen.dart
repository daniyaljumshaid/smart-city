import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';

class LocationSelection {
  const LocationSelection({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  String toStorageString() {
    return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
  }

  static LocationSelection? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final regex = RegExp(
      r'Lat:\s*([-+]?\d+(?:\.\d+)?)\s*,\s*Lng:\s*([-+]?\d+(?:\.\d+)?)',
      caseSensitive: false,
    );

    final match = regex.firstMatch(value);
    if (match == null) return null;

    final lat = double.tryParse(match.group(1) ?? '');
    final lng = double.tryParse(match.group(2) ?? '');

    if (lat == null || lng == null) return null;
    return LocationSelection(latitude: lat, longitude: lng);
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, this.initialLocationText});

  final String? initialLocationText;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late LatLng selectedLocation;

  @override
  void initState() {
    super.initState();
    final initial = LocationSelection.tryParse(widget.initialLocationText);
    if (initial != null) {
      selectedLocation = LatLng(initial.latitude, initial.longitude);
      return;
    }

    // Default to Lahore coordinates when no location has been selected yet.
    selectedLocation = LatLng(31.5204, 74.3587);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(color: AppTheme.headingOnLight),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.panelDecoration(),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap anywhere on the map to set the issue location.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: selectedLocation,
                initialZoom: 14,
                onTap: (_, point) {
                  setState(() {
                    selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.classicon_vs_code',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F8FE),
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Text(
              'Selected: Lat ${selectedLocation.latitude.toStringAsFixed(6)}, Lng ${selectedLocation.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F3C54),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final selection = LocationSelection(
                    latitude: selectedLocation.latitude,
                    longitude: selectedLocation.longitude,
                  );

                  Navigator.pop(context, selection.toStorageString());
                },
                child: const Text('Confirm Location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
