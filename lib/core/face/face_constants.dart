class FaceConstants {
  /// Euclidean distance must be <= this to count as a match.
  static const double euclideanMatchThreshold = 0.80;

  /// Maps distance → UI %. Threshold distance maps to 75%.
  static const double distancePercentScale = euclideanMatchThreshold / 0.25;

  /// Display pass line (aligned with [euclideanMatchThreshold]).
  static const double matchPercentThreshold = 75.0;

  static const int embeddingSize = 192;
  static const int modelInputSize = 112;
  static const String modelAsset = 'assets/models/mobilefacenet.tflite';

  static const int embeddingSchemaVersion = 2;
  static const String profilePrefsKey = 'trackora_face_profile_v2';
  static const String schemaPrefsKey = 'trackora_face_schema';
}