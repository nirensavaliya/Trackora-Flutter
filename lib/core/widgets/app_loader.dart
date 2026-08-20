import 'package:flutter/material.dart';
import 'package:trackora/core/constants/app_colors.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({
    super.key,
    this.size = 70,
    this.color = AppColors.appColor,
    this.rippleCount = 3,
  });

  final double size;
  final Color color;
  final int rippleCount;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  static const _duration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    final stagger = _duration.inMilliseconds ~/ widget.rippleCount;
    _controllers = List.generate(widget.rippleCount, (i) {
      final controller = AnimationController(vsync: this, duration: _duration);
      Future.delayed(Duration(milliseconds: i * stagger), () {
        if (mounted) controller.repeat();
      });
      return controller;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final controller in _controllers)
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final t = controller.value;
                final scale = 0.35 + (0.65 * t);
                final opacity = (1 - t).clamp(0.0, 1.0) * 0.65;
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.color, width: 2),
                      ),
                    ),
                  ),
                );
              },
            ),
          Container(
            width: widget.size * 0.48,
            height: widget.size * 0.48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
            child: Icon(
              Icons.fingerprint,
              color: Colors.white,
              size: widget.size * 0.26,
            ),
          ),
        ],
      ),
    );
  }
}

class AppLoaderOverlay extends StatelessWidget {
  const AppLoaderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const AbsorbPointer(
      child: ColoredBox(
        color: Color(0x66000000),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.all(28),
              child: AppLoader(),
            ),
          ),
        ),
      ),
    );
  }
}
