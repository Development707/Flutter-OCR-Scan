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
        extendBody: true,
        body: Builder(builder: buildPreview),
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
  Widget buildPreview(BuildContext context) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    return OcrScanPreview(
      ocrDuration: const Duration(milliseconds: 5000),
      ocrProcess: ocrProcess,
      ocrZonePainter: OcrScanZonePainter(
        elements: const [
          OcrScanZone(
            Rect.fromLTWH(40, 200, 1200, 100),
            text: TextSpan(
              text: 'Zone 1: TOP',
              style: TextStyle(backgroundColor: Colors.red),
            ),
            paintingColor: Colors.red,
          ), // Zone1 TOP
          OcrScanZone(
            Rect.fromLTWH(40, 400, 1200, 100),
            text: TextSpan(
              text: 'Zone 2: BOTTOM',
              style: TextStyle(backgroundColor: Colors.green),
            ),
            paintingColor: Colors.green,
          ),
        ],
        previewSize: const Size(1280, 720),
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
