import 'package:permission_handler/permission_handler.dart';

/// Requests camera permission. On iOS, [PERMISSION_CAMERA=1] must be set in Podfile.
Future<CameraPermissionResult> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (status.isGranted) {
    return CameraPermissionResult.granted;
  }

  status = await Permission.camera.request();
  if (status.isGranted) {
    return CameraPermissionResult.granted;
  }
  if (status.isPermanentlyDenied) {
    return CameraPermissionResult.permanentlyDenied;
  }
  return CameraPermissionResult.denied;
}

enum CameraPermissionResult { granted, denied, permanentlyDenied }
