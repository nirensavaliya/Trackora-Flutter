import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// Copies camera-plane bytes so they stay valid after the next frame.

InputImage? inputImageFromCameraImage({
  required CameraImage image,
  required CameraController controller,
  required int sensorOrientation,
}) {
  final rotation = _rotation(controller, sensorOrientation);
  if (rotation == null) return null;

  if (Platform.isIOS) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format != InputImageFormat.bgra8888 || image.planes.isEmpty) {
      return null;
    }
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format!,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  final bytes = _androidNv21Bytes(image);
  if (bytes == null) return null;

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.width,
    ),
  );
}

Uint8List? _androidNv21Bytes(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final ySize = width * height;
  final expectedSize = ySize + ySize ~/ 2;

  if (image.planes.isEmpty) return null;

  if (image.planes.length == 1) {
    final plane = image.planes.first;
    if (plane.bytes.length >= expectedSize) {
      return Uint8List.fromList(plane.bytes.sublist(0, expectedSize));
    }
    return null;
  }

  final yPlane = image.planes[0];

  if (image.planes.length == 2) {
    final uvPlane = image.planes[1];
    final nv21 = Uint8List(expectedSize);

    var yOut = 0;
    for (var row = 0; row < height; row++) {
      final start = row * yPlane.bytesPerRow;
      nv21.setRange(yOut, yOut + width, yPlane.bytes, start);
      yOut += width;
    }

    final uvHeight = height ~/ 2;
    final uvPixelStride = uvPlane.bytesPerPixel ?? 2;
    var uvOut = ySize;
    for (var row = 0; row < uvHeight; row++) {
      final rowStart = row * uvPlane.bytesPerRow;
      for (var col = 0; col < width; col += uvPixelStride) {
        if (uvOut + 1 >= nv21.length) break;
        nv21[uvOut++] = uvPlane.bytes[rowStart + col];
        nv21[uvOut++] = uvPlane.bytes[rowStart + col + 1];
      }
    }

    return nv21;
  }

  if (image.planes.length < 3) return null;

  final uPlane = image.planes[1];
  final vPlane = image.planes[2];
  final nv21 = Uint8List(expectedSize);

  var out = 0;
  for (var row = 0; row < height; row++) {
    final start = row * yPlane.bytesPerRow;
    nv21.setRange(out, out + width, yPlane.bytes, start);
    out += width;
  }

  final uvHeight = height ~/ 2;
  final uvWidth = width ~/ 2;
  final uRowStride = uPlane.bytesPerRow;
  final vRowStride = vPlane.bytesPerRow;
  final uPixelStride = uPlane.bytesPerPixel ?? 1;
  final vPixelStride = vPlane.bytesPerPixel ?? 1;

  var uvIndex = ySize;
  for (var row = 0; row < uvHeight; row++) {
    for (var col = 0; col < uvWidth; col++) {
      final uIndex = row * uRowStride + col * uPixelStride;
      final vIndex = row * vRowStride + col * vPixelStride;
      if (uvIndex + 1 >= nv21.length) break;
      nv21[uvIndex++] = vPlane.bytes[vIndex];
      nv21[uvIndex++] = uPlane.bytes[uIndex];
    }
  }

  return nv21;
}

InputImageRotation? _rotation(
  CameraController controller,
  int sensorOrientation,
) {
  if (Platform.isIOS) {
    return InputImageRotationValue.fromRawValue(sensorOrientation);
  }

  var rotationCompensation =
      _orientations[controller.value.deviceOrientation] ?? 0;
  if (controller.description.lensDirection == CameraLensDirection.front) {
    rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
  } else {
    rotationCompensation =
        (sensorOrientation - rotationCompensation + 360) % 360;
  }
  return InputImageRotationValue.fromRawValue(rotationCompensation);
}

const _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

class CameraFrameSnapshot {
  CameraFrameSnapshot._({
    required this.width,
    required this.height,
    required this.bytes,
    required this.bytesPerRow,
    required this.isBgra,
    required this.sensorOrientation,
  });

  final int width;
  final int height;
  final Uint8List bytes;
  final int bytesPerRow;
  final bool isBgra;
  final int sensorOrientation;

  /// Copies the current camera frame so `takePicture()` is never needed.
  static CameraFrameSnapshot? capture({
    required CameraImage image,
    required int sensorOrientation,
  }) {
    if (image.planes.isEmpty) return null;

    if (Platform.isIOS || image.format.group == ImageFormatGroup.bgra8888) {
      final plane = image.planes.first;
      return CameraFrameSnapshot._(
        width: image.width,
        height: image.height,
        bytes: Uint8List.fromList(plane.bytes),
        bytesPerRow: plane.bytesPerRow,
        isBgra: true,
        sensorOrientation: sensorOrientation,
      );
    }

    final nv21 = _androidNv21Bytes(image);
    if (nv21 == null) return null;
    return CameraFrameSnapshot._(
      width: image.width,
      height: image.height,
      bytes: nv21,
      bytesPerRow: image.width,
      isBgra: false,
      sensorOrientation: sensorOrientation,
    );
  }

  img.Image? toRgbImage() {
    final decoded = isBgra ? _bgraToImage() : _nv21ToImage();
    if (decoded == null) return null;
    if (sensorOrientation == 0) return decoded;
    return img.copyRotate(decoded, angle: sensorOrientation);
  }

  img.Image? _bgraToImage() {
    try {
      return img.Image.fromBytes(
        width: width,
        height: height,
        bytes: bytes.buffer,
        bytesOffset: bytes.offsetInBytes,
        rowStride: bytesPerRow,
        order: img.ChannelOrder.bgra,
        numChannels: 4,
      );
    } catch (_) {
      return null;
    }
  }

  img.Image _nv21ToImage() {
    final out = img.Image(width: width, height: height);
    final frameSize = width * height;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yp = bytes[y * width + x];
        final uvIndex = frameSize + (y >> 1) * width + (x & ~1);
        if (uvIndex + 1 >= bytes.length) {
          out.setPixelRgb(x, y, yp, yp, yp);
          continue;
        }
        final v = bytes[uvIndex];
        final u = bytes[uvIndex + 1];
        final c = yp - 16;
        final d = u - 128;
        final e = v - 128;
        final r = ((298 * c + 409 * e + 128) >> 8).clamp(0, 255);
        final g = ((298 * c - 100 * d - 208 * e + 128) >> 8).clamp(0, 255);
        final b = ((298 * c + 516 * d + 128) >> 8).clamp(0, 255);
        out.setPixelRgb(x, y, r, g, b);
      }
    }
    return out;
  }
}
