class LeaveBalanceResponse {
  final bool? success;
  final List<LeaveBalance>? data;

  LeaveBalanceResponse({
    this.success,
    this.data,
  });

  factory LeaveBalanceResponse.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceResponse(
      success: json['success'] as bool?,
      data: json['data'] != null
          ? List<LeaveBalance>.from(
              (json['data'] as List).map(
                (x) => LeaveBalance.fromJson(
                  Map<String, dynamic>.from(x as Map),
                ),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class LeaveBalance {
  final String? id;
  final int? year;
  final int? entitled;
  final int? used;
  final String? employeeId;
  final String? leaveTypeId;
  final String? tenantId;
  final String? updatedAt;
  final LeaveBalanceType? leaveType;
  final LeaveBalanceEmployee? employee;
  final int? remaining;

  LeaveBalance({
    this.id,
    this.year,
    this.entitled,
    this.used,
    this.employeeId,
    this.leaveTypeId,
    this.tenantId,
    this.updatedAt,
    this.leaveType,
    this.employee,
    this.remaining,
  });

  int get remainingDays {
    if (remaining != null) return remaining!;
    return (entitled ?? 0) - (used ?? 0);
  }

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id']?.toString(),
      year: int.tryParse('${json['year']}'),
      entitled: int.tryParse('${json['entitled']}'),
      used: int.tryParse('${json['used']}'),
      employeeId: json['employeeId']?.toString(),
      leaveTypeId: json['leaveTypeId']?.toString(),
      tenantId: json['tenantId']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      leaveType: json['leaveType'] != null
          ? LeaveBalanceType.fromJson(
              Map<String, dynamic>.from(json['leaveType'] as Map),
            )
          : null,
      employee: json['employee'] != null
          ? LeaveBalanceEmployee.fromJson(
              Map<String, dynamic>.from(json['employee'] as Map),
            )
          : null,
      remaining: int.tryParse('${json['remaining']}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'entitled': entitled,
      'used': used,
      'employeeId': employeeId,
      'leaveTypeId': leaveTypeId,
      'tenantId': tenantId,
      'updatedAt': updatedAt,
      'leaveType': leaveType?.toJson(),
      'employee': employee?.toJson(),
      'remaining': remaining,
    };
  }
}

class LeaveBalanceType {
  final String? id;
  final String? name;
  final String? code;
  final bool? isPaid;

  LeaveBalanceType({
    this.id,
    this.name,
    this.code,
    this.isPaid,
  });

  factory LeaveBalanceType.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceType(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      isPaid: json['isPaid'] as bool?,
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

class LeaveBalanceEmployee {
  final String? id;
  final String? employeeCode;
  final String? userId;
  final LeaveBalanceEmployeeUser? user;

  LeaveBalanceEmployee({
    this.id,
    this.employeeCode,
    this.userId,
    this.user,
  });

  factory LeaveBalanceEmployee.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceEmployee(
      id: json['id']?.toString(),
      employeeCode: json['employeeCode']?.toString(),
      userId: json['userId']?.toString(),
      user: json['user'] != null
          ? LeaveBalanceEmployeeUser.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeCode': employeeCode,
      'userId': userId,
      'user': user?.toJson(),
    };
  }
}

class LeaveBalanceEmployeeUser {
  final String? id;
  final String? name;
  final String? email;

  LeaveBalanceEmployeeUser({
    this.id,
    this.name,
    this.email,
  });

  factory LeaveBalanceEmployeeUser.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceEmployeeUser(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
