import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/screens/attendance/attendance_screen.dart';
import 'package:trackora/screens/thoughts/daily_thoughts_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Map<String, dynamic> _loginData() {
    final raw = GetStorageData.readString(GetStorageData.loginData);
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    if (raw is Map<String, dynamic>) return raw;
    return {};
  }

  Future<void> _logout(BuildContext context) async {
    await GetStorageData.removeData(GetStorageData.token);
    await GetStorageData.removeData(GetStorageData.loginData);
    await GetStorageData.removeData(GetStorageData.userId);
    await GetStorageData.removeData(GetStorageData.companyCode);
    await GetStorageData.removeData(GetStorageData.userType);
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.loginScreen,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _loginData();
    final user = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : <String, dynamic>{};
    final tenant = data['tenant'] is Map
        ? Map<String, dynamic>.from(data['tenant'] as Map)
        : <String, dynamic>{};
    final name = user['name']?.toString() ?? 'User';
    final email = user['email']?.toString() ?? '';
    final company = tenant['name']?.toString() ?? '';

    return Drawer(
      backgroundColor: AppColors.scaffoldBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.appColor,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontFamily: 'Inter_Bold',
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Inter_SemiBold',
                            color: AppColors.textDark,
                            fontSize: 16,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: const TextStyle(
                              fontFamily: 'Inter_Regular',
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        if (company.isNotEmpty)
                          Text(
                            company,
                            style: const TextStyle(
                              fontFamily: 'Inter_Medium',
                              color: AppColors.appColor,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFD7DEDC)),
            _DrawerTile(
              icon: Icons.format_quote_rounded,
              title: 'Daily Thoughts',
              subtitle: 'Quotes to start your day',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyThoughtsScreen(),
                  ),
                );
              },
            ),
            _DrawerTile(
              icon: Icons.access_time_rounded,
              title: 'Attendance',
              subtitle: 'Punch in, punch out and timeline',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Inter_SemiBold',
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.appColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.appColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter_SemiBold',
          color: AppColors.textDark,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter_Regular',
          color: AppColors.textGrey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
    );
  }
}