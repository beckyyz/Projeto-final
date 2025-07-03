import 'package:flutter/material.dart';
import 'dart:io';

class PhotoViewScreen extends StatelessWidget {
  final String photoPath;

  const PhotoViewScreen({super.key, required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Foto'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(File(photoPath), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
