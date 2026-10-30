class EmployeeResponse {
  final bool? success;
  final List<Employee>? data;

  EmployeeResponse({
    this.success,
    this.data,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<Employee>.from(
        json['data'].map((x) => Employee.fromJson(x)),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class Employee {
  final String? id;
  final String? employeeCode;
  final DateTime? joinDate;
  final num? monthlySalary;
  final bool? pfEnabled;
  final num? pfPercent;
  final bool? taxEnabled;
  final num? taxPercent;
  final bool? employeeTaxEnabled;
  final num? employeeTaxAmount;
  final bool? overtimeEnabled;
  final num? overtimeRatePerHour;
  final bool? bonusEnabled;
  final num? bonusAmount;
  final DateTime? faceRegisteredAt;
  final String? userId;
  final String? departmentId;
  final String? tenantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final EmployeeUser? user;
  final Department? department;
  final bool? faceRegistered;

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
    this.faceRegisteredAt,
    this.userId,
    this.departmentId,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.department,
    this.faceRegistered,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeCode: json['employeeCode'],
      joinDate: json['joinDate'] != null
          ? DateTime.tryParse(json['joinDate'])
          : null,
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
      faceRegisteredAt: json['faceRegisteredAt'] != null
          ? DateTime.tryParse(json['faceRegisteredAt'])
          : null,
      userId: json['userId'],
      departmentId: json['departmentId'],
      tenantId: json['tenantId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      user: json['user'] != null
          ? EmployeeUser.fromJson(json['user'])
          : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      faceRegistered: json['faceRegistered'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeCode': employeeCode,
      'joinDate': joinDate?.toIso8601String(),
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
      'faceRegisteredAt': faceRegisteredAt?.toIso8601String(),
      'userId': userId,
      'departmentId': departmentId,
      'tenantId': tenantId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'department': department?.toJson(),
      'faceRegistered': faceRegistered,
    };
  }
}

class EmployeeUser {
  final String? id;
  final String? name;
  final String? email;
  final String? role;
  final bool? isActive;

  EmployeeUser({
    this.id,
    this.name,
    this.email,
    this.role,
    this.isActive,
  });

  factory EmployeeUser.fromJson(Map<String, dynamic> json) {
    return EmployeeUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
    };
  }
}

class Department {
  final String? id;
  final String? name;

  Department({
    this.id,
    this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}