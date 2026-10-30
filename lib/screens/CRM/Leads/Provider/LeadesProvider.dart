import 'package:flutter/material.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/Leads_Model.dart';
import 'package:trackora/data/models/People_model.dart';
import 'package:trackora/data/models/contact_model.dart';
class LeadProvider extends ChangeNotifier {
  bool isLoading = false;
  /// List fetch only — used for full-screen overlay (like Attendance).
  bool isListLoading = false;
  String? errorMessage;
  bool isDeleting = false;
  String? deletingLeadId;
  LeadModel? leadModel;
  UserModel? userModel;
  ContactModel? contactModel;

  String get token =>
      GetStorageData.readString(GetStorageData.token) ?? '';

  TextEditingController titleController = TextEditingController();

  TextEditingController sourceController = TextEditingController();

  TextEditingController notesController = TextEditingController();
   GlobalKey<FormState> leadFormKey = GlobalKey<FormState>();

  String selectedLeadStatus = 'NEW';

  String? selectedContactId;

  String? selectedAssignedId;

  final List<String> statusList = [
    'NEW',
    'CONTACTED',
    'QUALIFIED',
    'LOST',
  ];
  Future<void> getLeads() async {
    isListLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().getRequest(
        ApiConstants.leads,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'LEADS STATUS = ${response.statusCode}',
      );

      debugPrint(
        'LEADS RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        leadModel = LeadModel.fromJson(
          response.data,
        );

        debugPrint(
          'LEADS COUNT = ${leadModel?.data.length ?? 0}',
        );
      } else {
        leadModel = null;
      }
    } catch (e) {
      debugPrint(
        'LEADS ERROR = $e',
      );

      errorMessage = e.toString();
      leadModel = null;
    } finally {
      isListLoading = false;
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

  Future<void> getContact() async {
    try {
      final response = await ApiService().getRequest(
        ApiConstants.contact,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'CONTACT STATUS = ${response.statusCode}',
      );

      debugPrint(
        'CONTACT RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        contactModel = ContactModel.fromJson(
          response.data,
        );

        debugPrint(
          'CONTACT COUNT = ${contactModel?.data.length ?? 0}',
        );
      } else {
        contactModel = null;
      }
    } catch (e) {
      debugPrint(
        'CONTACT ERROR = $e',
      );

      contactModel = null;
    } finally {
      notifyListeners();
    }
  }
  void setLeadStatus(String? value) {
    if (value == null) return;

    selectedLeadStatus = value;

    notifyListeners();
  }


  void setContact(String? value) {
    selectedContactId = value;

    notifyListeners();
  }

  void setAssignedUser(String? value) {
    selectedAssignedId = value;

    notifyListeners();
  }

  void resetLeadForm() {
    titleController.clear();
    sourceController.clear();
    notesController.clear();

    selectedLeadStatus = 'NEW';
    selectedContactId = null;
    selectedAssignedId = null;

    errorMessage = null;
    isLoading = false;

    notifyListeners();
  }

  Future<bool> createLead() async {
    final form = leadFormKey.currentState;

    if (form == null) {
      errorMessage = 'Form is not initialized.';
      notifyListeners();
      return false;
    }

    if (!form.validate()) {
      return false;
    }

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'title': titleController.text.trim(),
        'status': selectedLeadStatus,
        'source': sourceController.text.trim(),
        'notes': notesController.text.trim(),
      };
      if (selectedContactId != null &&
          selectedContactId!.trim().isNotEmpty) {
        data['contactId'] = selectedContactId!.trim();
      }
      if (selectedAssignedId != null &&
          selectedAssignedId!.trim().isNotEmpty) {
        data['assignedToId'] = selectedAssignedId!.trim();
      }

      debugPrint(
        'CREATE LEAD DATA = $data',
      );

      final response = await ApiService().postRequest(
        ApiConstants.leads,
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        'CREATE LEAD STATUS = ${response.statusCode}',
      );

      debugPrint(
        'CREATE LEAD RESPONSE = ${response.data}',
      );


      if (response.statusCode == 201) {
        debugPrint(
          'LEAD CREATED SUCCESSFULLY',
        );

        await getLeads();
        titleController.clear();
        sourceController.clear();
        notesController.clear();

        selectedLeadStatus = 'NEW';
        selectedContactId = null;
        selectedAssignedId = null;

        return true;
      }

      if (response.data is Map) {
        final responseData = Map<String, dynamic>.from(response.data);
        errorMessage = responseData['message']?.toString() ?? 'Unable to create lead.';
      } else {
        errorMessage = 'Unable to create lead.';
      }
      debugPrint(
        'CREATE LEAD ERROR = $errorMessage',
      );

      return false;
    } catch (e) {
      debugPrint(
        'CREATE LEAD EXCEPTION = $e',
      );

      errorMessage = e.toString();

      return false;
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
  Future<bool> updateLeadStatus({
    required String leadId,
    required String status,
  }) async {
    errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'status': status,
      };

      debugPrint('======================================');
      debugPrint('UPDATE LEAD STATUS');
      debugPrint('LEAD ID = $leadId');
      debugPrint('STATUS = $status');
      debugPrint('REQUEST DATA = $data');
      debugPrint('======================================');

      final response = await ApiService().patchRequest(
        '${ApiConstants.leads}/$leadId',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('PATCH STATUS CODE = ${response.statusCode}');
      debugPrint('PATCH STATUS RESPONSE = ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('LEAD STATUS UPDATED');

        await getLeads();

        return true;
      }

      if (response.data is Map) {
        final responseData =
        Map<String, dynamic>.from(response.data);

        errorMessage =
            responseData['message']?.toString() ??
                'Unable to update lead status.';
      } else {
        errorMessage = 'Unable to update lead status.';
      }

      return false;
    } catch (e) {
      debugPrint('PATCH STATUS EXCEPTION = $e');

      errorMessage = e.toString();

      return false;
    } finally {
      notifyListeners();
    }
  }
  Future<bool> updateLeadAssignment({
    required String leadId,
    required String? assignedToId,
  }) async {
    errorMessage = null;

    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'assignedToId': assignedToId,
      };

      debugPrint('======================================');
      debugPrint('UPDATE LEAD ASSIGNMENT');
      debugPrint('LEAD ID = $leadId');
      debugPrint('ASSIGNED TO ID = $assignedToId');
      debugPrint('REQUEST DATA = $data');
      debugPrint('======================================');

      final response = await ApiService().patchRequest(
        '${ApiConstants.leads}/$leadId',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('PATCH ASSIGNMENT STATUS = ${response.statusCode}',);

      debugPrint('PATCH ASSIGNMENT RESPONSE = ${response.data}',);

      if (response.statusCode == 200) {
        debugPrint('LEAD ASSIGNMENT UPDATED');
        await getLeads();
        return true;
      }

      if (response.data is Map) {
        final responseData =
        Map<String, dynamic>.from(response.data);

        errorMessage =
            responseData['message']?.toString() ??
                'Unable to update lead assignment.';
      } else {
        errorMessage = 'Unable to update lead assignment.';
      }

      return false;
    } catch (e) {
      debugPrint(
        'PATCH ASSIGNMENT EXCEPTION = $e',
      );

      errorMessage = e.toString();

      return false;
    } finally {
      notifyListeners();
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
      debugPrint('======================================');
      debugPrint('DELETE LEAD');
      debugPrint('LEAD ID = $leadId');
      debugPrint('======================================');

      final response = await ApiService().deleteRequest(
        '${ApiConstants.leads}/$leadId',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        'DELETE LEAD STATUS = ${response.statusCode}',
      );

      debugPrint(
        'DELETE LEAD RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        debugPrint('LEAD DELETED SUCCESSFULLY');

        await getLeads();

        return true;
      }

      if (response.data is Map) {
        final responseData =
        Map<String, dynamic>.from(response.data);

        errorMessage =
            responseData['message']?.toString() ??
                'Unable to delete lead.';
      } else {
        errorMessage = 'Unable to delete lead.';
      }

      return false;
    } catch (e) {
      debugPrint(
        'DELETE LEAD EXCEPTION = $e',
      );

      errorMessage = e.toString();

      return false;
    } finally {
      isDeleting = false;
      deletingLeadId = null;

      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    sourceController.dispose();
    notesController.dispose();

    super.dispose();
  }
}