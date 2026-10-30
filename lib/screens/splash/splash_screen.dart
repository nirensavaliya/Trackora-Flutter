import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_images.dart';
import 'package:trackora/screens/splash/providers/splash_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _designWidth = 390.0;
  static bool _wavesPrecached = false;

  @override
  Widget build(BuildContext context) {
    if (!_wavesPrecached) {
      _wavesPrecached = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          precacheImage(AppImages.homeHeaderWaves, context);
        }
      });
    }
    return Consumer<SplashProvider>(
      builder: (context, splash, _) {
        if (splash.status != SplashStatus.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              splash.navigateOnce(context);
            }
          });
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final s = w / _designWidth;

                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: -65 * s,
                      top: -21 * s,
                      child: _GradientBlob(size: 220 * s),
                    ),
                    Positioned(
                      left: -90 * s,
                      top: 140 * s,
                      child: _GradientBlob(size: 150 * s),
                    ),

                    Positioned(
                      right: -70 * s,
                      bottom: -40 * s,
                      child: _GradientBlob(size: 220 * s),
                    ),
                    Positioned(
                      right: -50 * s,
                      bottom: 130 * s,
                      child: _GradientBlob(size: 140 * s),
                    ),

                    Positioned(
                      right: -90 * s,
                      top: -90 * s,
                      child: _OutlineRings(
                        size: 200 * s,
                        strokeWidth: 1.2 * s,
                      ),
                    ),

                    Positioned(
                      left: -90 * s,
                      bottom: -90 * s,
                      child: _OutlineRings(
                        size: 200 * s,
                        strokeWidth: 1.2 * s,
                      ),
                    ),

                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.splashLogo,
                            width: 130 * s,
                            height: 130 * s,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 16 * s),
                          Text(
                            'TRACKORA',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              fontSize: 40 * s,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.2 * s,
                              color: const Color(0xFF38847C),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _GradientBlob extends StatelessWidget {
  const _GradientBlob({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            const Color(0xFF38847C),
            const Color(0xFF92BCB7).withValues(alpha: 0.65),
          ],
        ),
      ),
    );
  }
}

class _OutlineRings extends StatelessWidget {
  const _OutlineRings({
    required this.size,
    required this.strokeWidth,
  });

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RingsPainter(strokeWidth: strokeWidth),
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter({required this.strokeWidth});

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF38847C).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final outer = size.width / 2;
    canvas.drawCircle(center, outer * 0.92, paint);
    canvas.drawCircle(center, outer * 0.72, paint);
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) =>
      oldDelegate.strokeWidth != strokeWidth;
}
