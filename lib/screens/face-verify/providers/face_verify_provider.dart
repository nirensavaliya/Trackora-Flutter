import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:trackora/core/face/circle_pose_tracker.dart';
import 'package:trackora/core/face/face_constants.dart';
import 'package:trackora/core/face/face_matcher.dart';
import 'package:trackora/core/face/face_profile_store.dart';

enum FaceVerifyPhase {
  scanning,
  capturing,
  verifying,
  success,
  failed,
}

class FaceVerifyProvider extends ChangeNotifier {
  FaceVerifyProvider() {
    loadProfile();
  }

  final tracker = CirclePoseTracker(segmentCount: 36);
  final _matcher = FaceMatcher();

  FaceVerifyPhase phase = FaceVerifyPhase.scanning;
  String title = 'Scanning...';
  String subtitle = 'Please position your face inside the circle';
  double matchPercent = 0;
  double matchDistance = 0;
  bool isFirstEnroll = true;

  Set<int> get completed => Set<int>.from(tracker.completed);

  int get ringPercent => (tracker.progress * 100).round();

  String get activeDirection => tracker.activeDirection;

  bool get isBusy =>
      phase == FaceVerifyPhase.capturing ||
      phase == FaceVerifyPhase.verifying;

  bool get showScore =>
      (phase == FaceVerifyPhase.success || phase == FaceVerifyPhase.failed) &&
      matchPercent > 0;

  Future<void> loadProfile() async {
    isFirstEnroll = !(await FaceProfileStore.hasProfile());
    subtitle = isFirstEnroll
        ? 'Center your face, then move slowly to fill the circle'
        : 'Place your face inside the circle';
    notifyListeners();
  }

  bool handleFrame({required List<Face> faces}) {
    if (phase != FaceVerifyPhase.scanning) return false;

    if (faces.length != 1) {
      title = 'Scanning...';
      subtitle = faces.isEmpty
          ? 'Face not found — look into the circle'
          : 'Only one face please';
      notifyListeners();
      return false;
    }

    final wasComplete = tracker.isComplete;
    subtitle = tracker.update(faces.first);
    title = !tracker.centerLocked
        ? 'Look CENTER'
        : tracker.activeDirection == 'DONE'
            ? 'Keep moving slowly'
            : 'Look ${tracker.activeDirection}';
    notifyListeners();

    if (!wasComplete && tracker.isComplete) {
      phase = FaceVerifyPhase.capturing;
      title = isFirstEnroll ? 'Saving face' : 'Checking identity';
      subtitle = isFirstEnroll
          ? 'Circle complete — saving your face…'
          : 'Circle complete — matching identity…';
      notifyListeners();
      return true;
    }
    return false;
  }

  List<List<double>> lastEmbeddings = [];

  Future<bool> completeWithEmbeddings(List<List<double>> live) async {
    phase = FaceVerifyPhase.verifying;
    title = 'Checking identity';
    subtitle = 'Please wait…';
    notifyListeners();

    if (live.isEmpty) {
      fail('Could not capture face — try again');
      return false;
    }

    lastEmbeddings = live;

    if (isFirstEnroll) {
      await FaceProfileStore.save(live);
      isFirstEnroll = false;
      matchPercent = 0;
      matchDistance = 0;
      return true;
    }

    final enrolled = await FaceProfileStore.load();
    if (enrolled.isEmpty) {
      fail('No enrolled face found — try again');
      return false;
    }

    final result = _matcher.match(
      liveEmbeddings: live,
      enrolledEmbeddings: enrolled,
    );
    matchPercent = result.matchPercent;
    matchDistance = result.distance.isFinite ? result.distance : 0;

    if (result.passed) {
      return true;
    }

    phase = FaceVerifyPhase.failed;
    title = 'Match failed';
    subtitle =
        'Match failed (${matchPercent.toStringAsFixed(1)}%, dist ${matchDistance.toStringAsFixed(3)}).\n'
        'Need ≥ ${FaceConstants.matchPercentThreshold.toStringAsFixed(0)}% '
        '(dist ≤ ${FaceConstants.euclideanMatchThreshold}).';
    notifyListeners();
    return false;
  }

  void fail(String message) {
    phase = FaceVerifyPhase.failed;
    title = 'Not verified';
    subtitle = message;
    notifyListeners();
  }

  void setPermissionNeeded() {
    title = 'Camera permission needed';
    subtitle = 'Allow camera to verify your face';
    notifyListeners();
  }

  void markCameraNotReady() {
    subtitle = 'Camera frame not ready…';
    notifyListeners();
  }

  void retry() {
    tracker.reset();
    phase = FaceVerifyPhase.scanning;
    matchPercent = 0;
    matchDistance = 0;
    title = 'Scanning...';
    subtitle = 'Please position your face inside the circle';
    notifyListeners();
  }
}
