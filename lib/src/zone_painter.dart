import 'package:flutter/widgets.dart';
import 'package:ocr_scan/ocr_scan.dart';

import 'utils/coordinates_translator.dart';

/// Zone
class Zone {
  /// Zone
  const Zone(
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
  Zone copyWith({
    Rect? boundingPaint,
    Rect? boundingBox,
    InlineSpan? text,
    PaintingStyle? paintingStyle,
    double? paintingStrokeWidth,
    Color? paintingColor,
  }) {
    return Zone(
      boundingBox ?? this.boundingBox,
      boundingPaint: boundingPaint ?? this.boundingPaint,
      text: text ?? this.text,
      paintingStyle: paintingStyle ?? this.paintingStyle,
      paintingStrokeWidth: paintingStrokeWidth ?? this.paintingStrokeWidth,
      paintingColor: paintingColor ?? this.paintingColor,
    );
  }
}

/// Zone painter
abstract class ZonePainter extends CustomPainter with ChangeNotifier {
  /// Zone painter
  ZonePainter({
    required this.elements,
    this.rotation = InputImageRotation.rotation0deg,
    this.style = PaintingStyle.stroke,
    this.strokeWidth = 1.0,
    this.color = const Color(0x88000000),
  });

  /// Elements to paint
  final List<Zone> elements;

  /// Painting style
  final PaintingStyle style;

  /// Stroke width
  final double strokeWidth;

  /// Color
  final Color color;

  /// Image rotation
  final InputImageRotation rotation;

  /// Camera lens direction
  late CameraLensDirection cameraLensDirection;

  /// Image size
  late Size previewSize;

  /// Configure
  void configure(CameraController controller) {
    cameraLensDirection = controller.description.lensDirection;
    previewSize = controller.value.previewSize ?? Size.zero;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int index = 0; index < elements.length; index++) {
      Zone element = elements.elementAt(index);

      /// Update element
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
      elements[index] = element.copyWith(boundingPaint: boundingPaint);
      element = elements[index];

      /// Paint
      paintBox(canvas, element);
      if (element.text != null) {
        paintText(canvas, element);
      }
    }
  }

  /// Paint box
  @protected
  void paintBox(Canvas canvas, Zone element) {
    final Paint paint = Paint()
      ..style = element.paintingStyle ?? style
      ..strokeWidth = element.paintingStrokeWidth ?? strokeWidth
      ..color = element.paintingColor ?? color;

    canvas.drawRect(element.boundingPaint, paint);
  }

  /// Paint text
  @protected
  void paintText(Canvas canvas, Zone element) {
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
      ellipsis: '\u2026',
      maxLines: 1,
    )
      ..text = element.text
      ..layout(maxWidth: element.boundingPaint.width);

    textPainter
      ..paint(
        canvas,
        element.boundingPaint.topLeft -
            Offset(
              (element.paintingStrokeWidth ?? strokeWidth) / 2, // dx
              textPainter.height, // dy
            ),
      )
      ..dispose();
  }

  /// Repaint UI [CustomPainter]
  void repaint() => notifyListeners();

  @override
  bool shouldRepaint(covariant ZonePainter oldDelegate) {
    return oldDelegate.elements != elements;
  }
}
