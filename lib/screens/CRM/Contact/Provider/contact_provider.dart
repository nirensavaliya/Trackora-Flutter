import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:trackora/core/constants/api_constants.dart';
import 'package:trackora/core/constants/api_service.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/data/models/contact_model.dart';

class ContactProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isCreatingContact = false;
  bool isDeletingContact = false;
  String? errorMessage;
  ContactModel? contactModel;

  final GlobalKey<FormState> contactFormKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  bool isUpdatingContact = false;
  String get token => GetStorageData.readString(GetStorageData.token) ?? '';

  Future<void> getContact() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService().getRequest(
        ApiConstants.contact,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('CONTACT STATUS = ${response.statusCode}');

      debugPrint('CONTACT RESPONSE = ${response.data}');

      if (response.statusCode == 200) {
        contactModel = ContactModel.fromJson(response.data);

        debugPrint(
          'CONTACT COUNT = '
          '${contactModel?.data.length ?? 0}',
        );
      } else {
        contactModel = null;

        errorMessage = response.statusMessage ?? 'Unable to fetch contacts';
      }
    } on DioException catch (e) {
      debugPrint('CONTACT DIO ERROR = ${e.message}');

      debugPrint('CONTACT STATUS = ${e.response?.statusCode}');

      debugPrint('CONTACT RESPONSE = ${e.response?.data}');

      errorMessage =
          _messageFromBody(e.response?.data) ?? 'Unable to fetch contacts';

      contactModel = null;
    } catch (e) {
      debugPrint('CONTACT ERROR = $e');

      errorMessage = e.toString().replaceFirst('Exception: ', '');

      contactModel = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createContact() async {
    final form = contactFormKey.currentState;

    if (form == null) {
      errorMessage = 'Form is not initialized.';
      notifyListeners();
      return false;
    }

    if (!form.validate()) {
      return false;
    }

    isCreatingContact = true;
    errorMessage = null;

    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'companyName': companyController.text.trim(),
        'notes': notesController.text.trim(),
      };

      debugPrint('CREATE CONTACT DATA = $data');

      final response = await ApiService().postRequest(
        ApiConstants.contact,
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        'CREATE CONTACT STATUS = '
        '${response.statusCode}',
      );

      debugPrint(
        'CREATE CONTACT RESPONSE = '
        '${response.data}',
      );

      if (response.statusCode == 201) {
        debugPrint('CONTACT CREATED SUCCESSFULLY');
        resetContactForm();
        await getContact();

        isCreatingContact = false;

        notifyListeners();

        return true;
      }

      errorMessage =
          _messageFromBody(response.data) ?? 'Unable to create contact';

      isCreatingContact = false;

      notifyListeners();

      return false;
    } on DioException catch (e) {
      debugPrint('CREATE CONTACT DIO ERROR = ${e.message}');

      debugPrint(
        'CREATE CONTACT STATUS = '
        '${e.response?.statusCode}',
      );

      debugPrint(
        'CREATE CONTACT RESPONSE = '
        '${e.response?.data}',
      );

      errorMessage =
          _messageFromBody(e.response?.data) ?? 'Unable to create contact';

      isCreatingContact = false;

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint('CREATE CONTACT ERROR = $e');

      errorMessage = e.toString().replaceFirst('Exception: ', '');

      isCreatingContact = false;

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateContact({required String contactId}) async {
    final form = contactFormKey.currentState;

    if (form == null) {
      errorMessage = 'Form is not initialized.';
      notifyListeners();
      return false;
    }

    if (!form.validate()) {
      return false;
    }

    isUpdatingContact = true;
    errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'companyName': companyController.text.trim(),
        'notes': notesController.text.trim(),
      };

      debugPrint('UPDATE CONTACT ID = $contactId');
      debugPrint('UPDATE CONTACT DATA = $data');

      final response = await ApiService().patchRequest(
        '${ApiConstants.contact}/$contactId',
        data: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint(
        'UPDATE CONTACT STATUS = ${response.statusCode}',
      );

      debugPrint(
        'UPDATE CONTACT RESPONSE = ${response.data}',
      );

      if (response.statusCode == 200) {
        debugPrint('CONTACT UPDATED SUCCESSFULLY');

        await getContact();

        isUpdatingContact = false;
        resetContactForm();

        return true;
      }

      errorMessage =
          _messageFromBody(response.data) ?? 'Unable to update contact';

      isUpdatingContact = false;
      notifyListeners();

      return false;
    } on DioException catch (e) {
      debugPrint('UPDATE CONTACT DIO ERROR = ${e.message}');
      debugPrint('UPDATE CONTACT STATUS = ${e.response?.statusCode}');
      debugPrint('UPDATE CONTACT RESPONSE = ${e.response?.data}');

      errorMessage =
          _messageFromBody(e.response?.data) ?? 'Unable to update contact';

      isUpdatingContact = false;
      notifyListeners();

      return false;
    } catch (e) {
      debugPrint('UPDATE CONTACT ERROR = $e');

      errorMessage = e.toString().replaceFirst('Exception: ', '');

      isUpdatingContact = false;
      notifyListeners();

      return false;
    }
  }
  Future<bool> deleteContact({required String contactId}) async {
    isDeletingContact = true;
    errorMessage = null;

    notifyListeners();

    try {
      final url = '${ApiConstants.contact}/$contactId';

      debugPrint('DELETE CONTACT URL = $url');

      final response = await ApiService().deleteRequest(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('DELETE CONTACT STATUS = ${response.statusCode}');

      debugPrint('DELETE CONTACT RESPONSE = ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('CONTACT DELETED SUCCESSFULLY');
        await getContact();

        isDeletingContact = false;
        notifyListeners();

        return true;
      }

      errorMessage =
          _messageFromBody(response.data) ?? 'Unable to delete contact';

      isDeletingContact = false;
      notifyListeners();

      return false;
    } on DioException catch (e) {
      debugPrint('DELETE CONTACT DIO ERROR = ${e.message}');

      debugPrint('DELETE CONTACT STATUS = ${e.response?.statusCode}');

      debugPrint('DELETE CONTACT RESPONSE = ${e.response?.data}');

      errorMessage =
          _messageFromBody(e.response?.data) ?? 'Unable to delete contact';

      isDeletingContact = false;
      notifyListeners();

      return false;
    } catch (e) {
      debugPrint('DELETE CONTACT ERROR = $e');

      errorMessage = e.toString().replaceFirst('Exception: ', '');

      isDeletingContact = false;
      notifyListeners();

      return false;
    }
  }

  void resetContactForm() {
    nameController.clear();
    companyController.clear();
    emailController.clear();
    phoneController.clear();
    notesController.clear();

    errorMessage = null;
    isCreatingContact = false;

    notifyListeners();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateCompany(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Company is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final email = value.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone is required';
    }

    if (value.trim().length < 10) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  String? _messageFromBody(dynamic body) {
    if (body is Map) {
      final message = body['message'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    notesController.dispose();

    super.dispose();
  }
}
