import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show File, Platform;
import 'package:image_picker/image_picker.dart';
import 'scan_results_screen.dart';

class ScanPrescriptionScreen extends StatefulWidget {
  const ScanPrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<ScanPrescriptionScreen> createState() => _ScanPrescriptionScreenState();
}

class _ScanPrescriptionScreenState extends State<ScanPrescriptionScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Navigate to results screen with the image
      if (Platform.isIOS) {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ScanResultsScreen(scannedImage: _image),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultsScreen(scannedImage: _image),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Scan Prescription'),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image != null
                    ? Image.file(
                      _image!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                    : Container(
                      height: 300,
                      width: double.infinity,
                      color: CupertinoColors.systemGrey5,
                      child: const Icon(
                        CupertinoIcons.photo,
                        size: 80,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: () => _getImage(ImageSource.camera),
                  child: const Text('Take Photo'),
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  onPressed: () => _getImage(ImageSource.gallery),
                  child: const Text('Choose from Gallery'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Prescription')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Image.file(
                    _image!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.photo,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _getImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => _getImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
