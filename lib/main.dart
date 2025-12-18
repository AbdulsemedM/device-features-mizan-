import 'package:flutter/material.dart';
import 'package:tests/screens/camera_image_screen.dart';
import 'package:tests/screens/files_system.dart';
import 'package:tests/screens/location_map_screen.dart';
import 'package:tests/screens/push_notification.dart';

void main() {
  runApp(const DeviceFeatures());
}

class DeviceFeatures extends StatelessWidget {
  const DeviceFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Features',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final screens = [
    ("Camera and Image", CameraImageScreen()),
    ("Location and Map", LocationMapScreen()),
    ("Push notification", PushNotification()),
    ("File system", FilesSystem()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Features')),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(12.0),
            child: ListTile(
              title: Text(screens[index].$1),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screens[index].$2),
                );
              },
              trailing: Icon(Icons.arrow_forward),
            ),
          );
        },
      ),
    );
  }
}
