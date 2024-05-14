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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Ocr Scan Example')),
        body: Builder(builder: buildPreviwew),
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

  // #docregion OcrScanPreview
  Widget buildPreviwew(BuildContext context) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    return OcrScanPreview(
      ocrDuration: const Duration(milliseconds: 4000),
      ocrProcess: ocrProcess,
      ocrZonePainter: OcrScanZonePainter(
        elements: [
          const OcrScanZone(Rect.fromLTWH(0, 200, 1280, 100)), // Zone1 TOP
          const OcrScanZone(Rect.fromLTWH(0, 400, 1280, 100)), // Zone2 BOTTOM
        ],
        previewSize: const Size(1280, 720),
        strokeWidth: 2,
        color: Colors.red,
      ),
      onOcrTextLine: ((int, List<TextLine>) value) {
        messenger.showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 2000),
          content: Text(
            value.$2.fold(
              'Rect ${value.$1 + 1} - Length ${value.$2.length}:',
              (String pre, TextLine e) => '$pre\n${e.text}',
            ),
          ),
        ));
      },
    );
  }
  // #enddocregion OcrScanPreview
}
