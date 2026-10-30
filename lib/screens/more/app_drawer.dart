import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/core/widgets/app_dialog.dart';
import 'package:trackora/screens/CRM/Contact/Provider/contact_provider.dart';
import 'package:trackora/screens/CRM/Contact/contact_view.dart';
import 'package:trackora/screens/CRM/Leads/Leades_View.dart';
import 'package:trackora/screens/CRM/Task/Provider/TaskProvider.dart';
import 'package:trackora/screens/CRM/Task/Task_View.dart';
import 'package:trackora/screens/Department/Provider/Department_provider.dart';
import 'package:trackora/screens/Department/Department_view.dart';
import 'package:trackora/screens/Employee/Provider/employee_provider.dart';
import 'package:trackora/screens/Employee/Employee_view.dart';
import 'package:trackora/screens/leave/leave_screen.dart';
import 'package:trackora/screens/Setting/Provider/Setting_Provider.dart';
import 'package:trackora/screens/Setting/SettingView.dart';
import 'package:trackora/screens/thoughts/daily_thoughts_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onChildScreenClosed;

  const AppDrawer({
    super.key,
    this.onChildScreenClosed,
  });

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
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Log out?',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log out',
      confirmColor: const Color(0xFFD32F2F),
    );

    if (confirmed != true) return;

    await GetStorageData.removeData(GetStorageData.token);
    await GetStorageData.removeData(GetStorageData.loginData);
    await GetStorageData.removeData(GetStorageData.userId);
    await GetStorageData.removeData(GetStorageData.companyCode);
    await GetStorageData.removeData(GetStorageData.userType);
    if (!context.mounted) return;
    Fluttertoast.showToast(
      msg: 'Logged out successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.appColor,
      textColor: Colors.white,
    );
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
    final userRole = user['role']?.toString().toUpperCase() ?? '';

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
            Divider(color: Color(0xFFD7DEDC)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                        ).then((_) {
                          onChildScreenClosed?.call();
                        });
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.calendar_month_sharp,
                      title: 'Leave',
                      subtitle: 'Apply and manage leave requests',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LeaveScreen(showBack: true,);
                            },
                          ),
                        ).then((_) {
                          onChildScreenClosed?.call();
                        });
                      },
                    ),


                    if (userRole != 'USER')
                      _DrawerTile(
                        icon: Icons.person,
                        title: 'Employee',
                        subtitle: 'Manage employees and employee details',
                        onTap: () {
                          Navigator.pop(context);
                          context.read<EmployeeProvider>().initializeEmployee();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmployeeView(),
                            ),
                          ).then((_) {
                            onChildScreenClosed?.call();
                          });
                        },
                      ),
                    if (userRole != 'USER')
                      _DrawerTile(
                        icon: Icons.business_rounded,
                        title: 'Department',
                        subtitle: 'Organize teams and departments',
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<DepartmentProvider>()
                              .initializeDepartment();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DepartmentView(),
                            ),
                          ).then((_) {
                            onChildScreenClosed?.call();
                          });
                        },
                      ),
                    _DrawerTile(
                      icon: Icons.person_search_rounded,
                      title: 'Lead',
                      subtitle: 'Track leads and follow-ups',
                      onTap: () {

                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeadView(),
                          ),
                        ).then((_) {
                          onChildScreenClosed?.call();
                        });
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.task_alt_rounded,
                      title: 'Task',
                      subtitle: 'Manage tasks and follow-ups',
                      onTap: () {
                        Navigator.pop(context);
                        final tasks = context.read<TaskProvider>();
                        tasks.getTaskSummary();
                        tasks.getPeople();
                        tasks.getLeads();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaskView(),
                          ),
                        ).then((_) {
                          onChildScreenClosed?.call();
                        });
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.contacts_rounded,
                      title: 'Contact',
                      subtitle: 'Manage contacts and customers',
                      onTap: () {
                        Navigator.pop(context);
                        context.read<ContactProvider>().getContact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactView(),
                          ),
                        ).then((_) {
                          onChildScreenClosed?.call();
                        });
                      },
                    ),
                    if (userRole != 'USER' && userRole != 'HR')
                      _DrawerTile(
                        icon: Icons.settings,
                        title: 'Setting',
                        subtitle: 'Account and tenant settings',
                        onTap: () {
                          Navigator.pop(context);
                          context.read<SettingProvider>().getMeApi();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingView(),
                            ),
                          ).then((_) {
                            onChildScreenClosed?.call();
                          });
                        },
                      ),

                  ],
                ),
              ),
            ),
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
                    'Log out',
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
