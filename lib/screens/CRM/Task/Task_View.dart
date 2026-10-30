import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/storage/local_storage.dart';
import 'package:trackora/core/widgets/app_dialog.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/core/widgets/common_textfild.dart';
import 'package:trackora/data/models/TaskData_Model.dart';
import 'package:trackora/screens/CRM/Task/Provider/TaskProvider.dart';

import '../../../core/widgets/workforce_app_bar.dart';

class TaskView extends StatelessWidget {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskViewContent();
  }
}

class TaskViewContent extends StatefulWidget {
  const TaskViewContent({super.key});

  @override
  State<TaskViewContent> createState() => _TaskViewContentState();
}

class _TaskViewContentState extends State<TaskViewContent> {
  final List<String> statusList = ['TODO', 'IN_PROGRESS', 'DONE', "CANCELLED"];

  String statusLabel(String? status) {
    switch (status?.toUpperCase()) {
      case 'IN_PROGRESS':
        return 'IN PROGRESS';

      case 'DONE':
        return 'DONE';

      case 'TODO':
        return 'TODO';

      default:
        return status ?? 'TODO';
    }
  }

  Color priorityBackground(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'HIGH':
        return const Color(0xffffeeee);

      case 'MEDIUM':
        return const Color(0xFFFFF4D6);

      case 'LOW':
        return const Color(0xffeaf8f2);

      default:
        return const Color(0xfff3f5f5);
    }
  }

  Color priorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'HIGH':
        return const Color(0xffd64545);

      case 'MEDIUM':
        return const Color(0xFFC4841D);

      case 'LOW':
        return const Color(0xff16845b);

      default:
        return const Color(0xff667372);
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return '—';
    }

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _personInitial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'U';
    }

    return name.trim().substring(0, 1).toUpperCase();
  }

  Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return const Color(0xffD64545);

      case 'MEDIUM':
        return const Color(0xff9A6700);

      case 'LOW':
        return const Color(0xff16845B);

      default:
        return const Color(0xff667372);
    }
  }

  bool isOverdue(Task task) {
    if (task.dueDate == null) {
      return false;
    }

    if (task.status?.toUpperCase() == 'DONE') {
      return false;
    }

    final today = DateTime.now();

    final dueDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    final currentDate = DateTime(today.year, today.month, today.day);

    return dueDate.isBefore(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    final userRole = GetStorageData.readString(
      GetStorageData.userType,
    )?.toUpperCase();
    final isUserRole = userRole == 'USER';
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final List<Task> tasks = provider.taskDataResponse?.data ?? [];

        final int openCount = tasks.where((task) {
          return task.status?.toUpperCase() != 'DONE';
        }).length;

        final int overdueCount = tasks.where((task) {
          return isOverdue(task);
        }).length;

        final int doneCount = tasks.where((task) {
          return task.status?.toUpperCase() == 'DONE';
        }).length;

        final people = provider.userModel?.data ?? [];

        final List<Task> filteredTasks;

        if (isUserRole) {
          final currentUserId = GetStorageData.readString(
            GetStorageData.userId,
          );

          filteredTasks = tasks.where((task) {
            return task.assignedToId?.toString() == currentUserId?.toString();
          }).toList();
        } else {
          filteredTasks = provider.selectedPerson == 'All people'
              ? tasks
              : tasks.where((task) {
                  return task.assignedTo?.name == provider.selectedPerson;
                }).toList();
        }

        final List<dynamic> whoHasWhatPeople = isUserRole
            ? []
            : provider.selectedPersonId == null
            ? people.where((person) {
                return tasks.any((task) => task.assignedToId == person.id);
              }).toList()
            : people.where((person) {
                return person.id == provider.selectedPersonId &&
                    tasks.any((task) => task.assignedToId == person.id);
              }).toList();
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: WorkforceAppBar(
            title: 'Tasks',
            showAction: isUserRole ? false: true,
            actionLabel: isUserRole ? '':'New Task',
            onTap: isUserRole
            ? (){}
             :   () {
              _showCreateTaskDialog(context, provider);
            } ,
          ),
          // floatingActionButton: isUserRole
          //     ? null
          //     : FloatingActionButton(
          //         onPressed: () {
          //           _showCreateTaskDialog(context, provider);
          //         },
          //         backgroundColor: AppColors.appColor,
          //         elevation: 4,
          //         child: const Icon(
          //           Icons.add_rounded,
          //           color: Colors.white,
          //           size: 28,
          //         ),
          //       ),
          body: Stack(
            children: [
              RefreshIndicator(
            color: AppColors.appColor,
            onRefresh: () async {
              await provider.getTaskSummary();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(15, 16, 15, 25),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Open',
                        value: openCount.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        title: 'Overdue',
                        value: overdueCount.toString(),
                        highlight: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SummaryCard(
                        title: 'Done',
                        value: doneCount.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isUserRole) ...[
                  Row(
                    children: [
                      const Text(
                        'Filter Assignee:',
                        style: TextStyle(
                          fontFamily: 'Inter_Medium',
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 34,
                        padding: const EdgeInsets.only(left: 12, right: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: provider.selectedPersonId,
                            isDense: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            selectedItemBuilder: (context) {
                              final labels = [
                                'All people',
                                ...people.map((person) => person.name),
                              ];
                              return labels
                                  .map(
                                    (label) => Text(
                                      label,
                                      style: const TextStyle(
                                        fontFamily: 'Inter_Medium',
                                        fontSize: 13,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  )
                                  .toList();
                            },
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All people'),
                              ),
                              ...people.map((person) {
                                return DropdownMenuItem<String?>(
                                  value: person.id,
                                  child: Text(person.name),
                                );
                              }),
                            ],
                            onChanged: (value) async {
                              provider.selectedPersonId = value;

                              if (value == null || value.isEmpty) {
                                await provider.getTaskSummary();
                              } else {
                                await provider.getTaskSummary(
                                  assignedToId: value,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    const Text(
                      'ASSIGNED TASKS',
                      style: TextStyle(
                        fontFamily: 'Inter_SemiBold',
                        fontSize: 11,
                        letterSpacing: 0.6,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F8F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filteredTasks.length} TASKS',
                        style: const TextStyle(
                          fontFamily: 'Inter_SemiBold',
                          fontSize: 10,
                          letterSpacing: 0.3,
                          color: Color(0xFF1B9A6C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...filteredTasks.map(
                  (task) => TaskCard(
                    task: task,
                    formatDate: formatDate,
                    priorityBackground: priorityBackground,
                    priorityColor: priorityColor,
                    statusLabel: statusLabel,
                    statusList: statusList,
                  ),
                ),

                const SizedBox(height: 20),

                if (!isUserRole && filteredTasks.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xffE5EBEA)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: AppColors.appColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.people_alt_outlined,
                                size: 20,
                                color: AppColors.appColor,
                              ),
                            ),

                            const SizedBox(width: 11),

                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Who has what',
                                  style: TextStyle(
                                    fontFamily: 'Inter_Bold',
                                    fontSize: 16,
                                    color: Color(0xff202828),
                                  ),
                                ),

                                SizedBox(height: 3),

                                Text(
                                  'Task distribution by person',
                                  style: TextStyle(
                                    fontFamily: 'Inter_Regular',
                                    fontSize: 11,
                                    color: Color(0xff7A8584),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...whoHasWhatPeople.map((person) {
                          final personTasks = tasks.where((task) {
                            return task.assignedToId == person.id;
                          }).toList();

                          final int personOpen = personTasks.where((task) {
                            return task.status?.toUpperCase() != 'DONE';
                          }).length;

                          final int personDone = personTasks.where((task) {
                            return task.status?.toUpperCase() == 'DONE';
                          }).length;

                          final String taskNames = personTasks
                              .map((task) => task.title ?? '')
                              .where((title) => title.isNotEmpty)
                              .join(' • ');

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFCFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xffE7ECEB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 38,
                                      width: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.appColor.withOpacity(
                                          0.10,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          (person.name ?? 'U').trim().isNotEmpty
                                              ? (person.name ?? 'U')
                                                    .trim()
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                              : 'U',
                                          style: TextStyle(
                                            fontFamily: 'Inter_Bold',
                                            fontSize: 14,
                                            color: AppColors.appColor,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            person.name ?? 'Unknown',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Inter_SemiBold',
                                              fontSize: 14,
                                              color: Color(0xff202828),
                                            ),
                                          ),

                                          const SizedBox(height: 2),

                                          Text(
                                            '${personTasks.length} task${personTasks.length == 1 ? '' : 's'} assigned',
                                            style: const TextStyle(
                                              fontFamily: 'Inter_Regular',
                                              fontSize: 11,
                                              color: Color(0xff7A8584),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _TaskCountCard(
                                        title: 'OPEN',
                                        value: personOpen,
                                        icon: Icons.pending_actions_outlined,
                                        backgroundColor: const Color(
                                          0xfffff7e8,
                                        ),
                                        textColor: const Color(0xff9a6700),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: _TaskCountCard(
                                        title: 'DONE',
                                        value: personDone,
                                        icon: Icons.check_circle_outline,
                                        backgroundColor: const Color(
                                          0xffeaf8f2,
                                        ),
                                        textColor: const Color(0xff16845b),
                                      ),
                                    ),
                                  ],
                                ),
                                if (taskNames.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xffE7ECEB),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.assignment_outlined,
                                          size: 17,
                                          color: Color(0xff667372),
                                        ),

                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Text(
                                            taskNames,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontFamily: 'Inter_Regular',
                                              fontSize: 12,
                                              height: 1.4,
                                              color: Color(0xff4E5A59),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                    ]),
                  ),
                ),
                if (filteredTasks.isEmpty && !provider.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No tasks found',
                        style: TextStyle(
                          fontFamily: 'Inter_Medium',
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
              if (provider.isLoading) const AppLoaderOverlay(),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTaskDialog(BuildContext context, TaskProvider provider) {
    provider.resetTaskForm();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: Consumer<TaskProvider>(
            builder: (context, provider, child) {
              final people = provider.userModel?.data ?? [];

              return AppDialogShell(
                title: 'Assign task',
                child: SingleChildScrollView(
                  child: Form(
                    key: provider.taskFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _taskSectionHeader(
                          icon: Icons.assignment_outlined,
                          title: 'Task information',
                          subtitle: 'Enter the basic task details',
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Task'),
                        const SizedBox(height: 6),
                        CommonTextField(
                          controller: provider.titleController,
                          hintText: 'Enter task title',
                          fontSize: 15,
                          borderRadius: 12,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Task is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Notes'),
                        const SizedBox(height: 6),
                        CommonTextField(
                          controller: provider.descriptionController,
                          hintText: 'Enter task notes',
                          fontSize: 15,
                          borderRadius: 12,
                          maxLine: 3,
                        ),
                        const SizedBox(height: 18),
                        _taskSectionHeader(
                          icon: Icons.person_add_alt_1_rounded,
                          title: 'Assignment',
                          subtitle: 'Choose who should handle this task',
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Assign to'),
                        const SizedBox(height: 6),
                        _TaskDropdown<String>(
                          value: provider.selectedTaskAssignedId,
                          hintText: 'Select person',
                          items: people.map((person) {
                            return DropdownMenuItem<String>(
                              value: person.id.toString(),
                              child: Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.appColor
                                          .withOpacity(.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _personInitial(person.name),
                                        style: const TextStyle(
                                          fontFamily: 'Inter_Bold',
                                          fontSize: 12,
                                          color: AppColors.appColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${person.name ?? 'Unknown'} • ${person.role ?? ''}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Inter_Medium',
                                        fontSize: 14,
                                        color: Color(0xff202828),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            provider.setTaskAssignedUser(value);
                          },
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Due date'),
                        const SizedBox(height: 6),
                        _TaskDateField(
                          date: provider.selectedTaskDueDate,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: provider.selectedTaskDueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.appColor,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              provider.setTaskDueDate(picked);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Priority'),
                        const SizedBox(height: 6),
                        _TaskDropdown<String>(
                          value: provider.selectedTaskPriority,
                          hintText: 'Select priority',
                          items: provider.priorityList.map((priority) {
                            return DropdownMenuItem<String>(
                              value: priority,
                              child: Row(
                                children: [
                                  Container(
                                    height: 8,
                                    width: 8,
                                    decoration: BoxDecoration(
                                      color: _priorityColor(priority),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    priority,
                                    style: const TextStyle(
                                      fontFamily: 'Inter_Medium',
                                      fontSize: 14,
                                      color: Color(0xff202828),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              provider.setTaskPriority(value);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        const AppDialogLabel('Linked lead'),
                        const SizedBox(height: 6),
                        _TaskDropdown<String?>(
                          value: provider.selectedTaskLeadId,
                          hintText: 'None',
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'None',
                                style: TextStyle(
                                  fontFamily: 'Inter_Medium',
                                  fontSize: 14,
                                  color: Color(0xff202828),
                                ),
                              ),
                            ),
                            ...((provider.leadModel?.data ?? []).map((lead) {
                              return DropdownMenuItem<String?>(
                                value: lead.id.toString(),
                                child: Text(
                                  lead.title ?? 'Untitled lead',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter_Medium',
                                    fontSize: 14,
                                    color: Color(0xff202828),
                                  ),
                                ),
                              );
                            })),
                          ],
                          onChanged: (value) {
                            provider.setTaskLead(value);
                          },
                        ),
                        const SizedBox(height: 18),
                        AppDialogActions(
                          primaryLabel: 'Assign task',
                          busy: provider.isCreatingTask,
                          onPrimary: () async {
                            final success = await provider.createTask();

                            if (!context.mounted) {
                              return;
                            }

                            if (success) {
                              Navigator.pop(dialogContext);
                              Fluttertoast.showToast(
                                msg: 'Task assigned successfully',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: AppColors.appColor,
                                textColor: Colors.white,
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: provider.errorMessage ??
                                    'Unable to create task',
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
          ),
        );
      },
    );
  }

  Widget _taskSectionHeader({
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

// class _EmployeeCard extends StatelessWidget {
//   const _EmployeeCard({required this.employee});
//
//   final Employee employee;
//
//   @override
//   Widget build(BuildContext context) {
//     final user = employee.user;
//
//     final payrollEnabled =
//         (employee.pfEnabled ?? false) ||
//             (employee.taxEnabled ?? false) ||
//             (employee.employeeTaxEnabled ?? false);
//
//     final faceRegistered = employee.faceRegistered ?? false;
//     final isActive = employee.user?.isActive ?? true;
//     final isDeactivated = !isActive;
//     return Container(
//       width: double.infinity,
//
//       padding: const EdgeInsets.all(16),
//
//       decoration: BoxDecoration(
//         color: Colors.white,
//
//         borderRadius: BorderRadius.circular(18),
//
//         border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
//
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//
//                   children: [
//                     Text(
//                       user?.name ?? '-',
//
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//
//                       style: const TextStyle(
//                         fontFamily: 'Inter_SemiBold',
//                         color: AppColors.textDark,
//                         fontSize: 16,
//                       ),
//                     ),
//
//                     const SizedBox(height: 5),
//
//                     Text(
//                       user?.email ?? '-',
//
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//
//                       style: const TextStyle(
//                         fontFamily: 'Inter_Regular',
//                         color: AppColors.textGrey,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(width: 10),
//
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _RoleBadge(
//                     role: user?.role ?? '-',
//                   ),
//
//                   if (isDeactivated) ...[
//                     const SizedBox(width: 8),
//
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 7,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFE5E5),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text(
//                         'Deactivated',
//                         style: TextStyle(
//                           fontFamily: 'Inter_Bold',
//                           fontSize: 10,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               )
//             ],
//           ),
//
//           const SizedBox(height: 18),
//
//           Row(
//             children: [
//               Expanded(
//                 child: _InfoItem(
//                   title: 'CODE',
//                   value: employee.employeeCode ?? '-',
//                 ),
//               ),
//
//               const SizedBox(width: 12),
//
//               Expanded(
//                 child: _InfoItem(
//                   title: 'SALARY',
//                   value: '₹${employee.monthlySalary ?? 0}',
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//
//                   children: [
//                     const Text('PAYROLL', style: _smallTitleStyle),
//
//                     const SizedBox(height: 8),
//
//                     if (!payrollEnabled)
//                       const Text(
//                         '—',
//                         style: TextStyle(
//                           fontFamily: 'Inter_Regular',
//                           color: AppColors.textGrey,
//                           fontSize: 13,
//                         ),
//                       )
//                     else
//                       Wrap(
//                         spacing: 6,
//                         runSpacing: 6,
//
//                         children: [
//                           if (employee.pfEnabled ?? false)
//                             const _SmallBadge(text: 'PF'),
//
//                           if (employee.taxEnabled ?? false)
//                             const _SmallBadge(text: 'Tax'),
//
//                           if (employee.employeeTaxEnabled ?? false)
//                             const _SmallBadge(text: 'Emp tax'),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(width: 12),
//
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//
//                 children: [
//                   const Text('FACE', style: _smallTitleStyle),
//
//                   const SizedBox(height: 8),
//
//                   _FaceBadge(registered: faceRegistered),
//                 ],
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 18),
//
//           const Divider(height: 1),
//
//           const SizedBox(height: 14),
//
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     _showEditEmployeeDialog(context, employee);
//                   },
//
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 44),
//
//                     foregroundColor: AppColors.textDark,
//
//                     side: BorderSide(
//                       color: Colors.black.withValues(alpha: 0.10),
//                     ),
//
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//
//                   child: const Text(
//                     'Payroll',
//                     style: TextStyle(
//                       fontFamily: 'Inter_SemiBold',
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: 10),
//
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     _deactivateEmployee(context, employee);
//
//                   },
//
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 44),
//
//                     foregroundColor: AppColors.textDark,
//
//                     side: BorderSide(
//                       color: Colors.black.withValues(alpha: 0.10),
//                     ),
//
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//
//                   child: const Text(
//                     'Deactivate',
//                     style: TextStyle(
//                       fontFamily: 'Inter_SemiBold',
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   void _showEditEmployeeDialog(
//       BuildContext context,
//       Employee employee,
//       ) {
//     final provider = context.read<EmployeeProvider>();
//     provider.fillEmployeeData(employee);
//
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (dialogContext) {
//         return ChangeNotifierProvider.value(
//           value: provider,
//           child: _CreateEmployeeDialog(
//             employee: employee,
//           ),
//         );
//       },
//     );
//   }
//   Future<void> _deactivateEmployee(
//       BuildContext context,
//       Employee employee,
//       ) async {
//     final employeeId = employee.id;
//
//     if (employeeId == null || employeeId.isEmpty) {
//       Fluttertoast.showToast(
//         msg: 'Employee ID not found',
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//       return;
//     }
//
//     final provider = context.read<EmployeeProvider>();
//
//     // Confirmation dialog
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           title: const Text(
//             'Deactivate employee?',
//             style: TextStyle(
//               fontFamily: 'Inter_Bold',
//               fontSize: 18,
//             ),
//           ),
//           content: Text(
//             'Are you sure you want to deactivate '
//                 '${employee.user?.name ?? 'this employee'}?',
//             style: const TextStyle(
//               fontFamily: 'Inter_Regular',
//               fontSize: 14,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, false);
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   fontFamily: 'Inter_SemiBold',
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, true);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 'Deactivate',
//                 style: TextStyle(
//                   fontFamily: 'Inter_SemiBold',
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (confirm != true) {
//       return;
//     }
//
//     final success = await provider.deactivateEmployee(
//       employeeId,
//     );
//
//     if (!context.mounted) return;
//
//     if (success) {
//       Fluttertoast.showToast(
//         msg: 'Employee deactivated successfully',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: AppColors.appColor,
//         textColor: Colors.white,
//       );
//     } else if (provider.errorMessage != null) {
//       Fluttertoast.showToast(
//         msg: provider.errorMessage!,
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }
// }

class TaskCard extends StatelessWidget {
  final Task task;
  final String Function(DateTime?) formatDate;
  final Color Function(String?) priorityBackground;
  final Color Function(String?) priorityColor;
  final String Function(String?) statusLabel;
  final List<String> statusList;

  const TaskCard({
    super.key,
    required this.task,
    required this.formatDate,
    required this.priorityBackground,
    required this.priorityColor,
    required this.statusLabel,
    required this.statusList,
  });

  @override
  Widget build(BuildContext context) {
    final bool overdue =
        task.dueDate != null &&
        task.status?.toUpperCase() != 'DONE' &&
        task.dueDate!.isBefore(
          DateTime.now().subtract(
            Duration(
              hours: DateTime.now().hour,
              minutes: DateTime.now().minute,
              seconds: DateTime.now().second,
              milliseconds: DateTime.now().millisecond,
            ),
          ),
        );
    final taskProvider = context.read<TaskProvider>();
    return Container(
      width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title ?? 'Untitled task',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter_Bold',
                        fontSize: 16,
                        color: Color(0xff0F172A),
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter_Regular',
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityBackground(task.priority),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (task.priority ?? '—').toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    letterSpacing: 0.3,
                    color: priorityColor(task.priority),
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
                child: _TaskMeta(
                  title: 'ASSIGNED TO',
                  value: task.assignedTo?.name ?? '—',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TaskMeta(
                  title: 'ASSIGNED BY',
                  value: task.assignedBy?.name ?? '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TaskMeta(
                  title: 'DUE DATE',
                  value: formatDate(task.dueDate),
                  valueColor: overdue ? const Color(0xFFEF4444) : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TaskMeta(
                  title: 'LINKED LEAD',
                  value: task.lead?.title ?? '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                height: 34,
                padding: const EdgeInsets.only(left: 10, right: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: statusList.contains(task.status)
                        ? task.status
                        : null,
                    isDense: true,
                    hint: Text(
                      'Status: ${statusLabel(task.status)}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        letterSpacing: 0.4,
                        color: Color(0xff334155),
                      ),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    selectedItemBuilder: (context) {
                      return statusList.map((item) {
                        return Text(
                          'Status: ${statusLabel(item)}',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Color(0xff334155),
                          ),
                        );
                      }).toList();
                    },
                    items: statusList.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          statusLabel(item),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Color(0xff202828),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (value == null) return;

                      final provider = context.read<TaskProvider>();

                      final bool success = await provider.updateTaskStatus(
                        taskId: task.id ?? '',
                        status: value,
                      );

                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.errorMessage ??
                                  'Unable to update task status',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: taskProvider.isLoading
                    ? null
                    : () async {
                        final success = await taskProvider.deleteLead(
                          leadId: task.id.toString(),
                        );
                        if (!context.mounted) return;
                        if (success) {
                          Fluttertoast.showToast(
                            msg: 'Task deleted successfully',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: AppColors.appColor,
                            textColor: Colors.white,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg:
                                taskProvider.errorMessage ??
                                'Unable to delete task',
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
                    horizontal: 14,
                    vertical: 6,
                  ),
                  backgroundColor: const Color(0xFFFFF1F2),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:  Text(
                  'Delete',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _TaskDropdown({
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

class _TaskDateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _TaskDateField({required this.date, required this.onTap});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xffFBFCFC),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xffDEE7E5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formatDate(date),
                style: const TextStyle(
                  fontFamily: 'Inter_Medium',
                  fontSize: 14,
                  color: Color(0xff202828),
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xff202828),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskMeta extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _TaskMeta({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 10,
            letterSpacing: 0.4,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: valueColor ?? const Color(0xff1E293B),
          ),
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = highlight
        ? const Color(0xFFE07A12)
        : const Color(0xff111827);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? const Color(0xFFF0B45A)
              : const Color(0xFFE6EEF2),
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

// class TaskTableRow extends StatelessWidget {
//   final Task task;
//
//   final String Function(DateTime?) formatDate;
//
//   final Color Function(String?) priorityBackground;
//
//   final Color Function(String?) priorityColor;
//
//   final String Function(String?) statusLabel;
//
//   final List<String> statusList;
//
//   const TaskTableRow({
//     super.key,
//     required this.task,
//     required this.formatDate,
//     required this.priorityBackground,
//     required this.priorityColor,
//     required this.statusLabel,
//     required this.statusList,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 760,
//
//       constraints: const BoxConstraints(minHeight: 105),
//
//       decoration: const BoxDecoration(
//         border: Border(top: BorderSide(color: Color(0xffE1E8E7))),
//       ),
//
//       child: Row(
//         children: [
//           SizedBox(
//             width: 125,
//
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//
//                 mainAxisAlignment: MainAxisAlignment.center,
//
//                 children: [
//                   Text(
//                     task.title ?? '—',
//
//                     maxLines: 1,
//
//                     overflow: TextOverflow.ellipsis,
//
//                     style: const TextStyle(
//                       fontFamily: 'Inter_SemiBold',
//                       fontSize: 13,
//                       color: Color(0xff202828),
//                     ),
//                   ),
//
//                   if (task.description != null && task.description!.isNotEmpty)
//                     const SizedBox(height: 7),
//
//                   if (task.description != null && task.description!.isNotEmpty)
//                     Text(
//                       task.description!,
//
//                       maxLines: 1,
//
//                       overflow: TextOverflow.ellipsis,
//
//                       style: const TextStyle(
//                         fontFamily: 'Inter_Regular',
//                         fontSize: 11,
//                         height: 1.3,
//                         color: Color(0xff7A8584),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//
//           PersonCell(name: task.assignedTo?.name ?? '—'),
//
//           PersonCell(name: task.assignedBy?.name ?? '—'),
//
//           SizedBox(
//             width: 75,
//
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//
//               child: Text(
//                 formatDate(task.dueDate),
//
//                 style: const TextStyle(
//                   fontFamily: 'Inter_Regular',
//                   fontSize: 13,
//                   color: Color(0xff202828),
//                 ),
//               ),
//             ),
//           ),
//
//           SizedBox(
//             width: 90,
//
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 7,
//                 ),
//
//                 decoration: BoxDecoration(
//                   color: priorityBackground(task.priority),
//
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//
//                 child: Text(
//                   task.priority ?? '—',
//
//                   style: TextStyle(
//                     fontFamily: 'Inter_Bold',
//                     fontSize: 10,
//                     color: priorityColor(task.priority),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           TableDataCell(width: 90, value: task.lead?.title ?? '—'),
//
//           SizedBox(
//             width: 170,
//
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//
//               child: Container(
//                 height: 38,
//
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//
//                   borderRadius: BorderRadius.circular(9),
//
//                   border: Border.all(color: const Color(0xffDCE5E4)),
//                 ),
//
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: statusList.contains(task.status)
//                         ? task.status
//                         : null,
//
//                     hint: Text(
//                       statusLabel(task.status),
//
//                       style: const TextStyle(
//                         fontFamily: 'Inter_Regular',
//                         fontSize: 13,
//                       ),
//                     ),
//
//                     isExpanded: true,
//
//                     icon: const Icon(
//                       Icons.keyboard_arrow_down_rounded,
//                       size: 18,
//                     ),
//
//                     items: statusList.map((item) {
//                       return DropdownMenuItem<String>(
//                         value: item,
//
//                         child: Text(
//                           statusLabel(item),
//
//                           style: const TextStyle(
//                             fontFamily: 'Inter_Regular',
//                             fontSize: 13,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//
//                     onChanged: (value) async {
//                       if (value == null) return;
//
//                       final provider = context.read<TaskProvider>();
//
//                       final bool success = await provider.updateTaskStatus(
//                         taskId: task.id ?? '',
//                         status: value,
//                       );
//
//                       if (!success && context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               provider.errorMessage ??
//                                   'Unable to update task status',
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class WhoHeader extends StatelessWidget {
  final String text;

  const WhoHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Align(
        alignment: Alignment.centerLeft,

        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter_Bold',
            fontSize: 10,
            letterSpacing: .7,
            color: Color(0xff667372),
          ),
        ),
      ),
    );
  }
}

class _TaskCountCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const _TaskCountCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: Color(0xffF4F7F7),
        border: Border(bottom: BorderSide(color: Color(0xffE2E9E8))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter_Bold',
                  fontSize: 9,
                  letterSpacing: .5,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value.toString(),
                style: TextStyle(
                  fontFamily: 'Inter_Bold',
                  fontSize: 17,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PersonCell extends StatelessWidget {
  final String name;

  const PersonCell({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final String displayName = name.trim().isEmpty ? '—' : name;

    final String initial = displayName == '—'
        ? '—'
        : displayName.substring(0, 1).toUpperCase();

    return SizedBox(
      width: 105,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontFamily: 'Inter_Bold',
                    fontSize: 11,
                    color: AppColors.appColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: Text(
                displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  fontSize: 11,
                  color: Color(0xff202828),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
