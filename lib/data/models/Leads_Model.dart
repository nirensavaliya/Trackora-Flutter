class LeadModel {
  final bool success;
  final List<Lead> data;

  LeadModel({
    required this.success,
    required this.data,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Lead.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class Lead {
  final String id;
  final String title;
  final String status;
  final String? source;
  final String? notes;
  final String? contactId;
  final String? assignedToId;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Contact? contact;
  final AssignedTo? assignedTo;

  Lead({
    required this.id,
    required this.title,
    required this.status,
    this.source,
    this.notes,
    this.contactId,
    this.assignedToId,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    this.contact,
    this.assignedTo,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      source: json['source'],
      notes: json['notes'],
      contactId: json['contactId'],
      assignedToId: json['assignedToId'],
      tenantId: json['tenantId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      contact: json['contact'] != null
          ? Contact.fromJson(json['contact'])
          : null,
      assignedTo: json['assignedTo'] != null
          ? AssignedTo.fromJson(json['assignedTo'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'source': source,
      'notes': notes,
      'contactId': contactId,
      'assignedToId': assignedToId,
      'tenantId': tenantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'contact': contact?.toJson(),
      'assignedTo': assignedTo?.toJson(),
    };
  }
}

class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String companyName;
  final String? notes;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.companyName,
    this.notes,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      companyName: json['companyName'] ?? '',
      notes: json['notes'],
      tenantId: json['tenantId'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'notes': notes,
      'tenantId': tenantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AssignedTo {
  final String id;
  final String name;
  final String email;

  AssignedTo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
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