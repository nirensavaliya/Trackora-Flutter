import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';

import '../../../core/constants/app_colors.dart';

class LoginProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final clientCode = TextEditingController(text: 'G123');
  final email = TextEditingController(text: 'admin@gelai.com');
  final password = TextEditingController();

  bool obscure = true;
  bool isLoading = false;
  String? errorMessage;

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners();
  }

  String? validateClientCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter client code';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter email address';
    }
    final emailRegex = RegExp(r'^[\w.\-+]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(text)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  Future<void> onLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final success = await _login(
      clientCode: clientCode.text,
      email: email.text,
      password: password.text,
    );
    if (!context.mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'Login successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.appColor,
        textColor: Colors.white,
      );
      Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      return;
    }
    Fluttertoast.showToast(
      msg: errorMessage ?? 'Login failed. Please try again.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red.shade700,
      textColor: Colors.white,
    );
  }

  Future<bool> _login({
    required String clientCode,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().postRequest(
        ApiConstants.login,
        data: {
          'clientCode': clientCode.trim(),
          'email': email.trim(),
          'password': password.trim(),
        },
      );

      final body = response.data;
      if (body is Map && body['success'] == true && body['data'] is Map) {
        final data = Map<String, dynamic>.from(body['data'] as Map);
        final token = data['token']?.toString() ?? '';
        final user = data['user'] is Map
            ? Map<String, dynamic>.from(data['user'] as Map)
            : <String, dynamic>{};
        final tenant = data['tenant'] is Map
            ? Map<String, dynamic>.from(data['tenant'] as Map)
            : <String, dynamic>{};

        if (token.isEmpty) {
          errorMessage = 'Login failed. Token missing.';
          isLoading = false;
          notifyListeners();
          return false;
        }

        await GetStorageData.saveString(GetStorageData.token, token);
        await GetStorageData.saveString(
          GetStorageData.loginData,
          jsonEncode(data),
        );
        await GetStorageData.saveString(
          GetStorageData.userId,
          user['id']?.toString() ?? '',
        );
        await GetStorageData.saveString(
          GetStorageData.companyCode,
          tenant['clientCode']?.toString() ?? clientCode.trim(),
        );
        await GetStorageData.saveString(
          GetStorageData.userType,
          user['role']?.toString() ?? '',
        );

        isLoading = false;
        notifyListeners();
        return true;
      }

      errorMessage =
          _messageFromBody(body) ?? 'Login failed. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String? _messageFromBody(dynamic body) {
    if (body is Map) {
      return body['message']?.toString() ?? body['error']?.toString();
    }
    return null;
  }

  @override
  void dispose() {
    clientCode.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }
}
