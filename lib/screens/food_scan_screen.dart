import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class FoodScanScreen extends StatefulWidget {
  @override
  _FoodScanScreenState createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  QRViewController? _qrController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;
    _qrController!.scannedDataStream.listen((scanData) {
      // Handle scanned data here
      print('Barcode scanned: ${scanData.code}');
      // You would typically navigate or process the scanned data here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned: ${scanData.code}')),
      );
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food & Barcode'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to manual entry screen
                      print('Manual Entry button pressed');
                      // TODO: Implement navigation to ManualFoodEntryScreen
                    },
                    child: const Text('Manual Food Entry'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger AI Meal Plan generation
                      print('Generate AI Meal Plan button pressed');
                      // TODO: Implement AI Meal Plan generation
                    },
                    child: const Text('Generate AI Meal Plan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}