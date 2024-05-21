import 'package:flutter/material.dart';
import 'package:ocr_scan/ocr_scan.dart';

///  scan preview
class ScanPreview extends StatefulWidget {
  ///  scan preview
  const ScanPreview({
    super.key,
    this.children,

    /// Camera config
    this.enableAudio = false,
    this.previewSize = const Size(1280, 720),
    this.cameraLensDirection = CameraLensDirection.back,
    this.scanDuration = const Duration(seconds: 2),
    this.scanProcess = false,
    this.controller,

    /// Text recognizer config
    this.textRecognizerConfig = const TextRecognizerConfig(onTextLine: null),

    /// Barcode scanner config
    this.barcodeScannerConfig = const BarcodeScannerConfig(onBarcode: null),
  });

  /// Children in Stack
  final List<Widget>? children;

  /// Camera: Enable audio
  final bool enableAudio;

  /// Camera: Preview size
  ///
  /// Issue: https://github.com/flutter/flutter/issues/15953
  final Size previewSize;

  /// Camera: Camera lens direction
  final CameraLensDirection cameraLensDirection;

  /// Camera: scan duration
  final Duration scanDuration;

  /// Camera: scan process
  final bool scanProcess;

  /// Camera: Controller
  final CameraController? controller;

  /// MLKit: Text recognizer config
  final TextRecognizerConfig textRecognizerConfig;

  /// MLKit: Barcode scanner config
  final BarcodeScannerConfig barcodeScannerConfig;

  @override
  State<ScanPreview> createState() => ScanPreviewState();
}

///  scan preview state
class ScanPreviewState extends ScanPreviewStateDelegate
    with
        WidgetsBindingObserver,
        CameraMixin,
        TextRecognizerMixin,
        BarcodeScannerMixin {
  /// Handling Lifecycle states
  /// https://pub.dev/packages/camera#handling-lifecycle-states
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      startLiveFeed(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? controller = this.controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(
      controller,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: widget.textRecognizerConfig.scanZonePainter
              ?..configure(controller),
          ),
          CustomPaint(
            painter: widget.barcodeScannerConfig.scanZonePainter
              ?..configure(controller),
          ),
          ...?widget.children,
        ],
      ),
    );
  }
}

///  scan preview state delegate
abstract class ScanPreviewStateDelegate extends State<ScanPreview> {
  /// Controls a device camera.
  CameraController? get controller;

  /// Process image
  Future<void> processImage(CameraImage image);

  /// Processes the given [InputImage] for text recognition.
  Future<void> processTextRecognizer(InputImage inputImage);

  /// Processes the given [InputImage] for barcode scanning.
  Future<void> processBarcodeScanner(InputImage inputImage);
}
