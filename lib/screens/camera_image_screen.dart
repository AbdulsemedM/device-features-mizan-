import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraImageScreen extends StatefulWidget {
  const CameraImageScreen({super.key});

  @override
  State<CameraImageScreen> createState() => _CameraImageScreenState();
}

class _CameraImageScreenState extends State<CameraImageScreen> {
  final picker = ImagePicker();
  File? image;

  Future<void> pickImage(ImageSource src) async {
    final file = await picker.pickImage(source: src);
    if (file != null) {
      setState(() {
        image = File(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera and Image')),
      body: Center(
        child: image != null
            ? Image.file(image!, height: 350)
            : Text('No image is selected.'),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'c',
            child: Icon(Icons.camera_alt),
            onPressed: () {
              pickImage(ImageSource.camera);
            },
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'g',
            child: Icon(Icons.photo),
            onPressed: () {
              pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
