import 'package:flutter/foundation.dart';

import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/employee_model.dart';
import 'package:trackora/data/models/salaryReport_Model.dart';

class ReportProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  EmployeeResponse? employeeResponse;
  SalaryResponse? salaryResponse;

  String userRole = '';

  String? selectedEmployeeId;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  String get token => GetStorageData.readString(GetStorageData.token) ?? '';

  ReportProvider();

  Future<void> loadRole() async {
    userRole = (GetStorageData.readString(GetStorageData.userType) ?? '')
        .trim()
        .toUpperCase();

    debugPrint('LOGIN USER ROLE = $userRole');

    notifyListeners();
  }

  bool get isUser => userRole == 'USER';

  bool get isHr => userRole == 'HR';

  bool get isAdmin => userRole == 'ADMIN';

  bool get canSelectEmployee => isAdmin || isHr;

  Future<void> initialize() async {
    isLoading = true;
    errorMessage = null;
    salaryResponse = null;

    notifyListeners();

    try {
      await loadRole();

      if (isAdmin || isHr) {
        await getEmployee();

        if (employeeResponse?.data != null &&
            employeeResponse!.data!.isNotEmpty) {
          selectedEmployeeId =
              employeeResponse!.data!.first.id;
        }
      }

      await getReport();
    } catch (e) {
      errorMessage = e.toString();

      debugPrint(
        'REPORT INITIALIZE ERROR = $e',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getEmployee() async {
    try {
      errorMessage = null;

      final response = await ApiService().getRequest(
        ApiConstants.getEmployees,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        'EMPLOYEE API STATUS = ${response.statusCode}',
      );

      debugPrint(
        'EMPLOYEE API RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        employeeResponse = EmployeeResponse.fromJson(
          response.data,
        );

        debugPrint(
          'TOTAL EMPLOYEES = ${employeeResponse?.data?.length}',
        );
      } else {
        errorMessage =
            response.statusMessage ?? 'Unable to get employees';
      }
    } catch (e) {
      errorMessage = e.toString();

      debugPrint(
        'GET EMPLOYEE ERROR = $e',
      );
    }

    notifyListeners();
  }


  Future<void> selectEmployeeAndLoadReport(
      String employeeId,
      ) async {
    selectedEmployeeId = employeeId;

    debugPrint(
      'SELECTED EMPLOYEE ID = $selectedEmployeeId',
    );

    notifyListeners();

    await getReport();
  }


  Future<void> selectYear(int year) async {
    selectedYear = year;

    notifyListeners();

    await getReport();
  }

  Future<void> selectMonth(int month) async {
    selectedMonth = month;

    notifyListeners();

    await getReport();
  }

  Future<void> getReport() async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      String url = ApiConstants.earning;

      final queryParams = <String>[];
      if (canSelectEmployee &&
          selectedEmployeeId != null &&
          selectedEmployeeId!.isNotEmpty) {
        queryParams.add(
          'employeeId=${Uri.encodeComponent(selectedEmployeeId!)}',
        );
      }
      queryParams.add(
        'year=$selectedYear',
      );
      queryParams.add(
        'month=$selectedMonth',
      );

      if (queryParams.isNotEmpty) {
        url = '$url?${queryParams.join('&')}';
      }

      debugPrint(
        'SALARY REPORT URL = $url',
      );

      final response = await ApiService().getRequest(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        'SALARY REPORT STATUS = ${response.statusCode}',
      );

      debugPrint(
        'SALARY REPORT RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        salaryResponse = SalaryResponse.fromJson(
          response.data,
        );

        debugPrint(
          'SALARY REPORT LOADED SUCCESSFULLY',
        );
      } else {
        salaryResponse = null;

        errorMessage =
            response.statusMessage ??
                'Unable to fetch earning report';
      }
    } catch (e) {
      salaryResponse = null;

      errorMessage = e.toString();

      debugPrint(
        'GET REPORT ERROR = $e',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



  void clearSelectedEmployee() {
    selectedEmployeeId = null;

    salaryResponse = null;

    notifyListeners();
  }
}