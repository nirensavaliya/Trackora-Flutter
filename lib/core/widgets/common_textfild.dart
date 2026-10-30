import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackora/core/constants/App_Font.dart';
import 'package:trackora/core/constants/app_colors.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Widget? suffix;
  final Widget? prefix;
  final int? maxLine;
  final String? hintText;
  final TextAlign? textAlign;
  final double? fontSize;
  final int? maxLength;
  final double? borderRadius;
  final bool isTitle;
  final bool obscureText;
  final bool showCursor;
  final bool readOnly;
  final String? title;
  final TextInputType? textInputType;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final BoxConstraints? prefixIconConstraints;
  final TextCapitalization textCapitalization;
  final Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const CommonTextField({
    super.key,
    required this.controller,
    this.prefix,
    this.suffix,
    this.maxLine,
    this.hintText,
    this.textAlign,
    this.fontSize,
    this.maxLength,
    this.borderRadius,
    this.isTitle = false,
    this.title,
    this.onTap,
    this.obscureText = false,
    this.showCursor = true,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.focusNode,
    this.onChanged,
    this.textInputType,
    this.validator,
    this.textInputAction,
    this.prefixIconConstraints,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional title
        if (isTitle) ...[
          Text(
            title ?? '',
            style: TextStyle(
              fontFamily: FontFamily.interBold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 7),
        ],

        TextFormField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          maxLines: obscureText ? 1 : (maxLine ?? 1),
          textAlign: textAlign ?? TextAlign.start,
          cursorColor: AppColors.appColor,
          onFieldSubmitted: onFieldSubmitted,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: fontSize ?? 16,
            fontFamily: FontFamily.interRegular,
            fontWeight: FontWeight.w400,
          ),
          maxLength: maxLength,
          textInputAction: textInputAction ?? TextInputAction.done,
          keyboardType: textInputType ?? TextInputType.text,
          obscureText: obscureText,

          inputFormatters: inputFormatters ??
              ((textInputType == TextInputType.number ||
                  textInputType ==
                      const TextInputType.numberWithOptions())
                  ? [
                FilteringTextInputFormatter.digitsOnly,
              ]
                  : (textInputType ==
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ))
                  ? [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*'),
                ),
              ]
                  : null),

          readOnly: readOnly,
          showCursor: showCursor,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,

          textAlignVertical: suffix != null
              ? TextAlignVertical.center
              : TextAlignVertical.top,

          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFCFEFE),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            counter: const SizedBox(),
            counterText: '',

            prefixIcon: prefix,
            suffixIcon: suffix,
            prefixIconConstraints: prefixIconConstraints,

            hintText: hintText,
            hintStyle: TextStyle(
              color: Color(0xFF8F8F8F),
              fontSize: 14,
              fontFamily: FontFamily.interRegular,
              fontWeight: FontWeight.w400,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? 13,
              ),
              borderSide: const BorderSide(
                color: Color(0xFFDCE5E4),
                width: 1,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? 13,
              ),
              borderSide: const BorderSide(
                color: Color(0xFFDCE5E4),
                width: 1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? 13,
              ),
              borderSide: const BorderSide(
                color: AppColors.appColor,
                width: 1.2,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? 13,
              ),
              borderSide: const BorderSide(
                color: AppColors.appColor,
                width: 1.2,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? 13,
              ),
              borderSide: const BorderSide(
                color: AppColors.appColor,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text;

    if (newValue.selection.baseOffset <
        oldValue.selection.baseOffset) {
      return newValue;
    }

    if (text.length == 2 || text.length == 5) {
      if (!text.endsWith('/')) {
        text += '/';
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }
}