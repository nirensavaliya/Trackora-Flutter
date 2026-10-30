import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/core/widgets/app_dialog.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/core/widgets/common_textfild.dart';
import 'package:trackora/screens/CRM/Contact/Provider/contact_provider.dart';

import '../../../core/widgets/workforce_app_bar.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      // appBar: CommonAppBar(title: "Contact", showBackButton: true),
      appBar: WorkforceAppBar(
        title: 'Contact',
        actionLabel: 'New Contact',
        onTap:    () {
          final provider = context.read<ContactProvider>();

          provider.resetContactForm();

          _showContactDialog(context, provider);
          } ,
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, child) {
          final contacts = provider.contactModel?.data ?? [];

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Text(
                      'CONTACTS DIRECTORY (${contacts.length})',
                      style: const TextStyle(
                        fontFamily: 'Inter_SemiBold',
                        fontSize: 12,
                        letterSpacing: 0.6,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: contacts.isEmpty
                        ? provider.isLoading
                            ? const SizedBox.shrink()
                            : const Center(
                                child: Text(
                                  'No contacts found',
                                  style: TextStyle(
                                    fontFamily: 'Inter_Medium',
                                    fontSize: 15,
                                    color: Color(0xff718080),
                                  ),
                                ),
                              )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              final contact = contacts[index];
                              return _contactCard(context, provider, contact);
                            },
                          ),
                  ),
                ],
              ),
              if (provider.isLoading) const AppLoaderOverlay(),
            ],
          );
        },
      ),
    );
  }

  void _showContactDialog(
    BuildContext context,
    ContactProvider provider, {
    dynamic contact,
  }) {
    final bool isEdit = contact != null;

    if (isEdit) {
      provider.nameController.text = contact.name ?? '';
      provider.companyController.text = contact.companyName ?? '';
      provider.emailController.text = contact.email ?? '';
      provider.phoneController.text = contact.phone ?? '';
      provider.notesController.text = contact.notes ?? '';
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: Consumer<ContactProvider>(
            builder: (context, provider, child) {
              final userRole = GetStorageData.readString(
                GetStorageData.userType,
              )?.toUpperCase();

              final isUserRole = userRole == 'USER';
              final busy =
                  provider.isCreatingContact || provider.isUpdatingContact;

              return AppDialogShell(
                title: isEdit ? 'Edit contact' : 'New contact',
                child: SingleChildScrollView(
                  child: Form(
                    key: provider.contactFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppDialogLabel('Name'),
                        const SizedBox(height: 6),
                        CommonTextField(
                          controller: provider.nameController,
                          hintText: 'Enter Contact name',
                          fontSize: 15,
                          borderRadius: 12,
                          prefix: const Icon(Icons.person_outline_rounded),
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.text,
                          validator: provider.validateName,
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Company'),
                        const SizedBox(height: 6),
                        CommonTextField(
                          controller: provider.companyController,
                          hintText: 'Enter Company Name',
                          fontSize: 15,
                          borderRadius: 12,
                          prefix: const Icon(Icons.business_outlined),
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.text,
                          validator: provider.validateCompany,
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Email'),
                        const SizedBox(height: 6),
                        CommonTextField(
                          controller: provider.emailController,
                          hintText: 'Enter email address',
                          fontSize: 15,
                          borderRadius: 12,
                          prefix: const Icon(Icons.email_outlined),
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.emailAddress,
                          validator: provider.validateEmail,
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Phone'),
                        const SizedBox(height: 6),
                        CommonTextField(
                          controller: provider.phoneController,
                          hintText: 'Enter phone number',
                          fontSize: 15,
                          borderRadius: 12,
                          prefix: const Icon(Icons.phone_outlined),
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.phone,
                          validator: provider.validatePhone,
                        ),
                        if (!isUserRole) ...[
                          const SizedBox(height: 14),
                          const AppDialogLabel('Notes'),
                          const SizedBox(height: 6),
                          CommonTextField(
                            controller: provider.notesController,
                            hintText: 'Add notes about this contact',
                            fontSize: 15,
                            borderRadius: 12,
                            maxLine: 3,
                            textInputAction: TextInputAction.done,
                            textInputType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Note is required.';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 18),
                        AppDialogActions(
                          primaryLabel: isEdit ? 'Update' : 'Save',
                          busy: busy,
                          onPrimary: () async {
                            final bool success;

                            if (isEdit) {
                              success = await provider.updateContact(
                                contactId: contact.id,
                              );
                            } else {
                              success = await provider.createContact();
                            }
                            if (!context.mounted) {
                              return;
                            }
                            if (success) {
                              Navigator.pop(dialogContext);
                              Fluttertoast.showToast(
                                msg: isEdit
                                    ? 'Contact updated successfully'
                                    : 'Contact created successfully',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: AppColors.appColor,
                                textColor: Colors.white,
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: provider.errorMessage ??
                                    (isEdit
                                        ? 'Unable to update contact'
                                        : 'Unable to create contact'),
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _contactCard(
    BuildContext context,
    ContactProvider provider,
    dynamic contact,
  ) {
    final company = (contact.companyName ?? '').toString().trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EEF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFDDF6EE),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initial(contact.name),
                  style: const TextStyle(
                    fontFamily: 'Inter_Bold',
                    fontSize: 18,
                    color: Color(0xFF1F6B63),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name.isEmpty ? '—' : contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter_Bold',
                        fontSize: 16,
                        color: Color(0xff111827),
                      ),
                    ),
                    if (company.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter_Regular',
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _iconAction(
                icon: Icons.edit_outlined,
                color: AppColors.appColor,
                background: const Color(0xFFE7F8F1),
                border: const Color(0xFFB7E4D4),
                onTap: provider.isUpdatingContact
                    ? null
                    : () {
                        _showContactDialog(
                          context,
                          provider,
                          contact: contact,
                        );
                      },
              ),
              const SizedBox(width: 8),
              _iconAction(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFEF4444),
                background: const Color(0xFFFFF1F2),
                border: const Color(0xFFFECACA),
                onTap: provider.isDeletingContact
                    ? null
                    : () {
                        _showDeleteDialog(context, provider, contact);
                      },
              ),
            ],
          ),
          const SizedBox(height: 14),
          _contactLine(
            icon: Icons.email_outlined,
            value: contact.email,
          ),
          const SizedBox(height: 8),
          _contactLine(
            icon: Icons.phone_outlined,
            value: contact.phone,
          ),
          if (contact.notes != null &&
              contact.notes.toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _contactLine(
              icon: Icons.notes_rounded,
              value: contact.notes,
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required Color background,
    required Color border,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Icon(icon, size: 18, color: onTap == null ? color.withValues(alpha: 0.4) : color),
        ),
      ),
    );
  }

  Widget _contactLine({
    required IconData icon,
    required String? value,
  }) {
    final text = value == null || value.trim().isEmpty ? '—' : value;
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter_Medium',
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    ContactProvider provider,
    dynamic contact,
  ) async {
    final confirm = await showAppConfirmDialog(
      context: context,
      title: 'Delete contact?',
      message:
          'Are you sure you want to delete '
          '"${contact.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: Colors.red,
    );

    if (confirm != true) return;

    final success = await provider.deleteContact(contactId: contact.id);

    if (!context.mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'Contact deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.appColor,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: provider.errorMessage ?? 'Unable to delete contact',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  String _initial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'C';
    }

    return name.trim().substring(0, 1).toUpperCase();
  }
}
