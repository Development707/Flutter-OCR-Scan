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
      body: Center(child: Builder(builder: buildPreview)),
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
        zonePainter: ZonePainter(
          elements: [
            const Zone(
              Rect.fromLTWH(40, 100, 1200, 100),
              text: TextSpan(
                text: 'Zone: TextRecognizer',
                style: TextStyle(backgroundColor: Colors.red),
              ),
              paintingColor: Colors.red,
            ),
          ],
        ),
        onTextLine: ((int, List<TextLine>) value) {
          messenger.showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text(
              value.$2.fold(
                'TextRecognizer - Length ${value.$2.length}:',
                (String pre, TextLine e) => '$pre\n${e.text}',
              ),
            ),
          ));
        },
      ),
      barcodeScannerConfig: BarcodeScannerConfig(
        zonePainter: ZonePainter(
          rotation: InputImageRotation.rotation90deg,
          elements: [
            Zone(
              Rect.fromCenter(
                center: const Size(720, 1280).center(Offset.zero),
                width: 400,
                height: 400,
              ),
              text: const TextSpan(
                text: 'Zone: BarcodeScanner',
                style: TextStyle(backgroundColor: Colors.green),
              ),
              paintingColor: Colors.green,
            ),
          ],
        ),
        onBarcode: ((int, List<Barcode>) value) {
          messenger.showSnackBar(SnackBar(
            duration: const Duration(milliseconds: 2000),
            content: Text(
              value.$2.fold(
                'BarcodeScanner - Length ${value.$2.length}:',
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
