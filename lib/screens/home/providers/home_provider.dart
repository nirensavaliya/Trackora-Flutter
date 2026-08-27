import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/api_service.dart';
import '../../../core/storage/local_storage.dart';

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

  String get attendanceStatusLabel {
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

  HomeProvider(){
    refreshSession();
  }

  Future<void> refreshSession() async {
    loadUser();
    await Future.wait([
      loadTaskSummary(),
      loadEarnings(),
      loadTodayAttendance(),
    ]);
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

  String get netPayText {
    return _formatInr(netPay);
  }
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
      final token = GetStorageData.readString(GetStorageData.token)?.toString();
      if (token == null || token.isEmpty) return;
      final response = await ApiService().getRequest(
        ApiConstants.taskSummary,
        headers: {'Authorization': 'Bearer $token'},
      );
      final body = response.data;
      print('TASK SUMMARY: $body');
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
      print('TASK SUMMARY ERROR: $e');
    }
  }

  Future<void> loadEarnings() async {
    try {
      final token = GetStorageData.readString(GetStorageData.token)?.toString();
      if (token == null || token.isEmpty) return;
      final response = await ApiService().getRequest(
        ApiConstants.earnings,
        headers: {'Authorization': 'Bearer $token'},
      );
      final body = response.data;
      print('EARNINGS: $body');
      if (body is Map && body['success'] == true && body['data'] is Map) {
        final data = Map<String, dynamic>.from(body['data'] as Map);
        netPay = double.tryParse('${data['netPay']}') ?? 0;
        monthlySalary = double.tryParse('${data['monthlySalary']}') ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print('EARNINGS ERROR: $e');
    }
  }

  Future<void> loadTodayAttendance() async {
    try {
      final token = GetStorageData.readString(GetStorageData.token)?.toString();
      if (token == null || token.isEmpty) return;
      final response = await ApiService().getRequest(
        ApiConstants.attendanceToday,
        headers: {'Authorization': 'Bearer $token'},
      );
      final body = response.data;
      print('ATTENDANCE TODAY STATUS: ${response.statusCode}');
      print('ATTENDANCE TODAY BODY: $body');
      if (body is! Map || body['success'] != true) return;
      final data = body['data'];
      // No attendance today
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
      print('ATTENDANCE status: $apiStatus');
      if (checkInAt != null && checkInAt.isNotEmpty && (checkOutAt == null || checkOutAt.isEmpty)) {
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
      print('ATTENDANCE TODAY ERROR: $e');
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }
}
