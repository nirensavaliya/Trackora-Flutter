import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/data/models/leave_model.dart';
import 'package:trackora/screens/leave/providers/leave_provider.dart';
import 'package:trackora/screens/leave/providers/leave_types_provider.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LeaveProvider>().loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: widget.showBack,
          leading: widget.showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: const Text(
            'My Leave',
            style: TextStyle(
              fontFamily: 'Inter_Bold',
              color: AppColors.appColor,
              fontSize: 22,
            ),
          ),
          centerTitle: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openApplyDialog(context),
          backgroundColor: AppColors.appColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Apply Leave',
            style: TextStyle(fontFamily: 'Inter_SemiBold'),
          ),
        ),
        body: Consumer<LeaveProvider>(
          builder: (context, leave, _) {
            if (leave.loading && leave.leaves.isEmpty) {
              return const Center(child: AppLoader());
            }
            if (leave.error != null && leave.leaves.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        leave.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter_Regular',
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: leave.loadRequests,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (leave.leaves.isEmpty) {
              return const Center(
                child: Text(
                  'No leave applied yet',
                  style: TextStyle(
                    fontFamily: 'Inter_Regular',
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              );
            }
            return RefreshIndicator(
              color: AppColors.appColor,
              onRefresh: leave.loadRequests,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: leave.leaves.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _LeaveCard(leave: leave.leaves[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openApplyDialog(BuildContext context) async {
    final leave = context.read<LeaveProvider>();
    final types = context.read<LeaveTypesProvider>();
    leave.resetForm();
    types.loadTypes();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: leave),
            ChangeNotifierProvider.value(value: types),
          ],
          child: const _ApplyLeaveDialog(),
        );
      },
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave});

  final LeaveModel leave;

  Color get _statusColor {
    switch (leave.status) {
      case LeaveRequestStatus.pending:
        return const Color(0xFFFB8C00);
      case LeaveRequestStatus.approved:
        return AppColors.appColor;
      case LeaveRequestStatus.rejected:
        return const Color(0xFFE53935);
      case LeaveRequestStatus.cancelled:
        return const Color(0xFF8A9391);
    }
  }

  Color get _statusBg {
    switch (leave.status) {
      case LeaveRequestStatus.pending:
        return const Color(0xFFFFF3E0);
      case LeaveRequestStatus.approved:
        return const Color(0xFFE7F4EF);
      case LeaveRequestStatus.rejected:
        return const Color(0xFFFFEBEE);
      case LeaveRequestStatus.cancelled:
        return const Color(0xFFEEF1F0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.appColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: AppColors.appColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.typeName,
                      style: const TextStyle(
                        fontFamily: 'Inter_SemiBold',
                        color: AppColors.textDark,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.dateRangeLabel,
                      style: const TextStyle(
                        fontFamily: 'Inter_Regular',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${leave.dayCount} ${leave.dayCount == 1 ? 'day' : 'days'}  •  ${leave.reason}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter_Regular',
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      leave.statusLabel,
                      style: TextStyle(
                        fontFamily: 'Inter_Medium',
                        color: _statusColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (leave.status == LeaveRequestStatus.pending)
                    _CancelLeaveButton(leaveId: leave.id),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelLeaveButton extends StatelessWidget {
  const _CancelLeaveButton({required this.leaveId});

  final String leaveId;

  Future<void> _confirmAndCancel(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Cancel leave?',
            style: TextStyle(
              fontFamily: 'Inter_Bold',
              color: AppColors.textDark,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'This pending leave request will be cancelled.',
            style: TextStyle(
              fontFamily: 'Inter_Regular',
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'No',
                style: TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  color: AppColors.textGrey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Yes, cancel',
                style: TextStyle(
                  fontFamily: 'Inter_SemiBold',
                  color: Color(0xFFD32F2F),
                ),
              ),
            ),
          ],
        );
      },
    );
    if (ok != true || !context.mounted) return;

    final error = await context.read<LeaveProvider>().cancelLeave(leaveId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Leave cancelled'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error == null ? AppColors.appColor : const Color(0xFFD32F2F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<LeaveProvider>().cancellingId == leaveId;
    return GestureDetector(
      onTap: busy ? null : () => _confirmAndCancel(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: busy
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Color(0xFFD32F2F),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD32F2F)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Inter_Medium',
                    color: Color(0xFFD32F2F),
                    fontSize: 11,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ApplyLeaveDialog extends StatelessWidget {
  const _ApplyLeaveDialog();

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Select date';
    return LeaveModel.formatDate(date);
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime? current,
    required DateTime firstDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.appColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final leave = context.watch<LeaveProvider>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apply Leave',
                style: TextStyle(
                  fontFamily: 'Inter_Bold',
                  color: AppColors.appColor,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Leave type',
                style: TextStyle(
                  fontFamily: 'Inter_Medium',
                  color: AppColors.textDark,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Consumer<LeaveTypesProvider>(
                builder: (context, types, _) {
                  if (types.loading && types.activeTypes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  if (types.error != null && types.activeTypes.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          types.error!,
                          style: const TextStyle(
                            fontFamily: 'Inter_Regular',
                            color: Color(0xFFE53935),
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: () => types.loadTypes(force: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }
                  final items = types.activeTypes;
                  final selected = leave.selectedType;
                  final selectedId = selected != null &&
                          items.any((t) => t.id == selected.id)
                      ? selected.id
                      : null;
                  return DropdownButtonFormField<String>(
                    key: ValueKey('${selectedId}_${items.length}'),
                    initialValue: selectedId,
                    hint: const Text('Select leave type'),
                    decoration: _fieldDecoration(),
                    items: items
                        .map(
                          (type) => DropdownMenuItem(
                            value: type.id,
                            child: Text(type.dropdownLabel),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id == null) {
                        leave.setType(null);
                        return;
                      }
                      leave.setType(
                        items.firstWhere((t) => t.id == id),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Start date',
                      value: _dateLabel(leave.startDate),
                      onTap: () => _pickDate(
                        context: context,
                        current: leave.startDate,
                        firstDate: DateTime.now(),
                        onPicked: leave.setStartDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      label: 'End date',
                      value: _dateLabel(leave.endDate),
                      onTap: () => _pickDate(
                        context: context,
                        current: leave.endDate ?? leave.startDate,
                        firstDate: leave.startDate ?? DateTime.now(),
                        onPicked: leave.setEndDate,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Reason',
                style: TextStyle(
                  fontFamily: 'Inter_Medium',
                  color: AppColors.textDark,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: leave.reasonController,
                maxLines: 3,
                decoration: _fieldDecoration(hint: 'Write your reason'),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.appColor,
                        side: const BorderSide(color: AppColors.appColor),
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontFamily: 'Inter_SemiBold'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: leave.applying
                          ? null
                          : () async {
                              final error = await leave.applyLeave();
                              if (!context.mounted) return;
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error)),
                                );
                                return;
                              }
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.appColor.withValues(alpha: 0.6),
                        elevation: 0,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: leave.applying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Apply',
                              style: TextStyle(fontFamily: 'Inter_SemiBold'),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F8F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8E6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8E6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.appColor),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter_Medium',
            color: AppColors.textDark,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F8F7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8E6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8E6)),
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter_Regular',
                fontSize: 13,
                color: value == 'Select date'
                    ? AppColors.textGrey
                    : AppColors.textDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
