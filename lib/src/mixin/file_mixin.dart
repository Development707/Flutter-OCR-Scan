import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

/// File mixin
mixin FileMixin on ScanFileStateDelegate {
  bool _canProcess = true;

  @override
  Future<void> processImage(String path) async {
    if (!_canProcess) return;
    _canProcess = false;

    try {
      final InputImage? inputImage = _inputImageFromPath(path);
      if (inputImage != null) {
        await Future.wait([
          processTextRecognizer(inputImage),
          processBarcodeScanner(inputImage),
        ]);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _canProcess = true;
    }
  }

  InputImage? _inputImageFromPath(String path) {
    if (path.isEmpty) return null;

    return InputImage.fromFilePath(path);
  }
}
