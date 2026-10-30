import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/CommonAppBar.dart';
import 'package:trackora/core/widgets/app_dialog.dart';
import 'package:trackora/core/widgets/workforce_app_bar.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/core/widgets/common_textfild.dart';
import 'package:trackora/screens/Employee/Provider/employee_provider.dart';
import '../../data/models/employee_model.dart';

class EmployeeView extends StatelessWidget {
  const EmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final employees = employeeProvider.employeeResponse?.data ?? [];
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: WorkforceAppBar(
        title: 'Employees',
        actionLabel: 'New user',
        onTap: () => _showCreateEmployeeDialog(context),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xffEFFCFE),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xff1B6B63)),
                      const SizedBox(width: 8),
                      Text(
                        'Create user time PF, tax, employee tax, overtime,\nbonus on/off set.',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: employees.isEmpty
                    ? employeeProvider.isLoading
                        ? const SizedBox.shrink()
                        : const Center(
                            child: Text(
                              'No employees found',
                              style: TextStyle(
                                fontFamily: 'Inter_Regular',
                                color: AppColors.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: employees.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          return _EmployeeCard(employee: employees[index]);
                        },
                      ),
              ),
            ],
          ),
          if (employeeProvider.isLoading) const AppLoaderOverlay(),
        ],
      ),
    );
  }

  void _showCreateEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: context.read<EmployeeProvider>(),
          child: const _CreateEmployeeDialog(),
        );
      },
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final user = employee.user;

    final faceRegistered = employee.faceRegistered ?? false;
    final isActive = employee.user?.isActive ?? true;
    final isDeactivated = !isActive;
    final role = (user?.role ?? '-').toUpperCase();
    final isStaff = role == 'ADMIN' || role == 'HR';
    final name = user?.name ?? '-';
    final payrollChips = <Widget>[
      if (employee.pfEnabled ?? false)
        const _SmallBadge(
          text: 'PF',
          color: Color(0xFF0891B2),
          background: Color(0xFFE0F7FB),
        ),
      if (employee.taxEnabled ?? false)
        const _SmallBadge(
          text: 'Tax',
          color: Color(0xFF2563EB),
          background: Color(0xFFE8F1FF),
        ),
      if (employee.employeeTaxEnabled ?? false)
        const _SmallBadge(
          text: 'Emp tax',
          color: Color(0xFF7C3AED),
          background: Color(0xFFF3E8FF),
        ),
      if (employee.bonusEnabled ?? false)
        const _SmallBadge(
          text: 'Bonus',
          color: Color(0xFF0F766E),
          background: Color(0xFFE6F6F4),
        ),
      if (employee.overtimeEnabled ?? false)
        const _SmallBadge(
          text: 'OverTime',
          color: Color(0xFFC2410C),
          background: Color(0xFFFFF1E8),
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B6B63).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isStaff
                      ? AppColors.appColor
                      : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials(name),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isStaff ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RoleBadge(role: role),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CODE',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.employeeCode ?? '-',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8EEED)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _StatColumn(
                    title: 'SALARY',
                    child: Text(
                      _formatSalary(employee.monthlySalary),
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _StatColumn(
                    title: 'PAYROLL',
                    child: payrollChips.isEmpty
                        ? Text(
                            '—',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9CA3AF),
                            ),
                          )
                        : _PayrollChips(chips: payrollChips),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _StatColumn(
                    title: 'FACE',
                    child: _FaceBadge(registered: faceRegistered),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CardActionButton(
                  label: 'Payroll',
                  onPressed: () => _showEditEmployeeDialog(context, employee),
                ),
                const SizedBox(width: 10),
                if (isDeactivated)
                  const _InactivePill()
                else
                  _CardActionButton(
                    label: 'Deactivate',
                    onPressed: () => _deactivateEmployee(context, employee),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty || parts.first == '-') return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static String _formatSalary(num? amount) {
    final raw = (amount ?? 0).round().abs().toString();
    if (raw.length <= 3) return '₹$raw';
    final last3 = raw.substring(raw.length - 3);
    var head = raw.substring(0, raw.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    return '₹${parts.join(',')},$last3';
  }

  void _showEditEmployeeDialog(BuildContext context, Employee employee) {
    final provider = context.read<EmployeeProvider>();
    provider.fillEmployeeData(employee);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: _CreateEmployeeDialog(employee: employee),
        );
      },
    );
  }

  Future<void> _deactivateEmployee(
    BuildContext context,
    Employee employee,
  ) async {
    final employeeId = employee.id;

    if (employeeId == null || employeeId.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Employee ID not found',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final provider = context.read<EmployeeProvider>();

    final confirm = await showAppConfirmDialog(
      context: context,
      title: 'Deactivate employee?',
      message:
          'Are you sure you want to deactivate '
          '${employee.user?.name ?? 'this employee'}?',
      confirmLabel: 'Deactivate',
      confirmColor: Colors.red,
    );

    if (confirm != true) {
      return;
    }

    final success = await provider.deactivateEmployee(employeeId);

    if (!context.mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'Employee deactivated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.appColor,
        textColor: Colors.white,
      );
    } else if (provider.errorMessage != null) {
      Fluttertoast.showToast(
        msg: provider.errorMessage!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _PayrollChips extends StatelessWidget {
  const _PayrollChips({required this.chips});

  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final first = chips.take(3).toList();
    final rest = chips.skip(3).toList();

    return Column(
      children: [
        _chipRow(first),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 6),
          _chipRow(rest),
        ],
      ],
    );
  }

  Widget _chipRow(List<Widget> items) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isStaff = role == 'ADMIN' || role == 'HR';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isStaff ? AppColors.appColor : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: isStaff ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _InactivePill extends StatelessWidget {
  const _InactivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF4D7A), width: 1.4),
      ),
      child: Text(
        'Inactive',
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFF4D7A),
        ),
      ),
    );
  }
}

class _FaceBadge extends StatelessWidget {
  const _FaceBadge({required this.registered});

  final bool registered;

  @override
  Widget build(BuildContext context) {
    final color = registered ? const Color(0xFF16A37F) : const Color(0xFFF08A24);
    final background =
        registered ? const Color(0xFFE7F7F1) : const Color(0xFFFFF4E8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        registered ? 'Yes' : 'No',
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.text,
    required this.color,
    required this.background,
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF111827),
        minimumSize: const Size(96, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CreateEmployeeDialog extends StatefulWidget {
  final Employee? employee;

  bool get isEdit => employee != null;
  const _CreateEmployeeDialog({super.key, this.employee});

  @override
  State<_CreateEmployeeDialog> createState() => _CreateEmployeeDialogState();
}

class _CreateEmployeeDialogState extends State<_CreateEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final departments = provider.departmentResponse?.data ?? [];
    final departmentItems = [
      'None',
      ...departments
          .where((department) => department.name != null)
          .map((department) => department.name!)
          .where((name) => name.isNotEmpty),
    ];
    return AppDialogShell(
      title: widget.isEdit ? 'Edit employee' : 'New user',
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Inter_Regular',
          color: AppColors.textDark,
          fontSize: 13,
        ),
        child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                        _sectionHeader(
                          icon: Icons.person_outline_rounded,
                          title: 'Basic information',
                          subtitle: 'Enter the employee account details',
                        ),
                        const SizedBox(height: 10),
                        const AppDialogLabel('Name'),
                        const SizedBox(height: 4),
                        CommonTextField(
                          controller: provider.nameController,
                          hintText: 'Enter employee name',
                          fontSize: 15,
                          borderRadius: 13,
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name is required.";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        const AppDialogLabel('Email'),
                        const SizedBox(height: 4),

                        CommonTextField(
                          controller: provider.emailController,
                          hintText: 'Enter email',
                          fontSize: 15,
                          borderRadius: 13,
                          textInputType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required.";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        const AppDialogLabel('Password'),
                        const SizedBox(height: 4),

                        CommonTextField(
                          controller: provider.passwordController,
                          hintText: 'Enter password',
                          fontSize: 15,
                          borderRadius: 13,
                          obscureText: provider.obscurePassword,
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.text,
                          suffix: TextButton(
                            onPressed: () {
                              setState(() {
                                provider.obscurePassword =
                                    !provider.obscurePassword;
                              });
                            },
                            child: Text(
                              provider.obscurePassword ? 'SHOW' : 'HIDE',
                              style: const TextStyle(
                                fontFamily: 'Inter_Bold',
                                color: AppColors.textGrey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password Must Be Strong.";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppDialogLabel('Role'),
                                  const SizedBox(height: 4),

                                  _dropdownField(
                                    value: provider.selectedRole,
                                    items: const ['USER', 'HR', 'ADMIN'],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select role.';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        provider.selectedRole = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppDialogLabel('Employee code'),
                                  const SizedBox(height: 4),

                                  CommonTextField(
                                    controller: provider.employeeCodeController,
                                    hintText: 'Enter code',
                                    fontSize: 15,
                                    borderRadius: 13,
                                    textInputAction: TextInputAction.next,
                                    textInputType: TextInputType.text,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Code is required.";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        const AppDialogLabel('Department'),
                        const SizedBox(height: 4),

                        _dropdownField(
                          value:
                              departmentItems.contains(
                                provider.selectedDepartmentName,
                              )
                              ? provider.selectedDepartmentName
                              : 'None',
                          items: departmentItems,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == 'None') {
                              return 'Please select department.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value == null) return;

                            if (value == 'None') {
                              provider.setDepartment(id: '', name: 'None');
                              return;
                            }

                            final selectedDepartment = departments.firstWhere(
                              (department) => department.name == value,
                            );

                            provider.setDepartment(
                              id: selectedDepartment.id ?? '',
                              name: selectedDepartment.name ?? 'None',
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        _sectionHeader(
                          icon: Icons.work_outline_rounded,
                          title: 'Employment details',
                          subtitle: 'Set joining date and monthly salary',
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppDialogLabel('Join date'),
                                  const SizedBox(height: 4),

                                  InkWell(
                                    onTap: _selectDate,
                                    borderRadius: BorderRadius.circular(13),
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFCFEFE),
                                        border: Border.all(
                                          color: const Color(0xFFDCE5E4),
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${provider.selectedDate.day.toString().padLeft(2, '0')}/'
                                              '${provider.selectedDate.month.toString().padLeft(2, '0')}/'
                                              '${provider.selectedDate.year}',
                                              style: const TextStyle(
                                                fontFamily: 'Inter_Regular',
                                                color: AppColors.textDark,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 18,
                                            color: AppColors.textDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppDialogLabel('Monthly salary'),
                                  const SizedBox(height: 4),

                                  _dialogTextField(
                                    controller: provider.salaryController,
                                    hint: 'Enter salary',
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        _sectionHeader(
                          icon: Icons.payments_outlined,
                          title: 'Payroll settings',
                          subtitle: 'Choose deductions and additional earnings',
                        ),
                        const SizedBox(height: 10),
                        _PayrollEditOption(
                          title: 'PF deduct',
                          subtitle: 'Provident fund monthly salary par.',
                          value: provider.pfEnabled,
                          controller: provider.pfPercentController,
                          fieldLabel: 'PF %',
                          hint: '12',
                          onChanged: provider.setPf,
                        ),

                        const SizedBox(height: 10),

                        _PayrollEditOption(
                          title: 'Tax (TDS) deduct',
                          subtitle: 'Salary + overtime + bonus par %.',
                          value: provider.taxEnabled,
                          controller: provider.taxPercentController,
                          fieldLabel: 'Tax %',
                          hint: '10',
                          onChanged: provider.setTax,
                        ),

                        const SizedBox(height: 10),

                        _PayrollEditOption(
                          title: 'Employee tax deduct',
                          subtitle: 'Professional tax — fixed monthly amount.',
                          value: provider.employeeTaxEnabled,
                          controller: provider.employeeTaxAmountController,
                          fieldLabel: 'Monthly tax',
                          hint: '200',
                          onChanged: provider.setEmployeeTax,
                        ),

                        const SizedBox(height: 10),

                        _PayrollEditOption(
                          title: 'Overtime add',
                          subtitle:
                              'Hours Earnings page par HR set kare. Rate × hours add thase.',
                          value: provider.overtimeEnabled,
                          controller: provider.overtimeRateController,
                          fieldLabel: 'Rate per hour',
                          hint: '150',
                          onChanged: provider.setOvertime,
                        ),

                        const SizedBox(height: 10),

                        _PayrollEditOption(
                          title: 'Bonus add',
                          subtitle:
                              'Fixed monthly bonus, tick hoy to net ma add.',
                          value: provider.bonusEnabled,
                          controller: provider.bonusAmountController,
                          fieldLabel: 'Monthly bonus',
                          hint: '2000',
                          onChanged: provider.setBonus,
                        ),

                        const SizedBox(height: 14),
                        AppDialogActions(
                          primaryLabel: widget.isEdit
                              ? 'Save Payroll'
                              : 'Create user',
                          busy: provider.isLoading,
                          onPrimary: widget.isEdit
                              ? _updateEmployee
                              : _createEmployee,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      );
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<EmployeeProvider>();

    final employeeId = widget.employee?.id;

    if (employeeId == null || employeeId.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Employee ID not found',
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    final success = await provider.updateEmployee(employeeId);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);

      Fluttertoast.showToast(
        msg: 'Employee updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.appColor,
        textColor: Colors.white,
      );
    } else if (provider.errorMessage != null) {
      Fluttertoast.showToast(
        msg: provider.errorMessage!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: AppColors.appColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.appColor, size: 17),
        ),

        const SizedBox(width: 10),

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
              const SizedBox(height: 1),
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

  Future<void> _selectDate() async {
    final provider = context.read<EmployeeProvider>();

    final date = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      provider.setDate(date);
    }
  }

  Future<void> _createEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<EmployeeProvider>();

    final success = await provider.createEmployee();

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);

      Fluttertoast.showToast(
        msg: 'User created successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.appColor,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: provider.errorMessage ?? 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget _dialogTextField({
    required TextEditingController controller,
    String hint = '',
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return CommonTextField(
      controller: controller,
      hintText: hint,
      textInputType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      fontSize: 15,
      borderRadius: 13,
      isTitle: false,
    );
  }

  Widget _dropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFCFEFE),
                border: Border.all(
                  color: state.hasError ? Colors.red : const Color(0xFFDCE5E4),
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textDark,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter_Regular',
                    color: AppColors.textDark,
                    fontSize: 15,
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Inter_Regular',
                          color: AppColors.textDark,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    state.didChange(newValue);
                    onChanged(newValue);
                  },
                ),
              ),
            ),

            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 5),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    fontFamily: 'Inter_Regular',
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PayrollEditOption extends StatelessWidget {
  const _PayrollEditOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.controller,
    required this.fieldLabel,
    required this.hint,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  final TextEditingController controller;
  final String fieldLabel;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: value
              ? AppColors.appColor.withValues(alpha: 0.35)
              : const Color(0xFFDCE5E4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              onChanged(!value);
            },
            borderRadius: BorderRadius.circular(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: value,
                    onChanged: (checked) {
                      onChanged(checked ?? false);
                    },
                    activeColor: AppColors.appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter_Bold',
                          color: AppColors.textDark,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter_Regular',
                          color: AppColors.textGrey,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (value) ...[
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                fieldLabel,
                style: const TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  color: AppColors.textGrey,
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: CommonTextField(
                controller: controller,
                hintText: hint,
                textInputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                fontSize: 15,
                borderRadius: 13,
                isTitle: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PayrollDialog extends StatefulWidget {
  const _PayrollDialog({required this.employee});

  final Employee employee;

  @override
  State<_PayrollDialog> createState() => _PayrollDialogState();
}

class _PayrollDialogState extends State<_PayrollDialog> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();

    return AppDialogShell(
      title: 'Payroll settings',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.employee.user?.name ?? 'Employee',
              style: const TextStyle(
                fontFamily: 'Inter_Regular',
                color: AppColors.textGrey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Payroll — tick je deduct / add karvu hoy',
              style: TextStyle(
                fontFamily: 'Inter_Bold',
                color: AppColors.textDark,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
                      _PayrollEditOption(
                        title: 'PF deduct',
                        subtitle: 'Provident fund monthly salary par.',
                        value: provider.pfEnabled,
                        controller: provider.pfPercentController,
                        fieldLabel: 'PF %',
                        hint: '12',
                        onChanged: provider.setPf,
                      ),

                      const SizedBox(height: 10),

                      _PayrollEditOption(
                        title: 'Tax (TDS) deduct',
                        subtitle: 'Salary + overtime + bonus par %.',
                        value: provider.taxEnabled,
                        controller: provider.taxPercentController,
                        fieldLabel: 'Tax %',
                        hint: '10',
                        onChanged: provider.setTax,
                      ),

                      const SizedBox(height: 10),
                      _PayrollEditOption(
                        title: 'Employee tax deduct',
                        subtitle: 'Professional tax — fixed monthly amount.',
                        value: provider.employeeTaxEnabled,
                        controller: provider.employeeTaxAmountController,
                        fieldLabel: 'Monthly tax',
                        hint: '200',
                        onChanged: provider.setEmployeeTax,
                      ),

                      const SizedBox(height: 10),
                      _PayrollEditOption(
                        title: 'Overtime add',
                        subtitle:
                            'Hours Earnings page par HR set kare. '
                            'Rate × hours add thase.',
                        value: provider.overtimeEnabled,
                        controller: provider.overtimeRateController,
                        fieldLabel: 'Rate per hour',
                        hint: '150',
                        onChanged: provider.setOvertime,
                      ),

                      const SizedBox(height: 10),
                      _PayrollEditOption(
                        title: 'Bonus add',
                        subtitle:
                            'Fixed monthly bonus, tick hoy to net ma add.',
                        value: provider.bonusEnabled,
                        controller: provider.bonusAmountController,
                        fieldLabel: 'Monthly bonus',
                        hint: '2000',
                        onChanged: provider.setBonus,
                      ),

            const SizedBox(height: 18),
            AppDialogActions(
              primaryLabel: 'Save payroll',
              busy: provider.isLoading,
              onPrimary: _savePayroll,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePayroll() async {
    final provider = context.read<EmployeeProvider>();

    final employeeId = widget.employee.id;

    if (employeeId == null || employeeId.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Employee ID not found',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final success = await provider.updateEmployee(employeeId);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);

      Fluttertoast.showToast(
        msg: 'Payroll updated successfully',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.appColor,
        textColor: Colors.white,
      );
    } else if (provider.errorMessage != null) {
      Fluttertoast.showToast(
        msg: provider.errorMessage!,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
