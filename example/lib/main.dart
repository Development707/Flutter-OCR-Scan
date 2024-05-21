import 'package:flutter/material.dart';
import 'package:ocr_scan/ocr_scan.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool process = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ocr Scan Example')),
      extendBody: true,
      body: Builder(builder: buildPreview),
      bottomNavigationBar: buildBottomAppBar(),
    );
  }

  Widget buildBottomAppBar() {
    return BottomAppBar(
      child: ElevatedButton.icon(
        onPressed: () {
          process = !process;
          setState(() {});
        },
        icon: const Icon(Icons.document_scanner),
        label: Text(process ? 'Stop' : 'Start'),
      ),
    );
  }

  // #docregion ScanPreview
  Widget buildPreview(BuildContext context) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    return ScanPreview(
      scanProcess: process,
      scanDuration: const Duration(milliseconds: 2000 * 3),
      textRecognizerConfig: TextRecognizerConfig(
        scanZonePainter: OcrScanZonePainter(
          elements: [
            const Zone(
              Rect.fromLTWH(40, 100, 1200, 100),
              text: TextSpan(
                text: 'Zone 1: TOP',
                style: TextStyle(backgroundColor: Colors.red),
              ),
              paintingColor: Colors.red,
            ), // Zone1 TOP
            const Zone(
              Rect.fromLTWH(40, 500, 1200, 100),
              text: TextSpan(
                text: 'Zone 2: BOTTOM',
                style: TextStyle(backgroundColor: Colors.green),
              ),
              paintingColor: Colors.green,
            ),
          ],
        ),
        onTextLine: ((int, List<TextLine>) value) {
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
      ),
      barcodeScannerConfig: BarcodeScannerConfig(
        scanZonePainter: BarcodeScanZonePainter(
          elements: [
            const Zone(
              Rect.fromLTWH(40, 250, 1200, 200),
              text: TextSpan(
                text: 'Zone 3: CENTER',
                style: TextStyle(backgroundColor: Colors.yellow),
              ),
              paintingColor: Colors.yellow,
            ),
          ],
        ),
        onBarcode: ((int, List<Barcode>) value) {
          messenger.showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text(
              value.$2.fold(
                'Rect 3 - Length ${value.$2.length}:',
                (String pre, Barcode e) => '$pre\n${e.displayValue}',
              ),
            ),
          ));
        },
      ),
    );
  }
  // #enddocregion ScanPreview
}
