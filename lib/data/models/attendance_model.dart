class AttendanceModel {
  final String id;
  final DateTime? date;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String punchSource;
  final double? checkInFaceScore;
  final double? checkOutFaceScore;
  final String status;
  final String employeeId;
  final String tenantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final EmployeeModel? employee;

  AttendanceModel({
    required this.id,
    required this.date,
    this.checkInAt,
    this.checkOutAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    required this.punchSource,
    this.checkInFaceScore,
    this.checkOutFaceScore,
    required this.status,
    required this.employeeId,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    this.employee,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',

      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,

      checkInAt: json['checkInAt'] != null
          ? DateTime.tryParse(json['checkInAt'].toString())
          : null,

      checkOutAt: json['checkOutAt'] != null
          ? DateTime.tryParse(json['checkOutAt'].toString())
          : null,

      checkInLat: (json['checkInLat'] as num?)?.toDouble(),
      checkInLng: (json['checkInLng'] as num?)?.toDouble(),
      checkOutLat: (json['checkOutLat'] as num?)?.toDouble(),
      checkOutLng: (json['checkOutLng'] as num?)?.toDouble(),

      punchSource: json['punchSource']?.toString() ?? '',

      checkInFaceScore:
      (json['checkInFaceScore'] as num?)?.toDouble(),

      checkOutFaceScore:
      (json['checkOutFaceScore'] as num?)?.toDouble(),

      status: json['status']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,

      employee: json['employee'] is Map
          ? EmployeeModel.fromJson(
        Map<String, dynamic>.from(json['employee']),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'checkInAt': checkInAt?.toIso8601String(),
      'checkOutAt': checkOutAt?.toIso8601String(),
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'employee': employee?.toJson(),
    };
  }
}


class EmployeeModel {
  final String id;
  final String employeeCode;
  final DateTime? joinDate;
  final String monthlySalary;
  final bool pfEnabled;
  final String pfPercent;
  final bool taxEnabled;
  final String taxPercent;
  final bool employeeTaxEnabled;
  final String employeeTaxAmount;
  final bool overtimeEnabled;
  final String overtimeRatePerHour;
  final bool bonusEnabled;
  final String bonusAmount;
  final String faceEmbedding;
  final DateTime? faceRegisteredAt;
  final String userId;
  final String departmentId;
  final String tenantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserModel? user;
  final DepartmentModel? department;

  EmployeeModel({
    required this.id,
    required this.employeeCode,
    this.joinDate,
    required this.monthlySalary,
    required this.pfEnabled,
    required this.pfPercent,
    required this.taxEnabled,
    required this.taxPercent,
    required this.employeeTaxEnabled,
    required this.employeeTaxAmount,
    required this.overtimeEnabled,
    required this.overtimeRatePerHour,
    required this.bonusEnabled,
    required this.bonusAmount,
    required this.faceEmbedding,
    this.faceRegisteredAt,
    required this.userId,
    required this.departmentId,
    required this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.department,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',

      joinDate: json['joinDate'] != null
          ? DateTime.tryParse(json['joinDate'].toString())
          : null,

      monthlySalary: json['monthlySalary']?.toString() ?? '0',

      pfEnabled: json['pfEnabled'] == true,
      pfPercent: json['pfPercent']?.toString() ?? '0',

      taxEnabled: json['taxEnabled'] == true,
      taxPercent: json['taxPercent']?.toString() ?? '0',

      employeeTaxEnabled:
      json['employeeTaxEnabled'] == true,

      employeeTaxAmount:
      json['employeeTaxAmount']?.toString() ?? '0',

      overtimeEnabled:
      json['overtimeEnabled'] == true,

      overtimeRatePerHour:
      json['overtimeRatePerHour']?.toString() ?? '0',

      bonusEnabled:
      json['bonusEnabled'] == true,

      bonusAmount:
      json['bonusAmount']?.toString() ?? '0',

      faceEmbedding:
      json['faceEmbedding']?.toString() ?? '',

      faceRegisteredAt: json['faceRegisteredAt'] != null
          ? DateTime.tryParse(
        json['faceRegisteredAt'].toString(),
      )
          : null,

      userId: json['userId']?.toString() ?? '',
      departmentId: json['departmentId']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,

      user: json['user'] is Map
          ? UserModel.fromJson(
        Map<String, dynamic>.from(json['user']),
      )
          : null,

      department: json['department'] is Map
          ? DepartmentModel.fromJson(
        Map<String, dynamic>.from(json['department']),
      )
          : null,
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
      'faceEmbedding': faceEmbedding,
      'faceRegisteredAt': faceRegisteredAt?.toIso8601String(),
      'userId': userId,
      'departmentId': departmentId,
      'tenantId': tenantId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'department': department?.toJson(),
    };
  }
}


class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
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


class DepartmentModel {
  final String id;
  final String name;

  DepartmentModel({
    required this.id,
    required this.name,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}