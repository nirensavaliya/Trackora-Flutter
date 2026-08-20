import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackora/screens/splash/providers/splash_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Consumer<SplashProvider>(
      builder: (context, splash, _) {
        if (splash.status != SplashStatus.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) splash.navigateOnce(context);
          });
        }
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img_splash_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // const SizedBox(height: 24),
                  Image.asset(
                    'assets/images/Icon (1).png',
                  ),
                  const SizedBox(height: 8),
                  _SplashBranding(),

                ],
              ),
            ),
          ),
        );
      }
    );
  }
}



class _SplashBranding extends StatelessWidget {
  const _SplashBranding();
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TrackoraMark(),
        SizedBox(height: 16),
        Text(
          'Trackora',
          style: TextStyle(
            fontFamily: 'Inter_Bold',
            color: Colors.white,
            fontSize: 36,
            height: 1.1,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'WORKFORCE INTELLIGENCE',
          style: TextStyle(
            fontFamily: 'Inter_Medium',
            color: Color(0xFFB7D4CF),
            fontSize: 11,
            letterSpacing: 2.8,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
class _TrackoraMark extends StatelessWidget {
  const _TrackoraMark();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(painter: _TrackoraMarkPainter()),
    );
  }
}


class _TrackoraMarkPainter extends CustomPainter {
  const _TrackoraMarkPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 1.5;
    final ring = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0;
    canvas.drawCircle(c, r, ring);
    final bar = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(c.dx, c.dy - r * 0.42),
      Offset(c.dx, c.dy + r * 0.42),
      bar,
    );
    canvas.drawLine(
      Offset(c.dx - r * 0.34, c.dy),
      Offset(c.dx + r * 0.34, c.dy),
      bar,
    );
    final glow = Paint()
      ..color = const Color(0xFF5EEAD4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(c.dx, c.dy - r * 0.42), 3.2, glow);
    canvas.drawCircle(
      Offset(c.dx, c.dy - r * 0.42),
      2.2,
      Paint()..color = const Color(0xFF5EEAD4),
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
