import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackora/screens/bottom-bar/bottm_bar_screen.dart';
import 'package:trackora/screens/face-verify/providers/face_verify_provider.dart';

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
  static const faceVerify = '/faceVerify';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case homeScreen:
        return MaterialPageRoute(builder: (_) => const BottomBarScreen());
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
      case faceVerify:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => FaceVerifyProvider(),
            child: const FaceVerifyScreen(),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
