import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/App_Font.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/CommonAppBar.dart';
import 'package:trackora/screens/leave/providers/leave_provider.dart';

class LeaveDetail extends StatelessWidget {
  const LeaveDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaveProvider>();
    final data = provider.leaveDetailData?.data;

    return Scaffold(
      backgroundColor:AppColors.scaffoldBg,
      appBar: CommonAppBar(title: "Leave Detail",showBackButton: true,),
      body: data == null
          ? const Center(
        child: Text(
          'No leave details found',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _card(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xffEAF7F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: Color(0xff246D68),
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.leaveType?.name ?? 'Leave',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: FontFamily.interBold,
                            color: Color(0xff171717),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          data.leaveType?.code ?? '--',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontFamily: FontFamily.interSemiBold,

                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  _StatusChip(
                    status: data.status ?? '',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _card(
              child: Row(
                children: [
                  Expanded(
                    child: _DateInfo(
                      title: 'FROM',
                      value: _formatDate(data.fromDate),
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),

                  _divider(),

                  Expanded(
                    child: _DateInfo(
                      title: 'TO',
                      value: _formatDate(data.toDate),
                      icon: Icons.calendar_month_outlined,
                    ),
                  ),

                  _divider(),

                  Expanded(
                    child: _DateInfo(
                      title: 'DAYS',
                      value: '${data.days ?? 0}',
                      icon: Icons.timelapse_outlined,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
             _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.info_outline,
                    title: 'Leave Information',
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _DetailRow(
                          title: 'Reason',
                          value: data.reason?.toString() ?? '-',
                        ),
                      ),

                      Expanded(
                        child: _DetailRow(
                          title: 'Leave Type',
                          value: data.leaveType?.name?.toString() ?? '-',
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _DetailRow(
                          title: 'Leave Code',
                          value: data.leaveType?.code?.toString() ?? '-',
                        ),
                      ),

                      Expanded(
                        child: _DetailRow(
                          title: 'Paid Leave',
                          value: data.leaveType?.isPaid == true
                              ? 'Yes'
                              : 'No',
                        ),
                      ),
                    ],
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _DetailRow(
                        title: 'Paid Days',
                        value: '${data.paidDays ?? 0}',
                      ),
                    ),

                    Expanded(
                      child: _DetailRow(
                        title: 'Unpaid Days',
                        value: '${data.unpaidDays ?? 0}',
                      ),
                    ),
                  ],
                ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Expanded(
                        child: _DetailRow(
                          title: 'Backdated',
                          value: data.isBackdated == true
                              ? 'Yes'
                              : 'No',
                        ),
                      ),

                      Expanded(
                        child: _DetailRow(
                          title: 'Deducted Amount',
                          value: '${data.deductedAmount ?? 0}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.person_outline,
                    title: 'Employee',
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _DetailRow(
                          title: 'Name',
                          value:
                          data.employee?.user?.name?.toString() ?? '-',
                        ),
                      ),

                      Expanded(
                        child: _DetailRow(
                          title: 'Employee Code',
                          value:
                          data.employee?.employeeCode?.toString() ?? '-',
                        ),
                      ),
                    ],
                  ),

                  _DetailRow(
                    title: 'Join Date',
                    value: _formatDate(
                      data.employee?.joinDate,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.history,
                    title: 'Request Information',
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _DetailRow(
                          title: 'Requested By',
                          value:
                          data.requestedBy?.name.toString() ?? '-',
                        ),
                      ),

                      Expanded(
                        child: _DetailRow(
                          title: 'Approved By',
                          value:
                          data.approvedBy?.name.toString() ?? '-',
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _DetailRow(
                          title: 'Decided At',
                          value:
                          _formatDate(data.decidedAt),
                        ),
                      ),

                      Expanded(
                        child: _DetailRow(
                          title: 'Created At',
                          value:
                          _formatDateTime(data.createdAt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
  static Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget _divider() {
    return Container(
      width: 1,
      height: 55,
      color: Colors.grey.shade200,
    );
  }


  static String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value.toString());

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  static String _formatDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value.toString());

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xffEAF7F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xff246D68),
            size: 21,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.interBold,
            color: Color(0xff171717),
          ),
        ),
      ],
    );
  }
}


class _DateInfo extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DateInfo({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xff246D68),
        ),

        const SizedBox(height: 6),

        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.grey.shade500,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xff222222),
          ),
        ),
      ],
    );
  }
}
class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 5,left: 8,right: 8,bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontFamily: FontFamily.interBold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontFamily: FontFamily.interMedium,
              color: Color(0xff222222),
            ),
          ),
        ],
      ),
    );
  }
}



class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color backgroundColor;

    switch (status.toUpperCase()) {
      case 'APPROVED':
        textColor = const Color(0xff16834A);
        backgroundColor = const Color(0xffE8F7EE);
        break;

      case 'REJECTED':
        textColor = const Color(0xffD32F2F);
        backgroundColor = const Color(0xffffeeee);
        break;

      case 'CANCELLED':
        textColor = const Color(0xff777777);
        backgroundColor = const Color(0xffeeeeee);
        break;

      default:
        textColor = const Color(0xffD87900);
        backgroundColor = const Color(0xfffff0db);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'PENDING' : status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}