import 'package:dio/dio.dart';
import 'package:trackora/core/constants/api_constants.dart';


class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late Dio _dio;

  ApiService._internal() {
    _createDio();
  }

  void _createDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseurl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final path = error.requestOptions.path;
          //
          // if (error.response?.statusCode == 401) {
          //   if (path.contains(ApiConstants.login) ||
          //       path.contains(ApiConstants.deletePassword) ||
          //       path.contains(ApiConstants.editUser) ||
          //       path.contains(ApiConstants.dashBoardTransaction) ||
          //       path.contains(ApiConstants.summary)) {
          //     return handler.next(error);
          //   }
          //   print("⚠️ Token expired → Auto logout");
          //
          //   await GetStorageData.removeData(GetStorageData.token);
          //   await GetStorageData.removeData(GetStorageData.userType);
          //   await GetStorageData.removeData(GetStorageData.isOtpVerified);
          //
          //   Get.offAllNamed(AppRoutes.loginScreen);
          // }

          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  void syncBaseUrlFromEnvironment() {
    // updateBaseUrl(ApiEnvironment.baseUrl);
  }

  /// Reusable GET Method
  Future<Response> getRequest(
      String endpoint, {
        Map<String, dynamic>? queryParams,
        Map<String, dynamic>? headers,
        ResponseType? responseType,
      }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers, responseType: responseType),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "API Error");
    }
  }

  /// Generic POST
  Future<Response> postRequest(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParams,
        Map<String, dynamic>? headers,
      }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParams,
        options: Options(headers: headers, validateStatus: (status) => true),
      );
      print('POST--API---${response}');
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "POST API Error");
    }
  }

  Future<Response> putRequest(
      String url, {
        dynamic data,
        Map<String, String>? headers,
      }) async {
    return await _dio.put(
      url,
      data: data,
      options: Options(headers: headers),
    );
  }

  Future<Response> deleteRequest(
      String url, {
        Map<String, dynamic>? data,
        Map<String, String>? headers,
      }) async {
    print("---- DELETE API CALLED ----");
    print("Base URL: ${url}");
    print("Full URL: ${_dio.options.baseUrl}$url");
    print("Headers: $headers");
    print("Body: $data");
    return await _dio.delete(
      url,
      data: data,
      options: Options(headers: headers),
    );
  }

  /// Generic PATCH
  Future<Response> patchRequest(
      String url, {
        dynamic data,
        Map<String, dynamic>? headers,
      }) async {
    try {
      final response = await _dio.patch(
        url,
        data: data,
        options: Options(headers: headers, validateStatus: (status) => true),
      );
      print("PATCH API RESPONSE: $response");
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "PATCH API Error");
    }
  }
}
