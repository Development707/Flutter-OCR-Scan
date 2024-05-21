library ocr_scan;

export 'package:camera/camera.dart';
export 'package:google_mlkit_commons/google_mlkit_commons.dart';
export 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
export 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Painter
export 'src/painter/barcode_scan_zone_painter.dart';
export 'src/painter/ocr_scan_zone_painter.dart';

/// Main
export 'src/scan_preview.dart';
export 'src/zone_painter.dart';

/// Mixin
export 'src/mixin/barcode_scanner_mixin.dart';
export 'src/mixin/camera_mixin.dart';
export 'src/mixin/text_recognizer_mixin.dart';
