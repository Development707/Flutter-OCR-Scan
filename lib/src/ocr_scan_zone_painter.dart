import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

import 'utils/coordinates_translator.dart';

/// Ocr scan zone
class OcrScanZone {
  /// Ocr scan zone
  const OcrScanZone(
    this.boundingBox, {
    this.boundingPaint = Rect.zero,
  });

  /// Bounding paint
  final Rect boundingPaint;

  /// Bounding box
  final Rect boundingBox;

  /// Copy with
  OcrScanZone copyWith({
    Rect? boundingPaint,
    Rect? boundingBox,
  }) {
    return OcrScanZone(
      boundingBox ?? this.boundingBox,
      boundingPaint: boundingPaint ?? this.boundingPaint,
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
    final Paint paint = Paint()
      ..style = style
      ..strokeWidth = strokeWidth
      ..color = color;

    for (int index = 0; index < elements.length; index++) {
      final OcrScanZone element = elements.elementAt(index);

      /// Paint box
      final Rect boundingPaint = Rect.fromLTRB(
        translateX(
          element.boundingBox.left,
          size,
          previewSize,
          rotation,
          cameraLensDirection,
        ),
        translateY(
          element.boundingBox.top,
          size,
          previewSize,
          rotation,
          cameraLensDirection,
        ),
        translateX(
          element.boundingBox.right,
          size,
          previewSize,
          rotation,
          cameraLensDirection,
        ),
        translateY(
          element.boundingBox.bottom,
          size,
          previewSize,
          rotation,
          cameraLensDirection,
        ),
      );

      canvas.drawRect(boundingPaint, paint);

      /// Update element
      elements[index] = element.copyWith(
        boundingPaint: boundingPaint,
      );
    }
  }

  /// Repaint UI [CustomPainter]
  void repaint() => notifyListeners();

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
