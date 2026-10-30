import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/employee_model.dart';
import 'package:trackora/data/models/leave_balance_model.dart';
import 'package:trackora/data/models/leave_model.dart';

enum DayPeriod { morning, afternoon, evening }

class HomeProvider extends ChangeNotifier {
  String userName = '';
  int notificationCount = 3;
  double targetPercent = 0.78;
  String targetDone = '₹7,80,000';
  String targetTotal = '₹10,00,000';
  bool isPunchedIn = false;
  DateTime? punchedInAt;
  DateTime? punchedOutAt;
  Timer? _clock;
  int todayCount = 0;
  int overdueCount = 0;
  int unsolvedCount = 0;
  double netPay = 0;
  double monthlySalary = 0;
  String attendanceStatus = 'ABSENT';

  List<LeaveBalance> leaveBalances = [];
  List<LeaveModel> recentLeaves = [];
  List<Employee> employees = [];
  int teamPunchedInCount = 0;

  String get userRole =>
      (GetStorageData.readString(GetStorageData.userType) ?? '')
          .trim()
          .toUpperCase();

  bool get isUser => userRole == 'USER';

  bool get isHr => userRole == 'HR';

  bool get isAdmin => userRole == 'ADMIN';

  bool get isManager => isHr || isAdmin;

  bool get showPunchCard => isUser || isHr;

  int get pendingLeaveCount => recentLeaves
      .where((l) => l.status == LeaveRequestStatus.pending)
      .length;

  int get leaveLeftTotal {
    var total = 0;
    for (final b in leaveBalances) {
      total += b.remainingDays;
    }
    return total < 0 ? 0 : total;
  }

  int get peopleCount => employees.length;

  String get attendanceStatusLabel {
    if (isAdmin) {
      return '$teamPunchedInCount punched';
    }
    if (isPunchedIn || isPunchedOut) return 'PRESENT';
    final value = attendanceStatus.trim();
    if (value.isEmpty) return 'ABSENT';
    return value.toUpperCase();
  }

  bool get isPunchedOut => !isPunchedIn && punchedOutAt != null;

  DayPeriod get period {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return DayPeriod.morning;
    if (hour >= 12 && hour < 17) return DayPeriod.afternoon;
    return DayPeriod.evening;
  }

  String get greeting {
    switch (period) {
      case DayPeriod.morning:
        return 'Good Morning,';
      case DayPeriod.afternoon:
        return 'Good Afternoon,';
      case DayPeriod.evening:
        return 'Good Evening,';
    }
  }

  String get bannerImage {
    switch (period) {
      case DayPeriod.morning:
        return 'assets/images/img_morning.png';
      case DayPeriod.afternoon:
        return 'assets/images/img_afternoon.png';
      case DayPeriod.evening:
        return 'assets/images/img_evening.png';
    }
  }

  String get todayDate {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  Map<String, String>? _authHeaders() {
    final token = GetStorageData.readString(GetStorageData.token)?.toString();
    if (token == null || token.isEmpty) return null;
    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
    };
  }

  HomeProvider() {
    refreshSession();
  }

  Future<void> refreshSession() async {
    loadUser();
    final futures = <Future>[
      loadTaskSummary(),
      loadEarnings(),
      loadLeaveBalances(),
      loadRecentLeaves(),
    ];
    if (showPunchCard) {
      futures.add(loadTodayAttendance());
    }
    if (isManager) {
      futures.add(loadEmployees());
    }
    if (isAdmin) {
      futures.add(loadTeamPunchedInToday());
    }
    await Future.wait(futures);
  }

  void resetSession() {
    userName = '';
    isPunchedIn = false;
    punchedInAt = null;
    punchedOutAt = null;
    todayCount = 0;
    overdueCount = 0;
    unsolvedCount = 0;
    netPay = 0;
    monthlySalary = 0;
    attendanceStatus = 'ABSENT';
    leaveBalances = [];
    recentLeaves = [];
    employees = [];
    teamPunchedInCount = 0;
    _clock?.cancel();
    _clock = null;
    notifyListeners();
  }

  String _formatClock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get punchInClock {
    final time = punchedInAt;
    if (time == null) return currentClock;
    return _formatClock(time);
  }

  String get punchOutClock {
    final time = punchedOutAt;
    if (time == null) return currentClock;
    return _formatClock(time);
  }

  String get currentClock => _formatClock(DateTime.now());

  String get workingDuration {
    final start = punchedInAt;
    if (start == null) return '00:00:00';
    final end = punchedOutAt ?? DateTime.now();
    final d = end.difference(start);
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get netPayText => _formatInr(netPay);

  String _formatInr(num amount) {
    final n = amount.round();
    final s = n.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final withCommas = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₹$withCommas,$last3';
  }

  void punchIn() {
    isPunchedIn = true;
    punchedInAt = DateTime.now();
    punchedOutAt = null;
    attendanceStatus = 'PRESENT';
    _startClock();
    notifyListeners();
  }

  void punchOut() {
    isPunchedIn = false;
    punchedOutAt = DateTime.now();
    attendanceStatus = 'PRESENT';
    _clock?.cancel();
    _clock = null;
    notifyListeners();
  }

  void _startClock() {
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void loadUser() {
    final raw = GetStorageData.readString(GetStorageData.loginData);
    if (raw is! String || raw.isEmpty) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>? ?? {};
    userName = user['name']?.toString() ?? 'User';
    notifyListeners();
  }

  Future<void> loadTaskSummary() async {
    try {
      final headers = _authHeaders();
      if (headers == null) return;
      final response = await ApiService().getRequest(
        ApiConstants.taskSummary,
        headers: headers,
      );
      final body = response.data;
      debugPrint('TASK SUMMARY: $body');
      if (body is Map && body['success'] == true && body['data'] is Map) {
        final data = Map<String, dynamic>.from(body['data'] as Map);
        final counts = data['counts'] is Map
            ? Map<String, dynamic>.from(data['counts'] as Map)
            : <String, dynamic>{};
        todayCount = int.tryParse('${counts['today']}') ?? 0;
        overdueCount = int.tryParse('${counts['overdue']}') ?? 0;
        unsolvedCount = int.tryParse('${counts['unsolved']}') ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('TASK SUMMARY ERROR: $e');
    }
  }

  Future<void> loadEarnings() async {
    try {
      final headers = _authHeaders();
      if (headers == null) return;
      final response = await ApiService().getRequest(
        ApiConstants.earnings,
        headers: headers,
      );
      final body = response.data;
      debugPrint('EARNINGS: $body');
      if (body is Map && body['success'] == true && body['data'] is Map) {
        final data = Map<String, dynamic>.from(body['data'] as Map);
        netPay = double.tryParse('${data['netPay']}') ?? 0;
        monthlySalary = double.tryParse('${data['monthlySalary']}') ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('EARNINGS ERROR: $e');
    }
  }

  Future<void> loadLeaveBalances() async {
    try {
      final headers = _authHeaders();
      if (headers == null) return;
      final response = await ApiService().getRequest(
        ApiConstants.leaveBalance,
        headers: headers,
      );
      final body = response.data;
      debugPrint('LEAVE BALANCE: $body');
      if (body is Map) {
        final parsed = LeaveBalanceResponse.fromJson(
          Map<String, dynamic>.from(body),
        );
        leaveBalances = parsed.data ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('LEAVE BALANCE ERROR: $e');
    }
  }

  Future<void> loadRecentLeaves() async {
    try {
      final headers = _authHeaders();
      if (headers == null) return;
      final response = await ApiService().getRequest(
        ApiConstants.leaveRequests,
        queryParams: {'pageSize': 10},
        headers: headers,
      );
      final body = response.data;
      debugPrint('RECENT LEAVES: $body');
      if (body is Map && body['success'] == true) {
        final data = body['data'];
        final items = data is Map ? data['items'] : null;
        if (items is List) {
          recentLeaves = items
              .whereType<Map>()
              .map((e) => LeaveModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('RECENT LEAVES ERROR: $e');
    }
  }

  Future<void> loadEmployees() async {
    if (!isManager) return;
    try {
      final headers = _authHeaders();
      if (headers == null) return;
      final response = await ApiService().getRequest(
        ApiConstants.getEmployees,
        headers: headers,
      );
      final body = response.data;
      debugPrint('HOME EMPLOYEES: $body');
      if (body is Map) {
        final parsed =
            EmployeeResponse.fromJson(Map<String, dynamic>.from(body));
        employees = parsed.data ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('HOME EMPLOYEES ERROR: $e');
    }
  }

  Future<void> loadTeamPunchedInToday() async {
    if (!isAdmin) return;
    try {
      final headers = _authHeaders();
      if (headers == null) return;
      final now = DateTime.now();
      final day =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final response = await ApiService().getRequest(
        ApiConstants.attendance,
        queryParams: {'from': day, 'to': day},
        headers: headers,
      );
      final body = response.data;
      debugPrint('TEAM ATTENDANCE TODAY: $body');
      if (body is Map && body['data'] is List) {
        teamPunchedInCount = (body['data'] as List).where((item) {
          if (item is! Map) return false;
          final checkIn = item['checkInAt']?.toString();
          final checkOut = item['checkOutAt']?.toString();
          return checkIn != null &&
              checkIn.isNotEmpty &&
              (checkOut == null || checkOut.isEmpty);
        }).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('TEAM ATTENDANCE ERROR: $e');
    }
  }

  Future<void> loadTodayAttendance() async {
    try {
      final headers = _authHeaders();
      if (headers == null) return;
      final response = await ApiService().getRequest(
        ApiConstants.attendanceToday,
        headers: headers,
      );
      final body = response.data;
      debugPrint('ATTENDANCE TODAY STATUS: ${response.statusCode}');
      debugPrint('ATTENDANCE TODAY BODY: $body');
      if (body is! Map || body['success'] != true) return;
      final data = body['data'];
      if (data == null) {
        if (isPunchedIn) {
          attendanceStatus = 'PRESENT';
          notifyListeners();
          return;
        }
        if (isPunchedOut) {
          attendanceStatus = 'PRESENT';
          notifyListeners();
          return;
        }
        isPunchedIn = false;
        punchedInAt = null;
        punchedOutAt = null;
        attendanceStatus = 'ABSENT';
        _clock?.cancel();
        notifyListeners();
        return;
      }
      final map = Map<String, dynamic>.from(data as Map);
      final checkInAt = map['checkInAt']?.toString();
      final checkOutAt = map['checkOutAt']?.toString();
      final apiStatus = map['status']?.toString().trim() ?? '';
      debugPrint('ATTENDANCE status: $apiStatus');
      if (checkInAt != null &&
          checkInAt.isNotEmpty &&
          (checkOutAt == null || checkOutAt.isEmpty)) {
        isPunchedIn = true;
        punchedInAt = DateTime.tryParse(checkInAt)?.toLocal();
        punchedOutAt = null;
        attendanceStatus = 'PRESENT';
        _startClock();
      } else if (checkInAt != null && checkInAt.isNotEmpty) {
        isPunchedIn = false;
        punchedInAt = DateTime.tryParse(checkInAt)?.toLocal();
        punchedOutAt = DateTime.tryParse(checkOutAt!)?.toLocal();
        attendanceStatus = 'PRESENT';
        _clock?.cancel();
      } else {
        isPunchedIn = false;
        punchedInAt = null;
        punchedOutAt = null;
        attendanceStatus = 'ABSENT';
        _clock?.cancel();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('ATTENDANCE TODAY ERROR: $e');
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }
}
