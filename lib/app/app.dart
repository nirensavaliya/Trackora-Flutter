import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/screens/CRM/Contact/Provider/contact_provider.dart';
import 'package:trackora/screens/CRM/Leads/Provider/LeadesProvider.dart';
import 'package:trackora/screens/CRM/Task/Provider/TaskProvider.dart';
import 'package:trackora/screens/Department/Provider/Department_provider.dart';
import 'package:trackora/screens/Employee/Provider/employee_provider.dart';
import 'package:trackora/screens/Report/Provider/Report_Provider.dart';
import 'package:trackora/screens/Setting/Provider/Setting_Provider.dart';
import 'package:trackora/screens/attendance/Provider/attendance_provider.dart';
import 'package:trackora/screens/splash/providers/splash_provider.dart';
import 'package:trackora/screens/splash/splash_screen.dart';

import '../screens/home/providers/home_provider.dart';
import '../screens/leave/providers/leave_provider.dart';
import '../screens/leave/providers/leave_types_provider.dart';

class TrackoraApp extends StatelessWidget {
  const TrackoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // App / session
        ChangeNotifierProvider(create: (_) => SplashProvider()..init()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),

        // Core modules — create only; load data in screen/drawer (after login)
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => LeaveTypesProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),

        // HR / CRM modules
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => DepartmentProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
      ],
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
        ),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Trackora',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appColor),
            scaffoldBackgroundColor: AppColors.scaffoldBg,
            fontFamily: 'Inter_Regular',
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();