import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { todo, inProgress, done, cancelled }

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.leadTitle,
    required this.dueLabel,
    required this.priority,
    required this.status,
    required this.assignedToName,
  });

  final String id;
  final String title;
  final String description;
  final String leadTitle;
  final String dueLabel;
  final TaskPriority priority;
  final TaskStatus status;
  final String assignedToName;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      leadTitle: (json['lead'] is Map)
          ? (json['lead']['title']?.toString() ?? '')
          : '',
      dueLabel: _formatDue(json['dueDate']?.toString()),
      priority: _priorityFromApi(json['priority']?.toString()),
      status: _statusFromApi(json['status']?.toString()),
      assignedToName: (json['assignedTo'] is Map)
          ? (json['assignedTo']['name']?.toString() ?? '')
          : '',
    );
  }

  TaskModel copyWith({TaskStatus? status}) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      leadTitle: leadTitle,
      dueLabel: dueLabel,
      priority: priority,
      status: status ?? this.status,
      assignedToName: assignedToName,
    );
  }

  String get apiStatus {
    switch (status) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.done:
        return 'DONE';
      case TaskStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.high:
        return 'HIGH';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.low:
        return 'LOW';
    }
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.todo:
        return 'To-do';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.done:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData get icon {
    switch (status) {
      case TaskStatus.done:
        return Icons.check_rounded;
      case TaskStatus.cancelled:
        return Icons.close_rounded;
      case TaskStatus.inProgress:
        return Icons.timelapse_rounded;
      case TaskStatus.todo:
        return Icons.assignment_outlined;
    }
  }

  Color get iconColor {
    switch (status) {
      case TaskStatus.done:
        return const Color(0xFF2E9B6B);
      case TaskStatus.cancelled:
        return const Color(0xFF8A9391);
      case TaskStatus.inProgress:
        return const Color(0xFF1E88E5);
      case TaskStatus.todo:
        return const Color(0xFF5B6CFF);
    }
  }

  Color get iconBg {
    switch (status) {
      case TaskStatus.done:
        return const Color(0xFFE4F6EE);
      case TaskStatus.cancelled:
        return const Color(0xFFEEF1F0);
      case TaskStatus.inProgress:
        return const Color(0xFFE8F3FC);
      case TaskStatus.todo:
        return const Color(0xFFE8ECFF);
    }
  }

  static TaskPriority _priorityFromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'HIGH':
        return TaskPriority.high;
      case 'LOW':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  static TaskStatus _statusFromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'DONE':
        return TaskStatus.done;
      case 'CANCELLED':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.todo;
    }
  }

  static String _formatDue(String? iso) {
    if (iso == null || iso.isEmpty) return '--';
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return '--';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
