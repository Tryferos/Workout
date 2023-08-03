import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

// ···

class _ProfileWidgetState extends State<ProfileWidget> {
  String? path;
  @override
  void initState() {
    super.initState();
    readImage();
  }

  void readImage() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      path = image.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: Center(
        child: path == null
            ? const Text('pick')
            : Image.file(
                File(path!),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
