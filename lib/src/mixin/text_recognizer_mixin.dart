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
mixin TextRecognizerMixin<T extends StatefulWidget> on State<T> {
  TextRecognizer? _textRecognizer;

  /// Text recognizer config
  TextRecognizerConfig get textRecognizerConfig;

  /// A text recognizer that recognizes text from a given [InputImage].
  TextRecognizer get textRecognizer {
    if (textRecognizerConfig.textRecognizer == null) {
      return (_textRecognizer ??= TextRecognizer());
    }
    return textRecognizerConfig.textRecognizer!;
  }

  @override
  void dispose() {
    super.dispose();
    _textRecognizer?.close();
  }

  /// Processes the given [InputImage] for text recognition.
  Future<RecognizedText?> processTextRecognizer(InputImage inputImage) async {
    final ZonePainter? zonePainter = textRecognizerConfig.zonePainter;
    if (zonePainter == null) return null;

    /// Process image
    final result = await textRecognizer.processImage(inputImage);

    /// Filter zones
    if (textRecognizerConfig.onTextLine != null) {
      final List<TextLine> lines = result.blocks.fold(<TextLine>[], (pre, e) {
        return pre..addAll(e.lines);
      });

      for (int i = 0; i < zonePainter.elements.length; i++) {
        final Zone zone = zonePainter.elements[i];
        final List<TextLine> filtered = filterTextLines(
          lines,
          zone,
          inputImage.metadata?.size ?? Size.zero,
          inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg,
        );

        textRecognizerConfig.onTextLine?.call((i, filtered));
      }
    }

    return result;
  }

  /// Filter zone
  List<TextLine> filterTextLines(
    List<TextLine> inputs,
    Zone zone,
    Size imageSize,
    InputImageRotation imageRotation,
  ) {
    final ZonePainter? zonePainter = textRecognizerConfig.zonePainter;
    if (zonePainter == null) return [];

    final Size zoneSize = switch (zonePainter.rotation) {
      InputImageRotation.rotation0deg => zonePainter.previewSize,
      InputImageRotation.rotation90deg => zonePainter.previewSize.flipped,
      InputImageRotation.rotation180deg => zonePainter.previewSize,
      InputImageRotation.rotation270deg => zonePainter.previewSize.flipped,
    };

    return inputs.where((TextLine textLine) {
      final Rect textLineRect = translateRect(
        textLine.boundingBox,
        zoneSize,
        imageSize,
        imageRotation,
        zonePainter.cameraLensDirection,
      );

      return textLineRect.top >= zone.boundingBox.top &&
          textLineRect.bottom <= zone.boundingBox.bottom &&
          textLineRect.left >= zone.boundingBox.left &&
          textLineRect.right <= zone.boundingBox.right;
    }).toList();
  }
}
