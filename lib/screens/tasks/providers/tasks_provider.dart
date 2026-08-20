import 'package:flutter/material.dart';
import 'package:trackora/data/models/task_model.dart';

enum TasksTab { all, pending, completed }

class TasksProvider extends ChangeNotifier {
  TasksTab selectedTab = TasksTab.all;

  final List<TaskModel> tasks = const [
    TaskModel(
      id: '1',
      title: 'Follow up with RedApple Store',
      category: 'Customer Visit',
      time: '10:30 AM',
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      icon: Icons.storefront_outlined,
      iconColor: Color(0xFF5B6CFF),
      iconBg: Color(0xFFE8ECFF),
    ),
    TaskModel(
      id: '2',
      title: 'Prepare monthly review',
      category: 'Office Task',
      time: '02:00 PM',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      icon: Icons.calendar_month_outlined,
      iconColor: Color(0xFF9B6BFF),
      iconBg: Color(0xFFF1E8FF),
    ),
    TaskModel(
      id: '3',
      title: 'Complete store audit',
      category: 'Customer Visit',
      time: 'Yesterday',
      priority: TaskPriority.low,
      status: TaskStatus.completed,
      icon: Icons.check_rounded,
      iconColor: Color(0xFF2E9B6B),
      iconBg: Color(0xFFE4F6EE),
    ),
  ];

  int get allCount => tasks.length;

  int get pendingCount =>
      tasks.where((t) => t.status == TaskStatus.pending).length;

  int get completedCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  List<TaskModel> get visibleTasks {
    switch (selectedTab) {
      case TasksTab.all:
        return tasks;
      case TasksTab.pending:
        return tasks.where((t) => t.status == TaskStatus.pending).toList();
      case TasksTab.completed:
        return tasks.where((t) => t.status == TaskStatus.completed).toList();
    }
  }

  void selectTab(TasksTab tab) {
    if (selectedTab == tab) return;
    selectedTab = tab;
    notifyListeners();
  }
}
