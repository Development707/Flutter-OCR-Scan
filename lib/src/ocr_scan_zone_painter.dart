import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

/// Ocr scan zone painter
class OcrScanZonePainter extends ZonePainter {
  /// Ocr scan zone painter
  OcrScanZonePainter({
    required super.elements,
    super.rotation,
    super.style,
    super.strokeWidth,
    super.color,
  });
}

/// Text recognizer config
class TextRecognizerConfig {
  /// Text recognizer config
  const TextRecognizerConfig({
    this.textRecognizer,
    this.scanZonePainter,
    required this.onTextLine,
  });

  /// Text recognizer
  final TextRecognizer? textRecognizer;

  /// zone painter
  final OcrScanZonePainter? scanZonePainter;

  /// On ocr result text line
  /// - int: index
  /// - List<TextLine>: List lines
  final ValueChanged<(int, List<TextLine>)>? onTextLine;
}
