import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

import 'utils/coordinates_translator.dart';

class OcrScanZone {
  const OcrScanZone(
    this.boundingBox, {
    this.boundingPaint = Rect.zero,
  });

  final Rect boundingPaint;

  final Rect boundingBox;

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

class OcrScanZonePainter extends CustomPainter with ChangeNotifier {
  OcrScanZonePainter({
    required this.elements,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
    this.style = PaintingStyle.stroke,
    this.strokeWidth = 1.0,
    this.color = const Color(0x88000000),
  });

  final List<OcrScanZone> elements;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final PaintingStyle style;
  final double strokeWidth;
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
          imageSize,
          rotation,
          cameraLensDirection,
        ),
        translateY(
          element.boundingBox.top,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        ),
        translateX(
          element.boundingBox.right,
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        ),
        translateY(
          element.boundingBox.bottom,
          size,
          imageSize,
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
