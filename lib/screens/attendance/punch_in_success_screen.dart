import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/screens/attendance/start_my_day_screen.dart';

class PunchInSuccessScreen extends StatefulWidget {
  const PunchInSuccessScreen({
    super.key,
    required this.time,
    required this.date,
    required this.location,
    this.isPunchOut = false,
  });

  final String time;
  final String date;
  final String location;
  final bool isPunchOut;

  @override
  State<PunchInSuccessScreen> createState() => _PunchInSuccessScreenState();
}

class _PunchInSuccessScreenState extends State<PunchInSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _check;
  late final AnimationController _burst;
  late final Animation<double> _checkScale;
  late final Animation<double> _titleFade;

  static const _confettiColors = [
    Color(0xFFFF8A3D),
    Color(0xFFFFC107),
    Color(0xFF42A5F5),
    Color(0xFFEF5350),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
  ];

  @override
  void initState() {
    super.initState();
    _check = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _checkScale = CurvedAnimation(parent: _check, curve: Curves.elasticOut);
    _titleFade = CurvedAnimation(
      parent: _check,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
    _check.forward();
    _burst.forward();
  }

  @override
  void dispose() {
    _check.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: 220,
                height: 220,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_check, _burst]),
                  builder: (context, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        ...List.generate(22, (i) {
                          final angle = (i / 22) * math.pi * 2;
                          final dist = 24 + _burst.value * (70 + (i % 5) * 8);
                          final fall = _burst.value * (18 + (i % 4) * 10);
                          return Transform.translate(
                            offset: Offset(
                              math.cos(angle) * dist,
                              math.sin(angle) * dist + fall,
                            ),
                            child: Opacity(
                              opacity: (1 - _burst.value * 0.85).clamp(0.0, 1.0),
                              child: Transform.rotate(
                                angle: angle + _burst.value * 2.2,
                                child: Container(
                                  width: i.isEven ? 9 : 6,
                                  height: i % 3 == 0 ? 12 : 6,
                                  decoration: BoxDecoration(
                                    color: _confettiColors[
                                        i % _confettiColors.length],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        ScaleTransition(
                          scale: _checkScale,
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: const BoxDecoration(
                              color: AppColors.appColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              FadeTransition(
                opacity: _titleFade,
                child: Text(
                  widget.isPunchOut
                      ? 'Punch Out Successful!'
                      : 'Punch In Successful!',
                  style: const TextStyle(
                    fontFamily: 'Inter_Bold',
                    color: AppColors.appColor,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _titleFade,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: widget.time,
                      ),
                      const Divider(height: 1, color: Color(0xFFEEF1F0)),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: widget.date,
                      ),
                      const Divider(height: 1, color: Color(0xFFEEF1F0)),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.appColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.appColor,
                          ),
                        ),
                        title: const Text(
                          'Location',
                          style: TextStyle(
                            fontFamily: 'Inter_Medium',
                            color: AppColors.textDark,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.location,
                              style: const TextStyle(
                                fontFamily: 'Inter_Regular',
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Text(
                                  'Location Verified',
                                  style: TextStyle(
                                    fontFamily: 'Inter_Medium',
                                    color: AppColors.appColor,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.appColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _titleFade,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.isPunchOut) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        return;
                      }
                      Navigator.push(
                        context,
                        PageRouteBuilder<void>(
                          pageBuilder: (_, __, ___) => const StartMyDayScreen(),
                          transitionDuration: const Duration(milliseconds: 280),
                          transitionsBuilder: (_, anim, __, child) {
                            return FadeTransition(opacity: anim, child: child);
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Inter_SemiBold',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.appColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.appColor),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter_Medium',
          color: AppColors.textDark,
          fontSize: 15,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontFamily: 'Inter_SemiBold',
          color: AppColors.textDark,
          fontSize: 15,
        ),
      ),
    );
  }
}
