import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocr_scan/ocr_scan.dart';

/// Camera mixin
mixin CameraMixin on ScanPreviewStateDelegate {
  static List<CameraDescription> _cameras = [];
  static final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  CameraController? _controller;
  int _cameraIndex = -1;
  bool _canProcess = true;

  @override
  CameraController? get controller {
    return widget.controller ?? _controller;
  }

  @override
  Future<void> processImage(CameraImage image) async {
    if (!_canProcess) return;
    _canProcess = false;

    try {
      final InputImage? inputImage = _inputImageFromCameraImage(image);
      if (inputImage != null) {
        await Future.wait([
          processTextRecognizer(inputImage),
          processBarcodeScanner(inputImage),
          Future.delayed(widget.scanDuration),
        ]);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _canProcess = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant ScanPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scanProcess != widget.scanProcess) {
      if (widget.scanProcess) {
        _startScan();
      } else if (controller?.value.isStreamingImages ?? false) {
        _stopScan();
      }
    }
    if (oldWidget.previewSize != widget.previewSize) {
      controller?.value = controller!.value.copyWith(
        previewSize: widget.previewSize,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  Future<void> _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.cameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1 || widget.controller != null) {
      await startLiveFeed(null);
    }
  }

  /// Start ocr images from preview camera.
  Future startLiveFeed(CameraDescription? description) async {
    description ??= _cameras[_cameraIndex];

    /// Create camera controller form package.
    if (widget.controller == null) {
      _controller = CameraController(
        description,

        /// Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
        ResolutionPreset.veryHigh,
        enableAudio: widget.enableAudio,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
    }

    /// Set size preview
    controller?.value = controller!.value.copyWith(
      previewSize: widget.previewSize,
    );

    /// Initialize camera controller
    await controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    /// Start scan
    if (widget.scanProcess) {
      _startScan();
    }
  }

  void _startScan() {
    if (controller?.value.isInitialized ?? false) {
      if (!controller!.value.isStreamingImages) {
        controller?.startImageStream(processImage);
      }
    }
  }

  void _stopScan() {
    if (controller?.value.isInitialized ?? false) {
      if (controller!.value.isStreamingImages) {
        controller?.stopImageStream();
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
