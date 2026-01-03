import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tests/model/save_location_model.dart';
import 'package:tests/services/permission_service.dart';
import 'package:tests/services/storage_service.dart';

class FilesSystem extends StatefulWidget {
  const FilesSystem({super.key});

  @override
  State<FilesSystem> createState() => _FilesSystemState();
}

class _FilesSystemState extends State<FilesSystem> {
  final controller = TextEditingController();
  final fileNameController = TextEditingController(text: 'note.txt');
  String content = "";
  SaveLocation selectedLocation = SaveLocation.appDocuments;

  @override
  void initState() {
    super.initState();
    read();
  }

  @override
  void dispose() {
    controller.dispose();
    fileNameController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    try {
      // Ask for permission if saving to Downloads or Documents on Android
      if (selectedLocation != SaveLocation.appDocuments && Platform.isAndroid) {
        await PermissionService.requestStoragePermission();
      }

      // Get the file using StorageService
      final file = await StorageService.getFile(
        selectedLocation,
        fileNameController.text,
      );

      // Write the text to the file
      await file.writeAsString(controller.text);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to: ${file.path}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // If it's a permission error, show helpful message
      if (StorageService.isPermissionError(e)) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Needed'),
              content: Text(
                'Cannot save to ${selectedLocation.displayName}. '
                'Please grant storage permission.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    PermissionService.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      } else {
        // Show other errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> read() async {
    try {
      // Get the file using StorageService
      final file = await StorageService.getFile(
        selectedLocation,
        fileNameController.text,
      );

      // Check if file exists and read it
      if (await file.exists()) {
        final fileContent = await file.readAsString();
        setState(() {
          content = fileContent;
          controller.text = fileContent;
        });
      } else {
        setState(() {
          content = 'File does not exist yet.';
        });
      }
    } catch (e) {
      setState(() {
        content = 'Error reading file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File System')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Dropdown to select save location
            const Text(
              'Save Location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<SaveLocation>(
              value: selectedLocation,
              isExpanded: true,
              items: SaveLocation.values.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedLocation = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // File name input
            TextField(
              controller: fileNameController,
              decoration: const InputDecoration(
                labelText: "File Name",
                hintText: "e.g., note.txt",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Text content input
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Write Data",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Save and Read buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: save,
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: read,
                    icon: const Icon(Icons.folder_open),
                    label: const Text("Read"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Display file content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    content.isEmpty ? 'No content loaded' : content,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
