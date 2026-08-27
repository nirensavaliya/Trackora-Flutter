import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/app_loader.dart';

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
        backgroundColor: const Color(0xFFF0F7F6),
        body: Stack(
          children: [
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
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontFamily: 'Inter_Bold',
                          color: AppColors.textDark,
                          fontSize: 30,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Log in to manage your attendance and tasks.',
                        style: TextStyle(
                          fontFamily: 'Inter_Regular',
                          color: AppColors.textGrey,
                          fontSize: 14,
                          height: 1.4,
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
                            foregroundColor: AppColors.appColor,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontFamily: 'Inter_SemiBold',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: login.isLoading
                              ? null
                              : () => login.onLogin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.appColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.appColor,
                            elevation: 4,
                            shadowColor: AppColors.appColor.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                login.isLoading
                                    ? 'Login....'
                                    : login.loginButtonLabel,
                                style: const TextStyle(
                                  fontFamily: 'Inter_SemiBold',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Row(
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
                      const SizedBox(height: 36),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'New company? ',
                            style: const TextStyle(
                              fontFamily: 'Inter_Regular',
                              color: AppColors.textGrey,
                              fontSize: 14,
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
                                  child: const Text(
                                    'Create an account',
                                    style: TextStyle(
                                      fontFamily: 'Inter_SemiBold',
                                      color: AppColors.appColor,
                                      fontSize: 14,
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEEC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _RoleChip(
            label: 'Admin',
            selected: selected == LoginRole.admin,
            onTap: () => onSelected(LoginRole.admin),
          ),
          _RoleChip(
            label: 'HR',
            selected: selected == LoginRole.hr,
            onTap: () => onSelected(LoginRole.hr),
          ),
          _RoleChip(
            label: 'User',
            selected: selected == LoginRole.user,
            onTap: () => onSelected(LoginRole.user),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.appColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.appColor.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: selected ? 'Inter_SemiBold' : 'Inter_Medium',
              color: selected ? Colors.white : AppColors.textGrey,
              fontSize: 14,
            ),
          ),
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
          style: const TextStyle(
            fontFamily: 'Inter_SemiBold',
            color: AppColors.appColor,
            fontSize: 13,
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
          style: const TextStyle(
            fontFamily: 'Inter_Medium',
            color: AppColors.textDark,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'Inter_Regular',
              color: AppColors.textGrey,
              fontSize: 15,
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
