import 'package:flutter/material.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/DepartmentModel.dart';
import 'package:trackora/data/models/employee_model.dart';

class EmployeeProvider extends ChangeNotifier {
  EmployeeResponse? employeeResponse;
  DepartmentResponse? departmentResponse;

  bool isLoading = false;
  String? errorMessage;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController employeeCodeController = TextEditingController();

  TextEditingController salaryController = TextEditingController(text: '0');

  TextEditingController pfPercentController = TextEditingController(text: '12');

  TextEditingController taxPercentController = TextEditingController(text: '10');

  TextEditingController employeeTaxAmountController = TextEditingController(text: '200');

  TextEditingController overtimeRateController = TextEditingController(text: '150');

  TextEditingController bonusAmountController = TextEditingController(text: '2000');
  bool obscurePassword = true;
  bool pfEnabled = false;
  bool taxEnabled = false;
  bool employeeTaxEnabled = false;
  bool overtimeEnabled = false;
  bool bonusEnabled = false;
  String selectedRole = 'USER';
  String selectedDepartmentId = '';
  String selectedDepartmentName = 'None';
  DateTime selectedDate = DateTime.now();
  String get token => GetStorageData.readString(GetStorageData.token) ?? '';

  Future<void> initializeEmployee() async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        getEmployees(),
        getDepartment(),
      ]);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> getEmployees() async {
    try {
      final response = await ApiService().getRequest(
        ApiConstants.employees,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        'EMPLOYEES STATUS = ${response.statusCode}',
      );

      debugPrint(
        'EMPLOYEES RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        employeeResponse =
            EmployeeResponse.fromJson(response.data);

        debugPrint(
          'EMPLOYEE COUNT = '
              '${employeeResponse?.data?.length ?? 0}',
        );
      } else {
        employeeResponse = null;
      }
    } catch (e) {
      debugPrint('EMPLOYEES ERROR = $e');
      employeeResponse = null;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createEmployee() async {
    errorMessage = null;

    // Department is required by API
    if (selectedDepartmentId.isEmpty) {
      errorMessage = 'Please select department';
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final body = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'role': selectedRole,
        'employeeCode':
        employeeCodeController.text.trim(),

        'departmentId': selectedDepartmentId,

        'joinDate': _formatDate(selectedDate),

        'monthlySalary':
        double.tryParse(salaryController.text) ?? 0,

        'pfEnabled': pfEnabled,
        'pfPercent':
        double.tryParse(pfPercentController.text) ?? 0,

        'taxEnabled': taxEnabled,
        'taxPercent':
        double.tryParse(taxPercentController.text) ?? 0,

        'employeeTaxEnabled': employeeTaxEnabled,
        'employeeTaxAmount':
        double.tryParse(
          employeeTaxAmountController.text,
        ) ??
            0,

        'overtimeEnabled': overtimeEnabled,
        'overtimeRatePerHour':
        double.tryParse(
          overtimeRateController.text,
        ) ??
            0,

        'bonusEnabled': bonusEnabled,
        'bonusAmount':
        double.tryParse(
          bonusAmountController.text,
        ) ??
            0,
      };

      debugPrint(
        'CREATE EMPLOYEE BODY = $body',
      );

      final response = await ApiService().postRequest(
        ApiConstants.employees,
        data: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        'CREATE EMPLOYEE STATUS = '
            '${response.statusCode}',
      );

      debugPrint(
        'CREATE EMPLOYEE RESPONSE = '
            '${response.data}',
      );

      if (response.statusCode == 201) {
        errorMessage = null;

        clearForm();

        await getEmployees();

        return true;
      }

      errorMessage =
          response.data?['message'] ??
              'Failed to create employee';

      return false;
    } catch (e) {
      debugPrint(
        'CREATE EMPLOYEE ERROR = $e',
      );

      errorMessage = e.toString();

      return false;
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

      debugPrint('DEPARTMENT STATUS = ${response.statusCode}');
      debugPrint('DEPARTMENT RESPONSE = ${response.data}');
      if (response.statusCode == 200) {
        departmentResponse = DepartmentResponse.fromJson(response.data);
        debugPrint('DEPARTMENT COUNT = ''${departmentResponse?.data?.length ?? 0}');
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

  Future<bool> updateEmployee(String employeeId) async {
    errorMessage = null;

    if (selectedDepartmentId.isEmpty) {
      errorMessage = 'Please select department';
      notifyListeners();
      return false;
    }

    if (nameController.text.trim().length < 2) {
      errorMessage = 'Name must contain at least 2 characters';
      notifyListeners();
      return false;
    }

    if (employeeCodeController.text.trim().length < 2) {
      errorMessage = 'Employee code must contain at least 2 characters';
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final body = {
        'name': nameController.text.trim(),
        'role': selectedRole,
        'departmentId': selectedDepartmentId,
        'isActive': true,
        'employeeCode': employeeCodeController.text.trim(),
        'monthlySalary': double.tryParse(salaryController.text) ?? 0,
        'pfEnabled': pfEnabled,
        'pfPercent': double.tryParse(pfPercentController.text) ?? 0,
        'taxEnabled': taxEnabled,
        'taxPercent': double.tryParse(taxPercentController.text) ?? 0,
        'employeeTaxEnabled': employeeTaxEnabled,
        'employeeTaxAmount': double.tryParse(employeeTaxAmountController.text,) ?? 0,
        'overtimeEnabled': overtimeEnabled,
        'overtimeRatePerHour': double.tryParse(overtimeRateController.text,) ?? 0,
        'bonusEnabled': bonusEnabled,
        'bonusAmount': double.tryParse(bonusAmountController.text,) ?? 0,
      };
      debugPrint('UPDATE EMPLOYEE ID = $employeeId');
      debugPrint('UPDATE EMPLOYEE BODY = $body');
      final response = await ApiService().patchRequest(
        '${ApiConstants.employees}/$employeeId',
        data: body,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('UPDATE EMPLOYEE STATUS = ${response.statusCode}',);
      debugPrint('UPDATE EMPLOYEE RESPONSE = ${response.data}',);
      if (response.statusCode == 200) {
        errorMessage = null;
        clearForm();
        await getEmployees();
        return true;
      }
      errorMessage = response.data?['message'] ?? 'Failed to update employee';
      return false;
    } catch (e) {
      debugPrint('UPDATE EMPLOYEE ERROR = $e');
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateEmployee(String employeeId) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      debugPrint('DEACTIVATE EMPLOYEE ID = $employeeId');

      final response = await ApiService().deleteRequest(
        '${ApiConstants.employees}/$employeeId',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'DEACTIVATE EMPLOYEE STATUS = ${response.statusCode}',
      );

      debugPrint(
        'DEACTIVATE EMPLOYEE RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        errorMessage = null;

        // List refresh
        await getEmployees();

        return true;
      }

      errorMessage =
          response.data?['message'] ??
              'Failed to deactivate employee';

      return false;
    } catch (e) {
      debugPrint(
        'DEACTIVATE EMPLOYEE ERROR = $e',
      );

      errorMessage = e.toString();

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  void fillEmployeeData(Employee employee) {
    final user = employee.user;

    nameController.text = user?.name ?? '';
    emailController.text = user?.email ?? '';
    passwordController.clear();

    employeeCodeController.text =
        employee.employeeCode ?? '';

    salaryController.text =
        (employee.monthlySalary ?? 0).toString();

    selectedRole = user?.role ?? 'USER';

    selectedDepartmentId =
        employee.departmentId ?? '';

    selectedDepartmentName =
        employee.department?.name ?? 'None';

    pfEnabled =
        employee.pfEnabled ?? false;

    taxEnabled =
        employee.taxEnabled ?? false;

    employeeTaxEnabled =
        employee.employeeTaxEnabled ?? false;

    overtimeEnabled =
        employee.overtimeEnabled ?? false;

    bonusEnabled =
        employee.bonusEnabled ?? false;

    pfPercentController.text =
        (employee.pfPercent ?? 12).toString();

    taxPercentController.text =
        (employee.taxPercent ?? 10).toString();

    employeeTaxAmountController.text =
        (employee.employeeTaxAmount ?? 200).toString();

    overtimeRateController.text =
        (employee.overtimeRatePerHour ?? 150).toString();

    bonusAmountController.text =
        (employee.bonusAmount ?? 2000).toString();

    if (employee.joinDate != null) {
      selectedDate = employee.joinDate!;
    } else {
      selectedDate = DateTime.now();
    }

    obscurePassword = true;

    errorMessage = null;

    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void setRole(String value) {
    selectedRole = value;
    notifyListeners();
  }

  void setDepartment({
    required String id,
    required String name,
  }) {
    selectedDepartmentId = id;
    selectedDepartmentName = name;
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setPf(bool value) {
    pfEnabled = value;
    notifyListeners();
  }

  void setTax(bool value) {
    taxEnabled = value;
    notifyListeners();
  }

  void setEmployeeTax(bool value) {
    employeeTaxEnabled = value;
    notifyListeners();
  }

  void setOvertime(bool value) {
    overtimeEnabled = value;
    notifyListeners();
  }

  void setBonus(bool value) {
    bonusEnabled = value;
    notifyListeners();
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    employeeCodeController.clear();

    salaryController.text = '0';
    pfPercentController.text = '12';
    taxPercentController.text = '10';
    employeeTaxAmountController.text = '200';
    overtimeRateController.text = '150';
    bonusAmountController.text = '2000';

    obscurePassword = true;

    pfEnabled = false;
    taxEnabled = false;
    employeeTaxEnabled = false;
    overtimeEnabled = false;
    bonusEnabled = false;

    selectedRole = 'USER';

    selectedDepartmentId = '';
    selectedDepartmentName = 'None';

    selectedDate = DateTime.now();

    errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    employeeCodeController.dispose();
    salaryController.dispose();
    pfPercentController.dispose();
    taxPercentController.dispose();
    employeeTaxAmountController.dispose();
    overtimeRateController.dispose();
    bonusAmountController.dispose();

    super.dispose();
  }
}