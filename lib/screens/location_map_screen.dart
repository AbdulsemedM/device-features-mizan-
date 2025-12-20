import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationMapScreen extends StatefulWidget {
  const LocationMapScreen({super.key});

  @override
  State<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  bool loading = false;
  String? address;
  Position? position;

  Future<void> getLocationAddress() async {
    setState(() {
      loading = true;
    });

    var permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json",
    );

    final response = await http.get(
      url,
      headers: {"User-Agent": "Flutter App"},
    );

    final data = json.decode(response.body);

    print(data);

    setState(() {
      position = pos;
      address = data['display_name'];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location and Map')),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : position == null
            ? ElevatedButton(
                onPressed: getLocationAddress,
                child: Text("Get my location"),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Latitude: ${position!.latitude}\nLongitude: ${position!.longitude}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    "Address:\n${address ?? 'Address not found'}",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: getLocationAddress,
                    child: Text("Refresh"),
                  ),
                ],
              ),
      ),
    );
  }
}
