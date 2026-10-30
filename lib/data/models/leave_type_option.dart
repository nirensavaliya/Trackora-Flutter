class LeaveTypeResponse {
  const LeaveTypeResponse({
    this.success,
    this.data,
  });

  final bool? success;
  final List<LeaveTypeOption>? data;

  factory LeaveTypeResponse.fromJson(Map<String, dynamic> json) {
    return LeaveTypeResponse(
      success: json['success'] as bool?,
      data: json['data'] is List
          ? (json['data'] as List)
              .whereType<Map>()
              .map(
                (e) => LeaveTypeOption.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class LeaveTypeOption {
  const LeaveTypeOption({
    required this.id,
    required this.name,
    required this.code,
    required this.isPaid,
    required this.annualQuota,
    required this.isActive,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String code;
  final bool isPaid;
  final int annualQuota;
  final bool isActive;
  final String? tenantId;
  final String? createdAt;
  final String? updatedAt;

  factory LeaveTypeOption.fromJson(Map<String, dynamic> json) {
    return LeaveTypeOption(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isPaid: json['isPaid'] == true,
      annualQuota: int.tryParse('${json['annualQuota']}') ?? 0,
      isActive: json['isActive'] != false,
      tenantId: json['tenantId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'isPaid': isPaid,
      'annualQuota': annualQuota,
      'isActive': isActive,
      'tenantId': tenantId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get dropdownLabel {
    if (code.isEmpty) return name;
    return '$name ($code)';
  }
}
