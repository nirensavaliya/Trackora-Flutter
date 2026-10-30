import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_images.dart';
import 'package:trackora/core/storage/local_storage.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  static const _teal = Color(0xFF38847C);

  final List<OnBoardingData> pages = [
    OnBoardingData(
      image: AppImages.onboardingImg1,
      title: 'SMART\nGEO-ATTENDANCE',
      description:
          'Verify employee check-ins\ninstantly with AI face match\nand precise GPS locations.',
    ),
    OnBoardingData(
      image: AppImages.onboardingImg2,
      title: 'CRM & WORKFORCE MANAGEMENT',
      description:
          'Track sales pipeline, assign tasks,\nand manage team productivity all in\none unified platform.',
    ),
    OnBoardingData(
      image: AppImages.onboardingImg3,
      title: 'EMPOWER YOUR BUSINESS TODAY',
      description:
          'Join thousands of enterprises\noptimizing their daily operations with\nTrackora.',
    ),
  ];

  bool get _isLast => currentPage == pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (!_isLast) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      goToLogin();
    }
  }

  Future<void> goToLogin() async {
    await GetStorageData.saveBool(GetStorageData.onboardingScreen, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Skip
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: goToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: _teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _teal,
                        ),
                      ),
                    ),
                  ),

                  // Pages
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) {
                        setState(() => currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return _OnBoardingPage(data: pages[index]);
                      },
                    ),
                  ),

                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (i) {
                      final selected = i == currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? _teal
                              : _teal.withValues(alpha: 0.25),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 22),

                  // CTA
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: _isLast
                        ? Center(
                            child: _GetStartedButton(onTap: nextPage),
                          )
                        : Center(
                            child: _NextCircleButton(onTap: nextPage),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onTap});

  final VoidCallback onTap;

  static const _btnColor = Color(0xFF38847C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        height: 48,
        decoration: BoxDecoration(
          color: _btnColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _btnColor.withValues(alpha: 0.25),
              offset: const Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -4,
            ),
            BoxShadow(
              color: _btnColor.withValues(alpha: 0.25),
              offset: const Offset(0, 10),
              blurRadius: 15,
              spreadRadius: -3,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get Started',
              style: GoogleFonts.nunitoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorBlob extends StatelessWidget {
  const _DecorBlob({required this.size});

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

class _OnBoardingPage extends StatelessWidget {
  const _OnBoardingPage({required this.data});

  final OnBoardingData data;

  static const _teal = Color(0xFF38847C);
  static const _bodyGrey = Color(0xFF5DAFA7);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Expanded(
            flex: 10,
            child: Center(
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 0.6,
              color: _teal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.55,
              color: _bodyGrey,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

/// Circular next button with thin arc (Figma).
class _NextCircleButton extends StatelessWidget {
  const _NextCircleButton({required this.onTap});

  final VoidCallback onTap;

  static const _teal = Color(0xFF38847C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(72, 72),
              painter: _ArcPainter(),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _teal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38847C).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    // Partial arc around the button (Figma accent)
    canvas.drawArc(rect, -1.2, 2.6, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnBoardingData {
  final String image;
  final String title;
  final String description;

  OnBoardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
