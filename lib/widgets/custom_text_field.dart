import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Кастомное текстовое поле
class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool showSuccess;
  final bool showEyeIcon;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final int? maxLength;
  final bool enabled;
  final bool? obscureText;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.showSuccess = false,
    this.showEyeIcon = false,
    this.keyboardType,
    this.onChanged,
    this.maxLength,
    this.enabled = true,
    this.obscureText,
    this.suffixIcon,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.showSuccess
              ? AppColors.success
              : _isFocused
              ? AppColors.primary
              : AppColors.inputBorder,
          width: 2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        obscureText: widget.obscureText ?? widget.isPassword,
        keyboardType: widget.keyboardType,
        style: AppTextStyles.input,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.inputHint,
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                )
              : null,
          suffixIcon: widget.suffixIcon ??
              (widget.showSuccess
                  ? const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child:
                          Icon(Icons.check, color: AppColors.success, size: 24),
                    )
                  : widget.showEyeIcon
                      ? const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.visibility_off_outlined,
                            color: AppColors.textTertiary,
                            size: 24,
                          ),
                        )
                      : null),
        ),
      ),
    );
  }
}
