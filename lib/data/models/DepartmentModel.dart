class DepartmentResponse {
  final bool? success;
  final List<Department>? data;

  DepartmentResponse({
    this.success,
    this.data,
  });

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<Department>.from(
        json['data'].map(
              (x) => Department.fromJson(x),
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

class Department {
  final String? id;
  final String? name;
  final String? tenantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DepartmentCount? count;

  Department({
    this.id,
    this.name,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.count,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      tenantId: json['tenantId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      count: json['_count'] != null
          ? DepartmentCount.fromJson(json['_count'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tenantId': tenantId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '_count': count?.toJson(),
    };
  }
}

class DepartmentCount {
  final int? employees;

  DepartmentCount({
    this.employees,
  });

  factory DepartmentCount.fromJson(Map<String, dynamic> json) {
    return DepartmentCount(
      employees: json['employees'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employees': employees,
    };
  }
}