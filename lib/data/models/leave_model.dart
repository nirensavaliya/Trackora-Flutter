enum LeaveRequestStatus { pending, approved, rejected, cancelled }

class LeaveModel {
  const LeaveModel({
    required this.id,
    required this.typeId,
    required this.typeName,
    this.typeCode = '',
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.days = 1,
    this.employeeName = '',
  });

  final String id;
  final String typeId;
  final String typeName;
  final String typeCode;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveRequestStatus status;
  final int days;
  final String employeeName;

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    final leaveType = json['leaveType'] is Map
        ? Map<String, dynamic>.from(json['leaveType'] as Map)
        : <String, dynamic>{};
    final employee = json['employee'] is Map
        ? Map<String, dynamic>.from(json['employee'] as Map)
        : <String, dynamic>{};
    final user = employee['user'] is Map
        ? Map<String, dynamic>.from(employee['user'] as Map)
        : <String, dynamic>{};
    final from = DateTime.tryParse(json['fromDate']?.toString() ?? '')?.toLocal() ??
        DateTime.now();
    final to = DateTime.tryParse(json['toDate']?.toString() ?? '')?.toLocal() ??
        from;
    return LeaveModel(
      id: json['id']?.toString() ?? '',
      typeId: json['leaveTypeId']?.toString() ?? leaveType['id']?.toString() ?? '',
      typeName: leaveType['name']?.toString() ??
          leaveType['code']?.toString() ??
          'Leave',
      typeCode: leaveType['code']?.toString() ?? '',
      startDate: from,
      endDate: to,
      reason: json['reason']?.toString() ?? '',
      status: _statusFromApi(json['status']?.toString()),
      days: int.tryParse('${json['days']}') ?? 1,
      employeeName: user['name']?.toString() ??
          employee['employeeCode']?.toString() ??
          '',
    );
  }

  String get statusLabel {
    switch (status) {
      case LeaveRequestStatus.pending:
        return 'Pending';
      case LeaveRequestStatus.approved:
        return 'Approved';
      case LeaveRequestStatus.rejected:
        return 'Rejected';
      case LeaveRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get dateRangeLabel => '${formatDate(startDate)} – ${formatDate(endDate)}';

  int get dayCount => days < 1 ? 1 : days;

  static LeaveRequestStatus _statusFromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'APPROVED':
        return LeaveRequestStatus.approved;
      case 'REJECTED':
        return LeaveRequestStatus.rejected;
      case 'CANCELLED':
        return LeaveRequestStatus.cancelled;
      default:
        return LeaveRequestStatus.pending;
    }
  }

  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String apiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
