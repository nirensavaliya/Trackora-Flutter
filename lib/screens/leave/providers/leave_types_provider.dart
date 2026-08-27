import 'package:flutter/material.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/leave_type_option.dart';

class LeaveTypesProvider extends ChangeNotifier {
  List<LeaveTypeOption> types = [];
  bool loading = false;
  String? error;

  Map<String, String>? _authHeaders() {
    final token = GetStorageData.readString(GetStorageData.token)?.toString();
    if (token == null || token.isEmpty) return null;
    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  List<LeaveTypeOption> get activeTypes =>
      types.where((t) => t.isActive && t.id.isNotEmpty).toList();

  Future<void> loadTypes({bool force = false}) async {
    if (loading) return;
    if (!force && types.isNotEmpty) return;

    final headers = _authHeaders();
    if (headers == null) {
      error = 'Please login again';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService().getRequest(
        ApiConstants.leaveTypes,
        headers: headers,
      );
      final body = response.data;
      print('LEAVE TYPES STATUS: ${response.statusCode}');
      print('LEAVE TYPES BODY: $body');

      if (body is Map && body['success'] == true && body['data'] is List) {
        types = (body['data'] as List)
            .whereType<Map>()
            .map((e) => LeaveTypeOption.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        error = null;
      } else {
        error = body is Map
            ? (body['message']?.toString() ?? 'Could not load leave types')
            : 'Could not load leave types';
      }
    } catch (e) {
      print('LEAVE TYPES ERROR: $e');
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
