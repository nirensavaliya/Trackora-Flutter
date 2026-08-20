import 'package:flutter/material.dart';
import 'package:trackora/core/storage/local_storage.dart';

import '../../../app/routes.dart';

enum SplashStatus { loading, goToLogin, goToDashboard }

class SplashProvider extends ChangeNotifier {
  SplashStatus status = SplashStatus.loading;
  bool _didNavigate = false;

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = GetStorageData.readString(GetStorageData.token)?.toString();
    final loginData = GetStorageData.readString(GetStorageData.loginData)?.toString();
    print('token--${token}');
    print('loginData--${loginData}');
    status = (token != null && token.isNotEmpty)
        ? SplashStatus.goToDashboard
        : SplashStatus.goToLogin;
    notifyListeners();
  }


  void navigateOnce(BuildContext context) {
    if (status == SplashStatus.loading || _didNavigate) return;
    _didNavigate = true;
    if (status == SplashStatus.goToLogin) {
      Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
  }
}