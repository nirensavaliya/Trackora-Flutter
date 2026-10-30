import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/screens/Report/Report_View.dart';
import 'package:trackora/screens/attendance/attendance_screen.dart';

import '../../core/constants/app_images.dart';
import '../home/home_screen.dart';
import '../home/providers/home_provider.dart';
import '../more/app_drawer.dart';
import '../tasks/tasks_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  static final scaffoldKey = GlobalKey<ScaffoldState>();

  static void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int index = 0;

  final pages = [
    const HomeScreen(),
    const AttendanceScreen(),
    const ReportView(),
    const TasksScreen(),
  ];

  void _onTabTap(int i) {
    if (i == 3) {
      BottomBarScreen.openDrawer();
      return;
    }
    setState(() => index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: BottomBarScreen.scaffoldKey,
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: const _HomeHeader(),
      // drawer: const AppDrawer(),
      drawer: AppDrawer(
        onChildScreenClosed: () {
          setState(() {
            index = 0;
          });
        },
      ),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF143F3B), Color(0xFF1E8F84)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x331B6B63),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                _DockItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  selected: index == 0,
                  onTap: () => _onTabTap(0),
                ),
                _DockItem(
                  label: 'Attendance',
                  icon: Icons.people_outline,
                  activeIcon: Icons.people_rounded,
                  selected: index == 1,
                  onTap: () => _onTabTap(1),
                ),
                _DockItem(
                  label: 'Report',
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment_rounded,
                  selected: index == 2,
                  onTap: () => _onTabTap(2),
                ),
                _DockItem(
                  label: 'More',
                  icon: Icons.menu,
                  activeIcon: Icons.menu_rounded,
                  selected: false,
                  onTap: () => _onTabTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1B6B63) : Colors.white;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 12 : 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selected ? activeIcon : icon, size: 22, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: selected ? 'Inter_SemiBold' : 'Inter_Regular',
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _HomeStyle {
  static const pageBg = Color(0xFFF7F9F9);
  static const border = Color(0xFFE8EEED);
  static const title = Color(0xFF1F2A30);
  static const muted = Color(0xFF6B7280);
  static const subtle = Color(0xFF9CA3AF);
  static const mint = Color(0xFFE8F3F1);
  static const success = Color(0xFF16A37F);
  static const orange = Color(0xFFF28C38);
  static const orangeBg = Color(0xFFFFF3E8);
  static const red = Color(0xFFEF4462);

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF1B6B63).withValues(alpha: 0.05),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static TextStyle text(
      double size, {
        FontWeight weight = FontWeight.w500,
        Color color = title,
        double? letterSpacing,
      }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}


class _HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const _HomeHeader();

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      shape: const Border(bottom: BorderSide(color: _HomeStyle.border)),
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7DB9B1), Color(0xFF4F9A91)],
              ),
            ),
            child: Image.asset(AppImages.splashLogo, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Trackora',
                      style: _HomeStyle.text(18, weight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _HomeStyle.mint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCFE5E1)),
                      ),
                      child: Text(
                        'HRMS',
                        style: _HomeStyle.text(
                          9,
                          weight: FontWeight.w800,
                          color: AppColors.appColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Workforce Overview',
                  style: _HomeStyle.text(12, color: _HomeStyle.subtle),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: _HomeStyle.muted,
                size: 24,
              ),
              if (home.notificationCount > 0)
                Positioned(
                  right: 0,
                  top: -1,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16C79A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: BottomBarScreen.openDrawer,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _HomeStyle.mint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCFE5E1)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B6B63).withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF1F4F4A),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

