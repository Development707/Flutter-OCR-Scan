import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

import '../utils/coordinates_translator.dart';

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
    final OcrScanZonePainter? zonePainter = _config.scanZonePainter;
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
        final List<TextLine> filtered = [];

        for (TextLine textLine in lines) {
          final Rect boundingBox = Rect.fromLTRB(
            translateX(
              textLine.boundingBox.left,
              zonePainter.previewSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              textLine.boundingBox.top,
              zonePainter.previewSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateX(
              textLine.boundingBox.right,
              zonePainter.previewSize,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              textLine.boundingBox.bottom,
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

          filtered.add(textLine);
        }

        _config.onTextLine?.call((i, filtered));
      }
    }
  }
}
