import 'dart:math';

import 'package:trackora/core/face/face_constants.dart';

class FaceMatchResult {
  const FaceMatchResult({
    required this.distance,
    required this.matchPercent,
    required this.passed,
  });

  final double distance;
  final double matchPercent;
  final bool passed;
}

class FaceMatcher {
  double euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return double.infinity;
    var sum = 0.0;
    for (var i = 0; i < a.length; i++) {
      final d = a[i] - b[i];
      sum += d * d;
    }
    return sqrt(sum);
  }

  double distanceToPercent(double distance) {
    if (distance.isInfinite || distance.isNaN) return 0;
    final scale = FaceConstants.distancePercentScale;
    final raw = (1.0 - distance / scale) * 100.0;
    return max(0.0, min(100.0, raw));
  }

  FaceMatchResult match({
    required List<List<double>> liveEmbeddings,
    required List<List<double>> enrolledEmbeddings,
  }) {
    var bestDist = double.infinity;
    for (final live in liveEmbeddings) {
      for (final enrolled in enrolledEmbeddings) {
        final d = euclideanDistance(live, enrolled);
        if (d < bestDist) bestDist = d;
      }
    }

    final percent = distanceToPercent(bestDist);
    return FaceMatchResult(
      distance: bestDist,
      matchPercent: percent,
      passed: bestDist <= FaceConstants.euclideanMatchThreshold,
    );
  }
}
