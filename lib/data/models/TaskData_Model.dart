class TaskDataResponse {
  final bool? success;
  final List<Task>? data;

  TaskDataResponse({
    this.success,
    this.data,
  });

  factory TaskDataResponse.fromJson(Map<String, dynamic> json) {
    return TaskDataResponse(
      success: json['success'],
      data: json['data'] != null
          ? List<Task>.from(
        json['data'].map((x) => Task.fromJson(x)),
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

class Task {
  final String? id;
  final String? title;
  final String? description;
  final String? status;
  final String? priority;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? assignedToId;
  final String? assignedById;
  final String? leadId;
  final String? tenantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AssignedUser? assignedTo;
  final AssignedUser? assignedBy;
  final TaskLead? lead;

  Task({
    this.id,
    this.title,
    this.description,
    this.status,
    this.priority,
    this.dueDate,
    this.completedAt,
    this.assignedToId,
    this.assignedById,
    this.leadId,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.assignedTo,
    this.assignedBy,
    this.lead,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      assignedToId: json['assignedToId'],
      assignedById: json['assignedById'],
      leadId: json['leadId'],
      tenantId: json['tenantId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      assignedTo: json['assignedTo'] != null
          ? AssignedUser.fromJson(json['assignedTo'])
          : null,
      assignedBy: json['assignedBy'] != null
          ? AssignedUser.fromJson(json['assignedBy'])
          : null,
      lead: json['lead'] != null
          ? TaskLead.fromJson(json['lead'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'assignedToId': assignedToId,
      'assignedById': assignedById,
      'leadId': leadId,
      'tenantId': tenantId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'assignedTo': assignedTo?.toJson(),
      'assignedBy': assignedBy?.toJson(),
      'lead': lead?.toJson(),
    };
  }
}

class AssignedUser {
  final String? id;
  final String? name;
  final String? email;
  final String? role;

  AssignedUser({
    this.id,
    this.name,
    this.email,
    this.role,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    return AssignedUser(
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

class TaskLead {
  final String? id;
  final String? title;
  final String? status;

  TaskLead({
    this.id,
    this.title,
    this.status,
  });

  factory TaskLead.fromJson(Map<String, dynamic> json) {
    return TaskLead(
      id: json['id'],
      title: json['title'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}