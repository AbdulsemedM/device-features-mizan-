import 'package:flutter/material.dart';

class FilesSystem extends StatefulWidget {
  const FilesSystem({super.key});

  @override
  State<FilesSystem> createState() => _FilesSystemState();
}

class _FilesSystemState extends State<FilesSystem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File System')),
      body: Center(
        child: Text('File System Screen'),
      ),
    );
  }
}