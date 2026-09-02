import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/face/circle_pose_tracker.dart';
import 'package:trackora/core/face/face_constants.dart';
import 'package:trackora/core/face/face_matcher.dart';
import 'package:trackora/core/face/face_profile_store.dart';
import 'package:trackora/core/storage/local_storage.dart';

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
  double checkInFaceScore = 0;
  bool isFirstEnroll = true;
  List<List<double>> lastEmbeddings = [];

  /// Default office coords until GPS is wired (Surat).
  static const double defaultLat = 21.1702;
  static const double defaultLng = 72.8311;
  static const String punchLocationLabel = 'Surat, Gujarat';

  Set<int> get completed => Set<int>.from(tracker.completed);

  int get ringPercent => (tracker.progress * 100).round();

  String get activeDirection => tracker.activeDirection;

  bool get isBusy =>
      phase == FaceVerifyPhase.capturing ||
      phase == FaceVerifyPhase.verifying;

  bool get showScore =>
      (phase == FaceVerifyPhase.success || phase == FaceVerifyPhase.failed) &&
      matchPercent > 0;

  Map<String, String>? _authHeaders() {
    final token = GetStorageData.readString(GetStorageData.token)?.toString();
    if (token == null || token.isEmpty) return null;
    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  bool get _isFaceRegisteredOnServer {
    if (GetStorageData.readBool(GetStorageData.faceRegistered) != true) {
      return false;
    }
    final registeredFor =
        GetStorageData.readString(GetStorageData.faceRegisteredUserId)?.toString();
    final currentUser =
        GetStorageData.readString(GetStorageData.userId)?.toString();
    return registeredFor != null &&
        registeredFor.isNotEmpty &&
        registeredFor == currentUser;
  }

  Future<void> loadProfile() async {
    final hasLocal = await FaceProfileStore.hasProfile();
    isFirstEnroll = !hasLocal || !_isFaceRegisteredOnServer;
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

  /// [forPunchIn] false = punch-out after local match, then POST punch-out.
  Future<bool> completeWithEmbeddings(
    List<List<double>> live, {
    bool forPunchIn = true,
  }) async {
    phase = FaceVerifyPhase.verifying;
    title = 'Checking identity';
    subtitle = 'Please wait…';
    notifyListeners();

    if (live.isEmpty) {
      fail('Could not capture face — try again');
      return false;
    }

    lastEmbeddings = live;
    final embedding = live.first;

    // --- First time: local save + /face/register ---
    if (isFirstEnroll || !_isFaceRegisteredOnServer) {
      await FaceProfileStore.save(live);
      isFirstEnroll = false;
      matchPercent = 0;
      matchDistance = 0;

      final registered = await _registerFace(embedding);
      if (!registered) return false;

      if (forPunchIn) {
        final punched = await _punchIn(embedding);
        if (!punched) return false;
      } else {
        final punched = await _punchOut(embedding);
        if (!punched) return false;
      }

      phase = FaceVerifyPhase.success;
      title = 'Verified';
      subtitle = forPunchIn
          ? 'Face registered successfully'
          : 'Punch out successful';
      notifyListeners();
      return true;
    }

    // --- Next times: local match then punch-in API ---
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

    if (!result.passed) {
      phase = FaceVerifyPhase.failed;
      title = 'Match failed';
      subtitle =
      "This face doesn’t match the registered face. Punch in only with your own face.";
      print('Match_failed(${matchPercent.toStringAsFixed(1)}%, dist_${matchDistance.toStringAsFixed(3)})');
      // subtitle =
      //     'Match failed (${matchPercent.toStringAsFixed(1)}%, dist ${matchDistance.toStringAsFixed(3)}).\n'
      //     'Need ≥ ${FaceConstants.matchPercentThreshold.toStringAsFixed(0)}% '
      //     '(dist ≤ ${FaceConstants.euclideanMatchThreshold}).';
      notifyListeners();
      return false;
    }

    if (forPunchIn) {
      final punched = await _punchIn(embedding);
      if (!punched) return false;
    } else {
      final punched = await _punchOut(embedding);
      if (!punched) return false;
    }

    phase = FaceVerifyPhase.success;
    title = 'Verified';
    subtitle = forPunchIn ? 'Punch in successful' : 'Punch out successful';
    notifyListeners();
    return true;
  }

  Future<bool> _registerFace(List<double> embedding) async {
    final headers = _authHeaders();
    if (headers == null) {
      fail('Please login again — token missing');
      return false;
    }

    try {
      print('FACE REGISTER REQUEST embedding.length=${embedding.length}');
      final response = await ApiService().postRequest(
        ApiConstants.faceRegister,
        headers: headers,
        data: {'embedding': embedding},
      );

      final body = response.data;
      print('FACE REGISTER STATUS: ${response.statusCode}');
      print('FACE REGISTER BODY: $body');

      if (body is Map && body['success'] == true) {
        await GetStorageData.saveBool(GetStorageData.faceRegistered, true);
        final userId =
            GetStorageData.readString(GetStorageData.userId)?.toString();
        if (userId != null && userId.isNotEmpty) {
          await GetStorageData.saveString(
            GetStorageData.faceRegisteredUserId,
            userId,
          );
        }
        final message = body['message']?.toString();
        if (message != null && message.isNotEmpty) {
          print('FACE REGISTER MESSAGE: $message');
        }
        return true;
      }

      final msg = body is Map
          ? (body['message']?.toString() ?? body['error']?.toString())
          : null;
      fail(msg ?? 'Face register failed');
      return false;
    } catch (e) {
      print('FACE REGISTER ERROR: $e');
      fail(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> _punchIn(
    List<double> embedding, {
    bool allowRegisterFallback = true,
  }) async {
    final headers = _authHeaders();
    if (headers == null) {
      fail('Please login again — token missing');
      return false;
    }

    try {
      final payload = {
        'lat': defaultLat,
        'lng': defaultLng,
        'source': 'MOBILE',
        'embedding': embedding,
      };
      print('PUNCH IN REQUEST: lat=$defaultLat lng=$defaultLng '
          'embedding.length=${embedding.length}');

      final response = await ApiService().postRequest(
        ApiConstants.punchIn,
        headers: headers,
        data: payload,
      );

      final body = response.data;
      print('PUNCH IN STATUS: ${response.statusCode}');
      print('PUNCH IN BODY: $body');

      if (body is Map && body['success'] == true) {
        final data = body['data'] is Map
            ? Map<String, dynamic>.from(body['data'] as Map)
            : <String, dynamic>{};
        checkInFaceScore =
            double.tryParse('${data['checkInFaceScore']}') ?? 0;
        print('PUNCH IN checkInFaceScore: $checkInFaceScore');
        if (checkInFaceScore > 0) {
          matchPercent = checkInFaceScore <= 1
              ? checkInFaceScore * 100
              : checkInFaceScore;
        }
        return true;
      }

      if (allowRegisterFallback && _needsFaceRegister(body)) {
        print('PUNCH IN 403 → FACE REGISTER then retry punch-in');
        await GetStorageData.removeData(GetStorageData.faceRegistered);
        await GetStorageData.removeData(GetStorageData.faceRegisteredUserId);
        isFirstEnroll = true;
        final registered = await _registerFace(embedding);
        if (!registered) return false;
        return _punchIn(embedding, allowRegisterFallback: false);
      }

      final msg = body is Map
          ? (body['message']?.toString() ?? body['error']?.toString())
          : null;
      fail(msg ?? 'Punch in failed');
      return false;
    } catch (e) {
      print('PUNCH IN ERROR: $e');
      fail(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> _punchOut(List<double> embedding) async {
    final headers = _authHeaders();
    if (headers == null) {
      fail('Please login again — token missing');
      return false;
    }

    try {
      final payload = {
        'lat': defaultLat,
        'lng': defaultLng,
        'source': 'MOBILE',
        'embedding': embedding,
      };
      print('PUNCH OUT REQUEST: lat=$defaultLat lng=$defaultLng '
          'embedding.length=${embedding.length}');

      final response = await ApiService().postRequest(
        ApiConstants.punchOut,
        headers: headers,
        data: payload,
      );

      final body = response.data;
      print('PUNCH OUT STATUS: ${response.statusCode}');
      print('PUNCH OUT BODY: $body');

      if (body is Map && body['success'] == true) {
        return true;
      }

      final msg = body is Map
          ? (body['message']?.toString() ?? body['error']?.toString())
          : null;
      fail(msg ?? 'Punch out failed');
      return false;
    } catch (e) {
      print('PUNCH OUT ERROR: $e');
      fail(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  bool _needsFaceRegister(dynamic body) {
    if (body is! Map) return false;
    final message = body['message']?.toString().toLowerCase() ?? '';
    return message.contains('register your face') ||
        message.contains('/api/face/register');
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
    if (phase != FaceVerifyPhase.scanning) return;
    subtitle = 'Camera frame not ready — hold still';
    notifyListeners();
  }

  void reportScanIssue(String message) {
    if (phase != FaceVerifyPhase.scanning) return;
    subtitle = message;
    notifyListeners();
  }

  void retry() {
    tracker.reset();
    phase = FaceVerifyPhase.scanning;
    matchPercent = 0;
    matchDistance = 0;
    checkInFaceScore = 0;
    title = 'Scanning...';
    subtitle = 'Please position your face inside the circle';
    notifyListeners();
  }
}
