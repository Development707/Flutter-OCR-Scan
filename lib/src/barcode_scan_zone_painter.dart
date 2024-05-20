import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

/// Barcode scan zone painter
class BarcodeScanZonePainter extends ZonePainter {
  /// Barcode scan zone painter
  BarcodeScanZonePainter({
    required super.elements,
    super.rotation,
    super.style,
    super.strokeWidth,
    super.color,
  });
}

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
