class SalaryResponse {
  final bool? success;
  final SalaryData? data;

  SalaryResponse({
    this.success,
    this.data,
  });

  factory SalaryResponse.fromJson(Map<String, dynamic> json) {
    return SalaryResponse(
      success: json['success'],
      data: json['data'] != null
          ? SalaryData.fromJson(json['data'])
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

class SalaryData {
  final SalaryEmployee? employee;
  final SalaryPeriod? period;
  final num? monthlySalary;
  final num? overtime;
  final num? bonus;
  final num? pf;
  final num? tax;
  final num? employeeTax;
  final num? leaveDeduction;
  final num? deductedTotal;
  final num? additions;
  final num? adjustments;
  final num? netPay;
  final List<SalaryComponent>? components;
  final List<dynamic>? ledger;

  SalaryData({
    this.employee,
    this.period,
    this.monthlySalary,
    this.overtime,
    this.bonus,
    this.pf,
    this.tax,
    this.employeeTax,
    this.leaveDeduction,
    this.deductedTotal,
    this.additions,
    this.adjustments,
    this.netPay,
    this.components,
    this.ledger,
  });

  factory SalaryData.fromJson(Map<String, dynamic> json) {
    return SalaryData(
      employee: json['employee'] != null
          ? SalaryEmployee.fromJson(json['employee'])
          : null,
      period: json['period'] != null
          ? SalaryPeriod.fromJson(json['period'])
          : null,
      monthlySalary: json['monthlySalary'],
      overtime: json['overtime'],
      bonus: json['bonus'],
      pf: json['pf'],
      tax: json['tax'],
      employeeTax: json['employeeTax'],
      leaveDeduction: json['leaveDeduction'],
      deductedTotal: json['deductedTotal'],
      additions: json['additions'],
      adjustments: json['adjustments'],
      netPay: json['netPay'],
      components: json['components'] != null
          ? (json['components'] as List)
          .map((e) => SalaryComponent.fromJson(e))
          .toList()
          : [],
      ledger: json['ledger'] != null
          ? List<dynamic>.from(json['ledger'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee?.toJson(),
      'period': period?.toJson(),
      'monthlySalary': monthlySalary,
      'overtime': overtime,
      'bonus': bonus,
      'pf': pf,
      'tax': tax,
      'employeeTax': employeeTax,
      'leaveDeduction': leaveDeduction,
      'deductedTotal': deductedTotal,
      'additions': additions,
      'adjustments': adjustments,
      'netPay': netPay,
      'components': components
          ?.map((e) => e.toJson())
          .toList(),
      'ledger': ledger,
    };
  }
}

class SalaryEmployee {
  final String? id;
  final String? employeeCode;
  final num? monthlySalary;
  final SalaryUser? user;
  final bool? pfEnabled;
  final bool? taxEnabled;
  final bool? employeeTaxEnabled;
  final bool? overtimeEnabled;
  final bool? bonusEnabled;
  final num? overtimeRatePerHour;

  SalaryEmployee({
    this.id,
    this.employeeCode,
    this.monthlySalary,
    this.user,
    this.pfEnabled,
    this.taxEnabled,
    this.employeeTaxEnabled,
    this.overtimeEnabled,
    this.bonusEnabled,
    this.overtimeRatePerHour,
  });

  factory SalaryEmployee.fromJson(Map<String, dynamic> json) {
    return SalaryEmployee(
      id: json['id'],
      employeeCode: json['employeeCode'],
      monthlySalary: json['monthlySalary'],
      user: json['user'] != null
          ? SalaryUser.fromJson(json['user'])
          : null,
      pfEnabled: json['pfEnabled'],
      taxEnabled: json['taxEnabled'],
      employeeTaxEnabled: json['employeeTaxEnabled'],
      overtimeEnabled: json['overtimeEnabled'],
      bonusEnabled: json['bonusEnabled'],
      overtimeRatePerHour: json['overtimeRatePerHour'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeCode': employeeCode,
      'monthlySalary': monthlySalary,
      'user': user?.toJson(),
      'pfEnabled': pfEnabled,
      'taxEnabled': taxEnabled,
      'employeeTaxEnabled': employeeTaxEnabled,
      'overtimeEnabled': overtimeEnabled,
      'bonusEnabled': bonusEnabled,
      'overtimeRatePerHour': overtimeRatePerHour,
    };
  }
}

class SalaryUser {
  final String? id;
  final String? name;
  final String? email;
  final String? role;

  SalaryUser({
    this.id,
    this.name,
    this.email,
    this.role,
  });

  factory SalaryUser.fromJson(Map<String, dynamic> json) {
    return SalaryUser(
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

class SalaryPeriod {
  final int? year;
  final int? month;
  final num? overtimeHours;

  SalaryPeriod({
    this.year,
    this.month,
    this.overtimeHours,
  });

  factory SalaryPeriod.fromJson(Map<String, dynamic> json) {
    return SalaryPeriod(
      year: json['year'],
      month: json['month'],
      overtimeHours: json['overtimeHours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'overtimeHours': overtimeHours,
    };
  }
}

class SalaryComponent {
  final String? key;
  final String? label;
  final num? amount;
  final String? kind;
  final bool? enabled;

  SalaryComponent({
    this.key,
    this.label,
    this.amount,
    this.kind,
    this.enabled,
  });

  factory SalaryComponent.fromJson(Map<String, dynamic> json) {
    return SalaryComponent(
      key: json['key'],
      label: json['label'],
      amount: json['amount'],
      kind: json['kind'],
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'amount': amount,
      'kind': kind,
      'enabled': enabled,
    };
  }
}