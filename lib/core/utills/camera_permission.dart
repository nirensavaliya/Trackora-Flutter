import 'package:permission_handler/permission_handler.dart';

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
