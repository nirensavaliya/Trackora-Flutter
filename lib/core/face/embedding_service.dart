import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:trackora/core/face/face_constants.dart';

class EmbeddingService {
  Interpreter? _interpreter;
  bool get isReady => _interpreter != null;

  Future<void> init() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(FaceConstants.modelAsset);
  }

  List<double> embed(img.Image faceCrop) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('EmbeddingService not initialized');
    }

    final size = FaceConstants.modelInputSize;
    final square = img.copyResizeCropSquare(faceCrop, size: size);

    dynamic input = _imageToByteListFloat32(square);
    input = (input as List).reshape([1, size, size, 3]);

    dynamic output = List.generate(
      1,
      (_) => List<double>.filled(FaceConstants.embeddingSize, 0.0),
    );
    interpreter.run(input, output);
    final flat = (output as List).reshape([FaceConstants.embeddingSize]);
    return flat.map((e) => (e as num).toDouble()).toList();
  }

  Float32List _imageToByteListFloat32(img.Image image) {
    final size = FaceConstants.modelInputSize;
    final convertedBytes = Float32List(1 * size * size * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    var pixelIndex = 0;

    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = (pixel.r - 128.0) / 128.0;
        buffer[pixelIndex++] = (pixel.g - 128.0) / 128.0;
        buffer[pixelIndex++] = (pixel.b - 128.0) / 128.0;
      }
    }
    return convertedBytes;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
