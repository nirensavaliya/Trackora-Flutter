import 'package:flutter/material.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/employee_model.dart';
import 'package:trackora/data/models/leave_detail_model.dart' hide Employee;
import 'package:trackora/data/models/leave_model.dart';
import 'package:trackora/data/models/leave_type_option.dart';

class LeaveProvider extends ChangeNotifier {
  LeaveTypeOption? selectedType;
  DateTime? startDate;
  DateTime? endDate;
  final reasonController = TextEditingController();
  LeaveDetailModel? leaveDetailData;

  List<LeaveModel> leaves = [];
  List<Employee> employees = [];
  String? selectedEmployeeId;

  bool loading = false;
  bool applying = false;
  bool assigning = false;
  bool loadingEmployees = false;
  String? actionBusyId;
  String? error;
  bool isLeaveDetailLoading = false;
  String? errorMessage;

  String get token => GetStorageData.readString(GetStorageData.token) ?? '';

  String get userRole =>
      (GetStorageData.readString(GetStorageData.userType) ?? '')
          .trim()
          .toUpperCase();

  bool get isUser => userRole == 'USER';

  bool get isHr => userRole == 'HR';

  bool get isAdmin => userRole == 'ADMIN';

  bool get isManager => isHr || isAdmin;

  Map<String, String>? _authHeaders() {
    final token = GetStorageData.readString(GetStorageData.token)?.toString();
    if (token == null || token.isEmpty) return null;
    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  String? _messageFromBody(dynamic body, String fallback) {
    if (body is Map) {
      return body['message']?.toString() ??
          body['error']?.toString() ??
          fallback;
    }
    return fallback;
  }

  void resetForm() {
    selectedType = null;
    selectedEmployeeId = null;
    startDate = null;
    endDate = null;
    reasonController.clear();
    notifyListeners();
  }

  void setType(LeaveTypeOption? type) {
    selectedType = type;
    notifyListeners();
  }

  void setEmployeeId(String? id) {
    selectedEmployeeId = id;
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

  String? validate({bool requireEmployee = false}) {
    if (requireEmployee &&
        (selectedEmployeeId == null || selectedEmployeeId!.isEmpty)) {
      return 'Select employee';
    }
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
      debugPrint('LEAVE REQUESTS STATUS: ${response.statusCode}');
      debugPrint('LEAVE REQUESTS BODY: $body');

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
        error = _messageFromBody(body, 'Could not load leaves');
      }
    } catch (e) {
      debugPrint('LEAVE REQUESTS ERROR: $e');
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadEmployees({bool force = false}) async {
    if (!isManager) return;
    if (loadingEmployees) return;
    if (!force && employees.isNotEmpty) return;

    final headers = _authHeaders();
    if (headers == null) return;

    loadingEmployees = true;
    notifyListeners();

    try {
      final response = await ApiService().getRequest(
        ApiConstants.getEmployees,
        headers: headers,
      );
      final body = response.data;
      debugPrint('EMPLOYEES STATUS: ${response.statusCode}');
      debugPrint('EMPLOYEES BODY: $body');

      if (body is Map && body['success'] == true) {
        final parsed = EmployeeResponse.fromJson(Map<String, dynamic>.from(body));
        employees = parsed.data ?? [];
      } else if (response.statusCode == 200 && body is Map) {
        final parsed = EmployeeResponse.fromJson(Map<String, dynamic>.from(body));
        employees = parsed.data ?? [];
      }
    } catch (e) {
      debugPrint('EMPLOYEES ERROR: $e');
    } finally {
      loadingEmployees = false;
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
      final payload = <String, dynamic>{
        'leaveTypeId': selectedType!.id,
        'fromDate': LeaveModel.apiDate(startDate!),
        'toDate': LeaveModel.apiDate(endDate!),
        'reason': reasonController.text.trim(),
      };

      // Managers applying on behalf of someone via Apply still use leaveRequests.
      if (isManager &&
          selectedEmployeeId != null &&
          selectedEmployeeId!.isNotEmpty) {
        payload['employeeId'] = selectedEmployeeId;
      }

      debugPrint('LEAVE APPLY REQUEST: $payload');

      final response = await ApiService().postRequest(
        ApiConstants.leaveRequests,
        headers: headers,
        data: payload,
      );
      final body = response.data;
      debugPrint('LEAVE APPLY STATUS: ${response.statusCode}');
      debugPrint('LEAVE APPLY BODY: $body');

      if (body is Map && body['success'] == true) {
        resetForm();
        await loadRequests();
        return null;
      }

      return _messageFromBody(body, 'Could not apply leave');
    } catch (e) {
      debugPrint('LEAVE APPLY ERROR: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      applying = false;
      notifyListeners();
    }
  }

  Future<String?> assignLeave() async {
    final validation = validate(requireEmployee: true);
    if (validation != null) return validation;

    final headers = _authHeaders();
    if (headers == null) return 'Please login again';

    assigning = true;
    notifyListeners();

    try {
      final payload = {
        'employeeId': selectedEmployeeId,
        'leaveTypeId': selectedType!.id,
        'fromDate': LeaveModel.apiDate(startDate!),
        'toDate': LeaveModel.apiDate(endDate!),
        'reason': reasonController.text.trim(),
      };
      debugPrint('LEAVE ASSIGN REQUEST: $payload');

      final response = await ApiService().postRequest(
        ApiConstants.assignLeave,
        headers: headers,
        data: payload,
      );
      final body = response.data;
      debugPrint('LEAVE ASSIGN STATUS: ${response.statusCode}');
      debugPrint('LEAVE ASSIGN BODY: $body');

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body is Map &&
          body['success'] == true) {
        resetForm();
        await loadRequests();
        return null;
      }

      return _messageFromBody(body, 'Could not assign leave');
    } catch (e) {
      debugPrint('LEAVE ASSIGN ERROR: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      assigning = false;
      notifyListeners();
    }
  }

  Future<String?> cancelLeave(String id) async {
    final headers = _authHeaders();
    if (headers == null) return 'Please login again';

    actionBusyId = id;
    notifyListeners();

    try {
      debugPrint('LEAVE CANCEL REQUEST: $id');
      final response = await ApiService().postRequest(
        ApiConstants.leaveRequestCancel(id),
        headers: headers,
      );
      final body = response.data;
      debugPrint('LEAVE CANCEL STATUS: ${response.statusCode}');
      debugPrint('LEAVE CANCEL BODY: $body');

      if (body is Map && body['success'] == true) {
        await loadRequests();
        return null;
      }

      return _messageFromBody(body, 'Could not cancel leave');
    } catch (e) {
      debugPrint('LEAVE CANCEL ERROR: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      actionBusyId = null;
      notifyListeners();
    }
  }

  Future<String?> approveLeave(String id) async {
    final headers = _authHeaders();
    if (headers == null) return 'Please login again';

    actionBusyId = id;
    notifyListeners();

    try {
      debugPrint('LEAVE APPROVE REQUEST: $id');
      final response = await ApiService().postRequest(
        ApiConstants.leaveRequestApprove(id),
        headers: headers,
      );
      final body = response.data;
      debugPrint('LEAVE APPROVE STATUS: ${response.statusCode}');
      debugPrint('LEAVE APPROVE BODY: $body');

      if (body is Map && body['success'] == true) {
        await loadRequests();
        return null;
      }

      return _messageFromBody(body, 'Could not approve leave');
    } catch (e) {
      debugPrint('LEAVE APPROVE ERROR: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      actionBusyId = null;
      notifyListeners();
    }
  }

  Future<String?> rejectLeave(String id) async {
    final headers = _authHeaders();
    if (headers == null) return 'Please login again';

    actionBusyId = id;
    notifyListeners();

    try {
      debugPrint('LEAVE REJECT REQUEST: $id');
      final response = await ApiService().postRequest(
        ApiConstants.leaveRequestReject(id),
        headers: headers,
      );
      final body = response.data;
      debugPrint('LEAVE REJECT STATUS: ${response.statusCode}');
      debugPrint('LEAVE REJECT BODY: $body');

      if (body is Map && body['success'] == true) {
        await loadRequests();
        return null;
      }

      return _messageFromBody(body, 'Could not reject leave');
    } catch (e) {
      debugPrint('LEAVE REJECT ERROR: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      actionBusyId = null;
      notifyListeners();
    }
  }

  Future<bool> leaveDetail(String leaveId) async {
    isLeaveDetailLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('OPEN LEAVE DETAIL API');
      debugPrint('LEAVE ID = $leaveId');

      final headers = _authHeaders() ?? {'Authorization': 'Bearer $token'};
      final response = await ApiService().getRequest(
        '${ApiConstants.leaveRequests}/$leaveId',
        headers: headers,
      );

      debugPrint('LEAVE DETAIL STATUS = ${response.statusCode}');
      debugPrint('LEAVE DETAIL RESPONSE = ${response.data}');

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map) {
          leaveDetailData =
              LeaveDetailModel.fromJson(Map<String, dynamic>.from(body));
        }
        return leaveDetailData?.data != null;
      }

      errorMessage = 'Unable to load leave details';
      return false;
    } catch (e) {
      debugPrint('LEAVE DETAIL ERROR = $e');
      errorMessage = e.toString();
      return false;
    } finally {
      isLeaveDetailLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }
}
