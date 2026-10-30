class ApiConstants {
  static const String baseurl = "https://crm.200.97.163.242.sslip.io/api";

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
  static const String getEmployees = "/employees";
  static const String assignLeave = "/leave/assign";
  static const String earning = "/earnings";
  static const String leaveBalance = "/leave/balances";
  static const String department = "/departments";
  static const String leads = "/leads";
  static const String people = "/tasks/people";
  static const String contact = "/contacts";
  static const String task = "/tasks";
  static const String tenants = "/tenants/me";
  static const String attendance = "/attendance";
  static const String employees = "/employees";



  static String leaveRequestCancel(String id) => "/leave/requests/$id/cancel";
  static String leaveRequestApprove(String id) => "/leave/requests/$id/approve";
  static String leaveRequestReject(String id) => "/leave/requests/$id/reject";
}