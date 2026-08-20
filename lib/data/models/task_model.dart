import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, completed }

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.priority,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String id;
  final String title;
  final String category;
  final String time;
  final TaskPriority priority;
  final TaskStatus status;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}
