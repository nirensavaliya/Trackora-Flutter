import 'package:flutter/material.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/leave_model.dart';
import 'package:trackora/data/models/leave_type_option.dart';

class LeaveProvider extends ChangeNotifier {
  LeaveTypeOption? selectedType;
  DateTime? startDate;
  DateTime? endDate;
  final reasonController = TextEditingController();

  List<LeaveModel> leaves = [];
  bool loading = false;
  bool applying = false;
  String? cancellingId;
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

  void resetForm() {
    selectedType = null;
    startDate = null;
    endDate = null;
    reasonController.clear();
    notifyListeners();
  }

  void setType(LeaveTypeOption? type) {
    selectedType = type;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    startDate = date;
    if (endDate != null && endDate!.isBefore(date)) {
      endDate = date;
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  String? validate() {
    if (selectedType == null) return 'Select leave type';
    if (startDate == null) return 'Select start date';
    if (endDate == null) return 'Select end date';
    if (endDate!.isBefore(startDate!)) {
      return 'End date cannot be before start date';
    }
    if (reasonController.text.trim().isEmpty) return 'Enter a reason';
    return null;
  }

  Future<void> loadRequests() async {
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
        ApiConstants.leaveRequests,
        queryParams: {'pageSize': 50},
        headers: headers,
      );
      final body = response.data;
      print('LEAVE REQUESTS STATUS: ${response.statusCode}');
      print('LEAVE REQUESTS BODY: $body');

      if (body is Map && body['success'] == true) {
        final data = body['data'];
        final items = data is Map ? data['items'] : null;
        if (items is List) {
          leaves = items
              .whereType<Map>()
              .map((e) => LeaveModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          error = null;
        } else {
          leaves = [];
        }
      } else {
        error = body is Map
            ? (body['message']?.toString() ?? 'Could not load leaves')
            : 'Could not load leaves';
      }
    } catch (e) {
      print('LEAVE REQUESTS ERROR: $e');
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> applyLeave() async {
    final validation = validate();
    if (validation != null) return validation;

    final headers = _authHeaders();
    if (headers == null) return 'Please login again';

    applying = true;
    notifyListeners();

    try {
      final payload = {
        'leaveTypeId': selectedType!.id,
        'fromDate': LeaveModel.apiDate(startDate!),
        'toDate': LeaveModel.apiDate(endDate!),
        'reason': reasonController.text.trim(),
      };
      print('LEAVE APPLY REQUEST: $payload');

      final response = await ApiService().postRequest(
        ApiConstants.leaveRequests,
        headers: headers,
        data: payload,
      );
      final body = response.data;
      print('LEAVE APPLY STATUS: ${response.statusCode}');
      print('LEAVE APPLY BODY: $body');

      if (body is Map && body['success'] == true) {
        resetForm();
        await loadRequests();
        return null;
      }

      return body is Map
          ? (body['message']?.toString() ??
              body['error']?.toString() ??
              'Could not apply leave')
          : 'Could not apply leave';
    } catch (e) {
      print('LEAVE APPLY ERROR: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      applying = false;
      notifyListeners();
    }
  }

  Future<String?> cancelLeave(String id) async {
    final headers = _authHeaders();
    if (headers == null) return 'Please login again';

    cancellingId = id;
    notifyListeners();

    try {
      print('LEAVE CANCEL REQUEST: $id');
      final response = await ApiService().postRequest(
        ApiConstants.leaveRequestCancel(id),
        headers: headers,
      );
      final body = response.data;
      print('LEAVE CANCEL STATUS: ${response.statusCode}');
      print('LEAVE CANCEL BODY: $body');

      if (body is Map && body['success'] == true) {
        await loadRequests();
        return null;
      }

      return body is Map
          ? (body['message']?.toString() ??
              body['error']?.toString() ??
              'Could not cancel leave')
          : 'Could not cancel leave';
    } catch (e) {
      print('LEAVE CANCEL ERROR: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      cancellingId = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
