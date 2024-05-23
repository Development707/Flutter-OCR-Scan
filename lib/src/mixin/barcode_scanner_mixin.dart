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
mixin BarcodeScannerMixin<T extends StatefulWidget> on State<T> {
  BarcodeScanner? _barcodeScanner;

  /// Barcode scanner config
  BarcodeScannerConfig get barcodeConfig;

  /// A barcode scanner that scans and decodes barcodes from a given [InputImage].
  BarcodeScanner get barcodeScanner {
    if (barcodeConfig.barcodeScanner == null) {
      return (_barcodeScanner ??= BarcodeScanner());
    }
    return barcodeConfig.barcodeScanner!;
  }

  @override
  void dispose() {
    super.dispose();
    _barcodeScanner?.close();
  }

  /// Processes the given [InputImage] for barcode scanning.
  Future<List<Barcode>?> processBarcodeScanner(InputImage inputImage) async {
    final ZonePainter? zonePainter = barcodeConfig.zonePainter;
    if (zonePainter == null) return null;

    /// Process image
    final result = await barcodeScanner.processImage(inputImage);

    /// Filter zones
    if (barcodeConfig.onBarcode != null) {
      for (int i = 0; i < zonePainter.elements.length; i++) {
        final Zone zone = zonePainter.elements[i];
        final List<Barcode> filtered = filterBarcodes(
          result,
          zone,
          inputImage.metadata?.size ?? Size.zero,
          inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg,
        );

        barcodeConfig.onBarcode?.call((i, filtered));
      }
    }

    return result;
  }

  /// Filter zone
  List<Barcode> filterBarcodes(
    List<Barcode> inputs,
    Zone zone,
    Size imageSize,
    InputImageRotation imageRotation,
  ) {
    final ZonePainter? zonePainter = barcodeConfig.zonePainter;
    if (zonePainter == null) return [];

    final Size zoneSize = switch (zonePainter.rotation) {
      InputImageRotation.rotation0deg => zonePainter.previewSize,
      InputImageRotation.rotation90deg => zonePainter.previewSize.flipped,
      InputImageRotation.rotation180deg => zonePainter.previewSize,
      InputImageRotation.rotation270deg => zonePainter.previewSize.flipped,
    };

    return inputs.where((Barcode barcode) {
      final Rect barcodeRect = translateRect(
        barcode.boundingBox,
        zoneSize,
        imageSize,
        imageRotation,
        zonePainter.cameraLensDirection,
      );

      return barcodeRect.top >= zone.boundingBox.top &&
          barcodeRect.bottom <= zone.boundingBox.bottom &&
          barcodeRect.left >= zone.boundingBox.left &&
          barcodeRect.right <= zone.boundingBox.right;
    }).toList();
  }
}
