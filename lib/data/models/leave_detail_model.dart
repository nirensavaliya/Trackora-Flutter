class LeaveDetailModel {
  final bool? success;
  final LeaveRequestData? data;

  LeaveDetailModel({
    this.success,
    this.data,
  });

  factory LeaveDetailModel.fromJson(Map<String, dynamic> json) {
    return LeaveDetailModel(
      success: json['success'],
      data: json['data'] != null
          ? LeaveRequestData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}
class LeaveRequestData {
  final String? id;
  final String? fromDate;
  final String? toDate;
  final int? days;
  final String? reason;
  final String? status;
  final bool? isBackdated;
  final int? paidDays;
  final int? unpaidDays;
  final num? deductedAmount;
  final String? employeeId;
  final String? leaveTypeId;
  final String? requestedById;
  final String? approvedById;
  final String? decidedAt;
  final String? tenantId;
  final String? createdAt;
  final String? updatedAt;
  final LeaveType? leaveType;
  final Employee? employee;
  final RequestedBy? requestedBy;
  final ApprovedBy? approvedBy;

  LeaveRequestData({
    this.id,
    this.fromDate,
    this.toDate,
    this.days,
    this.reason,
    this.status,
    this.isBackdated,
    this.paidDays,
    this.unpaidDays,
    this.deductedAmount,
    this.employeeId,
    this.leaveTypeId,
    this.requestedById,
    this.approvedById,
    this.decidedAt,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.leaveType,
    this.employee,
    this.requestedBy,
    this.approvedBy,
  });

  factory LeaveRequestData.fromJson(Map<String, dynamic> json) {
    return LeaveRequestData(
      id: json['id'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      days: json['days'],
      reason: json['reason'],
      status: json['status'],
      isBackdated: json['isBackdated'],
      paidDays: json['paidDays'],
      unpaidDays: json['unpaidDays'],
      deductedAmount: json['deductedAmount'],
      employeeId: json['employeeId'],
      leaveTypeId: json['leaveTypeId'],
      requestedById: json['requestedById'],
      approvedById: json['approvedById'],
      decidedAt: json['decidedAt'],
      tenantId: json['tenantId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      leaveType: json['leaveType'] != null
          ? LeaveType.fromJson(json['leaveType'])
          : null,
      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'])
          : null,
      requestedBy: json['requestedBy'] != null
          ? RequestedBy.fromJson(json['requestedBy'])
          : null,
      approvedBy: json['approvedBy'] != null
          ? ApprovedBy.fromJson(json['approvedBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromDate': fromDate,
      'toDate': toDate,
      'days': days,
      'reason': reason,
      'status': status,
      'isBackdated': isBackdated,
      'paidDays': paidDays,
      'unpaidDays': unpaidDays,
      'deductedAmount': deductedAmount,
      'employeeId': employeeId,
      'leaveTypeId': leaveTypeId,
      'requestedById': requestedById,
      'approvedById': approvedById,
      'decidedAt': decidedAt,
      'tenantId': tenantId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'leaveType': leaveType?.toJson(),
      'employee': employee?.toJson(),
      'requestedBy': requestedBy?.toJson(),
      'approvedBy': approvedBy?.toJson(),
    };
  }
}

class LeaveType {
  final String? id;
  final String? name;
  final String? code;
  final bool? isPaid;

  LeaveType({
    this.id,
    this.name,
    this.code,
    this.isPaid,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      isPaid: json['isPaid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'isPaid': isPaid,
    };
  }
}

class Employee {
  final String? id;
  final String? employeeCode;
  final String? joinDate;
  final String? monthlySalary;
  final bool? pfEnabled;
  final String? pfPercent;
  final bool? taxEnabled;
  final String? taxPercent;
  final bool? employeeTaxEnabled;
  final String? employeeTaxAmount;
  final bool? overtimeEnabled;
  final String? overtimeRatePerHour;
  final bool? bonusEnabled;
  final String? bonusAmount;
  final String? faceEmbedding;
  final String? faceRegisteredAt;
  final String? userId;
  final String? departmentId;
  final String? tenantId;
  final String? createdAt;
  final String? updatedAt;
  final EmployeeUser? user;

  Employee({
    this.id,
    this.employeeCode,
    this.joinDate,
    this.monthlySalary,
    this.pfEnabled,
    this.pfPercent,
    this.taxEnabled,
    this.taxPercent,
    this.employeeTaxEnabled,
    this.employeeTaxAmount,
    this.overtimeEnabled,
    this.overtimeRatePerHour,
    this.bonusEnabled,
    this.bonusAmount,
    this.faceEmbedding,
    this.faceRegisteredAt,
    this.userId,
    this.departmentId,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeCode: json['employeeCode'],
      joinDate: json['joinDate'],
      monthlySalary: json['monthlySalary'],
      pfEnabled: json['pfEnabled'],
      pfPercent: json['pfPercent'],
      taxEnabled: json['taxEnabled'],
      taxPercent: json['taxPercent'],
      employeeTaxEnabled: json['employeeTaxEnabled'],
      employeeTaxAmount: json['employeeTaxAmount'],
      overtimeEnabled: json['overtimeEnabled'],
      overtimeRatePerHour: json['overtimeRatePerHour'],
      bonusEnabled: json['bonusEnabled'],
      bonusAmount: json['bonusAmount'],
      faceEmbedding: json['faceEmbedding'],
      faceRegisteredAt: json['faceRegisteredAt'],
      userId: json['userId'],
      departmentId: json['departmentId'],
      tenantId: json['tenantId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      user: json['user'] != null
          ? EmployeeUser.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeCode': employeeCode,
      'joinDate': joinDate,
      'monthlySalary': monthlySalary,
      'pfEnabled': pfEnabled,
      'pfPercent': pfPercent,
      'taxEnabled': taxEnabled,
      'taxPercent': taxPercent,
      'employeeTaxEnabled': employeeTaxEnabled,
      'employeeTaxAmount': employeeTaxAmount,
      'overtimeEnabled': overtimeEnabled,
      'overtimeRatePerHour': overtimeRatePerHour,
      'bonusEnabled': bonusEnabled,
      'bonusAmount': bonusAmount,
      'faceEmbedding': faceEmbedding,
      'faceRegisteredAt': faceRegisteredAt,
      'userId': userId,
      'departmentId': departmentId,
      'tenantId': tenantId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'user': user?.toJson(),
    };
  }
}

class EmployeeUser {
  final String? id;
  final String? name;
  final String? email;
  final String? role;

  EmployeeUser({
    this.id,
    this.name,
    this.email,
    this.role,
  });

  factory EmployeeUser.fromJson(Map<String, dynamic> json) {
    return EmployeeUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class RequestedBy {
  final String? id;
  final String? name;
  final String? role;

  RequestedBy({
    this.id,
    this.name,
    this.role,
  });

  factory RequestedBy.fromJson(Map<String, dynamic> json) {
    return RequestedBy(
      id: json['id'],
      name: json['name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }
}

class ApprovedBy {
  final String? id;
  final String? name;
  final String? role;

  ApprovedBy({
    this.id,
    this.name,
    this.role,
  });

  factory ApprovedBy.fromJson(Map<String, dynamic> json) {
    return ApprovedBy(
      id: json['id'],
      name: json['name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }
}