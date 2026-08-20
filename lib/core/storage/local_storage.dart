import 'dart:convert';
import 'package:get_storage/get_storage.dart';


/// <<< To store data in phone storage --------- >>>
class GetStorageData {
  static String loginData = "LoginData";
  static String userId = "userId";
  static String token = "token";
  static String isOtpVerified = "isOtpVerified";
  static String companyCode = "CompanyCode";
  static String userType = "isUser";
  static String demoUser = "demoUser";
  static String currencyCode = "currencyCode";
  static String currencySymbol = "currencySymbol";
  static String currencyUsdRate = "currencyUsdRate";

  /// <<< To save object data --------- >>>
  static saveString(String key, value) async {
    final box = GetStorage();
    return box.write(key, value);
  }

  /// <<< To read object data --------- >>>
  static readString(String key) {
    final box = GetStorage();
    if (box.hasData(key)) {
      return box.read(key);
    } else {
      return null;
    }
  }

  static saveBool(String key, value) async {
    final box = GetStorage();
    return box.write(key, value);
  }

  /// <<< To read object data --------- >>>
  static readBool(String key) {
    final box = GetStorage();
    if (box.hasData(key)) {
      return box.read(key);
    } else {
      return null;
    }
  }

  static void clearAll() {
    final box = GetStorage();
    box.erase();
  }

  /// <<< To remove data --------- >>>
  static removeData(String key) async {
    final box = GetStorage();
    return box.remove(key);
  }

  /// <<< To Store Key data --------- >>>
  static bool containKey(String key) {
    final box = GetStorage();
    return box.hasData(key);
  }
}
