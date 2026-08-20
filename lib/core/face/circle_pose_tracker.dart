import 'dart:math' as math;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Same tracker as face_lock_demo enroll: center lock, then fill the ring.
class CirclePoseTracker {
  CirclePoseTracker({this.segmentCount = 36});

  final int segmentCount;

  final Set<int> completed = {};
  bool centerLocked = false;
  int _centerStable = 0;

  static const double minTilt = 12;
  static const double maxTilt = 42;

  double get progress => completed.length / segmentCount;

  bool get isComplete =>
      centerLocked && completed.length >= (segmentCount * 0.75).ceil();

  void reset() {
    completed.clear();
    centerLocked = false;
    _centerStable = 0;
  }

  String update(Face face) {
    final yaw = face.headEulerAngleY ?? 0;
    final pitch = face.headEulerAngleX ?? 0;

    if (!centerLocked) {
      if (yaw.abs() < 10 && pitch.abs() < 12) {
        _centerStable++;
        if (_centerStable >= 3) {
          centerLocked = true;
          return 'Look TOP';
        }
        return 'Center your face — hold still ($_centerStable/3)';
      }
      _centerStable = 0;
      return 'Place your face inside the circle';
    }

    final magnitude = math.sqrt(yaw * yaw + pitch * pitch);
    if (magnitude < minTilt) {
      return _directionHint();
    }
    if (magnitude > maxTilt) {
      return 'A bit too far — move gently';
    }

    final radians = math.atan2(-yaw, -pitch);
    var degrees = radians * 180 / math.pi;
    if (degrees < 0) degrees += 360;

    final index = (degrees / 360 * segmentCount).floor() % segmentCount;
    completed.add(index);
    completed.add((index - 1 + segmentCount) % segmentCount);
    completed.add((index + 1) % segmentCount);
    completed.add((index - 2 + segmentCount) % segmentCount);
    completed.add((index + 2) % segmentCount);

    if (isComplete) {
      return 'Circle complete — capturing…';
    }
    return _directionHint();
  }

  /// Next pose the user should show.
  String get activeDirection {
    if (!centerLocked) return 'CENTER';
    if (!_quadrantFilled(0)) return 'TOP';
    if (!_quadrantFilled(2)) return 'BOTTOM';
    if (!_quadrantFilled(3)) return 'LEFT';
    if (!_quadrantFilled(1)) return 'RIGHT';
    return 'DONE';
  }

  String _directionHint() {
    switch (activeDirection) {
      case 'TOP':
        return 'Look TOP';
      case 'BOTTOM':
        return 'Look BOTTOM';
      case 'LEFT':
        return 'Turn LEFT';
      case 'RIGHT':
        return 'Turn RIGHT';
      default:
        return 'Move your head slowly to complete the circle';
    }
  }

  /// 0 top, 1 right, 2 bottom, 3 left.
  bool _quadrantFilled(int quadrant) {
    final size = segmentCount ~/ 4;
    final start = quadrant * size;
    final end = start + size;
    var count = 0;
    for (final i in completed) {
      if (i >= start && i < end) count++;
    }
    return count >= 4;
  }
}
