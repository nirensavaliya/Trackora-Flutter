import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/screens/bottom-bar/bottm_bar_screen.dart';
import 'package:trackora/screens/home/providers/home_provider.dart';

import '../../app/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: _HomeHeader(),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: const [
              _PunchInCard(),
              SizedBox(height: 24),
              _OverviewHeader(),
              SizedBox(height: 12),
              _OverviewRow(),
              SizedBox(height: 16),
              _TargetCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const _HomeHeader();

  @override
  Size get preferredSize => const Size.fromHeight(130);

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return AppBar(
      backgroundColor: AppColors.scaffoldBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: BottomBarScreen.openDrawer,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.menu, color: AppColors.textDark, size: 26),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textDark,
                          size: 26,
                        ),
                      ),
                      if (home.notificationCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.appColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${home.notificationCount}',
                              style: const TextStyle(
                                fontFamily: 'Inter_Bold',
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    home.greeting,
                    style: const TextStyle(
                      fontFamily: 'Inter_Regular',
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${home.userName} ',
                    style: const TextStyle(
                      fontFamily: 'Inter_Bold',
                      color: AppColors.textDark,
                      fontSize: 20,
                      height: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                home.todayDate,
                style: const TextStyle(
                  fontFamily: 'Inter_Regular',
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _PunchInCard extends StatelessWidget {
  const _PunchInCard();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    if (home.isPunchedIn) {
      return const _PunchedInCard();
    }
    return const _NotPunchedInCard();
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: Color(0xFF7DFFB3), size: 10),
              SizedBox(width: 8),
              Text(
                'PUNCHED IN',
                style: TextStyle(
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
            home.currentClock,
            style: const TextStyle(
              fontFamily: 'Inter_Bold',
              color: Colors.white,
              fontSize: 40,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Working ${home.workingDuration}',
            style: const TextStyle(
              fontFamily: 'Inter_Regular',
              color: Colors.white,
              fontSize: 14,
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
              label: const Text(
                'PUNCH OUT',
                style: TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  fontSize: 14,
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
                const Text(
                  'Not Punched In',
                  style: TextStyle(
                    fontFamily: 'Inter_Bold',
                    color: AppColors.textDark,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please punch in to start your day',
                  style: TextStyle(
                    fontFamily: 'Inter_Regular',
                    color: AppColors.textGrey,
                    fontSize: 13,
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
                    label: const Text(
                      'PUNCH IN',
                      style: TextStyle(
                        fontFamily: 'Inter_SemiBold',
                        fontSize: 14,
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

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Today's Overview",
          style: TextStyle(
            fontFamily: 'Inter_SemiBold',
            color: AppColors.textDark,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'View all',
            style: TextStyle(
              fontFamily: 'Inter_Medium',
              color: AppColors.appColor,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.assignment_outlined,
            value: '${home.taskCount}',
            label: 'Tasks',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.location_on_outlined,
            value: '${home.visitCount}',
            label: 'Visits',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.appColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter_Bold',
                  color: AppColors.textDark,
                  fontSize: 20,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter_Regular',
                  color: AppColors.textGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard();

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final percent = (home.targetPercent * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Today's Target",
                style: TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  color: AppColors.textDark,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  color: AppColors.textDark,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: home.targetPercent,
              minHeight: 8,
              backgroundColor: AppColors.progressTrack,
              color: AppColors.appColor,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${home.targetDone} / ${home.targetTotal}',
              style: const TextStyle(
                fontFamily: 'Inter_Regular',
                color: AppColors.textGrey,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}