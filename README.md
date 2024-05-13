# OCR Scan

[![Pub Version](https://img.shields.io/pub/v/ocr_scan)](https://pub.dev/packages/ocr_scan)

OCR scan library for Flutter. It can scan text form zones in preview.

## How to use

1. Add `ocr_scan` to your `pubspec.yaml`
2. Import the desired package or class.

```dart
import 'package:ocr_scan/ocr_scan.dart';

...
OcrScanPreview(
    ocrZonePainter: OcrScanZonePainter(
        elements: [
            const OcrScanZone(Rect.fromLTWH(0, 0, 1280, 100)),   // Zone1: Top center
            const OcrScanZone(Rect.fromLTWH(0, 620, 1280, 100)), // Zone2: Bottom center
        ],
        imageSize: const Size(1280, 720),
        rotation: InputImageRotation.rotation0deg,
        cameraLensDirection: CameraLensDirection.back,
    ),
    onOcrTextLine: ((int, List<TextLine>) value) {
      print(value);
    },
);
...
```

## Contributing

Contributions are always welcome!

Please check out our [contribution guidelines](https://github.com/development707/ocr_scan_flutter/blob/main/CONTRIBUTING.md) for more details.

## License

Bloc Architecture Core is licensed under the [MIT License](https://github.com/development707/ocr_scan_flutter/blob/main/LICENSE).
