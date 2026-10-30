import 'package:flutter/cupertino.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/DepartmentModel.dart';

class DepartmentProvider extends ChangeNotifier{
  DepartmentResponse? departmentResponse;
  bool isLoading = false;
  String? errorMessage;
  String get token => GetStorageData.readString(GetStorageData.token) ?? '';
  TextEditingController namecontroller = TextEditingController();

  Future<void> initializeDepartment() async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        getDepartment(),
      ]);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> getDepartment() async {
    try {
      final response = await ApiService().getRequest(
        ApiConstants.department,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        'DEPARTMENT STATUS = ${response.statusCode}',
      );

      debugPrint(
        'DEPARTMENT RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        departmentResponse =
            DepartmentResponse.fromJson(response.data);

        debugPrint(
          'DEPARTMENT COUNT = '
              '${departmentResponse?.data?.length ?? 0}',
        );
      } else {
        departmentResponse = null;
      }
    } catch (e) {
      debugPrint('DEPARTMENT ERROR = $e');
      departmentResponse = null;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createDepartment(String name) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint('CREATE DEPARTMENT');
      debugPrint('DEPARTMENT NAME = $namecontroller');
      final response = await ApiService().postRequest(
        ApiConstants.department,
        data: {'name': name},
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('CREATE DEPARTMENT STATUS = ${response.statusCode}',);
      debugPrint('CREATE DEPARTMENT RESPONSE = ${response.data}',);
      if (response.statusCode == 201) {
        debugPrint('DEPARTMENT CREATED SUCCESSFULLY');
        namecontroller.clear();
        await getDepartment();
        return true;
      }
      if (response.statusCode == 409) {
        errorMessage = response.data?['message'] ?? 'Department name already exists';
        debugPrint('DEPARTMENT ALREADY EXISTS',);
        return false;
      }
      errorMessage = response.data?['message'] ?? 'Unable to create department';
      return false;
    } catch (e) {
      debugPrint('CREATE DEPARTMENT ERROR = $e');

      errorMessage = e.toString();

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  @override
  void dispose() {
    namecontroller.dispose();
    super.dispose();
  }
}