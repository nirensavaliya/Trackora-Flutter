import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/app_dialog.dart';
import 'package:trackora/core/widgets/workforce_app_bar.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/core/widgets/common_textfild.dart';
import 'package:trackora/data/models/DepartmentModel.dart';
import 'package:trackora/screens/Department/Provider/Department_provider.dart';



class DepartmentView extends StatelessWidget {
  const DepartmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DepartmentProvider>(
      builder: (context, provider, child) {
        final departments = provider.departmentResponse?.data ?? [];
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9F9),
          appBar: WorkforceAppBar(
            title: 'Departments',
            actionLabel: 'New',
            onTap: () => _showCreateDepartmentDialog(context, provider),
          ),
          body: Stack(
            children: [
              ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: departments.isEmpty ? 1 : departments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (departments.isEmpty) {
                    if (provider.isLoading) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          'No departments found',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    );
                  }
                  return _DepartmentCard(department: departments[index]);
                },
              ),
              if (provider.isLoading) const AppLoaderOverlay(),
            ],
          ),
        );
      },
    );
  }
  static void _showCreateDepartmentDialog(
      BuildContext context,
      DepartmentProvider provider,
      ) {

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AppDialogShell(
          title: 'New department',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppDialogLabel('Name'),
              const SizedBox(height: 6),
              CommonTextField(
                controller: provider.namecontroller,
                hintText: 'Enter department name',
                fontSize: 15,
                borderRadius: 12,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Department name is required.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              AppDialogActions(
                primaryLabel: 'Create',
                onPrimary: () async {
                  final name = provider.namecontroller.text.trim();
                  if (name.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Department name is required',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                    return;
                  }
                  Navigator.pop(dialogContext);
                  final success = await provider.createDepartment(name);

                  if (!context.mounted) {
                    return;
                  }

                  if (success) {
                    Fluttertoast.showToast(
                      msg: 'Department created successfully',
                      backgroundColor: const Color(0xff246D68),
                      textColor: Colors.white,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: provider.errorMessage ?? 'Something went wrong',
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({required this.department});

  final Department department;

  @override
  Widget build(BuildContext context) {
    final people = department.count?.employees ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.apartment_outlined,
              size: 18,
              color: AppColors.appColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEPARTMENT',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  department.name ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
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
                'PEOPLE',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$people',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.appColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

