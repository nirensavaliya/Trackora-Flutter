import 'package:flutter/cupertino.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/SettingMe_model.dart';

class SettingProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  CompanyResponse? companyResponse;
  TextEditingController companyNameController = TextEditingController(text: "");
  TextEditingController clientCodeController = TextEditingController();
  TextEditingController officeLatitudeController = TextEditingController();
  TextEditingController officeLongitudeController = TextEditingController();
  TextEditingController geoFenceController = TextEditingController();
  TextEditingController lateAfterController = TextEditingController();
  String get token => GetStorageData.readString(GetStorageData.token) ?? '';

  Future<void> getMeApi() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await ApiService().getRequest(
        ApiConstants.tenants,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("setting Response---${response.data}");

      if (response.statusCode == 200) {
        companyResponse = CompanyResponse.fromJson(response.data);
        final data = companyResponse?.data;
        if (data != null) {
          companyNameController.text = data.name ?? '';
          clientCodeController.text = data.clientCode ?? '';
          officeLatitudeController.text = data.officeLat?.toString() ?? '';
          officeLongitudeController.text = data.officeLng?.toString() ?? '';
          geoFenceController.text = data.geoFenceRadiusMeters?.toString() ?? '';
          lateAfterController.text = data.lateAfterMinutes.toString() ?? '';
        }
      } else {
        companyResponse = null;
      }
    } catch (e) {
      debugPrint('SETTING ERROR = $e');
      companyResponse = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> updateCompany(String companyId) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final body = {
        'name': companyNameController.text.trim(),
        'officeLat': double.tryParse(officeLatitudeController.text.trim(),),
        'officeLng': double.tryParse(officeLongitudeController.text.trim(),),
        'geoFenceRadiusMeters': null,
        'lateAfterMinutes': 600,
      };
      debugPrint("UPDATE BODY = $body");
      final response = await ApiService().patchRequest(
        ApiConstants.tenants,
        data: body,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('UPDATE RESPONSE = ${response.data}');
      if (response.statusCode == 200) {
        errorMessage = null;
        await getMeApi();
        clearForm();
        return true;
      }
      errorMessage = response.data?['message'] ?? 'Failed to update company';
      return false;
    } catch (e) {
      debugPrint('UPDATE COMPANY ERROR = $e');
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  void clearForm() {
    companyNameController.clear();
    clientCodeController.clear();
    officeLatitudeController.clear();
    officeLongitudeController.clear();
    geoFenceController.clear();
    lateAfterController.clear();
    errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    companyNameController.clear();
    clientCodeController.clear();
    officeLatitudeController.clear();
    officeLongitudeController.clear();
    geoFenceController.clear();
    lateAfterController.clear();
    errorMessage = null;
    super.dispose();
  }
}
