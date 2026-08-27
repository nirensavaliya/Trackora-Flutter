import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/screens/home/providers/home_provider.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  String _formatClock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _todayHeader(DateTime now) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Today, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final now = DateTime.now();
    final punched = home.isPunchedIn && home.punchedInAt != null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontFamily: 'Inter_Bold',
            color: AppColors.textDark,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textDark,
              size: 22,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            _todayHeader(now),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter_Medium',
              color: AppColors.textDark,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          _StatusCard(punched: punched, home: home, formatClock: _formatClock),
          const SizedBox(height: 28),
          const Text(
            "Today's Timeline",
            style: TextStyle(
              fontFamily: 'Inter_SemiBold',
              color: AppColors.textDark,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _Timeline(
            punched: punched || home.isPunchedOut,
            punchInTime: home.punchedInAt != null
                ? _formatClock(home.punchedInAt!)
                : '- -',
            punchOutTime: home.punchedOutAt != null
                ? _formatClock(home.punchedOutAt!)
                : '- -',
            punchedOut: home.isPunchedOut,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.punched,
    required this.home,
    required this.formatClock,
  });

  final bool punched;
  final HomeProvider home;
  final String Function(DateTime) formatClock;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.appColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
              color: punched || home.isPunchedOut
                  ? const Color(0xFF7DFFB3)
                  : Colors.white54,
                size: 10,
              ),
              const SizedBox(width: 8),
              Text(
                punched
                    ? 'PUNCHED IN'
                    : home.isPunchedOut
                        ? 'PUNCHED OUT'
                        : 'NOT PUNCHED IN',
                style: const TextStyle(
                  fontFamily: 'Inter_Bold',
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            punched
                ? formatClock(home.punchedInAt!)
                : home.isPunchedOut && home.punchedOutAt != null
                    ? formatClock(home.punchedOutAt!)
                    : '--:--',
            style: const TextStyle(
              fontFamily: 'Inter_Bold',
              color: Colors.white,
              fontSize: 40,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            punched
                ? 'Working ${home.workingDuration}'
                : home.isPunchedOut
                    ? 'Worked ${home.workingDuration}'
                    : 'Start your day',
            style: const TextStyle(
              fontFamily: 'Inter_Regular',
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          if (home.isPunchedOut) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
              ),
              child: const Text(
                'DAY CLOSED',
                style: TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
          if (!home.isPunchedOut) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.faceVerify);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.appColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: Icon(
                  punched ? Icons.timer_outlined : Icons.fingerprint,
                  size: 20,
                ),
                label: Text(
                  punched ? 'PUNCH OUT' : 'PUNCH IN',
                  style: const TextStyle(
                    fontFamily: 'Inter_SemiBold',
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.punched,
    required this.punchInTime,
    required this.punchOutTime,
    required this.punchedOut,
  });

  final bool punched;
  final String punchInTime;
  final String punchOutTime;
  final bool punchedOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineRow(
          time: punchInTime,
          label: 'Punched In',
          done: punched,
          isLast: false,
        ),
        _TimelineRow(
          time: punchOutTime,
          label: 'Punched Out',
          done: punchedOut,
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.label,
    required this.done,
    required this.isLast,
  });

  final String time;
  final String label;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: done ? AppColors.appColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done ? AppColors.appColor : const Color(0xFFC5CDCB),
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: const Color(0xFFD7DEDC),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'Inter_SemiBold',
                      color: done ? AppColors.textDark : AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter_Regular',
                    color: done ? AppColors.textDark : AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
