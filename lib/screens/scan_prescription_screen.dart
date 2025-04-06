import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class ScanPrescriptionScreen extends StatefulWidget {
  const ScanPrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<ScanPrescriptionScreen> createState() => _ScanPrescriptionScreenState();
}

class _ScanPrescriptionScreenState extends State<ScanPrescriptionScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isCameraPermissionGranted = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize the camera
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras!.isEmpty) {
        setState(() {
          _isCameraPermissionGranted = false;
        });
        return;
      }

      // Select the back camera
      final CameraDescription camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
        _isCameraPermissionGranted = true;
      });
    } catch (e) {
      setState(() {
        _isCameraPermissionGranted = false;
      });
      print('Error initializing camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }

      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessing) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile photo = await _cameraController!.takePicture();

      // Process the image (in a real app, this would use ML Kit or similar)
      await _processPrescriptionImage(photo.path);
    } catch (e) {
      print('Error taking picture: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.gallery);

      if (photo == null) {
        return;
      }

      setState(() {
        _isProcessing = true;
      });

      await _processPrescriptionImage(photo.path);
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processPrescriptionImage(String imagePath) async {
    // In a real app, this would use ML Kit or a similar service to extract text
    // and identify medications from the prescription

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock detected medications
    final List<Map<String, dynamic>> detectedMedications = [
      {
        'name': 'Amoxicillin',
        'dosage': '500mg',
        'frequency': 'Three times daily',
        'duration': '7 days',
        'confidence': 0.95,
      },
      {
        'name': 'Paracetamol',
        'dosage': '1000mg',
        'frequency': 'Every 6 hours as needed',
        'duration': '5 days',
        'confidence': 0.88,
      },
    ];

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    // Navigate to results screen with the detected medications
    Navigator.pushNamed(
      context,
      '/scan_results',
      arguments: detectedMedications,
    );
  }

  Widget _buildPermissionDeniedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Prescription'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Permission Required',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Please grant camera permission to scan prescriptions.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _initializeCamera();
              },
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return _buildPermissionDeniedScreen();
    }

    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Prescription'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Camera preview
                CameraPreview(_cameraController!),

                // Overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 1.1,
                ),

                // Processing indicator
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Processing prescription...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Text(
                  'Position the prescription within the frame',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure the text is clearly visible and the image is well-lit',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _takePicture,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Capture'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
