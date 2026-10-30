import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/core/widgets/CommonAppBar.dart';
import 'package:trackora/core/widgets/app_dialog.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/core/widgets/common_textfild.dart';
import 'package:trackora/screens/CRM/Leads/Provider/LeadesProvider.dart';

import '../../../core/widgets/workforce_app_bar.dart';

class LeadView extends StatefulWidget {
  const LeadView({super.key});

  @override
  State<LeadView> createState() => _LeadViewState();
}

class _LeadViewState extends State<LeadView> {
  final Map<String, String> selectedStatus = {};
  final Map<String, String?> selectedAssignedUser = {};
  final List<String> statusList = ['NEW', 'CONTACTED', 'QUALIFIED', 'LOST'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<LeadProvider>();
      provider.getLeads();
      provider.getPeople();
      provider.getContact();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadProvider>(
      builder: (context, provider, child) {
        final leads = provider.leadModel?.data ?? [];
        final people = provider.userModel?.data ?? [];
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: WorkforceAppBar(
            title: 'Leads',
            actionLabel: 'New Lead',
            onTap: () => _showCreateLeadDialog(context, provider),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'TOTAL LEADS (${leads.length})',
                          style: const TextStyle(
                            fontFamily: 'Inter_SemiBold',
                            fontSize: 11,
                            letterSpacing: 0.6,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'STATUS & ASSIGNEE',
                          style: TextStyle(
                            fontFamily: 'Inter_SemiBold',
                            fontSize: 11,
                            letterSpacing: 0.6,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: leads.isEmpty
                        ? provider.isListLoading
                            ? const SizedBox.shrink()
                            : const Center(
                                child: Text(
                                  'No leads found',
                                  style: TextStyle(
                                    fontFamily: 'Inter_Medium',
                                    fontSize: 14,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              )
                        : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          final lead = leads[index];

                          final currentStatus =
                              selectedStatus[lead.id] ?? lead.status;

                          final assignedId =
                              selectedAssignedUser[lead.id] ??
                                  lead.assignedToId;
                          final userRole = GetStorageData.readString(
                                  GetStorageData.userType)
                              ?.toUpperCase();
                          final assignedPerson = people.cast<dynamic>().where((person) {
                            return person.id.toString() == (assignedId ?? '');
                          });
                          final assignedName = assignedPerson.isEmpty
                              ? (lead.assignedTo?.name ?? 'Unassigned')
                              : (assignedPerson.first.name?.toString() ?? 'Unassigned');
                          final assignedRole = assignedPerson.isEmpty
                              ? ''
                              : (assignedPerson.first.role?.toString() ?? '');
                          final assignedLabel = assignedRole.isEmpty
                              ? assignedName
                              : '$assignedName · $assignedRole';

                          return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE6EEF2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                lead.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter_Bold',
                                  fontSize: 16,
                                  color: Color(0xff111827),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusDropdown(
                              value: currentStatus,
                              items: statusList,
                              onChanged: (value) async {
                                if (value == null) return;

                                final oldStatus = lead.status;

                                debugPrint('======================================');
                                debugPrint('STATUS DROPDOWN CHANGED');
                                debugPrint('LEAD ID = ${lead.id}');
                                debugPrint('OLD STATUS = $oldStatus');
                                debugPrint('NEW STATUS = $value');
                                debugPrint('======================================');

                                if (value == oldStatus) {
                                  debugPrint('STATUS SAME - API NOT CALLED');
                                  return;
                                }
                                selectedStatus[lead.id] = value;
                                final success = await provider.updateLeadStatus(
                                  leadId: lead.id,
                                  status: value,
                                );

                                if (!context.mounted) return;

                                if (success) {
                                  debugPrint('STATUS UPDATE SUCCESS');

                                  Fluttertoast.showToast(
                                    msg: 'Lead status updated successfully',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: AppColors.appColor,
                                    textColor: Colors.white,
                                  );
                                } else {
                                  debugPrint('STATUS UPDATE FAILED');
                                  selectedStatus[lead.id] = oldStatus;
                                  Fluttertoast.showToast(
                                    msg: provider.errorMessage ??
                                        'Unable to update lead status',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Source:',
                              style: TextStyle(
                                fontFamily: 'Inter_Medium',
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  lead.source?.isNotEmpty == true
                                      ? lead.source!
                                      : '—',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter_SemiBold',
                                    fontSize: 12,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: Color(0xFFE8EEF2)),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'CONTACT',
                                    style: TextStyle(
                                      fontFamily: 'Inter_SemiBold',
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lead.contact?.name.isNotEmpty == true
                                        ? lead.contact!.name
                                        : '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter_Medium',
                                      fontSize: 13,
                                      color: Color(0xff1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ASSIGNED TO',
                                    style: TextStyle(
                                      fontFamily: 'Inter_SemiBold',
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (userRole == 'USER')
                                    Text(
                                      assignedLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Inter_Medium',
                                        fontSize: 14,
                                        color: Color(0xff1E293B),
                                      ),
                                    )
                                  else
                                    _AssignedDropdown(
                              value: assignedId,
                              people: people,
                              onChanged: (value) async {
                                debugPrint('======================================');
                                debugPrint('ASSIGN DROPDOWN CHANGED');
                                debugPrint('LEAD ID = ${lead.id}');
                                debugPrint('OLD ASSIGNED ID = $assignedId');
                                debugPrint('NEW ASSIGNED ID = $value');
                                debugPrint('======================================');

                                if (value == null) {
                                  debugPrint('ASSIGNED VALUE IS NULL');
                                  return;
                                }

                                if (value == assignedId) {
                                  debugPrint('ASSIGNED USER SAME - API NOT CALLED');
                                  return;
                                }
                                selectedAssignedUser[lead.id] = value;

                                final success = await provider.updateLeadAssignment(
                                  leadId: lead.id,
                                  assignedToId: value,
                                );

                                if (!context.mounted) return;

                                if (success) {
                                  debugPrint('ASSIGNMENT UPDATE SUCCESS');

                                  Fluttertoast.showToast(
                                    msg: 'Lead assigned successfully',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: AppColors.appColor,
                                    textColor: Colors.white,
                                  );
                                } else {
                                  debugPrint('ASSIGNMENT UPDATE FAILED');
                                  selectedAssignedUser[lead.id] = assignedId;
                                  Fluttertoast.showToast(
                                    msg: provider.errorMessage ??
                                        'Unable to update assignment',
                                    toastLength: Toast.LENGTH_LONG,
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
                          ],
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                              final success = await provider.deleteLead(
                                leadId: lead.id,
                              );

                              if (!context.mounted) return;

                              if (success) {
                                Fluttertoast.showToast(
                                  msg: 'Lead deleted successfully',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: AppColors.appColor,
                                  textColor: Colors.white,
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                  provider.errorMessage ??
                                      'Unable to delete lead',
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minimumSize: const Size(72, 32),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                              backgroundColor: const Color(0xFFFFF1F2),
                              side: const BorderSide(
                                color: Color(0xFFFECACA),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.appColor,
                              ),
                            )
                                : const Text(
                              'Delete',
                              style: TextStyle(
                                fontFamily: 'Inter_Medium',
                                fontSize: 12,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                        },
                      ),
                  ),
                ],
              ),
            if (provider.isListLoading) const AppLoaderOverlay(),
            ],
          ),
        );
      },
    );
  }

  void _showCreateLeadDialog(BuildContext context, LeadProvider provider) {
    provider.resetLeadForm();

    final contacts = provider.contactModel?.data ?? [];
    final people = provider.userModel?.data ?? [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        bool isSaving = false;

        String? dialogContactId = provider.selectedContactId;
        String? dialogAssignedId = provider.selectedAssignedId;
        final userRole = GetStorageData.readString(GetStorageData.userType);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Future<void> saveLead() async {
            //   if (provider.titleController.text.trim().isEmpty) {
            //     Fluttertoast.showToast(
            //       msg: 'Please enter lead title',
            //       toastLength: Toast.LENGTH_SHORT,
            //       gravity: ToastGravity.BOTTOM,
            //     );
            //     return;
            //   }
            //
            //   setDialogState(() {
            //     isSaving = true;
            //   });
            //
            //   final success = await provider.createLead(
            //     title: provider.titleController.text.trim(),
            //     status: provider.selectedStatus,
            //     source: provider.sourceController.text.trim(),
            //     notes: provider.notesController.text.trim(),
            //     contactId: provider.selectedContactId,
            //     assignedToId: provider.selectedAssignedId,
            //   );
            //
            //   if (!context.mounted) return;
            //
            //   if (success) {
            //     Navigator.pop(dialogContext);
            //
            //     Fluttertoast.showToast(
            //       msg: 'Lead created successfully',
            //       toastLength: Toast.LENGTH_SHORT,
            //       gravity: ToastGravity.BOTTOM,
            //       backgroundColor: AppColors.appColor,
            //       textColor: Colors.white,
            //     );
            //   } else {
            //     setDialogState(() {
            //       isSaving = false;
            //     });
            //
            //     Fluttertoast.showToast(
            //       msg: provider.errorMessage ?? 'Unable to create lead',
            //       toastLength: Toast.LENGTH_LONG,
            //       gravity: ToastGravity.BOTTOM,
            //       backgroundColor: Colors.red,
            //       textColor: Colors.white,
            //     );
            //   }
            // }
            return AppDialogShell(
              title: 'New lead',
              child: SingleChildScrollView(
                child: Form(
                  key: provider.leadFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _leadSectionHeader(
                        icon: Icons.info_outline_rounded,
                        title: 'Lead information',
                        subtitle: 'Enter the basic lead details',
                      ),
                      const SizedBox(height: 14),
                      const AppDialogLabel('Title'),
                      const SizedBox(height: 6),
                      CommonTextField(
                        controller: provider.titleController,
                        hintText: 'Enter lead title',
                        fontSize: 15,
                        borderRadius: 12,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lead title is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const AppDialogLabel('Source'),
                      const SizedBox(height: 6),
                      CommonTextField(
                        controller: provider.sourceController,
                        hintText: 'Website, call, walk-in',
                        fontSize: 15,
                        borderRadius: 12,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Source is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _leadSectionHeader(
                        icon: Icons.contacts_outlined,
                        title: 'Contact & assignment',
                        subtitle: 'Connect contact and assign this lead',
                      ),
                      const SizedBox(height: 14),
                      const AppDialogLabel('Contact'),
                      const SizedBox(height: 6),
                      _LeadDropdown<String?>(
                        value: dialogContactId,
                        hintText: 'None',
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None'),
                          ),
                          ...contacts.map((contact) {
                            return DropdownMenuItem<String?>(
                              value: contact.id.toString(),
                              child: Text(
                                contact.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            dialogContactId = value;
                          });
                          provider.setContact(value);
                          debugPrint('SELECTED CONTACT ID = $value');
                        },
                      ),
                      const SizedBox(height: 14),
                      if (userRole?.toUpperCase() != 'USER') ...[
                        const AppDialogLabel('Assign to'),
                        const SizedBox(height: 6),
                        _LeadDropdown<String?>(
                          value: dialogAssignedId,
                          hintText: 'Unassigned',
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Unassigned'),
                            ),
                            ...people.map((person) {
                              return DropdownMenuItem<String?>(
                                value: person.id.toString(),
                                child: Text(
                                  '${person.name} • ${person.role}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              dialogAssignedId = value;
                            });
                            provider.setAssignedUser(value);
                          },
                        ),
                        const SizedBox(height: 18),
                      ],
                      _leadSectionHeader(
                        icon: Icons.notes_rounded,
                        title: 'Additional information',
                        subtitle: 'Add notes related to this lead',
                      ),
                      const SizedBox(height: 14),
                      const AppDialogLabel('Notes'),
                      const SizedBox(height: 6),
                      CommonTextField(
                        controller: provider.notesController,
                        hintText: 'Enter notes',
                        fontSize: 15,
                        borderRadius: 12,
                        maxLine: 3,
                      ),
                      const SizedBox(height: 18),
                      AppDialogActions(
                        primaryLabel: 'Create lead',
                        busy: provider.isLoading,
                        onPrimary: () async {
                          final success = await provider.createLead();

                          if (!context.mounted) return;

                          if (success) {
                            Navigator.pop(dialogContext);
                            Fluttertoast.showToast(
                              msg: 'Lead created successfully',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: AppColors.appColor,
                              textColor: Colors.white,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: provider.errorMessage ??
                                  'Unable to create lead',
                              toastLength: Toast.LENGTH_LONG,
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
        );
      },
    );
  }

  Widget _leadSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: AppColors.appColor.withOpacity(.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.appColor, size: 20),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter_Bold',
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter_Regular',
                  color: AppColors.textGrey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeadDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _LeadDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validValue = value != null && items.any((item) => item.value == value)
        ? value
        : null;

    return Container(
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xffFBFCFC),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xffDEE7E5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: validValue,
          isExpanded: true,
          hint: Text(
            hintText,
            style: const TextStyle(
              fontFamily: 'Inter_Regular',
              fontSize: 14,
              color: Color(0xff202828),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xff394745),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StatusDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'NEW':
        return const Color(0xFF1B9A6C);

      case 'CONTACTED':
        return const Color(0xff9A6700);

      case 'QUALIFIED':
        return const Color(0xff16845B);

      case 'LOST':
        return const Color(0xffD64545);

      default:
        return const Color(0xff667372);
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'NEW':
        return const Color(0xFFE7F8F1);

      case 'CONTACTED':
        return const Color(0xffFFF7E5);

      case 'QUALIFIED':
        return const Color(0xffEAF8F2);

      case 'LOST':
        return const Color(0xffffeeee);

      default:
        return const Color(0xffF4F6F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(value);
    final background = _statusBackground(value);

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4,top: 2,bottom: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: color),
          selectedItemBuilder: (context) {
            return items.map((status) {
              return Text(
                status,
                style: TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  fontSize: 11,
                  letterSpacing: 0.4,
                  color: _statusColor(status),
                ),
              );
            }).toList();
          },
          items: items.map((status) {
            final itemColor = _statusColor(status);

            return DropdownMenuItem<String>(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: itemColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status,
                    style: TextStyle(
                      fontFamily: 'Inter_SemiBold',
                      fontSize: 11,
                      color: itemColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AssignedDropdown extends StatelessWidget {
  final String? value;
  final List<dynamic> people;
  final ValueChanged<String?> onChanged;

  const _AssignedDropdown({
    required this.value,
    required this.people,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedUser =
        value != null &&
        people.any((person) => person.id.toString() == value.toString());

    const labelStyle = TextStyle(
      fontFamily: 'Inter_Medium',
      fontSize: 14,
      color: Color(0xff1E293B),
    );

    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        isDense: true,
        isExpanded: true,
        value: hasSelectedUser ? value : null,
        hint: const Text('Unassigned', style: labelStyle),
        style: labelStyle,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16,
          color: Color(0xff111827),
        ),
        selectedItemBuilder: (context) {
          return [
            const Text(
              'Unassigned',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
            ...people.map((person) {
              final personName = person.name?.toString() ?? 'Unknown';
              final role = person.role?.toString() ?? '';
              return Text(
                role.isNotEmpty ? '$personName · $role' : personName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              );
            }),
          ];
        },
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'Unassigned',
                style: TextStyle(
                  fontFamily: 'Inter_Medium',
                  fontSize: 15,
                  color: Color(0xff202828),
                ),
              ),
            ),
            ...people.map<DropdownMenuItem<String?>>((person) {
              final String personId = person.id.toString();

              final String personName = person.name?.toString() ?? 'Unknown';

              final String role = person.role?.toString() ?? '';

              return DropdownMenuItem<String?>(
                value: personId,
                child: Text(
                  role.isNotEmpty ? '$personName · $role' : personName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter_Medium',
                    fontSize: 15,
                    color: Color(0xff202828),
                  ),
                ),
              );
            }),
          ],

          onChanged: (String? selectedValue) {
            onChanged(selectedValue);
          },
        ),
    );
  }
}
