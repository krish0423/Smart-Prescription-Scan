import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../services/gemini_service.dart';
import '../widgets/loading_indicator.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isAnalyzing = false;
  final GeminiService _geminiService = GeminiService();
  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 90,
    );

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _analyzePrescription() async {
    if (_imageFile == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final prescriptionData = await _geminiService.analyzePrescription(
        _imageFile!,
      );
      debugPrint('Prescription Data: $prescriptionData');
      if (!mounted) return;

      if (prescriptionData.containsKey('error')) {
        _showErrorDialog(prescriptionData['error']);
      } else {
        Navigator.push(
          context,
          Platform.isIOS
              ? CupertinoPageRoute(
                builder:
                    (context) => ResultScreen(
                      prescriptionData: prescriptionData,
                      imageFile: _imageFile!,
                    ),
              )
              : MaterialPageRoute(
                builder:
                    (context) => ResultScreen(
                      prescriptionData: prescriptionData,
                      imageFile: _imageFile!,
                    ),
              ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to analyze prescription: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSLayout() : _buildAndroidLayout();
  }

  Widget _buildIOSLayout() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Scan Prescription'),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: _buildImagePreview()),
                _buildIOSBottomControls(),
              ],
            ),
            if (_isAnalyzing)
              Container(
                color: CupertinoColors.systemBackground.withOpacity(0.7),
                child: const LoadingIndicator(
                  message: 'Analyzing prescription...',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroidLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Prescription')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildImagePreview()),
              _buildBottomControls(),
            ],
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const LoadingIndicator(
                message: 'Analyzing prescription...',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Platform.isIOS ? CupertinoIcons.camera : Icons.camera_alt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Take a picture or select an image\nof your prescription',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_imageFile!, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildIOSBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_imageFile != null)
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: _isAnalyzing ? null : _analyzePrescription,
                child: const Text('Analyze Prescription'),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _takePicture,
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.camera,
                        size: 28,
                        color: CupertinoColors.activeBlue,
                      ),
                      const SizedBox(height: 4),
                      const Text('Camera', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _pickImage,
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.photo,
                        size: 28,
                        color: CupertinoColors.activeBlue,
                      ),
                      const SizedBox(height: 4),
                      const Text('Gallery', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_imageFile != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzePrescription,
                icon: const Icon(Icons.document_scanner),
                label: const Text('Analyze Prescription'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
