import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/app_loader.dart';

import '../../../core/constants/app_images.dart';
import '../providers/login_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final login = context.watch<LoginProvider>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned(
              top: -26,
              right: -28,
              child: _TopRightDecor(),
            ),
            const Positioned(
              left: 0,
              bottom: 0,
              child: _BottomLeftDecor(),
            ),
            SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                  child: Form(
                    key: login.formKey,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            AppImages.splashLogo,
                            width: 54 ,
                            height: 54 ,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'TRACKORA',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF38847C),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome back',
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.55,
                          color: const Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                       Text(
                        'Sign in to continue to Trackora',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'LOGIN AS',
                        style: TextStyle(
                          fontFamily: 'Inter_SemiBold',
                          color: AppColors.textGrey,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RoleSelector(
                        selected: login.selectedRole,
                        onSelected: login.selectRole,
                      ),
                      const SizedBox(height: 24),
                        _LabeledField(
                        label: 'Client Code',
                        controller: login.clientCode,
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.text,
                        validator: login.validateClientCode,
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Email Address',
                        controller: login.email,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: login.validateEmail,
                      ),
                      const SizedBox(height: 18),
                      _LabeledField(
                        label: 'Password',
                        controller: login.password,
                        icon: Icons.lock_outline_rounded,
                        hintText: 'Enter your password',
                        obscure: login.obscure,
                        suffix: IconButton(
                          onPressed: login.toggleObscure,
                          icon: Icon(
                            login.obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textGrey,
                            size: 22,
                          ),
                        ),
                        validator: login.validatePassword,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xff6B7280),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child:  Text(
                            'Forgot Password?',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff6B7280),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _LoginButton(
                        label: login.isLoading ? 'Login....' : 'Login',
                        isLoading: login.isLoading,
                        onTap: () => login.onLogin(context),
                      ),
                      const SizedBox(height: 28),
                      /*const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFD7DEDC))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                fontFamily: 'Inter_Regular',
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFD7DEDC))),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textDark,
                            side: const BorderSide(color: Color(0xFFE2E6E5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GoogleMark(),
                              SizedBox(width: 10),
                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontFamily: 'Inter_SemiBold',
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),*/
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'New company? ',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff6B7280),
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.signUpScreen,
                                    );
                                  },
                                  child:  Text(
                                    'Create an account',
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff1B6B63),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              );
            },
          ),
        ),
            if (login.isLoading)
              const Positioned.fill(child: AppLoaderOverlay()),
          ],
        ),
      ),
    );
  }
}

/// Figma: tilted ellipse (#92BCB7 @ 20%) clipped at the top-right corner.
class _TopRightDecor extends StatelessWidget {
  const _TopRightDecor();

  static const _fill = Color(0xFF92BCB7);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: 0.17,
        child: Container(
          width: 134.43,
          height: 77,
          decoration: ShapeDecoration(
            color: _fill.withValues(alpha: 0.2),
            shape: const OvalBorder(),
          ),
        ),
      ),
    );
  }
}

/// Figma: concentric quarter-circles anchored at bottom-left.
class _BottomLeftDecor extends StatelessWidget {
  const _BottomLeftDecor();

  static const _outer = Color(0xFFE6F0EE);
  static const _inner = Color(0xFF8FB3B0);
  static const double _outerSize = 125;
  static const double _innerSize = 90;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: _outerSize,
        height: _outerSize,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              width: _outerSize,
              height: _outerSize,
              decoration: const BoxDecoration(
                color: _outer,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(_outerSize),
                ),
              ),
            ),
            Container(
              width: _innerSize,
              height: _innerSize,
              decoration: const BoxDecoration(
                color: _inner,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(_innerSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  static const _fill = Color(0xFF38847C);
  static const _shadow = Color(0xFF1B6B63);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: _fill,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _shadow.withValues(alpha: 0.45),
              offset: const Offset(0, 10),
              blurRadius: 25,
              spreadRadius: -4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (!isLoading) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onSelected,
  });

  final LoginRole selected;
  final ValueChanged<LoginRole> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withValues(alpha: 0.90),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _RoleChip(
            label: 'Admin',
            icon: Icons.groups_outlined,
            selected: selected == LoginRole.admin,
            onTap: () => onSelected(LoginRole.admin),
            showDividerAfter: selected != LoginRole.admin &&
                selected != LoginRole.hr,
          ),
          _RoleChip(
            label: 'HR',
            icon: Icons.groups_outlined,
            selected: selected == LoginRole.hr,
            onTap: () => onSelected(LoginRole.hr),
            showDividerAfter: selected != LoginRole.hr &&
                selected != LoginRole.user,
          ),
          _RoleChip(
            label: 'User',
            icon: Icons.person_outline_rounded,
            selected: selected == LoginRole.user,
            onTap: () => onSelected(LoginRole.user),
            showDividerAfter: false,
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.showDividerAfter,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool showDividerAfter;

  static const _selectedBg = Color(0xFF3D9489);
  static const _unselectedFg = Color(0xFF374151);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: selected ? _selectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: selected ? Colors.white : _unselectedFg,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                        color: selected ? Colors.white : _unselectedFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showDividerAfter)
              Positioned(
                right: 0,
                top: 6,
                bottom: 6,
                child: Container(
                  width: 1,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.validator,
    this.hintText,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?) validator;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xff374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: AppColors.appColor,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff1F2937),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff1F2937),
            ),
            prefixIcon: Icon(icon, color: AppColors.textGrey, size: 22),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDE4E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.appColor, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD32F2F)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    stroke.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.4, 1.8, false, stroke);
    stroke.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.4, 1.1, false, stroke);
    stroke.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.5, 0.9, false, stroke);
    stroke.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.4, 1.3, false, stroke);
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.5),
      Offset(size.width - 2, size.height * 0.5),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
