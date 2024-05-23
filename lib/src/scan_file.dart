import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

/// Scan file
class ScanFile extends StatefulWidget {
  /// Scan file
  const ScanFile({
    super.key,

    /// Text recognizer config
    this.textRecognizerConfig = const TextRecognizerConfig(onTextLine: null),

    /// Barcode scanner config
    this.barcodeScannerConfig = const BarcodeScannerConfig(onBarcode: null),
  });

  /// MLKit: Text recognizer config
  final TextRecognizerConfig textRecognizerConfig;

  /// MLKit: Barcode scanner config
  final BarcodeScannerConfig barcodeScannerConfig;

  @override
  State<ScanFile> createState() => ScanFileState();
}

/// Scan file state
class ScanFileState extends ScanFileStateDelegate with FileMixin {
  @override
  TextRecognizerConfig get textRecognizerConfig => widget.textRecognizerConfig;

  @override
  BarcodeScannerConfig get barcodeConfig => widget.barcodeScannerConfig;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/// Scan file state delegate
abstract class ScanFileStateDelegate extends State<ScanFile>
    with TextRecognizerMixin, BarcodeScannerMixin {
  /// Process image
  Future<void> processImage(String path);
}
