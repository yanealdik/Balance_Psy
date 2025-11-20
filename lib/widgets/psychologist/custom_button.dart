import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool showArrow;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isFullWidth = false,
    this.showArrow = false,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.textTertiary.withOpacity(0.3)
              : (backgroundColor ?? AppColors.primary),
          foregroundColor: textColor ?? AppColors.textWhite,
          elevation: isDisabled ? 0 : 4,
          shadowColor: (backgroundColor ?? AppColors.primary).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          disabledBackgroundColor: AppColors.textTertiary.withOpacity(0.3),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppColors.textWhite,
                  ),
                ),
              )
            : Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: textColor ?? AppColors.textWhite,
                    ),
                  ),
                  if (showArrow) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: textColor ?? AppColors.textWhite,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
