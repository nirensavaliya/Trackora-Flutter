class ApiConstants {
  static const String baseurl = "https://honeydew-newt-829755.hostingersite.com/api";

  static const String login = "/auth/login";
  static const String registerTenant = "/auth/register-tenant";
  static const String taskSummary = "/tasks/summary";
  static const String tasks = "/tasks";
  static const String earnings = "/earnings";
  static const String faceRegister = "/face/register";
  static const String punchIn = "/attendance/punch-in";
  static const String punchOut = "/attendance/punch-out";
  static const String attendanceToday = "/attendance/today";
  static const String leaveTypes = "/leave/types";
  static const String leaveRequests = "/leave/requests";

  static String leaveRequestCancel(String id) => "/leave/requests/$id/cancel";


}