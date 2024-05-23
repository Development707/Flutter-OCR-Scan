import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker picker = ImagePicker();
  XFile? image;
  bool process = false;

  bool get hasImage => image != null;
  ScaffoldMessengerState get messenger => ScaffoldMessenger.of(context);

  late final TextRecognizerConfig textRecognizerConfig = TextRecognizerConfig(
    zonePainter: ZonePainter(
      elements: [
        const Zone(
          Rect.fromLTWH(0, 24, 720, 400),
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
  );
  late final BarcodeScannerConfig barcodeScannerConfig = BarcodeScannerConfig(
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
  );

  @override
  void dispose() {
    super.dispose();
    textRecognizerConfig.zonePainter?.dispose();
    barcodeScannerConfig.zonePainter?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ocr Scan Example')),
      body: Center(
        child: Builder(builder: hasImage ? buildImage : buildPreview),
      ),
      bottomNavigationBar: buildBottomAppBar(),
    );
  }

  Widget buildBottomAppBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: hasImage
                ? null
                : () {
                    process = !process;
                    setState(() {});
                  },
            icon: const Icon(Icons.document_scanner),
            label: Text(process ? 'Stop' : 'Start'),
          ),
          IconButton(
            onPressed: hasImage
                ? null
                : () async {
                    image = await picker.pickImage(source: ImageSource.gallery);
                    setState(() {});
                  },
            icon: const Icon(Icons.image),
          ),
          IconButton(
            onPressed: hasImage
                ? null
                : () async {
                    image = await picker.pickImage(source: ImageSource.camera);
                    setState(() {});
                  },
            icon: const Icon(Icons.camera_alt),
          ),
          IconButton(
            onPressed: !hasImage
                ? null
                : () {
                    image = null;
                    setState(() {});
                  },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget buildPreview(BuildContext context) {
    return ScanPreview(
      scanProcess: process,
      scanDuration: const Duration(milliseconds: 2000 * 3),
      textRecognizerConfig: textRecognizerConfig,
      barcodeScannerConfig: barcodeScannerConfig,
    );
  }

  Widget buildImage(BuildContext context) {
    return ScanFile(
      scanFile: File(image!.path),
      previewSize: const Size(720, 1280),
      textRecognizerConfig: textRecognizerConfig,
      barcodeScannerConfig: barcodeScannerConfig,
    );
  }
}
