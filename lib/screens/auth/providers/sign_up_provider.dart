import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackora/app/routes.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/storage/local_storage.dart';

class SignUpProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final company = TextEditingController(text: '');
  final clientCode = TextEditingController(text: '');
  final adminName = TextEditingController(text: '');
  final email = TextEditingController(text: '');
  final password = TextEditingController();

  bool obscure = true;
  bool isLoading = false;
  String? errorMessage;
  double geofenceMeters = 300;
  LatLng office = const LatLng(21.1702, 72.8311);

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners();
  }

  void setGeofence(double value) {
    geofenceMeters = value;
    notifyListeners();
  }

  String? requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String? validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter admin email';
    final emailRegex = RegExp(r'^[\w.\-+]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(text)) return 'Please enter a valid email';
    return null;
  }

  void _toast(BuildContext context, String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppColors.appColor : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> onSignUp(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final ok = await _register();
    if (!context.mounted) return;

    if (ok) {
      _toast(context, errorMessage ?? 'Account created successfully', success: true);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeScreen,
            (route) => false,
      );
      return;
    }

    _toast(context, errorMessage ?? 'Signup failed. Please try again.');
  }

  Future<bool> _register() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().postRequest(
        ApiConstants.registerTenant,
        data: {
          'companyName': company.text.trim(),
          'clientCode': clientCode.text.trim(),
          'adminName': adminName.text.trim(),
          'adminEmail': email.text.trim(),
          'adminPassword': password.text.trim(),
          'officeLat': office.latitude,
          'officeLng': office.longitude,
          'geoFenceRadiusMeters': geofenceMeters.round(),
        },
      );

      final body = response.data;
      print('SIGNUP STATUS: ${response.statusCode}');
      print('SIGNUP BODY: $body');

      if (body is Map && body['success'] == true) {
        errorMessage = body['message']?.toString() ?? 'Account created successfully';

        if (body['data'] is Map) {
          final data = Map<String, dynamic>.from(body['data'] as Map);
          final token = data['token']?.toString() ?? '';
          final user = data['user'] is Map
              ? Map<String, dynamic>.from(data['user'] as Map)
              : <String, dynamic>{};
          final tenant = data['tenant'] is Map
              ? Map<String, dynamic>.from(data['tenant'] as Map)
              : <String, dynamic>{};

          if (token.isNotEmpty) {
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
              tenant['clientCode']?.toString() ?? clientCode.text.trim(),
            );
            await GetStorageData.saveString(
              GetStorageData.userType,
              user['role']?.toString() ?? '',
            );
          }
        }

        isLoading = false;
        notifyListeners();
        return true;
      }

      errorMessage = body is Map
          ? (body['message']?.toString() ?? body['error']?.toString())
          : null;
      errorMessage ??= 'Signup failed. Please try again.';
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

  @override
  void dispose() {
    company.dispose();
    clientCode.dispose();
    adminName.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }
}