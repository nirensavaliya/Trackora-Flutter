import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:trackora/app/app.dart';
import 'package:trackora/core/face/face_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await _initGoogleMaps();
  await initFaceServices();
  runApp(const TrackoraApp());
}

Future<void> _initGoogleMaps() async {
  if (!Platform.isAndroid) return;
  final implementation = GoogleMapsFlutterPlatform.instance;
  if (implementation is GoogleMapsFlutterAndroid) {
    implementation.useAndroidViewSurface = true;
    try {
      await implementation.initializeWithRenderer(AndroidMapRenderer.latest);
    } catch (_) {}
  }
}
