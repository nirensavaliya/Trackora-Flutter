import 'package:flutter/material.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/task_model.dart';

enum TasksTab { all, open, completed }

class TasksProvider extends ChangeNotifier {
  TasksTab selectedTab = TasksTab.all;
  List<TaskModel> tasks = [];
  bool loading = false;
  bool updating = false;
  String? error;
  String? updatingTaskId;

  Map<String, String>? _authHeaders() {
    final token = GetStorageData.readString(GetStorageData.token)?.toString();
    if (token == null || token.isEmpty) return null;
    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  int get allCount => tasks.length;

  int get pendingCount => tasks
      .where(
        (t) =>
            t.status == TaskStatus.todo || t.status == TaskStatus.inProgress,
      )
      .length;

  int get completedCount =>
      tasks.where((t) => t.status == TaskStatus.done).length;

  List<TaskModel> get visibleTasks {
    switch (selectedTab) {
      case TasksTab.all:
        return tasks;
      case TasksTab.open:
        return tasks
            .where(
              (t) =>
                  t.status == TaskStatus.todo ||
                  t.status == TaskStatus.inProgress,
            )
            .toList();
      case TasksTab.completed:
        return tasks.where((t) => t.status == TaskStatus.done).toList();
    }
  }

  void selectTab(TasksTab tab) {
    if (selectedTab == tab) return;
    selectedTab = tab;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    final headers = _authHeaders();
    if (headers == null) {
      error = 'Please login again';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService().getRequest(
        ApiConstants.tasks,
        headers: headers,
      );
      final body = response.data;
      print('TASKS STATUS: ${response.statusCode}');
      print('TASKS BODY: $body');

      if (body is Map && body['success'] == true && body['data'] is List) {
        tasks = (body['data'] as List)
            .whereType<Map>()
            .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        error = null;
      } else {
        final msg = body is Map
            ? (body['message']?.toString() ?? 'Could not load tasks')
            : 'Could not load tasks';
        error = msg;
      }
    } catch (e) {
      print('TASKS ERROR: $e');
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String taskId, TaskStatus status) async {
    final headers = _authHeaders();
    if (headers == null) {
      error = 'Please login again';
      notifyListeners();
      return false;
    }

    updating = true;
    updatingTaskId = taskId;
    notifyListeners();

    try {
      final payload = {'status': _apiStatus(status)};
      print('TASK STATUS UPDATE: $taskId $payload');
      final response = await ApiService().patchRequest(
        '${ApiConstants.tasks}/$taskId',
        headers: headers,
        data: payload,
      );
      final body = response.data;
      print('TASK PATCH STATUS: ${response.statusCode}');
      print('TASK PATCH BODY: $body');

      if (body is Map && body['success'] == true) {
        if (body['data'] is Map) {
          final updated = TaskModel.fromJson(
            Map<String, dynamic>.from(body['data'] as Map),
          );
          tasks = [
            for (final task in tasks)
              if (task.id == taskId) updated else task,
          ];
        } else {
          tasks = [
            for (final task in tasks)
              if (task.id == taskId) task.copyWith(status: status) else task,
          ];
        }
        return true;
      }

      error = body is Map
          ? (body['message']?.toString() ?? 'Could not update status')
          : 'Could not update status';
      return false;
    } catch (e) {
      print('TASK PATCH ERROR: $e');
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      updating = false;
      updatingTaskId = null;
      notifyListeners();
    }
  }

  String _apiStatus(TaskStatus status) {
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
}
