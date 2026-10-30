import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/constants/app_images.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/data/models/attendance_model.dart';
import 'package:trackora/data/models/employee_model.dart';
import 'package:trackora/screens/attendance/Provider/attendance_provider.dart';
import 'package:trackora/screens/home/providers/home_provider.dart';

import '../bottom-bar/bottm_bar_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedEmployeeId = 'ALL';

  String _yearFrom() {
    final now = DateTime.now();
    return '${now.year}-01-01';
  }

  String _yearTo() {
    final now = DateTime.now();
    return '${now.year}-12-31';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AttendanceProvider>().initializeAttendance(
            from: _yearFrom(),
            to: _yearTo(),
          );
    });
  }

  String _formatClock(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _todayHeader(DateTime now) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Today, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _refresh() async {
    final attendance = context.read<AttendanceProvider>();
    final home = context.read<HomeProvider>();
    await Future.wait([
      home.loadTodayAttendance(),
      attendance.getAttendance(
        from: _yearFrom(),
        to: _yearTo(),
        employeeId: selectedEmployeeId == 'ALL' ? null : selectedEmployeeId,
      ),
      if (attendance.isManager) attendance.getEmployee(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final attendance = context.watch<AttendanceProvider>();
    final now = DateTime.now();
    final punched = home.isPunchedIn && home.punchedInAt != null;
    final showPunch = home.showPunchCard;
    final list = attendance.attendanceList;
    int countOf(String s) =>
        list.where((a) => a.status.toUpperCase() == s).length;
    final present = countOf('PRESENT');
    final late = countOf('LATE');
    final onLeave = countOf('ON_LEAVE');
    final absent = list.length - present - late - onLeave;

    return Scaffold(
      backgroundColor: _AttStyle.pageBg,
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.appColor,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                Text(
                  'Attendance',
                  style: _AttStyle.text(24, weight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  attendance.isManager
                      ? 'Team in / out. Admins do not punch.'
                      : 'Your in / out history.',
                  style: _AttStyle.text(12, color: _AttStyle.muted),
                ),
                const SizedBox(height: 14),
                if (attendance.isManager) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _EmployeeFilter(
                          selectedEmployeeId: selectedEmployeeId,
                          employees: attendance.employeeResponse?.data ?? [],
                          onChanged: (value) async {
                            setState(() => selectedEmployeeId = value ?? 'ALL');
                            await attendance.getAttendance(
                              from: _yearFrom(),
                              to: _yearTo(),
                              employeeId: selectedEmployeeId == 'ALL'
                                  ? null
                                  : selectedEmployeeId,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const _ViewToggle(),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CountChip(
                        label: 'Total: ${list.length}',
                        color: const Color(0xFF9CA3AF),
                        bg: Colors.white,
                      ),
                      _CountChip(
                        label: '$present Present',
                        color: _AttStyle.green,
                        bg: _AttStyle.greenBg,
                      ),
                      _CountChip(
                        label: '$late Late',
                        color: _AttStyle.orange,
                        bg: _AttStyle.orangeBg,
                      ),
                      _CountChip(
                        label: '$onLeave On leave',
                        color: _AttStyle.blue,
                        bg: _AttStyle.blueBg,
                      ),
                      if (absent > 0)
                        _CountChip(
                          label: '$absent Absent',
                          color: const Color(0xFF6B7280),
                          bg: const Color(0xFFF3F4F6),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (showPunch) ...[
                  Text(
                    _todayHeader(now),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter_Medium',
                      color: AppColors.textDark,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _StatusCard(
                    punched: punched,
                    home: home,
                    formatClock: _formatClock,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "Today's Timeline",
                    style: TextStyle(
                      fontFamily: 'Inter_SemiBold',
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Timeline(
                    punched: punched || home.isPunchedOut,
                    punchInTime: home.punchedInAt != null
                        ? _formatClock(home.punchedInAt!)
                        : '- -',
                    punchOutTime: home.punchedOutAt != null
                        ? _formatClock(home.punchedOutAt!)
                        : '- -',
                    punchedOut: home.isPunchedOut,
                  ),
                  const SizedBox(height: 24),
                ],
                if (attendance.attendanceList.isEmpty && !attendance.isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No attendance found',
                        style: _AttStyle.text(13, color: _AttStyle.muted),
                      ),
                    ),
                  )
                else
                  ...attendance.attendanceList.map(
                    (item) => _AttendanceHistoryCard(
                      attendance: item,
                      showEmployee: attendance.isManager,
                      formatClock: _formatClock,
                    ),
                  ),
              ],
            ),
          ),
          if (attendance.isLoading) const AppLoaderOverlay(),
        ],
      ),
    );
  }
}

class _EmployeeFilter extends StatelessWidget {
  const _EmployeeFilter({
    required this.selectedEmployeeId,
    required this.employees,
    required this.onChanged,
  });

  final String selectedEmployeeId;
  final List<Employee> employees;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items =
        employees.where((e) => (e.id ?? '').isNotEmpty).toList(growable: false);

    return DropdownButtonFormField<String>(
      initialValue: selectedEmployeeId,
      isExpanded: true,
      isDense: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: _AttStyle.muted,
        size: 20,
      ),
      style: _AttStyle.text(13, weight: FontWeight.w600),
      borderRadius: BorderRadius.circular(12),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _AttStyle.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _AttStyle.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.appColor),
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: 'ALL',
          child: Text('All people'),
        ),
        ...items.map((employee) {
          final id = employee.id!;
          final name =
              employee.user?.name ?? employee.employeeCode ?? 'Employee';
          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  const _AttendanceHistoryCard({
    required this.attendance,
    required this.showEmployee,
    required this.formatClock,
  });

  final AttendanceModel attendance;
  final bool showEmployee;
  final String Function(DateTime) formatClock;

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  String get _statusKey => attendance.status.toUpperCase();

  Color get _statusColor {
    switch (_statusKey) {
      case 'PRESENT':
        return _AttStyle.green;
      case 'LATE':
        return _AttStyle.orange;
      case 'ON_LEAVE':
        return _AttStyle.blue;
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  Color get _statusBg {
    switch (_statusKey) {
      case 'PRESENT':
        return _AttStyle.greenBg;
      case 'LATE':
        return _AttStyle.orangeBg;
      case 'ON_LEAVE':
        return _AttStyle.blueBg;
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  String get _sourceLabel {
    final words = attendance.punchSource
        .split(RegExp(r'[_\s]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    return [
      for (var i = 0; i < words.length; i++)
        if (words[i].length <= 3 && i > 0)
          words[i].toUpperCase()
        else if (i == 0)
          '${words[i][0].toUpperCase()}${words[i].substring(1).toLowerCase()}'
        else
          words[i].toLowerCase(),
    ].join(' ');
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = attendance.employee?.user?.name ??
        attendance.employee?.employeeCode ??
        '';
    final role = (attendance.employee?.user?.role ?? '').toUpperCase();
    final showPerson = showEmployee && name.isNotEmpty;
    final isStaffRole = role == 'HR' || role == 'ADMIN';
    final date = _formatDate(attendance.date ?? attendance.checkInAt);
    final source = _sourceLabel;
    final isWeb = attendance.punchSource.toUpperCase().contains('WEB');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _AttStyle.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B6B63).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: _statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isStaffRole
                                ? _AttStyle.mint
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isStaffRole
                                  ? const Color(0xFFCFE5E1)
                                  : _AttStyle.border,
                            ),
                          ),
                          child: showPerson
                              ? Text(
                                  _initials(name),
                                  style: _AttStyle.text(
                                    12,
                                    weight: FontWeight.w700,
                                    color: isStaffRole
                                        ? AppColors.appColor
                                        : const Color(0xFF4B5563),
                                  ),
                                )
                              : const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Color(0xFF4B5563),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      showPerson ? name : date,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _AttStyle.text(
                                        14,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (showPerson && role.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isStaffRole
                                            ? _AttStyle.mint
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        role,
                                        style: _AttStyle.text(
                                          8,
                                          weight: FontWeight.w800,
                                          color: isStaffRole
                                              ? AppColors.appColor
                                              : _AttStyle.muted,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (showPerson) ...[
                                const SizedBox(height: 2),
                                Text(
                                  date,
                                  style: _AttStyle.text(
                                    11,
                                    color: _AttStyle.subtle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            attendance.status.isEmpty
                                ? '—'
                                : attendance.status.toUpperCase(),
                            style: _AttStyle.text(
                              9,
                              weight: FontWeight.w800,
                              color: _statusColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: _AttStyle.border),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _TimeCell(
                          label: 'IN',
                          value: attendance.checkInAt != null
                              ? formatClock(attendance.checkInAt!)
                              : '—',
                          color: _statusKey == 'LATE'
                              ? _AttStyle.orange
                              : _AttStyle.title,
                        ),
                        const SizedBox(width: 18),
                        _TimeCell(
                          label: 'OUT',
                          value: attendance.checkOutAt != null
                              ? formatClock(attendance.checkOutAt!)
                              : '—',
                          color: _AttStyle.title,
                        ),
                        const Spacer(),
                        if (source.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _AttStyle.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isWeb
                                      ? Icons.location_on_outlined
                                      : Icons.face_retouching_natural_outlined,
                                  size: 11,
                                  color: AppColors.appColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  source,
                                  style: _AttStyle.text(
                                    10,
                                    color: _AttStyle.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  const _TimeCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _AttStyle.text(
            9,
            weight: FontWeight.w600,
            color: _AttStyle.subtle,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: _AttStyle.text(12, weight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

class _AttStyle {
  static const pageBg = Color(0xFFF7F9F9);
  static const border = Color(0xFFE8EEED);
  static const title = Color(0xFF1F2A30);
  static const muted = Color(0xFF6B7280);
  static const subtle = Color(0xFF9CA3AF);
  static const mint = Color(0xFFE8F3F1);
  static const green = Color(0xFF16A37F);
  static const greenBg = Color(0xFFE7F7F1);
  static const orange = Color(0xFFF08A24);
  static const orangeBg = Color(0xFFFFF3E6);
  static const blue = Color(0xFF3B82F6);
  static const blueBg = Color(0xFFEAF2FE);

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

class _AttendanceHeader extends StatelessWidget implements PreferredSizeWidget {
  const _AttendanceHeader();

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return AppBar(
      backgroundColor: Color(0xF6FAFAF2),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      shape: const Border(bottom: BorderSide(color: _AttStyle.border)),
      titleSpacing: 16,
      title: GestureDetector(
        onTap: BottomBarScreen.openDrawer,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.appColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withOpacity(0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Image.asset(AppImages.threeDAppLogo, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Text(
              'TRACKORA HRMS',
              style: _AttStyle.text(
                12,
                weight: FontWeight.w800,
                color: const Color(0xff64748B),
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
      actions: [
        _HeaderCircleButton(
          onTap: () {},
          child: const Icon(
            Icons.search_rounded,
            size: 18,
            color: _AttStyle.title,
          ),
        ),
        const SizedBox(width: 8),
        _HeaderCircleButton(
          onTap: () {},
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 18,
                color: _AttStyle.title,
              ),
              if (home.notificationCount > 0)
                Positioned(
                  right: -1,
                  top: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16C79A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _HeaderCircleButton(
          onTap: BottomBarScreen.openDrawer,
          child: const Icon(
            Icons.menu_rounded,
            size: 18,
            color: _AttStyle.title,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _AttStyle.border),
        ),
        child: child,
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _AttStyle.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _AttStyle.mint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.view_agenda_outlined,
              size: 16,
              color: AppColors.appColor,
            ),
          ),
          const SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: _AttStyle.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: _AttStyle.text(
              13,
              weight: FontWeight.w700,
              color: color == const Color(0xFF9CA3AF) ? _AttStyle.title : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.punched,
    required this.home,
    required this.formatClock,
  });

  final bool punched;
  final HomeProvider home;
  final String Function(DateTime) formatClock;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.appColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: punched || home.isPunchedOut
                    ? const Color(0xFF7DFFB3)
                    : Colors.white54,
                size: 10,
              ),
              const SizedBox(width: 8),
              Text(
                punched
                    ? 'PUNCHED IN'
                    : home.isPunchedOut
                        ? 'PUNCHED OUT'
                        : 'NOT PUNCHED IN',
                style: const TextStyle(
                  fontFamily: 'Inter_Bold',
                  color: Colors.white,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            punched
                ? formatClock(home.punchedInAt!)
                : home.isPunchedOut && home.punchedOutAt != null
                    ? formatClock(home.punchedOutAt!)
                    : '--:--',
            style: const TextStyle(
              fontFamily: 'Inter_Bold',
              color: Colors.white,
              fontSize: 40,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            punched
                ? 'Working ${home.workingDuration}'
                : home.isPunchedOut
                    ? 'Worked ${home.workingDuration}'
                    : 'Start your day',
            style: const TextStyle(
              fontFamily: 'Inter_Regular',
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          if (home.isPunchedOut) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
              ),
              child: const Text(
                'DAY CLOSED',
                style: TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  color: Colors.white,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
          if (!home.isPunchedOut) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.faceVerify);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.appColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: Icon(
                  punched ? Icons.timer_outlined : Icons.fingerprint,
                  size: 20,
                ),
                label: Text(
                  punched ? 'PUNCH OUT' : 'PUNCH IN',
                  style: const TextStyle(
                    fontFamily: 'Inter_SemiBold',
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.punched,
    required this.punchInTime,
    required this.punchOutTime,
    required this.punchedOut,
  });

  final bool punched;
  final String punchInTime;
  final String punchOutTime;
  final bool punchedOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineRow(
          time: punchInTime,
          label: 'Punched In',
          done: punched,
          isLast: false,
        ),
        _TimelineRow(
          time: punchOutTime,
          label: 'Punched Out',
          done: punchedOut,
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.label,
    required this.done,
    required this.isLast,
  });

  final String time;
  final String label;
  final bool done;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: done ? AppColors.appColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done ? AppColors.appColor : const Color(0xFFC5CDCB),
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: const Color(0xFFD7DEDC),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'Inter_SemiBold',
                      color: done ? AppColors.textDark : AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter_Regular',
                    color: done ? AppColors.textDark : AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
