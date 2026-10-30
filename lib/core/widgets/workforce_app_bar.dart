import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackora/core/constants/app_colors.dart';

class WorkforceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WorkforceAppBar({
    super.key,
    required this.title,
    required this.onTap,
    this.actionLabel = '',
    this.showAction = true,
    this.decorated = true,
  });

  final String title;
  final VoidCallback? onTap;
  final String actionLabel;
  final bool showAction;
  final bool decorated;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      // backgroundColor: decorated ? Colors.transparent : const Color(0xFFF8FAFC),
      surfaceTintColor: Colors.transparent,
      elevation: decorated ? 0 : 5,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 0,
      flexibleSpace: decorated ? const _MintAppBarBackground() : null,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      iconTheme: const IconThemeData(color: Color(0xff0F172A)),
      leading: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back_ios_new_outlined),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xff0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Trackora Workforce',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.appColor,
            ),
          ),
        ],
      ),
      actions: showAction
       ? [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(decorated ? 18 : 8),
              color: onTap == null
                  ? AppColors.appColor.withValues(alpha: 0.5)
                  : const Color(0xff38847C),
              boxShadow: decorated
                  ? const [
                      BoxShadow(
                        color: Color(0x401B6B63),
                        offset: Offset(0, 6),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  actionLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
      ]: null
    );
  }
}

class _MintAppBarBackground extends StatelessWidget {
  const _MintAppBarBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE7F6F2), Color(0xFFD5EFEA)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x241B6B63),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -18,
            right: -24,
            child: _AppBarCurve(),
          ),
        ],
      ),
    );
  }
}

class _AppBarCurve extends StatelessWidget {
  const _AppBarCurve();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.45,
      child: Container(
        width: 120,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF92BCB7).withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(70),
        ),
      ),
    );
  }
}
