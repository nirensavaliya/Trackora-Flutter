import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackora/core/face/face_constants.dart';

class FaceProfileStore {
  static Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(FaceConstants.schemaPrefsKey);
    if (current == FaceConstants.embeddingSchemaVersion) return;
    await prefs.remove(FaceConstants.profilePrefsKey);
    await prefs.setInt(
      FaceConstants.schemaPrefsKey,
      FaceConstants.embeddingSchemaVersion,
    );
  }

  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(FaceConstants.profilePrefsKey);
    return raw != null && raw.isNotEmpty;
  }

  static Future<List<List<double>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(FaceConstants.profilePrefsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => (e as List).map((v) => (v as num).toDouble()).toList())
        .toList();
  }

  static Future<void> save(List<List<double>> embeddings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(FaceConstants.profilePrefsKey, jsonEncode(embeddings));
    await prefs.setInt(
      FaceConstants.schemaPrefsKey,
      FaceConstants.embeddingSchemaVersion,
    );
  }
}
