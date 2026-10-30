import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/Punch_response.dart';
import 'package:trackora/data/models/attendance_Response_Model.dart';
import 'package:trackora/data/models/attendance_model.dart';
import 'package:trackora/data/models/employee_model.dart';

class AttendanceProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  DateTime? punchedOutAt;
  List<AttendanceModel> attendanceList = [];
  List<AttendanceModel> attendanceTableList = [];
  AttendanceModel? currentAttendance;
  AttendanceResponse? attendanceResponse;
  PunchResponse? punchResponse;
  EmployeeResponse? employeeResponse;
  bool isLoadingMoreRecentLeave = false;
  bool hasMoreRecentLeave = true;
  String get token => GetStorageData.readString(GetStorageData.token);

  String get currentUserId => GetStorageData.readString(GetStorageData.userId);

  String get userRole =>
      (GetStorageData.readString(GetStorageData.userType) ?? '')
          .trim()
          .toUpperCase();

  bool get isUser => userRole == 'USER';

  bool get isHr => userRole == 'HR';

  bool get isAdmin => userRole == 'ADMIN';

  bool get isManager => isHr || isAdmin;
  bool get isCurrentlyPunchedIn {
    final attendance = currentAttendance;

    if (attendance == null) return false;

    return attendance.checkInAt != null &&
        attendance.checkOutAt == null;
  }
  String formatTime(DateTime? date) {
    if (date == null) return '—';

    final d = date.toLocal();

    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
  Future<void> initializeAttendance({
    required String from,
    required String to,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (isUser) {
        debugPrint('LOGIN ROLE = USER');

        await getAttendance(
          from: from,
          to: to,
          employeeId: null,
        );
      } else {
        debugPrint('LOGIN ROLE = $userRole');

        await getEmployee();

        await getAttendance(
          from: from,
          to: to,
          employeeId: null,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('INITIALIZE ATTENDANCE ERROR = $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> attendance() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().getRequest(
        ApiConstants.attendance,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("ATTENDANCE STATUS: ${response.statusCode}");
      debugPrint("ATTENDANCE RESPONSE: ${response.data}");

      if (response.statusCode == 200) {
        attendanceList.clear();
        currentAttendance = null;
        final List data = response.data['data'] ?? [];
        for (var item in data) {
          final attendance = AttendanceModel.fromJson(
            Map<String, dynamic>.from(item),
          );

          print('Attendance ID: ${attendance.id}',);
         print('Employee: ${attendance.employee?.user?.name}',);
          if (attendance.employee?.userId != currentUserId) {
            continue;
          }
          attendanceList.add(attendance);
          if (attendance.checkInAt == null) {
            continue;
          }
          final now = DateTime.now();
          final checkInLocal = attendance.checkInAt!.toLocal();

          final isToday =
              checkInLocal.year == now.year &&
                  checkInLocal.month == now.month &&
                  checkInLocal.day == now.day;
          if (!isToday) {
            continue;
          }
          if (currentAttendance == null) {
            currentAttendance = attendance;
          } else {
            final oldCheckIn = currentAttendance!.checkInAt;
            if (oldCheckIn == null ||
                attendance.checkInAt!.isAfter(oldCheckIn)) {
              currentAttendance = attendance;
            }
          }
        }if (isUser) {
          attendanceTableList =
          List<AttendanceModel>.from(attendanceList);
          debugPrint('USER TABLE LENGTH = ${attendanceTableList.length}',);
        }
        debugPrint("Current Attendance: ${currentAttendance?.id}",);
        isLoading = false;
        notifyListeners();
        return true;
      }

      errorMessage = _messageFromBody(response.data) ?? 'Failed to load attendance.';
      isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      debugPrint("ATTENDANCE DIO ERROR: ${e.message}");
      debugPrint("ATTENDANCE STATUS: ${e.response?.statusCode}",);
      debugPrint("ATTENDANCE RESPONSE: ${e.response?.data}",);
      if (e.response != null) {
        errorMessage = _messageFromBody(e.response?.data) ??'Failed to load attendance.';
      } else {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            errorMessage =
            'Connection timeout. Please try again.';
            break;

          case DioExceptionType.sendTimeout:
            errorMessage =
            'Request timeout. Please try again.';
            break;

          case DioExceptionType.receiveTimeout:
            errorMessage =
            'Server response timeout. Please try again.';
            break;

          case DioExceptionType.connectionError:
            errorMessage =
            'No internet connection.';
            break;

          case DioExceptionType.cancel:
            errorMessage =
            'Request cancelled.';
            break;

          default:
            errorMessage =
            'Something went wrong. Please try again.';
        }
      }

      isLoading = false;
      notifyListeners();

      return false;
    } catch (e) {
      debugPrint("ATTENDANCE UNKNOWN ERROR: $e");
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> todayAttendance() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().getRequest(
        ApiConstants.attendanceToday,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      debugPrint(
        "TODAY ATTENDANCE STATUS: ${response.statusCode}",
      );

      debugPrint(
        "TODAY ATTENDANCE RESPONSE: ${response.data}",
      );
      print("today Punch in----${response.data}");
      if(response.statusCode ==200){
        final punchResponse = PunchData.fromJson(response.data);
        currentAttendance = null;
        attendanceList.clear();
        return true;
      }
      errorMessage =
          _messageFromBody(response.data) ??
              'Failed to load today attendance.';

      isLoading = false;
      notifyListeners();

      return false;
    } on DioException catch (e) {
      debugPrint(
        'TODAY ATTENDANCE DIO ERROR: ${e.message}',
      );

      debugPrint(
        'TODAY ATTENDANCE STATUS: '
            '${e.response?.statusCode}',
      );

      debugPrint(
        'TODAY ATTENDANCE RESPONSE: '
            '${e.response?.data}',
      );

      errorMessage =
          _messageFromBody(e.response?.data) ??
              'Failed to load today attendance.';

      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint(
        'TODAY ATTENDANCE ERROR: $e',
      );

      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }
  Future<void> getEmployee() async {
    try {
      var response = await ApiService().getRequest(
        ApiConstants.getEmployees,
        headers: {'Authorization': 'Bearer $token'},
      );
      print("Employee Response=====${response.data}");
      if (response.statusCode == 200) {
        employeeResponse = EmployeeResponse.fromJson(response.data);
        debugPrint('STORED LEAVE DETAIL = $employeeResponse');
      } else {
        errorMessage = response.statusMessage ?? 'Unable to get Employee';
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Employee ERROR = $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> getAttendance({
    required String from,
    required String to,
    String? employeeId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      String url =
          '${ApiConstants.attendance}?from=$from&to=$to';

      if (employeeId != null &&
          employeeId.isNotEmpty &&
          employeeId != 'ALL') {
        url += '&employeeId=$employeeId';
      }

      debugPrint(
        'GET ATTENDANCE URL = $url',
      );

      final response =
      await ApiService().getRequest(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        'ATTENDANCE TABLE STATUS = '
            '${response.statusCode}',
      );

      debugPrint(
        'ATTENDANCE TABLE RESPONSE = '
            '${response.data}',
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];

        debugPrint('API DATA LENGTH = ${data.length}');
        attendanceList = data
            .map(
              (item) => AttendanceModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        ).toList();
        attendanceTableList = List<AttendanceModel>.from(attendanceList);

        debugPrint(
          'ATTENDANCE LIST LENGTH = ${attendanceList.length}',
        );

        debugPrint(
          'ATTENDANCE TABLE LENGTH = ${attendanceTableList.length}',
        );

        notifyListeners();

        return true;
      }

      errorMessage =
      'Unable to fetch attendance';

      return false;
    } catch (e) {
      errorMessage = e.toString();

      debugPrint(
        'ATTENDANCE TABLE ERROR = $e',
      );

      return false;
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  String? _messageFromBody(dynamic body) {
    if (body is Map) {
      return body['message']?.toString() ??
          body['error']?.toString() ??
          body['responseMsg']?.toString();
    }

    return null;
  }
}