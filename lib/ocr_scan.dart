library ocr_scan;

export 'package:camera/camera.dart';
export 'package:google_mlkit_commons/google_mlkit_commons.dart';
export 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
export 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Main
export 'src/scan_preview.dart';
export 'src/zone_painter.dart';
export 'src/scan_file.dart';

/// Mixin
export 'src/mixin/barcode_scanner_mixin.dart';
export 'src/mixin/camera_mixin.dart';
export 'src/mixin/text_recognizer_mixin.dart';
export 'src/mixin/file_mixin.dart';
