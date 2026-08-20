import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/screens/home/providers/home_provider.dart';

class StartMyDayScreen extends StatelessWidget {
  const StartMyDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const SizedBox(
                width: double.infinity,
                height: 132,
                child: CustomPaint(painter: _MorningScenePainter()),
              ),
              const SizedBox(height: 8),
              const Text(
                'GOOD MORNING!',
                style: TextStyle(
                  fontFamily: 'Inter_Bold',
                  color: AppColors.appColor,
                  fontSize: 22,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${home.userName}',
                style: const TextStyle(
                  fontFamily: 'Inter_Bold',
                  color: AppColors.textDark,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 28),
              const _QuoteDivider(),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFF5C518), size: 16),
                  SizedBox(width: 8),
                  Text(
                    "TODAY'S THOUGHT",
                    style: TextStyle(
                      fontFamily: 'Inter_Bold',
                      color: AppColors.appColor,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star_rounded, color: Color(0xFFF5C518), size: 16),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Success doesn't come from what you do occasionally. It comes from what you do consistently.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  color: AppColors.textDark,
                  fontSize: 20,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '— Unknown',
                style: TextStyle(
                  fontFamily: 'Inter_Regular',
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              const Divider(color: Color(0xFFE2E6E5), height: 1),
              const SizedBox(height: 22),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ThoughtItem(
                    icon: _SmileyIcon(),
                    label: 'Stay Positive',
                  ),
                  _ThoughtItem(
                    icon: _TargetIcon(),
                    label: 'Stay Focused',
                  ),
                  _ThoughtItem(
                    icon: _SproutIcon(),
                    label: 'Keep Growing',
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.homeScreen, // "/HomeScreen"
                          (route) => false,     // peechhli har route hatao
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start My Day',
                        style: TextStyle(
                          fontFamily: 'Inter_SemiBold',
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
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

class _QuoteDivider extends StatelessWidget {
  const _QuoteDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E6E5), height: 1)),
        Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD7DEDD)),
          ),
          child: const Icon(
            Icons.format_quote_rounded,
            size: 18,
            color: Color(0xFF5B8A84),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E6E5), height: 1)),
      ],
    );
  }
}

class _ThoughtItem extends StatelessWidget {
  const _ThoughtItem({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        icon,
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter_Medium',
            color: AppColors.textDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SmileyIcon extends StatelessWidget {
  const _SmileyIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _SmileyPainter(),
    );
  }
}

class _TargetIcon extends StatelessWidget {
  const _TargetIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _TargetPainter(),
    );
  }
}

class _SproutIcon extends StatelessWidget {
  const _SproutIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 36),
      painter: _SproutPainter(),
    );
  }
}

class _MorningScenePainter extends CustomPainter {
  const _MorningScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;
    const sunR = 28.0;

    final rayPaint = Paint()
      ..color = const Color(0xFFFFC44D)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + math.cos(a) * (sunR + 8), cy + math.sin(a) * (sunR + 8)),
        Offset(cx + math.cos(a) * (sunR + 20), cy + math.sin(a) * (sunR + 20)),
        rayPaint,
      );
    }

    canvas.drawCircle(
      Offset(cx, cy),
      sunR,
      Paint()..color = const Color(0xFFFFD24A),
    );

    _cloud(canvas, Offset(cx - 86, cy + 6), 1.05);
    _cloud(canvas, Offset(cx + 88, cy + 10), 0.92);

    final bird = Paint()
      ..color = const Color(0xFF3D6B9A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    _bird(canvas, Offset(cx - 58, cy - 38), bird);
    _bird(canvas, Offset(cx + 62, cy - 42), bird);
  }

  void _cloud(Canvas canvas, Offset c, double s) {
    final paint = Paint()..color = const Color(0xFFE8EEF2);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 78 * s, height: 28 * s),
      paint,
    );
    canvas.drawCircle(c.translate(-18 * s, -6 * s), 16 * s, paint);
    canvas.drawCircle(c.translate(10 * s, -10 * s), 18 * s, paint);
    canvas.drawCircle(c.translate(22 * s, -2 * s), 13 * s, paint);
  }

  void _bird(Canvas canvas, Offset c, Paint paint) {
    final left = Path()
      ..moveTo(c.dx - 10, c.dy)
      ..quadraticBezierTo(c.dx - 5, c.dy - 7, c.dx, c.dy);
    final right = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(c.dx + 5, c.dy - 7, c.dx + 10, c.dy);
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SmileyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, size.width / 2, Paint()..color = const Color(0xFFFFC107));
    final eye = Paint()..color = const Color(0xFF5D4037);
    canvas.drawCircle(Offset(c.dx - 6, c.dy - 4), 2.1, eye);
    canvas.drawCircle(Offset(c.dx + 6, c.dy - 4), 2.1, eye);
    final smile = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 2), width: 16, height: 12),
      0.2,
      math.pi - 0.4,
      false,
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 16, Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(c, 10, Paint()..color = Colors.white);
    canvas.drawCircle(c, 4.5, Paint()..color = const Color(0xFFE53935));
    final arrow = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx + 4, c.dy - 4), Offset(c.dx + 14, c.dy - 14), arrow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0xFF43A047)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width / 2, size.height - 4),
      Offset(size.width / 2, size.height * 0.42),
      stem,
    );
    final leaf = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2 - 8, size.height * 0.42),
        width: 16,
        height: 10,
      ),
      leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2 + 8, size.height * 0.34),
        width: 16,
        height: 10,
      ),
      leaf,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
