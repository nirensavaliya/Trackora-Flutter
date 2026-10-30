import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackora/screens/CRM/Contact/Provider/contact_provider.dart';
import 'package:trackora/screens/CRM/Contact/contact_view.dart';
import 'package:trackora/screens/CRM/Leads/Leades_View.dart';
import 'package:trackora/screens/CRM/Task/Provider/TaskProvider.dart';
import 'package:trackora/screens/CRM/Task/Task_View.dart';
import 'package:trackora/screens/Department/Department_view.dart';
import 'package:trackora/screens/Department/Provider/Department_provider.dart';
import 'package:trackora/screens/Employee/Employee_view.dart';
import 'package:trackora/screens/Employee/Provider/employee_provider.dart';
import 'package:trackora/screens/OnBoarding/OnBoardingView.dart';
import 'package:trackora/screens/Setting/Provider/Setting_Provider.dart';
import 'package:trackora/screens/Setting/SettingView.dart';
import 'package:trackora/screens/attendance/attendance_screen.dart';
import 'package:trackora/screens/bottom-bar/bottm_bar_screen.dart';
import 'package:trackora/screens/face-verify/providers/face_verify_provider.dart';
import 'package:trackora/screens/leave/leave_screen.dart';
import 'package:trackora/screens/Report/Report_View.dart';

import '../screens/auth/login/login_screen.dart';
import '../screens/auth/providers/login_provider.dart';
import '../screens/auth/providers/sign_up_provider.dart';
import '../screens/auth/signup/sign_up_screen.dart';
import '../screens/face-verify/face_verify_screen.dart';
import '../screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splashScreen = "/";
  static const String homeScreen = "/HomeScreen";
  static const String loginScreen = "/LoginScreen";
  static const String signUpScreen = "/SignUpScreen";
  static const String faceVerify = '/faceVerify';
  static const String onboarding = "/OnBoardingView";
  static const String attendance = "/AttendanceScreen";
  static const String leave = '/LeaveScreen';
  static const String report = '/ReportView';
  static const String employee = '/EmployeeView';
  static const String departmentView = '/DepartmentView';
  static const String leads = '/LeadView';
  static const String task = '/TaskView';
  static const String contact = '/Contact';
  static const String setting = '/SettingView';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case homeScreen:
        // HomeProvider already in MultiProvider (app.dart)
        return MaterialPageRoute(builder: (_) => const BottomBarScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnBoardingView());

      case loginScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => LoginProvider(),
            child: const LoginScreen(),
          ),
        );

      case signUpScreen:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => SignUpProvider(),
            child: const SignUpScreen(),
          ),
        );

      case attendance:
        // AttendanceProvider already global; screen loads in initState
        return MaterialPageRoute(builder: (_) => const AttendanceScreen());

      case faceVerify:
        // Screen-scoped provider (not in app MultiProvider)
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (_) => FaceVerifyProvider(),
            child: const FaceVerifyScreen(),
          ),
        );

      case leave:
        // LeaveProvider already global; LeaveScreen.initState → loadRequests
        return MaterialPageRoute(builder: (_) => const LeaveScreen());

      case report:
        // ReportProvider already global; ReportView.initState → initialize
        return MaterialPageRoute(builder: (_) => const ReportView());

      case employee:
        return MaterialPageRoute(
          builder: (context) {
            context.read<EmployeeProvider>().initializeEmployee();
            return const EmployeeView();
          },
        );

      case departmentView:
        return MaterialPageRoute(
          builder: (context) {
            context.read<DepartmentProvider>().initializeDepartment();
            return const DepartmentView();
          },
        );

      case leads:
        // LeadView.initState loads data (same pattern as Attendance)
        return MaterialPageRoute(builder: (_) => const LeadView());

      case task:
        return MaterialPageRoute(
          builder: (context) {
            final tasks = context.read<TaskProvider>();
            tasks.getTaskSummary();
            tasks.getPeople();
            tasks.getLeads();
            return const TaskView();
          },
        );

      case contact:
        return MaterialPageRoute(
          builder: (context) {
            context.read<ContactProvider>().getContact();
            return const ContactView();
          },
        );

      case setting:
        return MaterialPageRoute(
          builder: (context) {
            context.read<SettingProvider>().getMeApi();
            return const SettingView();
          },
        );

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
