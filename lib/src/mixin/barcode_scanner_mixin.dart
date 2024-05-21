import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

import '../utils/coordinates_translator.dart';

/// Barcode scanner config
class BarcodeScannerConfig {
  /// Barcode scanner config
  const BarcodeScannerConfig({
    this.barcodeScanner,
    this.scanZonePainter,
    required this.onBarcode,
  });

  /// MLKit: Barcode scanner
  final BarcodeScanner? barcodeScanner;

  /// zone painter
  final BarcodeScanZonePainter? scanZonePainter;

  /// On ocr result barcode
  /// - int: index
  /// - List<Barcode>: List barcodes
  final ValueChanged<(int, List<Barcode>)>? onBarcode;
}

/// Barcode scanner mixin.
mixin BarcodeScannerMixin on ScanPreviewStateDelegate {
  BarcodeScanner? _barcodeScanner;

  BarcodeScannerConfig get _config => widget.barcodeScannerConfig;

  /// A text recognizer that recognizes text from a given [InputImage].
  BarcodeScanner get barcodeScanner {
    return _config.barcodeScanner ?? (_barcodeScanner ??= BarcodeScanner());
  }

  @override
  void dispose() {
    super.dispose();
    _barcodeScanner?.close();
  }

  @override
  Future<void> processBarcodeScanner(InputImage inputImage) async {
    final BarcodeScanZonePainter? zonePainter = _config.scanZonePainter;
    if (zonePainter == null) return;

    /// Process image
    final result = await barcodeScanner.processImage(inputImage);

    /// Filter zones
    if (_config.onBarcode != null) {
      if (inputImage.metadata == null) return;
      final Size imageSize = inputImage.metadata!.size;
      final InputImageRotation rotation = inputImage.metadata!.rotation;

      if (controller == null) return;
      final cameraLensDirection = controller!.description.lensDirection;

      for (int i = 0; i < zonePainter.elements.length; i++) {
        final Zone zone = zonePainter.elements[i];
        final List<Barcode> filtered = [];

        for (Barcode barcode in result) {
          final Rect boundingBox = Rect.fromLTRB(
            translateX(
              barcode.boundingBox.left,
              zonePainter.previewSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              barcode.boundingBox.top,
              zonePainter.previewSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateX(
              barcode.boundingBox.right,
              zonePainter.previewSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              barcode.boundingBox.bottom,
              zonePainter.previewSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
          );

          if (boundingBox.top < zone.boundingBox.top ||
              boundingBox.bottom > zone.boundingBox.bottom ||
              boundingBox.left < zone.boundingBox.left ||
              boundingBox.right > zone.boundingBox.right) {
            continue;
          }

          filtered.add(barcode);
        }

        _config.onBarcode?.call((i, filtered));
      }
    }
  }
}
