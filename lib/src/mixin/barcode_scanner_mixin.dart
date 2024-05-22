import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

import '../utils/coordinates_translator.dart';

/// Barcode scanner config
class BarcodeScannerConfig {
  /// Barcode scanner config
  const BarcodeScannerConfig({
    this.barcodeScanner,
    this.zonePainter,
    required this.onBarcode,
  });

  /// MLKit: Barcode scanner
  final BarcodeScanner? barcodeScanner;

  /// zone painter
  final ZonePainter? zonePainter;

  /// On ocr result barcode
  /// - int: index
  /// - List<Barcode>: List barcodes
  final ValueChanged<(int, List<Barcode>)>? onBarcode;
}

/// Barcode scanner mixin.
mixin BarcodeScannerMixin on ScanPreviewStateDelegate {
  BarcodeScanner? _barcodeScanner;

  BarcodeScannerConfig get _config => widget.barcodeScannerConfig;

  /// A barcode scanner that scans and decodes barcodes from a given [InputImage].
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
    final ZonePainter? zonePainter = _config.zonePainter;
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
        final Size zoneSize = switch (zonePainter.rotation) {
          InputImageRotation.rotation0deg => zonePainter.previewSize,
          InputImageRotation.rotation90deg => zonePainter.previewSize.flipped,
          InputImageRotation.rotation180deg => zonePainter.previewSize,
          InputImageRotation.rotation270deg => zonePainter.previewSize.flipped,
        };
        final List<Barcode> filtered = [];

        for (Barcode barcode in result) {
          final Rect barcodeRect = Rect.fromLTRB(
            translateX(
              barcode.boundingBox.left,
              zoneSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              barcode.boundingBox.top,
              zoneSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateX(
              barcode.boundingBox.right,
              zoneSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              barcode.boundingBox.bottom,
              zoneSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
          );

          if (barcodeRect.top < zone.boundingBox.top ||
              barcodeRect.bottom > zone.boundingBox.bottom ||
              barcodeRect.left < zone.boundingBox.left ||
              barcodeRect.right > zone.boundingBox.right) {
            continue;
          }

          filtered.add(barcode);
        }

        _config.onBarcode?.call((i, filtered));
      }
    }
  }
}
