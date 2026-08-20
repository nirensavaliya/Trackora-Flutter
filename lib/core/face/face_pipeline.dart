import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:trackora/core/face/embedding_service.dart';

class FacePipeline {
  FacePipeline(this._embedding);

  final EmbeddingService _embedding;

  late final FaceDetector detector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.15,
    ),
  );

  Future<void> init() => _embedding.init();

  Future<List<double>?> embeddingFromImageFile(File file) async {
    final bytes = await file.readAsBytes();
    var decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    decoded = img.bakeOrientation(decoded);

    final tmpDir = await getTemporaryDirectory();
    final tmpPath = p.join(
      tmpDir.path,
      'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final tmpFile = File(tmpPath)
      ..writeAsBytesSync(img.encodeJpg(decoded, quality: 95));

    final inputImage = InputImage.fromFilePath(tmpFile.path);
    final faces = await detector.processImage(inputImage);
    try {
      await tmpFile.delete();
    } catch (_) {}

    if (faces.isEmpty) return null;

    faces.sort(
      (a, b) => (b.boundingBox.width * b.boundingBox.height)
          .compareTo(a.boundingBox.width * a.boundingBox.height),
    );
    final crop = _cropFace(decoded, faces.first.boundingBox);
    if (crop == null) return null;
    return _embedding.embed(crop);
  }

  img.Image? _cropFace(img.Image full, Rect box) {
    var left = (box.left - 10).floor();
    var top = (box.top - 10).floor();
    var width = (box.width + 20).ceil();
    var height = (box.height + 20).ceil();

    left = max(0, left);
    top = max(0, top);
    if (left + width > full.width) width = full.width - left;
    if (top + height > full.height) height = full.height - top;
    if (width < 40 || height < 40) return null;

    return img.copyCrop(full, x: left, y: top, width: width, height: height);
  }

  Future<void> dispose() async {
    await detector.close();
    _embedding.dispose();
  }
}
