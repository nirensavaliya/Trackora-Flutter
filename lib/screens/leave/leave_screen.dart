import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/app_dialog.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/data/models/leave_model.dart';
import 'package:trackora/screens/leave/Leave_Detail.dart';
import 'package:trackora/screens/leave/providers/leave_provider.dart';
import 'package:trackora/screens/leave/providers/leave_types_provider.dart';

import '../../core/widgets/workforce_app_bar.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

enum _LeaveFilter { all, pending, approved, rejected, cancelled }

class _LeaveScreenState extends State<LeaveScreen> {
  final TextEditingController _searchController = TextEditingController();
  _LeaveFilter _filter = _LeaveFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LeaveModel> _matchingSearch(List<LeaveModel> leaves) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return leaves;
    return leaves.where((leave) {
      return leave.employeeName.toLowerCase().contains(query) ||
          leave.typeName.toLowerCase().contains(query) ||
          leave.typeCode.toLowerCase().contains(query);
    }).toList();
  }

  List<LeaveModel> _visible(List<LeaveModel> leaves) {
    final searched = _matchingSearch(leaves);
    final filtered = switch (_filter) {
      _LeaveFilter.all => searched,
      _LeaveFilter.pending => searched
          .where((leave) => leave.status == LeaveRequestStatus.pending)
          .toList(),
      _LeaveFilter.approved => searched
          .where((leave) => leave.status == LeaveRequestStatus.approved)
          .toList(),
      _LeaveFilter.rejected => searched
          .where((leave) => leave.status == LeaveRequestStatus.rejected)
          .toList(),
      _LeaveFilter.cancelled => searched
          .where((leave) => leave.status == LeaveRequestStatus.cancelled)
          .toList(),
    };
    final sorted = [...filtered]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted;
  }

  int _statusCount(List<LeaveModel> leaves, LeaveRequestStatus status) {
    return _matchingSearch(leaves).where((leave) => leave.status == status).length;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final leave = context.read<LeaveProvider>();
      leave.loadRequests();
      if (leave.isManager) {
        leave.loadEmployees();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final leave = context.watch<LeaveProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: WorkforceAppBar(
          title: 'Leave',
          showAction: false,
          onTap: () =>null,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Consumer<LeaveProvider>(
                builder: (context, leave, _) {
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
                  final searched = _matchingSearch(leave.leaves);
                  final visible = _visible(leave.leaves);
                  return RefreshIndicator(
                    color: AppColors.appColor,
                    onRefresh: leave.loadRequests,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        Text(
                          'Approve, assign past/future, or add a request.',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _LeaveActionButton(
                                label: 'Apply',
                                icon: Icons.add,
                                filled: false,
                                onTap: () => _openApplyDialog(context),
                              ),
                            ),
                            if (leave.isManager) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: _LeaveActionButton(
                                  label: 'Assign leave',
                                  icon: Icons.person_add_alt_1_outlined,
                                  filled: true,
                                  onTap: () => _openApplyDialog(
                                    context,
                                    isAssign: true,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search employee or leave type...',
                            hintStyle: GoogleFonts.manrope(
                              fontSize: 13,
                              color: const Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF94A3B8),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.appColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChipButton(
                                label: 'All (${searched.length})',
                                color: const Color(0xFF0F3D38),
                                selected: _filter == _LeaveFilter.all,
                                onTap: () =>
                                    setState(() => _filter = _LeaveFilter.all),
                              ),
                              _FilterChipButton(
                                label:
                                    'Pending (${_statusCount(leave.leaves, LeaveRequestStatus.pending)})',
                                color: const Color(0xFF3B82F6),
                                selected: _filter == _LeaveFilter.pending,
                                onTap: () => setState(
                                  () => _filter = _LeaveFilter.pending,
                                ),
                              ),
                              _FilterChipButton(
                                label:
                                    'Approved (${_statusCount(leave.leaves, LeaveRequestStatus.approved)})',
                                color: const Color(0xFF16A37F),
                                selected: _filter == _LeaveFilter.approved,
                                onTap: () => setState(
                                  () => _filter = _LeaveFilter.approved,
                                ),
                              ),
                              _FilterChipButton(
                                label:
                                    'Rejected (${_statusCount(leave.leaves, LeaveRequestStatus.rejected)})',
                                color: const Color(0xFFE11D48),
                                selected: _filter == _LeaveFilter.rejected,
                                onTap: () => setState(
                                  () => _filter = _LeaveFilter.rejected,
                                ),
                              ),
                              _FilterChipButton(
                                label:
                                    'Cancel (${_statusCount(leave.leaves, LeaveRequestStatus.cancelled)})',
                                color: const Color(0xFFF08A24),
                                selected: _filter == _LeaveFilter.cancelled,
                                onTap: () => setState(
                                  () => _filter = _LeaveFilter.cancelled,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'REQUESTS RECORDS (${visible.length})',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.swap_vert_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sorted by date',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (visible.isEmpty && !leave.loading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            child: Center(
                              child: Text(
                                leave.leaves.isEmpty
                                    ? 'No leave applied yet'
                                    : 'No leave found',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          )
                        else
                          ...visible.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _LeaveCard(leave: item),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Same as Attendance / Lead: full overlay while list loads
            if (leave.loading)
              leave.leaves.isEmpty
                  ? const AppLoaderCard()
                  : const AppLoaderOverlay(),
            if (leave.isLeaveDetailLoading) const AppLoaderOverlay(),
          ],
        ),
      ),
    );
  }

  Future<void> _openApplyDialog(
    BuildContext context, {
    bool isAssign = false,
  }) async {
    final leave = context.read<LeaveProvider>();
    final types = context.read<LeaveTypesProvider>();
    leave.resetForm();
    types.loadTypes();
    if (isAssign || leave.isManager) {
      leave.loadEmployees();
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: leave),
            ChangeNotifierProvider.value(value: types),
          ],
          child: _ApplyLeaveDialog(isAssign: isAssign),
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
        return const Color(0xFF3B82F6);
      case LeaveRequestStatus.approved:
        return const Color(0xFF16A37F);
      case LeaveRequestStatus.rejected:
        return const Color(0xFFE11D48);
      case LeaveRequestStatus.cancelled:
        return const Color(0xFFF08A24);
    }
  }

  Color get _statusBg {
    switch (leave.status) {
      case LeaveRequestStatus.pending:
        return const Color(0xFFEAF2FE);
      case LeaveRequestStatus.approved:
        return const Color(0xFFE7F7F1);
      case LeaveRequestStatus.rejected:
        return const Color(0xFFFFF1F4);
      case LeaveRequestStatus.cancelled:
        return const Color(0xFFFFF6EC);
    }
  }

  String get _typeCode {
    final code = leave.typeCode.trim();
    if (code.isNotEmpty) return code.toUpperCase();
    final parts = leave.typeName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'LV';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get _initials {
    final source = leave.employeeName.trim().isNotEmpty
        ? leave.employeeName
        : leave.typeName;
    final parts = source
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _openDetail(BuildContext context) async {
    if (leave.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave ID not found')),
      );
      return;
    }

    final provider = context.read<LeaveProvider>();
    final ok = await provider.leaveDetail(leave.id);
    if (!context.mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Unable to load leave details'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaveDetail()),
    );
  }

  Future<void> _runAction({
    required BuildContext context,
    required String title,
    required String message,
    required Future<String?> Function() action,
    required String successMessage,
  }) async {
    final isDestructive = title.toLowerCase().contains('reject') ||
        title.toLowerCase().contains('cancel');
    final ok = await showAppConfirmDialog(
      context: context,
      title: title,
      message: message,
      cancelLabel: 'No',
      confirmLabel: 'Yes',
      confirmColor:
          isDestructive ? const Color(0xFFD32F2F) : AppColors.appColor,
    );
    if (ok != true || !context.mounted) return;

    final error = await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? successMessage),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            error == null ? AppColors.appColor : const Color(0xFFD32F2F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaveProvider>();
    final pending = leave.status == LeaveRequestStatus.pending;
    final busy = provider.actionBusyId == leave.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: provider.isLeaveDetailLoading ? null : () => _openDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EEED)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B6B63).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      _initials,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.employeeName.isNotEmpty
                              ? leave.employeeName
                              : leave.typeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F7F1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _typeCode,
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.appColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                leave.typeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _statusColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      leave.statusLabel.toUpperCase(),
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${LeaveModel.apiDate(leave.startDate)} → ${LeaveModel.apiDate(leave.endDate)}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      '${leave.dayCount} ${leave.dayCount == 1 ? 'Day' : 'Days'}',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
              if (pending) ...[
                const SizedBox(height: 12),
                if (busy)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.8),
                    ),
                  )
                else
                  Row(
                    children: [
                      if (provider.isManager) ...[
                        Expanded(
                          child: _ActionChip(
                            label: 'Approve',
                            color: const Color(0xFF16834A),
                            filled: true,
                            onTap: () => _runAction(
                              context: context,
                              title: 'Approve leave?',
                              message: 'This leave request will be approved.',
                              action: () => provider.approveLeave(leave.id),
                              successMessage: 'Leave approved',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: _ActionChip(
                          label: 'Cancel',
                          color: const Color(0xFF555555),
                          onTap: () => _runAction(
                            context: context,
                            title: 'Cancel leave?',
                            message:
                                'This pending leave request will be cancelled.',
                            action: () => provider.cancelLeave(leave.id),
                            successMessage: 'Leave cancelled',
                          ),
                        ),
                      ),
                      if (provider.isManager) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionChip(
                            label: 'Reject',
                            color: const Color(0xFFD32F2F),
                            onTap: () => _runAction(
                              context: context,
                              title: 'Reject leave?',
                              message: 'This leave request will be rejected.',
                              action: () => provider.rejectLeave(leave.id),
                              successMessage: 'Leave rejected',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveActionButton extends StatelessWidget {
  const _LeaveActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.appColor : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled ? AppColors.appColor : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: filled ? Colors.white : AppColors.appColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : AppColors.appColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? color : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? color : color.withValues(alpha: 0.45)),
            ),
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: filled ? null : Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter_SemiBold',
              color: filled ? Colors.white : color,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplyLeaveDialog extends StatelessWidget {
  const _ApplyLeaveDialog({this.isAssign = false});

  final bool isAssign;

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
    final showEmployee = isAssign || leave.isManager;
    final busy = isAssign ? leave.assigning : leave.applying;

    return AppDialogShell(
      title: isAssign ? 'Assign Leave' : 'Apply Leave',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              if (showEmployee) ...[
                const AppDialogLabel('Employee'),
                const SizedBox(height: 6),
                if (leave.loadingEmployees && leave.employees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      '${leave.selectedEmployeeId}_${leave.employees.length}',
                    ),
                    initialValue: () {
                      final selected = leave.selectedEmployeeId;
                      if (selected == null || selected.isEmpty) return null;
                      final exists =
                          leave.employees.any((e) => e.id == selected);
                      return exists ? selected : null;
                    }(),
                    hint: const Text('Select employee'),
                    decoration: appDialogFieldDecoration(),
                    items: leave.employees
                        .where((e) => (e.id ?? '').isNotEmpty)
                        .map((e) {
                          final id = e.id!;
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(
                              e.user?.name ?? e.employeeCode ?? 'Employee',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                        .toList(),
                    onChanged: leave.setEmployeeId,
                  ),
                const SizedBox(height: 14),
              ],
              const AppDialogLabel('Leave type'),
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
                    decoration: appDialogFieldDecoration(),
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
              const AppDialogLabel('Reason'),
              const SizedBox(height: 6),
              TextField(
                controller: leave.reasonController,
                maxLines: 3,
                decoration: appDialogFieldDecoration(hint: 'Write your reason'),
              ),
              const SizedBox(height: 18),
              AppDialogActions(
                primaryLabel: isAssign ? 'Assign' : 'Apply',
                busy: busy,
                onPrimary: () async {
                  final error = isAssign
                      ? await leave.assignLeave()
                      : await leave.applyLeave();
                  if (!context.mounted) return;
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAssign ? 'Leave assigned' : 'Leave applied',
                      ),
                      backgroundColor: AppColors.appColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
          ],
        ),
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
