import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

import '../utils/coordinates_translator.dart';

/// Text recognizer config
class TextRecognizerConfig {
  /// Text recognizer config
  const TextRecognizerConfig({
    this.textRecognizer,
    this.zonePainter,
    required this.onTextLine,
  });

  /// Text recognizer
  final TextRecognizer? textRecognizer;

  /// zone painter
  final ZonePainter? zonePainter;

  /// On ocr result text line
  /// - int: index
  /// - List<TextLine>: List lines
  final ValueChanged<(int, List<TextLine>)>? onTextLine;
}

/// Text recognizer mixin
mixin TextRecognizerMixin on ScanPreviewStateDelegate {
  TextRecognizer? _textRecognizer;

  TextRecognizerConfig get _config => widget.textRecognizerConfig;

  /// A text recognizer that recognizes text from a given [InputImage].
  TextRecognizer get textRecognizer {
    return _config.textRecognizer ?? (_textRecognizer ??= TextRecognizer());
  }

  @override
  void dispose() {
    super.dispose();
    _textRecognizer?.close();
  }

  @override
  Future<void> processTextRecognizer(InputImage inputImage) async {
    final ZonePainter? zonePainter = _config.zonePainter;
    if (zonePainter == null) return;

    /// Process image
    final result = await textRecognizer.processImage(inputImage);

    /// Filter zones
    if (_config.onTextLine != null) {
      List<TextLine> lines = result.blocks.fold(<TextLine>[], (pre, e) {
        return pre..addAll(e.lines);
      });

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
        final List<TextLine> filtered = [];

        for (TextLine textLine in lines) {
          final Rect textLineRect = Rect.fromLTRB(
            translateX(
              textLine.boundingBox.left,
              zoneSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              textLine.boundingBox.top,
              zoneSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateX(
              textLine.boundingBox.right,
              zoneSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              textLine.boundingBox.bottom,
              zoneSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
          );

          if (textLineRect.top < zone.boundingBox.top ||
              textLineRect.bottom > zone.boundingBox.bottom ||
              textLineRect.left < zone.boundingBox.left ||
              textLineRect.right > zone.boundingBox.right) {
            continue;
          }

          filtered.add(textLine);
        }

        _config.onTextLine?.call((i, filtered));
      }
    }
  }
}
