import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/constants/app_images.dart';
import 'package:trackora/data/models/leave_model.dart';
import 'package:trackora/screens/bottom-bar/bottm_bar_screen.dart';
import 'package:trackora/screens/home/providers/home_provider.dart';

import '../../app/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 HomeScreen BUILD');
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _HomeStyle.pageBg,
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: AppColors.appColor,
            onRefresh: () => context.read<HomeProvider>().refreshSession(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
              children: const [
                _PunchInCard(),
                _SummaryGrid(),
                SizedBox(height: 12),
                _TasksStrip(),
                SizedBox(height: 12),
                _LeaveBalancesSection(),
                SizedBox(height: 12),
                _RecentLeaveSection(),
              ],
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

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 SummaryGrid BUILD');

    // final home = context.watch<HomeProvider>();
    final summary = context.select<
        HomeProvider,
        ({
        int pendingLeaveCount,
        String attendanceStatusLabel,
        bool isAdmin,
        int peopleCount,
        int leaveLeftTotal,
        })
    >(
          (home) => (
      pendingLeaveCount: home.pendingLeaveCount,
      attendanceStatusLabel: home.attendanceStatusLabel,
      isAdmin: home.isAdmin,
      peopleCount: home.peopleCount,
      leaveLeftTotal: home.leaveLeftTotal,
      ),
    );
    final pending = summary.pendingLeaveCount;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Today',
                  value: summary.attendanceStatusLabel,
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.appColor,
                  iconBg: _HomeStyle.mint,
                  footer: const _DotFooter(
                    text: 'Live sync active',
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Pending leave',
                  value: '$pending',
                  icon: Icons.pending_actions_rounded,
                  iconColor: _HomeStyle.orange,
                  iconBg: _HomeStyle.orangeBg,
                  footer: pending == 0
                      ? Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 13,
                              color: _HomeStyle.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'All cleared',
                              style: _HomeStyle.text(
                                11,
                                weight: FontWeight.w600,
                                color: _HomeStyle.success,
                              ),
                            ),
                          ],
                        )
                      : _DotFooter(
                          text: '$pending awaiting review',
                          color: _HomeStyle.orange,
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: _NetPayCard()),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: summary.isAdmin ? 'People' : 'Leave left',
                  value: summary.isAdmin
                      ? '${summary.peopleCount}'
                      : '${summary.leaveLeftTotal}',
                  icon: summary.isAdmin
                      ? Icons.groups_rounded
                      : Icons.event_available_rounded,
                  iconColor: AppColors.appColor,
                  iconBg: _HomeStyle.mint,
                  footer: _DotFooter(
                    text: summary.isAdmin ? 'Active headcount' : 'Days available',
                    color: const Color(0xFF16C79A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.footer,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: _HomeStyle.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _HomeStyle.text(
                    13,
                    weight: FontWeight.w600,
                    color: _HomeStyle.muted,
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: _HomeStyle.text(20, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          footer,
        ],
      ),
    );
  }
}

class _DotFooter extends StatelessWidget {
  const _DotFooter({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _HomeStyle.text(11, color: _HomeStyle.subtle),
          ),
        ),
      ],
    );
  }
}

class _NetPayCard extends StatelessWidget {
  const _NetPayCard();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F9187), Color(0xFF2F7A72)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B6B63).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -40,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Net pay',
                        style: _HomeStyle.text(
                          13,
                          weight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    home.netPayText,
                    style: _HomeStyle.text(
                      22,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'MONTHLY',
                        style: _HomeStyle.text(
                          8,
                          weight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Disbursal batch',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _HomeStyle.text(
                          11,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TasksStrip extends StatelessWidget {
  const _TasksStrip();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: _HomeStyle.card(),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _TaskStat(
              label: 'Today tasks',
              value: '${home.todayCount}',
              color: _HomeStyle.title,
            ),
            const VerticalDivider(width: 1, color: _HomeStyle.border),
            _TaskStat(
              label: 'Past unsolved',
              value: '${home.unsolvedCount}',
              color: _HomeStyle.orange,
            ),
            const VerticalDivider(width: 1, color: _HomeStyle.border),
            _TaskStat(
              label: 'Overdue',
              value: '${home.overdueCount}',
              color: _HomeStyle.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskStat extends StatelessWidget {
  const _TaskStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _HomeStyle.text(
              12,
              weight: FontWeight.w600,
              color: _HomeStyle.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: _HomeStyle.text(17, weight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _PunchInCard extends StatelessWidget {
  const _PunchInCard();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    if (!home.showPunchCard) {
      return const SizedBox.shrink();
    }
    final Widget card;
    if (home.isPunchedIn) {
      card = const _PunchedInCard();
    } else if (home.isPunchedOut) {
      card = const _PunchedOutCard();
    } else {
      card = const _NotPunchedInCard();
    }
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: card);
  }
}

class _PunchedInCard extends StatelessWidget {
  const _PunchedInCard();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

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
              Icon(Icons.circle, color: Color(0xFF7DFFB3), size: 10),
              SizedBox(width: 8),
              Text(
                'PUNCHED IN',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,

                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            home.punchInClock,
            style: GoogleFonts.manrope(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Working ${home.workingDuration}',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
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
              icon: const Icon(Icons.timer_outlined, size: 20),
              label:  Text(
                'PUNCH OUT',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PunchedOutCard extends StatelessWidget {
  const _PunchedOutCard();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

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
              Icon(Icons.circle, color: Color(0xFF7DFFB3), size: 10),
              SizedBox(width: 8),
              Text(
                'PUNCHED OUT',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            home.punchOutClock,
            style: GoogleFonts.manrope(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Worked ${home.workingDuration}',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,

            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            ),
            child:  Text(
              'DAY CLOSED',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotPunchedInCard extends StatelessWidget {
  const _NotPunchedInCard();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              home.bannerImage,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                 Text(
                  'Not Punched In',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                 Text(
                  'Please punch in to start your day',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.faceVerify);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.fingerprint, size: 22),
                    label:  Text(
                      'PUNCH IN',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
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

class _LeaveBalancesSection extends StatelessWidget {
  const _LeaveBalancesSection();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final items = home.leaveBalances;

    final year = items.isNotEmpty ? items.first.year : null;

    return _SectionCard(
      title: 'Leave balances',
      trailing: year == null
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _HomeStyle.mint,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCFE5E1)),
              ),
              child: Text(
                'Cycle $year-${(year + 1) % 100}',
                style: _HomeStyle.text(
                  10,
                  weight: FontWeight.w700,
                  color: AppColors.appColor,
                ),
              ),
            ),
      emptyText: 'No leave balance data',
      children: items.take(5).map((b) {
        final code = b.leaveType?.code ?? b.leaveType?.name ?? 'Leave';
        final employeeName =
            b.employee?.user?.name ?? b.employee?.employeeCode ?? '';
        final remaining = b.remainingDays < 0 ? 0 : b.remainingDays;
        final hasBalance = remaining > 0;

        return _ItemTile(
          leading: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: hasBalance
                  ? const Color(0xFF16C79A)
                  : const Color(0xFFD1D5DB),
              shape: BoxShape.circle,
            ),
          ),
          title: employeeName.isEmpty ? code : '$code · $employeeName',
          subtitle: Text(
            b.leaveType?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _HomeStyle.text(11, color: _HomeStyle.subtle),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: hasBalance ? _HomeStyle.mint : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: hasBalance
                        ? const Color(0xFFCFE5E1)
                        : _HomeStyle.border,
                  ),
                ),
                child: Text(
                  '$remaining left',
                  style: _HomeStyle.text(
                    10,
                    weight: FontWeight.w700,
                    color: hasBalance ? AppColors.appColor : _HomeStyle.muted,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 40,
                child: Text(
                  '${b.used ?? 0} used',
                  textAlign: TextAlign.right,
                  style: _HomeStyle.text(10, color: _HomeStyle.subtle),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.emptyText,
    required this.children,
    this.trailing,
  });

  final String title;
  final String emptyText;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: _HomeStyle.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: _HomeStyle.text(14, weight: FontWeight.w700),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                emptyText,
                style: _HomeStyle.text(12, color: _HomeStyle.subtle),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.leading,
  });

  final Widget? leading;
  final String title;
  final Widget subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: _HomeStyle.pageBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _HomeStyle.text(12.5, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                subtitle,
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _RecentLeaveSection extends StatelessWidget {
  const _RecentLeaveSection();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final items = home.recentLeaves;

    return _SectionCard(
      title: 'Recent leave',
      trailing: items.isEmpty
          ? null
          : Text(
              '${items.length} ${items.length == 1 ? 'request' : 'requests'}',
              style: _HomeStyle.text(11, color: _HomeStyle.subtle),
            ),
      emptyText: 'No leave requests yet',
      children: items.take(5).map((leave) {
        final who =
            leave.employeeName.isNotEmpty ? leave.employeeName : leave.typeName;
        return _ItemTile(
          title: who,
          subtitle: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: _HomeStyle.subtle,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${LeaveModel.apiDate(leave.startDate)} → '
                  '${LeaveModel.apiDate(leave.endDate)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _HomeStyle.text(11, color: _HomeStyle.subtle),
                ),
              ),
            ],
          ),
          trailing: _LeaveStatusPill(status: leave.status),
        );
      }).toList(),
    );
  }
}

class _LeaveStatusPill extends StatelessWidget {
  const _LeaveStatusPill({required this.status});

  final LeaveRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      LeaveRequestStatus.approved => (
          'APPROVED',
          const Color(0xFF16A37F),
          const Color(0xFFE7F7F1),
        ),
      LeaveRequestStatus.rejected => (
          'REJECTED',
          const Color(0xFFE5484D),
          const Color(0xFFFDECEC),
        ),
      LeaveRequestStatus.cancelled => (
          'CANCELLED',
          const Color(0xFFF08A24),
          const Color(0xFFFFF3E6),
        ),
      LeaveRequestStatus.pending => (
          'PENDING',
          const Color(0xFF3B82F6),
          const Color(0xFFEAF2FE),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: _HomeStyle.text(
              9,
              weight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}