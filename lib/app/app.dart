import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/app_colors.dart';
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
        ChangeNotifierProvider(create: (_) => SplashProvider()..init()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => LeaveTypesProvider()),

        // baad mein: AuthProvider, CustomerProvider, ...
      ],
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: MaterialApp(
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