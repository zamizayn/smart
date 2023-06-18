import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
 XFile? _pickedFile;
  XFile? _croppedFile;

  // Define a MethodChannel
  final channel = const MethodChannel('com.example.crop_image');

  // Register the MethodChannel with the Flutter app
  @override
  void initState() {
    super.initState();
    channel.setMethodCallHandler(_handleMethod);
  }

  // Handle MethodChannel calls
  Future<void> _handleMethod(MethodCall call) async {
    if (call.method == 'cropImage') {
      await _cropImage();
    }
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile as XFile?;
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });

      // Call the cropImage method on the MethodChannel
      await channel.invokeMethod('cropImage');
    }
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker Widget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _pickedFile == null
                ? const Text('No image selected.')
                : Image.file(File(_pickedFile!.path)),
            const SizedBox(height: 20),
            _croppedFile == null
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      Image.file(File(_croppedFile!.path)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _clear,
                        child: const Text('Clear Image'),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cropImage,
              child: const Text('Crop Image'),
            ),
          ],
        ),
      ),
    );
  }
}