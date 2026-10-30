import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/Leads_Model.dart';
import 'package:trackora/data/models/People_model.dart';
import 'package:trackora/data/models/TaskData_Model.dart';


class TaskProvider extends ChangeNotifier{
  bool isLoading = false;
  String? errorMessage;
  bool isDeleting = false;
  String? deletingLeadId;

  TaskDataResponse? taskDataResponse;
  UserModel? userModel;
  LeadModel? leadModel;
  bool isCreatingTask = false;
  String? selectedPersonId;
  String selectedPerson = 'All people';
  String get token => GetStorageData.readString(GetStorageData.token) ?? '';
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedTaskAssignedId;
  String? selectedTaskLeadId;
  String selectedTaskPriority = 'MEDIUM';
  String selectedTaskStatus = 'TODO';
  DateTime selectedTaskDueDate = DateTime.now();
  final GlobalKey<FormState> taskFormKey = GlobalKey<FormState>();
  final List<String> priorityList = [
    'LOW',
    'MEDIUM',
    'HIGH',
  ];

  Future<void> getTaskSummary({String? assignedToId}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String url = ApiConstants.task;

      if (assignedToId != null && assignedToId.isNotEmpty) {
        url =
        '${ApiConstants.task}?assignedToId=${Uri.encodeQueryComponent(assignedToId)}';
      }

      debugPrint('TASK API URL = $url');

      final response = await ApiService().getRequest(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      debugPrint('TASK SUMMARY STATUS = ${response.statusCode}',);
      debugPrint('TASK SUMMARY RESPONSE = ${response.data}',);
      if (response.statusCode == 200) {
        taskDataResponse = TaskDataResponse.fromJson(
          response.data,
        );
        debugPrint('TASK SUMMARY LOADED SUCCESSFULLY',);
      } else {
        taskDataResponse = null;

        errorMessage =
            response.statusMessage ??
                'Unable to fetch task summary';
      }
    } on DioException catch (e) {
      debugPrint(
        'TASK SUMMARY DIO ERROR = ${e.message}',
      );

      debugPrint(
        'TASK SUMMARY STATUS = ${e.response?.statusCode}',
      );

      debugPrint(
        'TASK SUMMARY RESPONSE = ${e.response?.data}',
      );

      if (e.response != null) {
        errorMessage =
            _messageFromBody(e.response?.data) ??
                'Unable to fetch task summary';
      } else {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            errorMessage =
            'Connection timeout. Please try again.';
            break;

          case DioExceptionType.sendTimeout:
            errorMessage =
            'Request timeout. Please try again.';
            break;

          case DioExceptionType.receiveTimeout:
            errorMessage =
            'Server response timeout. Please try again.';
            break;

          case DioExceptionType.connectionError:
            errorMessage =
            'No internet connection.';
            break;

          case DioExceptionType.cancel:
            errorMessage =
            'Request cancelled.';
            break;

          default:
            errorMessage =
            'Something went wrong. Please try again.';
        }
      }

      taskDataResponse = null;
    } catch (e) {
      debugPrint(
        'TASK SUMMARY ERROR = $e',
      );

      errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      taskDataResponse = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPeople() async {
    try {
      final response = await ApiService().getRequest(
        ApiConstants.people,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'PEOPLE STATUS = ${response.statusCode}',
      );

      debugPrint(
        'PEOPLE RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        userModel = UserModel.fromJson(
          response.data,
        );

        debugPrint(
          'PEOPLE COUNT = ${userModel?.data.length ?? 0}',
        );
      } else {
        userModel = null;
      }
    } catch (e) {
      debugPrint(
        'PEOPLE ERROR = $e',
      );

      userModel = null;
    } finally {
      notifyListeners();
    }
  }
  Future<void> getLeads() async {
    try {
      final response = await ApiService().getRequest(
        ApiConstants.leads,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('LEADS STATUS = ${response.statusCode}');
      debugPrint('LEADS RESPONSE = ${response.data}');

      if (response.statusCode == 200) {
        leadModel = LeadModel.fromJson(response.data);

        debugPrint(
          'LEADS COUNT = ${leadModel?.data.length ?? 0}',
        );
      } else {
        leadModel = null;
      }
    } on DioException catch (e) {
      debugPrint('LEADS DIO ERROR = ${e.message}');
      debugPrint('LEADS STATUS = ${e.response?.statusCode}');
      debugPrint('LEADS RESPONSE = ${e.response?.data}');

      leadModel = null;
    } catch (e) {
      debugPrint('LEADS ERROR = $e');

      leadModel = null;
    } finally {
      notifyListeners();
    }
  }
  Future<bool> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final url = '${ApiConstants.task}/$taskId';

      debugPrint('PATCH TASK URL = $url');
      debugPrint('PATCH TASK STATUS = $status');
      final response = await ApiService().patchRequest(
        url,
        data: {'status': status},
        headers: {'Authorization': 'Bearer $token',},
      );

      debugPrint(
        'PATCH STATUS CODE = ${response.statusCode}',
      );

      debugPrint(
        'PATCH STATUS RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        await getTaskSummary(assignedToId: selectedPersonId,);
        return true;
      }
      errorMessage = _messageFromBody(response.data) ?? 'Unable to update task status';

      notifyListeners();

      return false;
    } on DioException catch (e) {
      debugPrint(
        'PATCH TASK ERROR = ${e.message}',
      );

      debugPrint(
        'PATCH TASK STATUS = ${e.response?.statusCode}',
      );

      debugPrint(
        'PATCH TASK RESPONSE = ${e.response?.data}',
      );

      errorMessage =
          _messageFromBody(e.response?.data) ??
              'Unable to update task status';

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint(
        'PATCH TASK ERROR = $e',
      );

      errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteLead({
    required String leadId,
  }) async {
    if (isDeleting) {
      return false;
    }

    isDeleting = true;
    deletingLeadId = leadId;
    errorMessage = null;

    notifyListeners();

    try {
      debugPrint('DELETE LEAD');
      debugPrint('LEAD ID = $leadId');

      final response = await ApiService().deleteRequest(
        '${ApiConstants.task}/$leadId',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        debugPrint('Task DELETED SUCCESSFULLY');

        await getLeads();

        return true;
      }

      if (response.data is Map) {
        final responseData =
        Map<String, dynamic>.from(response.data);

        errorMessage =
            responseData['message']?.toString() ??
                'Unable to delete Task.';
      } else {
        errorMessage = 'Unable to delete Task.';
      }

      return false;
    } catch (e) {
      debugPrint(
        'DELETE Task EXCEPTION = $e',
      );

      errorMessage = e.toString();

      return false;
    } finally {
      isDeleting = false;
      deletingLeadId = null;

      notifyListeners();
    }
  }
  void setTaskAssignedUser(String? value) {
    selectedTaskAssignedId = value;

    notifyListeners();
  }

  void setTaskDueDate(DateTime value) {
    selectedTaskDueDate = value;

    notifyListeners();
  }
  void resetTaskForm() {
    titleController.clear();
    descriptionController.clear();

    selectedTaskAssignedId = null;
    selectedTaskLeadId = null;

    selectedTaskPriority = 'MEDIUM';
    selectedTaskStatus = 'TODO';

    selectedTaskDueDate = DateTime.now();

    errorMessage = null;
    isCreatingTask = false;

    notifyListeners();
  }
  String _formatApiDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }


  Future<bool> createTask() async {
    final form = taskFormKey.currentState;
    if (form == null) {
      errorMessage = 'Form is not initialized.';
      notifyListeners();
      return false;
    }
    if (!form.validate()) {
      return false;
    }
    if (selectedTaskAssignedId == null ||
        selectedTaskAssignedId!.trim().isEmpty) {
      errorMessage = 'Please select a person.';
      notifyListeners();
      return false;
    }

    isCreatingTask = true;
    errorMessage = null;

    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'title': titleController.text.trim(),

        'description':
        descriptionController.text.trim(),

        'status': selectedTaskStatus,

        'priority': selectedTaskPriority,

        'dueDate':
        _formatApiDate(selectedTaskDueDate),

        'assignedToId':
        selectedTaskAssignedId!.trim(),
      };

      if (selectedTaskLeadId != null &&
          selectedTaskLeadId!.trim().isNotEmpty) {
        data['leadId'] =
            selectedTaskLeadId!.trim();
      }
      debugPrint(
        'CREATE TASK DATA = $data',
      );
      final response = await ApiService().postRequest(
        ApiConstants.task,
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      debugPrint(
        'CREATE TASK STATUS = ${response.statusCode}',
      );
      debugPrint(
        'CREATE TASK RESPONSE = ${response.data}',
      );
      if (response.statusCode == 201) {
        debugPrint(
          'TASK CREATED SUCCESSFULLY',
        );
        await getTaskSummary(
          assignedToId: selectedPersonId,
        );
        titleController.clear();
        descriptionController.clear();

        selectedTaskAssignedId = null;
        selectedTaskLeadId = null;

        selectedTaskPriority = 'MEDIUM';
        selectedTaskStatus = 'TODO';

        selectedTaskDueDate = DateTime.now();

        isCreatingTask = false;

        notifyListeners();

        return true;
      }
      errorMessage =
          _messageFromBody(response.data) ??
              'Unable to create task';

      isCreatingTask = false;

      notifyListeners();

      return false;
    } on DioException catch (e) {
      debugPrint(
        'CREATE TASK DIO ERROR = ${e.message}',
      );

      debugPrint(
        'CREATE TASK STATUS = ${e.response?.statusCode}',
      );

      debugPrint(
        'CREATE TASK RESPONSE = ${e.response?.data}',
      );

      errorMessage =
          _messageFromBody(e.response?.data) ??
              'Unable to create task';

      isCreatingTask = false;

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint(
        'CREATE TASK ERROR = $e',
      );

      errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      isCreatingTask = false;

      notifyListeners();

      return false;
    }
  }

  void setTaskLead(String? value) {
    selectedTaskLeadId = value;

    notifyListeners();
  }

  void setTaskPriority(String value) {
    selectedTaskPriority = value;

    notifyListeners();
  }

  String? _messageFromBody(dynamic body) {
    if (body is Map) {
      final message = body['message'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return null;
  }
}