import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/storage/local_storage.dart';

enum DayPeriod { morning, afternoon, evening }

class HomeProvider extends ChangeNotifier {
  String userName = '';
  int notificationCount = 3;
  int taskCount = 3;
  int visitCount = 2;
  double targetPercent = 0.78;
  String targetDone = '₹7,80,000';
  String targetTotal = '₹10,00,000';
  bool isPunchedIn = false;
  DateTime? punchedInAt;
  Timer? _clock;

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
    loadUser();
  }

  String get currentClock {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final periodLabel = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $periodLabel';
  }

  String get workingDuration {
    final start = punchedInAt;
    if (start == null) return '00:00:00';
    final d = DateTime.now().difference(start);
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void punchIn() {
    isPunchedIn = true;
    punchedInAt = DateTime.now();
    _startClock();
    notifyListeners();
  }

  void punchOut() {
    isPunchedIn = false;
    punchedInAt = null;
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
    userName = user['name']?.toString() ?? 'User'; // Gelai Admin
    notifyListeners();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }
}
