import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trackora/core/constants/app_colors.dart';
import 'package:trackora/core/widgets/CommonAppBar.dart';
import 'package:trackora/core/widgets/app_loader.dart';
import 'package:trackora/core/widgets/common_textfild.dart';
import 'package:trackora/screens/Setting/Provider/Setting_Provider.dart';

import '../../core/widgets/workforce_app_bar.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingProvider = context.watch<SettingProvider>();
    final data = settingProvider.companyResponse?.data;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: WorkforceAppBar(
        title: 'Settings',
        showAction: false,
        onTap: () {  },
      ),
      body: settingProvider.isLoading
          ? const AppLoaderOverlay()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dialogLabel('Company N'
                        ''
                        ''
                        'ame'),
                    const SizedBox(height: 7),
                    CommonTextField(
                      controller: settingProvider.companyNameController,
                      hintText: data?.name,
                      fontSize: 15,
                      borderRadius: 13,
                      textInputType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 15),
                    _dialogLabel('Client Code'),
                    const SizedBox(height: 7),
                    CommonTextField(
                      controller: settingProvider.clientCodeController,
                      hintText: data?.clientCode,
                      fontSize: 15,
                      borderRadius: 13,
                      textInputType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _dialogLabel('Office latitude'),
                              const SizedBox(height: 7),
                              CommonTextField(
                                controller:
                                    settingProvider.officeLatitudeController,
                                hintText: "",
                                fontSize: 15,
                                borderRadius: 13,
                                textInputType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _dialogLabel('Office longitude'),
                              const SizedBox(height: 7),
                              CommonTextField(
                                controller:
                                    settingProvider.officeLongitudeController,
                                hintText: "",
                                fontSize: 15,
                                borderRadius: 13,
                                textInputType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    _dialogLabel('Geo-fence radius (meters)'),
                    const SizedBox(height: 7),
                    CommonTextField(
                      controller: settingProvider.geoFenceController,
                      hintText: "Empty = Punch From anywhere",
                      fontSize: 15,
                      borderRadius: 13,
                      textInputType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 15),
                    _dialogLabel('Late after (minutes from midnight UTC)'),
                    const SizedBox(height: 7),
                    CommonTextField(
                      controller: settingProvider.lateAfterController,
                      hintText: "600",
                      fontSize: 15,
                      borderRadius: 13,
                      textInputType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 170,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              final companyId = data?.id;

                              final success = await settingProvider
                                  .updateCompany(companyId!);
                              if (success) {
                                Fluttertoast.showToast(
                                  msg: 'Updated successfully',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: AppColors.appColor,
                                  textColor: Colors.white,
                                );
                              } else if (settingProvider.errorMessage != null) {
                                Fluttertoast.showToast(
                                  msg: settingProvider.errorMessage!,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.appColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.appColor
                                  .withValues(alpha: 0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: settingProvider.isLoading
                                ? const SizedBox(
                                    height: 21,
                                    width: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 7),
                                      Text(
                                        'Save ',
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
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

  Widget _dialogLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter_SemiBold',
        color: AppColors.textGrey,
        fontSize: 12,
      ),
    );
  }
}
