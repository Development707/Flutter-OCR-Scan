import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

import 'utils/coordinates_translator.dart';

/// Ocr scan zone
class OcrScanZone {
  /// Ocr scan zone
  const OcrScanZone(
    this.boundingBox, {
    this.boundingPaint = Rect.zero,
    this.text,
    this.paintingStyle,
    this.paintingStrokeWidth,
    this.paintingColor,
  });

  /// Bounding paint
  final Rect boundingPaint;

  /// Bounding box
  final Rect boundingBox;

  /// Text
  final InlineSpan? text;

  /// Painting style
  final PaintingStyle? paintingStyle;

  /// Stroke width
  final double? paintingStrokeWidth;

  /// Painting color
  final Color? paintingColor;

  /// Copy with
  OcrScanZone copyWith({
    Rect? boundingPaint,
    Rect? boundingBox,
    InlineSpan? text,
    PaintingStyle? paintingStyle,
    double? paintingStrokeWidth,
    Color? paintingColor,
  }) {
    return OcrScanZone(
      boundingBox ?? this.boundingBox,
      boundingPaint: boundingPaint ?? this.boundingPaint,
      text: text ?? this.text,
      paintingStyle: paintingStyle ?? this.paintingStyle,
      paintingStrokeWidth: paintingStrokeWidth ?? this.paintingStrokeWidth,
      paintingColor: paintingColor ?? this.paintingColor,
    );
  }
}

/// Ocr scan zone painter
class OcrScanZonePainter extends CustomPainter with ChangeNotifier {
  /// Ocr scan zone painter
  OcrScanZonePainter({
    required this.elements,
    this.previewSize = const Size(1280, 720),
    this.rotation = InputImageRotation.rotation0deg,
    this.cameraLensDirection = CameraLensDirection.back,
    this.style = PaintingStyle.stroke,
    this.strokeWidth = 1.0,
    this.color = const Color(0x88000000),
  });

  /// Elements to paint
  final List<OcrScanZone> elements;

  /// Image size
  final Size previewSize;

  /// Image rotation
  final InputImageRotation rotation;

  /// Camera lens direction
  final CameraLensDirection cameraLensDirection;

  /// Painting style
  final PaintingStyle style;

  /// Stroke width
  final double strokeWidth;

  /// Color
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      ellipsis: '\u2026',
      maxLines: 1,
    );

    for (int index = 0; index < elements.length; index++) {
      final OcrScanZone element = elements.elementAt(index);

      /// Paint config
      paint
        ..style = element.paintingStyle ?? style
        ..strokeWidth = element.paintingStrokeWidth ?? strokeWidth
        ..color = element.paintingColor ?? color;

      /// Paint box
      final Rect boundingBox = element.boundingBox;
      final Rect boundingPaint = Rect.fromLTRB(
        translateX(
          boundingBox.left,
          size,
          previewSize,
          rotation,
          cameraLensDirection,
        ),
        translateY(
          boundingBox.top,
          size,
          previewSize,
          rotation,
          cameraLensDirection,
        ),
        translateX(
          boundingBox.right,
          size,
          previewSize,
          rotation,
          cameraLensDirection,
        ),
        translateY(
          boundingBox.bottom,
          size,
          previewSize,
          rotation,
          cameraLensDirection,
        ),
      );
      canvas.drawRect(boundingPaint, paint);

      /// Paint text
      final InlineSpan? text = element.text;
      if (text != null) {
        textPainter
          ..text = text
          ..layout(maxWidth: boundingPaint.width)
          ..paint(
            canvas,
            boundingPaint.topLeft -
                Offset(paint.strokeWidth / 2, textPainter.height),
          );
      }

      /// Update element
      elements[index] = element.copyWith(
        boundingPaint: boundingPaint,
      );
    }

    textPainter.dispose();
  }

  /// Repaint UI [CustomPainter]
  void repaint() => notifyListeners();

  @override
  bool shouldRepaint(covariant OcrScanZonePainter oldDelegate) {
    return oldDelegate.elements != elements;
  }
}
