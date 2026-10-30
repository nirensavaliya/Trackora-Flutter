import 'package:flutter/material.dart';
import 'package:trackora/core/storage/local_storage.dart';

import '../../../app/routes.dart';

enum SplashStatus { loading, goToOnboarding, goToLogin, goToDashboard }

class SplashProvider extends ChangeNotifier {
  SplashStatus status = SplashStatus.loading;
  bool _didNavigate = false;

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 3));

    final token = GetStorageData.readString(GetStorageData.token)?.toString();

    final onboardingSeen =
        GetStorageData.readBool(GetStorageData.onboardingScreen) ?? false;

    final loginData = GetStorageData.readString(
      GetStorageData.loginData,
    )?.toString();

    print('token--$token');
    print('loginData--$loginData');
    print('onboardingSeen--$onboardingSeen');

    if (token != null && token.isNotEmpty) {
      status = SplashStatus.goToDashboard;
    }
    else if (!onboardingSeen) {
      status = SplashStatus.goToOnboarding;
    }
    else {
      status = SplashStatus.goToLogin;
    }

    notifyListeners();
  }

  void navigateOnce(BuildContext context) {
    if (status == SplashStatus.loading || _didNavigate) return;

    _didNavigate = true;

    switch (status) {
      case SplashStatus.goToOnboarding:
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        break;

      case SplashStatus.goToLogin:
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        break;

      case SplashStatus.goToDashboard:
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        break;

      case SplashStatus.loading:
        break;
    }
  }
}
