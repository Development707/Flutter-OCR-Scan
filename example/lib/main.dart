import 'package:flutter/material.dart';
import 'package:ocr_scan/ocr_scan.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool ocrProcess = false;
  OcrScanZonePainter ocrZonePainter = OcrScanZonePainter(
    elements: [
      OcrScanZone(
        const Offset(80 / 2, 720 / 2 - 50) & const Size(1280 - 80, 100),
      ),
    ],
    previewSize: const Size(1280, 720),
    rotation: InputImageRotation.rotation0deg,
    cameraLensDirection: CameraLensDirection.back,
    strokeWidth: 2,
    color: Colors.red,
  );

  @override
  void dispose() {
    super.dispose();
    ocrZonePainter.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Ocr Scan Example')),
        body: Builder(builder: (context) {
          final messenger = ScaffoldMessenger.of(context);

          return OcrScanPreview(
            ocrDuration: const Duration(milliseconds: 4000),
            ocrProcess: ocrProcess,
            ocrZonePainter: ocrZonePainter,
            onOcrTextLine: ((int, List<TextLine>) value) {
              messenger.showSnackBar(SnackBar(
                content: Text(
                  value.$2.fold(
                    'Items ${value.$2.length}:',
                    (String pre, TextLine e) => '$pre\n${e.text}',
                  ),
                ),
              ));
            },
          );
        }),
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton.icon(
            onPressed: () {
              ocrProcess = !ocrProcess;
              setState(() {});
            },
            icon: const Icon(Icons.document_scanner),
            label: Text(ocrProcess ? 'Stop' : 'Start'),
          ),
        ),
      ),
    );
  }
}
