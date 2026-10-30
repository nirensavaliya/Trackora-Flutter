class AttendanceResponse {
  final bool? success;
  final List<AttendanceData>? data;

  AttendanceResponse({
    this.success,
    this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => AttendanceData.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class AttendanceData {
  final String? id;
  final String? date;
  final String? checkInAt;
  final String? checkOutAt;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? punchSource;
  final double? checkInFaceScore;
  final double? checkOutFaceScore;
  final String? status;
  final String? employeeId;
  final String? tenantId;
  final String? createdAt;
  final String? updatedAt;
  final Employee? employee;
  final Department? department;

  AttendanceData({
    this.id,
    this.date,
    this.checkInAt,
    this.checkOutAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.punchSource,
    this.checkInFaceScore,
    this.checkOutFaceScore,
    this.status,
    this.employeeId,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.employee,
    this.department,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'],
      date: json['date'],
      checkInAt: json['checkInAt'],
      checkOutAt: json['checkOutAt'],
      checkInLat: json['checkInLat']?.toDouble(),
      checkInLng: json['checkInLng']?.toDouble(),
      checkOutLat: json['checkOutLat']?.toDouble(),
      checkOutLng: json['checkOutLng']?.toDouble(),
      punchSource: json['punchSource'],
      checkInFaceScore: json['checkInFaceScore']?.toDouble(),
      checkOutFaceScore: json['checkOutFaceScore']?.toDouble(),
      status: json['status'],
      employeeId: json['employeeId'],
      tenantId: json['tenantId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'])
          : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'checkInAt': checkInAt,
      'checkOutAt': checkOutAt,
      'checkInLat': checkInLat,
      'checkInLng': checkInLng,
      'checkOutLat': checkOutLat,
      'checkOutLng': checkOutLng,
      'punchSource': punchSource,
      'checkInFaceScore': checkInFaceScore,
      'checkOutFaceScore': checkOutFaceScore,
      'status': status,
      'employeeId': employeeId,
      'tenantId': tenantId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'employee': employee?.toJson(),
      'department': department?.toJson(),
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
  final User? user;
  final Department? department;

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
    this.department,
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
          ? User.fromJson(json['user'])
          : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
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
      'department': department?.toJson(),
    };
  }
}

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? role;

  User({
    this.id,
    this.name,
    this.email,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

class Department {
  Department();

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}