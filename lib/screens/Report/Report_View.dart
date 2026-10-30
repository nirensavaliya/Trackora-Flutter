import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/App_Font.dart';
import 'package:trackora/core/widgets/CommonAppBar.dart';
import 'package:trackora/core/widgets/app_loader.dart';

import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/screens/Report/Provider/Report_Provider.dart';
import 'package:trackora/screens/bottom-bar/bottm_bar_screen.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9F9),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
              constraints.maxWidth > 1100 ? 40.0 : 20.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1400,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(),

                        const SizedBox(height: 15),

                        _buildFilterCard(
                          context,
                          provider,
                        ),

                        const SizedBox(height: 15),

                        if (provider.errorMessage != null)
                          _buildError(provider),

                        if (provider.salaryResponse == null &&
                            provider.errorMessage == null)
                          _buildNoReport(),

                        if (provider.salaryResponse != null) ...[
                          _buildSummaryCards(provider),

                          const SizedBox(height: 24),

                          _buildSalarySection(provider),

                          const SizedBox(height: 24),

                          _buildLeaveSection(provider),
                        ],
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
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reports',
          style: GoogleFonts.manrope(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Salary + overtime + bonus − PF − tax − employee tax − unpaid leave.',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }


  Widget _buildFilterCard(
      BuildContext context,
      ReportProvider provider,
      ) {
    return Column(
      children: [
        if (provider.canSelectEmployee) ...[
          _employeeDropdown(context, provider),
          const SizedBox(height: 10),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _yearDropdown(context, provider)),
            const SizedBox(width: 10),
            Expanded(child: _monthDropdown(context, provider)),
          ],
        ),
      ],
    );
  }

  Widget _employeeDropdown(
      BuildContext context,
      ReportProvider provider,
      ) {
    final employees =
        provider.employeeResponse?.data ?? [];

    return _dropdownContainer(
      label: 'Employee',
      child: DropdownButtonFormField<String>(
        value: provider.selectedEmployeeId,
        isExpanded: true,

        decoration: _inputDecoration(
          hint: 'Select Employee',
          icon: Icons.person_outline_rounded,
        ),

        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF94A3B8),
          size: 18,
        ),

        dropdownColor: AppColors.cardWhite,

        items: employees.map((employee) {
          final name =
              employee.user?.name ??
                  employee.employeeCode ??
                  'Employee';

          final role =
              employee.user?.role ?? '';

          return DropdownMenuItem<String>(
            value: employee.id,
            child: Text(
              role.isNotEmpty
                  ? '$name • $role'
                  : name,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(
                fontSize: 14,
                fontFamily: FontFamily.interBold,
                color: AppColors.textDark,
              ),
            ),
          );
        }).toList(),

        onChanged: (value) async {
          if (value == null) return;

          await provider
              .selectEmployeeAndLoadReport(value);
        },
      ),
    );
  }


  Widget _yearDropdown(
      BuildContext context,
      ReportProvider provider,
      ) {
    final currentYear = DateTime.now().year;

    final years = List.generate(
      5,
          (index) => currentYear - index,
    );

    return _dropdownContainer(
      label: 'Year',
      child: DropdownButtonFormField<int>(
        value: provider.selectedYear,
        isExpanded: true,

        decoration: _inputDecoration(
          hint: 'Select Year',
          icon: Icons.calendar_today_outlined,
        ),

        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF94A3B8),
          size: 18,
        ),

        dropdownColor: AppColors.cardWhite,

        items: years.map((year) {
          return DropdownMenuItem<int>(
            value: year,
            child: Text(
              year.toString(),
              style: TextStyle(
                fontSize: 14,
                fontFamily: FontFamily.interBold,
                color: AppColors.textDark,
              ),
            ),
          );
        }).toList(),

        onChanged: (value) {
          if (value == null) return;

          provider.selectYear(value);
        },
      ),
    );
  }


  Widget _monthDropdown(
      BuildContext context,
      ReportProvider provider,
      ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return _dropdownContainer(
      label: 'Month',
      child: DropdownButtonFormField<int>(
        value: provider.selectedMonth,
        isExpanded: true,

        decoration: _inputDecoration(
          hint: 'Select Month',
          icon: Icons.calendar_today_outlined,
        ),

        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF94A3B8),
          size: 18,
        ),

        dropdownColor: AppColors.cardWhite,
        selectedItemBuilder: (context) {
          return List.generate(12, (index) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${index + 1}',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            );
          });
        },

        items: List.generate(
          12,
              (index) {
            final month = index + 1;

            return DropdownMenuItem<int>(
              value: month,
              child: Text(
                months[index],
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: FontFamily.interBold,
                  color: AppColors.textDark,
                ),
              ),
            );
          },
        ),

        onChanged: (value) {
          if (value == null) return;

          provider.selectMonth(value);
        },
      ),
    );
  }
  Widget _dropdownContainer({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: const Color(0xFF94A3B8),
          ),
        ),

        const SizedBox(height: 7),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),

      prefixIcon: Icon(
        icon,
        size: 16,
        color: const Color(0xFF64748B),
      ),

      filled: true,
      fillColor: Colors.white,

      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.appColor,
          width: 1.4,
        ),
      ),
    );
  }


  Widget _buildSummaryCards(
      ReportProvider provider,
      ) {
    final data = provider.salaryResponse?.data;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        const columns = 2;
        final cardWidth = (constraints.maxWidth - spacing) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Gross',
                value: _money(data?.monthlySalary),
                icon: Icons.add,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Additions',
                value: _money(data?.additions),
                icon: Icons.show_chart_rounded,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Deductions',
                value: _money(data?.deductedTotal),
                icon: Icons.trending_down_rounded,
                isNegative: true,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _summaryCard(
                title: 'Net Pay',
                value: _money(data?.netPay),
                icon: Icons.payments_outlined,
                highlight: true,
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    bool isNegative = false,
    bool highlight = false,
  }) {
    final badgeColor = isNegative
        ? const Color(0xFFE11D48)
        : const Color(0xFF16A37F);
    final badgeBg = isNegative
        ? const Color(0xFFFFF1F4)
        : const Color(0xFFE7F7F1);

    return Container(
      height: 112,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? null : Colors.white,
        gradient: highlight
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3F9187), Color(0xFF2F7A72)],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: highlight
            ? null
            : Border.all(color: const Color(0xFFE8EEED)),
        boxShadow: [
          BoxShadow(
            color: highlight
                ? const Color(0xFF1B6B63).withValues(alpha: 0.28)
                : const Color(0xFF1B6B63).withValues(alpha: 0.04),
            blurRadius: highlight ? 16 : 10,
            offset: Offset(0, highlight ? 8 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: highlight
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
              if (highlight)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'FINAL',
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isNegative ? Icons.remove : icon,
                    size: 13,
                    color: badgeColor,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: highlight ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalarySection(
      ReportProvider provider,
      ) {
    final data = provider.salaryResponse?.data;

    final components = (data?.components ?? [])
        .where((component) => component.enabled != false)
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEED)),
      ),
      child: Column(
        children: [
          _salaryHeader(),
          if (components.isEmpty)
            _emptyTable(
              icon: Icons.receipt_long_outlined,
              text: 'No salary components available',
            )
          else
            ...components.map(
                  (component) {
                final isDeduction =
                    component.kind?.toLowerCase() == 'deduct';

                return _salaryRow(
                  component.label?.trim().isNotEmpty == true
                      ? component.label!
                      : component.key ?? 'Salary',
                  _money(component.amount),
                  isDeduction: isDeduction,
                );
              },
            ),

          _netPayRow(
            _money(data?.netPay),
          ),
        ],
      ),
    );
  }
  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.progressTrack,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark
                .withOpacity(.025),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding:
            EdgeInsets.fromLTRB(
              15,
              15,
              15,
              10,
            ),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.appColor
                        .withOpacity(.09),
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.appColor,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        fontFamily: FontFamily.interBold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                        fontFamily: FontFamily.interSemiBold,

                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          child,
        ],
      ),
    );
  }

  Widget _salaryHeader() {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg,
        border: Border(
          top: BorderSide(
            color: AppColors.progressTrack,
          ),
          bottom: BorderSide(
            color: AppColors.progressTrack,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'COMPONENT',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                FontWeight.w800,
                letterSpacing: .8,
                color:
                AppColors.textGrey,
                fontFamily: FontFamily.interBold,

              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment:
              Alignment.centerRight,
              child: Text(
                'AMOUNT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: .8,
                  color:
                  AppColors.textGrey,
                  fontFamily: FontFamily.interBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _salaryRow(
      String title,
      String amount, {
        bool isDeduction = false,
      }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.progressTrack,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  height: 7,
                  width: 7,
                  decoration: BoxDecoration(
                    color: isDeduction
                        ? const Color(0xFFE11D48)
                        : const Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      AppColors.textDark,
                      fontFamily: FontFamily.interBold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Align(
              alignment:
              Alignment.centerRight,
              child: Text(
                '${isDeduction ? '-' : ''}$amount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  AppColors.textDark,
                  fontFamily: FontFamily.interBold,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _netPayRow(String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF7FBFA),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF16A37F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Net pay',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF16A37F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveSection(
      ReportProvider provider,
      ) {
    final data =
        provider.salaryResponse?.data;

    final leaveDeduction =
        data?.leaveDeduction ?? 0;

    return _sectionCard(
      title: 'Leave Deductions',
      subtitle: 'Unpaid leave deductions',
      icon: Icons.event_busy_outlined,
      child: leaveDeduction == 0
          ? _emptyTable(
        icon:
        Icons.event_available_outlined,
        text:
        'No leave deductions this month',
      )
          : _leaveContent(
        provider,
        leaveDeduction,
      ),
    );
  }

  Widget _leaveContent(
      ReportProvider provider,
      dynamic leaveDeduction,
      ) {
    return Column(
      children: [
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 13,
          ),
          decoration: const BoxDecoration(
            color: AppColors.scaffoldBg,
            border: Border(
              top: BorderSide(
                color:
                AppColors.progressTrack,
              ),
              bottom: BorderSide(
                color:
                AppColors.progressTrack,
              ),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'WHEN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: .7,
                    color:
                    AppColors.textGrey,
                  ),
                ),
              ),

              Expanded(
                child: Text(
                  'TYPE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: .7,
                    color:
                    AppColors.textGrey,
                  ),
                ),
              ),

              Expanded(
                child: Text(
                  'NOTE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                    FontWeight.w800,
                    letterSpacing: .7,
                    color:
                    AppColors.textGrey,
                  ),
                ),
              ),

              Expanded(
                child: Align(
                  alignment:
                  Alignment.centerRight,
                  child: Text(
                    'AMOUNT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing: .7,
                      color:
                      AppColors.textGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 17,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${provider.selectedMonth}/${provider.selectedYear}',
                  style:
                  const TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    AppColors.textDark,
                  ),
                ),
              ),

              const Expanded(
                child: Text(
                  'Unpaid leave',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w600,
                    color:
                    AppColors.textDark,
                  ),
                ),
              ),

              const Expanded(
                child: Text(
                  'Leave deduction',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                    AppColors.textGrey,
                  ),
                ),
              ),

              Expanded(
                child: Align(
                  alignment:
                  Alignment.centerRight,
                  child: Text(
                    '-${_money(leaveDeduction)}',
                    style:
                    const TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w800,
                      color:
                      AppColors.appColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyTable({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 34,
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.progressTrack,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.textGrey,
              size: 23,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      ReportProvider provider,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.progressTrack,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.appColor
                  .withOpacity(.10),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.appColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              provider.errorMessage ??
                  'Something went wrong',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNoReport() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        vertical: 55,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.progressTrack,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: AppColors.appColor
                  .withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 32,
              color: AppColors.appColor,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No report available',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'There is no salary report for the selected period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }


  String _money(dynamic amount) {
    if (amount == null) {
      return '₹0';
    }

    final value = num.tryParse(amount.toString()) ?? 0;

    return '₹${value.toStringAsFixed(0)}';
  }
}

