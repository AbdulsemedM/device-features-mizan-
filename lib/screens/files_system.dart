import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FilesSystem extends StatefulWidget {
  const FilesSystem({super.key});

  @override
  State<FilesSystem> createState() => _FilesSystemState();
}

class _FilesSystemState extends State<FilesSystem> {
  final controller = TextEditingController();
  String content = "";

  @override
  void initState() {
    super.initState();
    read();
  }

  Future<File> getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/note.txt');
  }

  Future<void> save() async {
    try {
      final file = await getFile();
      await file.writeAsString(controller.text);
      print("file path: ${file.path}");
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  Future<void> read() async {
    try {
      final file = await getFile();
      if (await file.exists()) {
        final fileContent = await file.readAsString();
        setState(() {
          content = fileContent;
          controller.text = fileContent;
        });
      }
    } catch (e) {
      print("Error reading file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File System')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Write Data"),
            ),
            SizedBox(height: 15),
            ElevatedButton(onPressed: save, child: Text("Save")),
            ElevatedButton(onPressed: read, child: Text("Read")),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text("File Content: \n$content"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
