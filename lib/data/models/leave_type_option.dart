class LeaveTypeOption {
  const LeaveTypeOption({
    required this.id,
    required this.name,
    required this.code,
    required this.isPaid,
    required this.annualQuota,
    required this.isActive,
  });

  final String id;
  final String name;
  final String code;
  final bool isPaid;
  final int annualQuota;
  final bool isActive;

  factory LeaveTypeOption.fromJson(Map<String, dynamic> json) {
    return LeaveTypeOption(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isPaid: json['isPaid'] == true,
      annualQuota: int.tryParse('${json['annualQuota']}') ?? 0,
      isActive: json['isActive'] != false,
    );
  }

  String get dropdownLabel {
    if (code.isEmpty) return name;
    return '$name ($code)';
  }
}
